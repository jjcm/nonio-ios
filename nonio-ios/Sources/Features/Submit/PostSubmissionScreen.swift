import SwiftUI
import PhotosUI

struct PostSubmissionScreen: View {
    @EnvironmentObject var settings: AppSettings
    @StateObject private var viewModel = PostSubmissionViewModel()
    @State private var showTagsSearchView = false

    var body: some View {
        ZStack {
            content

            if viewModel.loading {
                ProgressView()
            }
        }
    }

    var content: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Content Type", selection: $viewModel.selectedContentType) {
                        ForEach(PostSubmissionViewModel.ContentType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .plainListItem()
                }
                mediaSection
                    .showIf(viewModel.showMeida)
                linkSection()
                descriptionSection()
                postURLSection()
                tagsSection()
                previewSection()
                submitButton
            }
            .onLoad { viewModel.onLoad() }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Submit Post")
            .sheet(isPresented: $showTagsSearchView, content: {
                SearchScreen(showCreateNewTag: true) { tag in
                    showTagsSearchView = false
                    if let tag {
                        viewModel.addTag(tag.tag)
                    }
                } onCancel: {
                    showTagsSearchView = false
                }
            })
            .navigationDestination(for: $viewModel.didCreatePost) { post in
                PostDetailsScreen(
                    viewModel: .init(postURL: post.url)
                )
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert, actions: {
                Button(action: {

                }, label: {
                    Text("Please try again")
                })
            }, message: {
                Text(viewModel.errorMessage)
            })
        }
    }
}

private extension PostSubmissionScreen {

    @ViewBuilder
    func postURLSection() -> some View {
        Section {
            HStack {
                Text(viewModel.host)

                HStack {
                    TextField("post-url", text: $viewModel.postURLPath)
                        .textFieldStyle(.plain)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.leading, -4)

                    Spacer()

                    if viewModel.checkingPostURL {
                        ProgressView()
                    } else if let valid = viewModel.postURLIsValid, viewModel.postURLPath.isNotEmpty {
                        Icon(image: Image(systemName: valid ? "checkmark.circle.fill" : "xmark.circle.fill"), size: .small)
                            .foregroundColor(valid ? .green : .red)
                    }
                }

                Spacer()
            }
        } footer: {
            if let error = viewModel.postURLError {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundStyle(.red)
            }
        }
    }

    @ViewBuilder
    func linkSection() -> some View {
        Section(header: SectionHeader("Details")) {
            InputForm(
                title: "Link",
                placeholder: "http://example.com",
                error: viewModel.invalidURLMessage,
                value: $viewModel.link
            )
            .showIf(viewModel.showLink)

            InputForm(
                title: "Title",
                placeholder: "Value",
                value: $viewModel.title
            )
        }
    }

    @ViewBuilder
    func descriptionSection() -> some View {
        Section {
            VStack(alignment: .leading) {
                Text("Description")
                    .font(.system(size: 15))
                    .foregroundStyle(UIColor.label.color)
                    .padding(.top, 8)

                ZStack(alignment: .topLeading) {
                    if viewModel.description.isEmpty {
                        Text("An optional description for the post")
                            .font(.system(size: 17))
                            .foregroundStyle(UIColor.tertiaryLabel.color)
                            .padding(.top, 0)
                            .padding(.leading, 0)
                            .frame(minHeight: 40)
                            .offset(y: -12)
                    }

                    TextEditor(text: $viewModel.description)
                        .font(.system(size: 17))
                        .foregroundStyle(UIColor.label.color)
                        .frame(minHeight: 40)
                }

                Spacer()
            }
        }
    }

    @ViewBuilder
    func tagsSection() -> some View {

        Section(header: SectionHeader("Tags", "Choose what tags the post should start with. If the post does not have tags, it will only appear on your profile.")) {

            ForEach(viewModel.tags, id: \.self) { tag in
                HStack {
                    Text(tag)

                    Spacer()

                    Button {
                        viewModel.removeTag(tag)
                    } label: {
                        Icon(image: Image(systemName: "xmark.circle.fill"), size: .small)
                            .foregroundColor(.red)
                    }
                }
            }

            HStack {
                Text("Add tag")
                    .font(.system(size: 17))
                    .foregroundStyle(UIColor.label.color)

                Spacer()

                Button {
                    showTagsSearchView = true
                } label: {
                    Icon(image: Image(systemName: "plus.circle.fill"), size: .small)
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    func previewSection() -> some View {
        Section(header: SectionHeader("Preview")) {
            PostPreviewView(
                title: viewModel.title,
                description: viewModel.description,
                link: viewModel.previewLink,
                image: viewModel.previewImageURL,
                user: settings.currentUser?.username ?? "",
                tags: viewModel.tags
            )
            .plainListItem()
        }
    }

    var mediaSection: some View {
        Section(header: SectionHeader(viewModel.mediaSectionTitle)) {
            if viewModel.uploading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(alignment: .center)
            }

            if let videoEncodingProgress = viewModel.videoEncodingProgressesArray {
                VideoEncodingView(progresses: videoEncodingProgress)
                    .padding(.vertical, 12)
            }

            if let result = viewModel.uploadSuccessResult {
                MediaView(media: result)
                    .plainListItem()
                    .frame(height: 220)
            }

            PhotosPicker(selection: $viewModel.imageSelection,
                         matching: .any(of: [.images, .videos]),
                         photoLibrary: .shared()) {

                HStack {
                    Icon(image: Image(systemName: "photo.badge.plus"), size: .medium)
                        .foregroundColor(UIColor.label.color)

                    Text(viewModel.imageSelection == nil ? "Select media" : "Select different media")
                        .foregroundStyle(UIColor.label.color)
                        .font(.system(size: 17))
                }

            }.buttonStyle(.borderless)
        }
    }

    var submitButton: some View {
        Button {
            viewModel.submitAction()
        } label: {
            VStack(alignment: .center) {
                if viewModel.postSubmitting {
                    ProgressView()
                } else {
                    Text("Submit post")
                        .font(.system(size: 17))
                        .foregroundColor(viewModel.submitButtonEnabled ? .blue : UIColor.tertiaryLabel.color)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(!viewModel.submitButtonEnabled)
    }
}

#Preview {
    PostSubmissionScreen().environmentObject(AppSettings())
}
