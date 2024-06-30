import SwiftUI
import Combine
import PhotosUI

struct PostSubmissionMediaType {
    let fileName: String
    let type: MediaType

    enum MediaType {
        case video, image
    }
}

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
    @Published private(set) var uploadSuccessResult: PostSubmissionMediaType?
    @Published private(set) var postSubmitting: Bool = false
    @Published var didCreatePost: Post?
    @Published private var _videoEncodingProgresses: [VideoResolution: EncodingProgress]?
    var videoEncodingProgressesArray: [EncodingProgress]? {
        guard let _videoEncodingProgresses else { return nil }
        return Array(_videoEncodingProgresses.values).sorted(by: { $0.resolution < $1.resolution })
    }

    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            guard let imageSelection else { return }
            loadTransferable(from: imageSelection)
        }
    }

    @Published private(set) var mediaSectionTitle = "Upload media"
    @Published private(set) var uploading: Bool = false
    private var manager: VideoEncodingManager?
    private var uploadedFileName: String?

    var showMeida: Bool {
        selectedContentType == .media
    }
    var previewImageURL: URL? {
        switch selectedContentType {
        case .link:
            return try? parseURLReponse?.image?.asURL()
        case .media:
            guard let uploadSuccessResult else { return nil }
            switch uploadSuccessResult.type {
            case .image:
                return ImageURLGenerator.imageURL(path: uploadSuccessResult.fileName)
            default:
                return nil
            }
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

    func submitAction() {
        if let uploadSuccessResult {
            let uploadUrl = (uploadSuccessResult.fileName
                             as NSString).deletingPathExtension
            moveURL(oldUrl: uploadUrl, url: postURLPath, type: uploadSuccessResult.type)
        } else {
            submitPost()
        }
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
                    self.uploadedFileName = responseFileName
                    switch media.type {
                    case .image:
                        self.handleImageUploadSuccess(fileName: responseFileName, media: media)
                    case .video:
                        self.handleVideoUploadSuccess(fileName: responseFileName, media: media)
                    }
                }
            })
            .store(in: &cancellables)
    }

    func handleImageUploadSuccess(fileName: String, media: NonioAPI.Media) {
        uploadSuccessResult = PostSubmissionMediaType(fileName: fileName, type: .image)
    }

    func moveURL(oldUrl: String, url: String, type: PostSubmissionMediaType.MediaType) {
        guard !postSubmitting else { return }
        postSubmitting = true
        provider.requestPublisher(.moveURL(from: oldUrl, to: url, type: type))
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
            }, receiveValue: { [weak self] _ in
                self?.postSubmitting = false
                self?.submitPost()
            })
            .store(in: &cancellables)

    }

    func handleVideoUploadSuccess(fileName: String, media: NonioAPI.Media) {
        startVideoEncoding(filename: fileName)
    }

    func startVideoEncoding(filename: String) {
        manager = VideoEncodingManager(server: Configuration.WEB_SOCKET_HOST)
        manager?.connect(filename: filename)
        manager?.delegate = self
    }

    func clearInput() {
        title = ""
        description = ""
        postURLPath = ""
        tags = []
        link = ""
        parseURLReponse = nil
        uploadSuccessResult = nil
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
            return uploadSuccessResult?.type == .image ? "image": "video"
        case .text:
            return "text"
        }
    }

    func initialEncodingProgress() -> [VideoResolution: EncodingProgress] {
        var result = [VideoResolution: EncodingProgress]()
        for resolution in VideoResolution.allCases {
            result[resolution] = .init(resolution, 0, false)
        }
        return result
    }
}

extension PostSubmissionViewModel: VideoEncodingManagerDelegate {
    func didUpdateProgress(_ progress: EncodingProgress) {
        if _videoEncodingProgresses == nil {
            _videoEncodingProgresses = initialEncodingProgress()
        }
        _videoEncodingProgresses![progress.resolution] = progress
    }

    func encodeDidFinish() {
        guard let uploadedFileName else { return }
        _videoEncodingProgresses = nil
        uploadSuccessResult = PostSubmissionMediaType(fileName: uploadedFileName, type: .video)
    }
}
