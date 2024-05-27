import SwiftUI
import Combine
import PhotosUI

class PostSubmissionViewModel: ObservableObject {

    let host: String = "https://non.io/"

    @Published var link: String = "" {
        didSet {
            validateLink(link)
        }
    }
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var tags: [String] = []
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    @Published var selectedContentType: ContentType = .link {
        didSet {
            reloadsections()
        }
    }
    @Published var parseURLReponse: ParseExternalURLResponse?
    @Published private(set) var loading = false
    @Published var postURLPath: String = ""
    @Published private(set) var invalidURLMessage: String?
    @Published private(set) var postURLError: String?
    @Published private(set) var checkingPostURL: Bool = false
    @Published private(set) var postURLIsValid: Bool?
    @Published private(set) var showLink: Bool = true
    @Published private(set) var uploadSuccessResult: (URL, NonioAPI.Media)?
    @Published private(set) var postSubmitting: Bool = false
    @Published var didCreatePost: Post?

    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            guard let imageSelection else { return }
            loadTransferable(from: imageSelection)
        }
    }

    @Published private(set) var mediaSectionTitle = "Upload media"
    @Published private(set) var uploading: Bool = false

    var showMeida: Bool {
        selectedContentType == .media
    }
    var previewImageURL: URL? {
        switch selectedContentType {
        case .link:
            return try? parseURLReponse?.image?.asURL()
        case .media:
            return uploadSuccessResult?.0
        case .text:
            return nil
        }
    }
    var previewLink: String? {
        selectedContentType == .link ? link : nil
    }

    var submitButtonEnabled: Bool {
        postURLPath.isNotEmpty
        && postURLIsValid == true
        && title.isNotEmpty
    }

    private let provider =  NonioProvider.default
    private var cancellables: Set<AnyCancellable> = []

    var dipslayLink: String {
        URL(string: host)!.appendingPathComponent(link).absoluteString
    }

    enum ContentType: String, CaseIterable {
        case link = "Link"
        case media = "Media"
        case text = "Text"
    }

    func addTag(_ tag: String) {
        guard !tag.isEmpty else { return }
        tags.append(tag)
    }

    func removeTag(_ tag: String) {
        tags.removeAll(where: { $0 == tag })
    }

    func submitPost() {
        guard !postSubmitting else { return }

        postSubmitting = true

        let params = CreatePostParams(
            content: description,
            title: title,
            type: getContentTypeParam(),
            url: postURLPath,
            link: link,
            tags: tags
        )
        provider.requestPublisher(.postCreate(params))
            .map(Post.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.handleError(error)
                }
                self.postSubmitting = false
            }, receiveValue: { [weak self] post in
                self?.didCreatePost = post
                self?.clearInput()
            })
            .store(in: &cancellables)
    }

    func onLoad() {
        $link
            .removeDuplicates()
            .throttle(for: 1, scheduler: RunLoop.main, latest: true)
            .sink { [weak self] value in
                guard value.isNotEmpty else { return }
                self?.fetchURL()
            }
            .store(in: &cancellables)

        $postURLPath
            .removeDuplicates()
            .throttle(for: 1, scheduler: RunLoop.main, latest: true)
            .sink { [weak self] value in
                guard value.isNotEmpty else { return }
                self?.validatePostURL()
            }
            .store(in: &cancellables)
    }

    func reloadsections() {
        showLink = selectedContentType == .link
    }
}

private extension PostSubmissionViewModel {
    
    func validatePostURL() {
        if postURLPath.isEmpty {
            self.postURLError = "URL can't be empty"
        } else if URLValidator.validate(postURLPath) {
            self.postURLError = nil
            self.checkPostURL()
        } else {
            self.postURLError = "URL can only contain alphanumerics, periods, dashes, and underscores"
        }
    }

    func checkPostURL() {
        guard !checkingPostURL, postURLPath.isNotEmpty else { return }

        checkingPostURL = true
        provider.requestPublisher(.checkURLAvailability(url: postURLPath))
            .map(Bool.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.handleError(error)
                }
                self.checkingPostURL = false
            }, receiveValue: { [weak self] valid in
                self?.postURLIsValid = valid
                self?.postURLError = valid ? nil : "URL is not available. Please choose a better one for your lovely meme."
            })
            .store(in: &cancellables)
    }

    func validateLink(_ link: String) {
        guard link.isNotEmpty else { return }

        var valid = false
        if let urlComponents = URLComponents(string: link) {
            valid = urlComponents.scheme != nil && urlComponents.host != nil
         }

        invalidURLMessage = valid ? nil : "Invalid URL"
    }

    func fetchURL() {
        guard !loading, link.isNotEmpty else { return }

        loading = true
        provider.requestPublisher(.parseExternalURL(url: link))
            .map(ParseExternalURLResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.handleError(error)
                }
                self.loading = false
            }, receiveValue: { [weak self] response in
                self?.parseURLReponse = response
                self?.populateResponse(response)
            })
            .store(in: &cancellables)
    }

    func populateResponse(_ response: ParseExternalURLResponse) {
        if title.isEmpty, response.title.isNotEmpty {
            title = response.title
        }
        if description.isEmpty, response.description.isNotEmpty {
            description = response.description
        }
        if postURLPath.isEmpty, response.title.isNotEmpty {
            postURLPath = response.title.split(separator: " ").joined(separator: "-")
        }
    }
    
    func loadTransferable(from item: PhotosPickerItem) {
        let mimeType = item.supportedContentTypes.first?.preferredMIMEType ?? ""
        let isImage = item.supportedContentTypes.contains(where: { $0.conforms(to: .image )})

        item.loadTransferable(type: FileTransferable.self) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch result {
                case .success(let file?):
                    self.upload(
                        media: .init(
                            file: file.url,
                            fileName: file.filename,
                            mimeType: mimeType,
                            type: isImage ? .image : .video
                        )
                    )
                case .success(nil):
                    break
                case .failure(let error):
                    self.handleError(error)
                }
            }
        }
    }

    func upload(media: NonioAPI.Media) {
        mediaSectionTitle = "Uploading"
        uploading = true

        provider.requestWithProgressPublisher(.uploadMedia(media))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.handleError(error)
                }
                self.mediaSectionTitle = "Upload media"
                self.uploading = false
            }, receiveValue: { [weak self] response in
                guard let self else { return }

                if response.completed,
                   let data = response.response?.data,
                   let responseFileName = String(data: data, encoding: .utf8) {
                    self.handleUploadSuccess(fileName: responseFileName, media: media)
                }
            })
            .store(in: &cancellables)
    }

    func handleUploadSuccess(fileName: String, media: NonioAPI.Media) {
        let url: URL
        switch media.type {
        case .image:
            url = Configuration.IMAGE_API_HOST.appending(path: fileName).appendingPathExtension("webp")
        case .video:
            url = Configuration.VIDEO_API_HOST.appending(path: fileName)
        }
        uploadSuccessResult = (url, media)
    }

    func clearInput() {
        title = ""
        description = ""
        postURLPath = ""
        tags = []
        link = ""
        parseURLReponse = nil
    }

    func handleError(_ error: Error) {
        showErrorAlert = true
        errorMessage = error.localizedDescription
    }

    func getContentTypeParam() -> String {
        switch selectedContentType {
        case .link:
            return "link"
        case .media:
            return uploadSuccessResult?.1.type == .image ? "image": "video"
        case .text:
            return "text"
        }
    }
}
