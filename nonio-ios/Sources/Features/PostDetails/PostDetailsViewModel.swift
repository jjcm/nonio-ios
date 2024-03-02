import Foundation
import UIKit
import Moya
import Combine

final class PostDetailsViewModel: ObservableObject {
    
    @Published private(set) var loading: Bool = false
    @Published private(set) var commentViewModels: [CommentModel] = []
    @Published private(set) var commentCount: Int = 0
    @Published private(set) var scrollToComment: Int?

    private(set) lazy var commentVotesViewModel: CommentVotesViewModel = {
        CommentVotesViewModel(postURL: post.url)
    }()

    var postContent: [QuillViewRenderObject] {
        parser.parseQuillJS(json: post.content)
    }
        
    let post: Post
    let votes: [Vote]
    
    var title: String {
        "\(commentCount) \(commentCount > 1 ? "Comments" : "Comment")"
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

    private let parser = QuillParser()
    private let provider: MoyaProvider<NonioAPI>
    private var cancellables: Set<AnyCancellable> = []
    private let scrollToCommentID: Int?

    init(
        post: Post,
        votes: [Vote],
        scrollToComment: Int? = nil,
        provider: MoyaProvider<NonioAPI> = .defaultProvider
    ) {
        self.post = post
        self.votes = votes
        self.provider = provider
        self.commentCount = post.commentCount
        self.scrollToCommentID = scrollToComment
    }
    
    func onLoad() {
        getComments()
    }
}

private extension PostDetailsViewModel {
    func getComments() {
        loading = true
        provider.requestPublisher(.getComments(id: post.url))
            .map([Comment].self, atKeyPath: "comments", using: .default)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    debugPrint("Error fetching comments: \(error)")
                }
                self.loading = false
            }, receiveValue: { [weak self] comments in
                guard let self else { return }
                self.commentCount = comments.count
                self.buildCommentHierarchy(from: comments)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.scrollToComment = self.scrollToCommentID
                }
            })
            .store(in: &cancellables)
    }
    
    // TODO: update sorting logic
    func buildCommentHierarchy(from allComments: [Comment]) {
        let commentsDict = Dictionary(uniqueKeysWithValues: allComments.map { ($0.id, CommentModel(comment: $0, level: 0)) })
        let rootComments = allComments.filter { $0.parent == 0 }
        var result = [CommentModel]()

        func attachChildren(to comment: inout CommentModel, level: Int) {
            let childComments = allComments
                .filter { $0.parent == comment.id }
                .map { CommentModel(comment: $0, level: level) }
            result.append(contentsOf: childComments)
            if !childComments.isEmpty {
                comment.children = childComments
                for child in childComments {
                    var child = child
                    attachChildren(to: &child, level: level + 1)
                }
            }
        }

        rootComments
            .forEach { topLevelComment in
                guard var comment = commentsDict[topLevelComment.id] else { return }
                result.append(.init(comment: topLevelComment, level: 0))
                attachChildren(to: &comment, level: 1)
            }

        commentViewModels = result
    }
}
