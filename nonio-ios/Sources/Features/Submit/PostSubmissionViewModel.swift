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

    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            guard let imageSelection else { return }
            loadTransferable(from: imageSelection)
        }
    }

    @Published private(set) var mediaSectionTitle = "Upload media"
    @Published private(set) var uploadingProgress: Double?

    var showMeida: Bool {
        selectedContentType == .media
    }
    var previewImageURL: URL? {
        selectedContentType == .link ? try? parseURLReponse?.image?.asURL() : nil
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
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    break
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
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    break
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
                    break
                }
            }
        }
    }

    func upload(media: NonioAPI.Media) {
        mediaSectionTitle = "Uploading"
        uploadingProgress = 0

        provider.requestWithProgressPublisher(.uploadMedia(media))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                self.mediaSectionTitle = "Upload media"
                self.uploadingProgress = nil
            }, receiveValue: { [weak self] response in
                guard let self else { return }
                self.uploadingProgress = response.progress >= 1 ? nil : response.progress
            })
            .store(in: &cancellables)
    }
}
