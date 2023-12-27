import Foundation
import UIKit
import Moya
import Combine

final class PostDetailsViewModel: ObservableObject {
    
    @Published private(set) var loading: Bool = false
    @Published private(set) var commentViewModels: [CommentModel] = []
    
    private(set) lazy var commentVotesViewModel: CommentVotesViewModel = {
        CommentVotesViewModel(post: post)
    }()

    var postContent: [QuillViewRenderObject] {
        parser.parseQuillJS(json: post.content)
    }
        
    let post: Post
    let votes: [Vote]
    
    var title: String {
        post.title
    }
    
    var imageURL: URL? {
        ImageURLGenerator.imageURL(path: post.url)
    }
    
    var videoURL: URL? {
        ImageURLGenerator.videoURL(path: post.url)
    }
    
    var linkString: String {
        post.link?.absoluteString ?? ""
    }
    
    var shouldShowImage: Bool {
        if post.type == .image || post.type == .link {
            return true
        }
        return false
    }
    
    var shouldShowLink: Bool {
        post.link != nil
    }
    
    var shouldShowTags: Bool {
        !post.tags.isEmpty
    }
    
    var mediaSize: CGSize {
        guard let width = post.width,
              let height = post.height,
              width > 0, 
                height > 0
        else {
            return CGSize(width: UIScreen.main.bounds.width, height: 200)
        }
        let ratio = CGFloat(height / width)
        let screenWidth = UIScreen.main.bounds.width
        let contentHeight = min(screenWidth * ratio, 320)
        return CGSize(width: screenWidth, height: contentHeight)
    }
    
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    private let parser = QuillParser()
    private let provider: MoyaProvider<NonioAPI>
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        post: Post,
        votes: [Vote],
        provider: MoyaProvider<NonioAPI>
    ) {
        self.post = post
        self.votes = votes
        self.provider = provider
    }
    
    func onLoad() {
        getComments()
    }
}

private extension PostDetailsViewModel {
    func getComments() {
        loading = true
        provider.requestPublisher(.getComments(id: post.url))
            .map([Comment].self, atKeyPath: "comments", using: decoder)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching posts: \(error)")
                }
                self.loading = false
            }, receiveValue: { comments in
                self.buildCommentHierarchy(from: comments)
            })
            .store(in: &cancellables)
    }
    
    // TODO: update sorting logic
    func buildCommentHierarchy(from allComments: [Comment]) {
        let commentsDict = Dictionary(uniqueKeysWithValues: allComments.map { ($0.id, CommentModel(comment: $0)) })

        func attachChildren(to comment: inout CommentModel) {
            let childComments = allComments
                .filter { $0.parent == comment.id }
                .map { CommentModel(comment: $0) }
            if !childComments.isEmpty {
                comment.children = childComments
                for child in childComments {
                    var child = child
                    attachChildren(to: &child)
                }
            }
        }

        let topLevelComments = allComments.filter { $0.parent == 0 }
        commentViewModels = topLevelComments
            .compactMap { topLevelComment in
                guard var comment = commentsDict[topLevelComment.id] else { return nil }
                attachChildren(to: &comment)
                return comment
            }
    }
}
