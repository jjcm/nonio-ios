import Foundation
import UIKit
import Moya
import Combine

final class PostDetailsViewModel: ObservableObject {
    
    @Published private(set) var loading: Bool = false
    @Published private(set) var post: Post?
    @Published private(set) var commentViewModels: [CommentModel] = []
    @Published private(set) var commentCount: Int = 0
    @Published private(set) var scrollToComment: Int?
    @Published private(set) var title: String = ""
    @Published private(set) var postContent: [QuillViewRenderObject] = []

    private(set) lazy var commentVotesViewModel: CommentVotesViewModel = {
        CommentVotesViewModel(postURL: postURL)
    }()

    let votes: [Vote]

    let postURL: String
    private let parser = QuillParser()
    private let provider = NonioProvider.default
    private var cancellables: Set<AnyCancellable> = []
    private let scrollToCommentID: Int?

    init(
        postURL: String,
        votes: [Vote],
        scrollToComment: Int? = nil
    ) {
        self.postURL = postURL
        self.votes = votes
        self.scrollToCommentID = scrollToComment
    }

    init(
        post: Post,
        commentViewModels: [CommentModel] = [],
        votes: [Vote]
    ) {
        self.post = post
        self.commentViewModels = commentViewModels
        self.postURL = post.url
        self.scrollToCommentID = nil
        self.votes = votes
    }

    func onLoad() {
        getPost()
        getComments()
    }
}

private extension PostDetailsViewModel {

    func getPost() {
        loading = true
        provider.requestPublisher(.getPost(id: postURL))
            .map(Post.self, using: .default)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    debugPrint("Error fetching post: \(error)")
                }
                self.loading = false
            }, receiveValue: { [weak self] post in
                guard let self else { return }
                self.post = post
                self.postContent = parser.parseQuillJS(json: post.content)
            })
            .store(in: &cancellables)
    }

    func getComments() {
        loading = true
        provider.requestPublisher(.getComments(id: postURL))
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
                result.append(comment)
                attachChildren(to: &comment, level: 1)
            }

        commentViewModels = result
    }
}


extension Post {

    var detailsTitle: String {
        "\(commentCount) \(commentCount > 1 ? "Comments" : "Comment")"
    }

    var imageURL: URL? {
        ImageURLGenerator.imageURL(path: url)
    }

    var videoURL: URL? {
        ImageURLGenerator.videoURL(path: url)
    }

    var linkString: String {
        link?.absoluteString ?? ""
    }

    var shouldShowImage: Bool {
        if type == .image || type == .link {
            return true
        }
        return false
    }

    var shouldShowLink: Bool {
        link != nil
    }

    var shouldShowTags: Bool {
        !tags.isEmpty
    }

    var mediaSize: CGSize {
        guard let width = width,
              let height = height,
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
}
