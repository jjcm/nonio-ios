import SwiftUI
import Combine

struct CommentEditorScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private var viewModel: CommentEditorViewModel
    private let editorFocusAction = PassthroughSubject<Void,Never>()
    @State private var showDeleteConfirmation = false
    @State private var content = ""
    
    let didCancel: (() -> Void)
    init(
        postURL: String,
        comment: Comment?,
        addCommentSuccess: @escaping (Comment) -> Void,
        didCancel: @escaping () -> Void
    ) {
        self.viewModel = .init(
            postURL: postURL,
            comment: comment,
            addCommentSuccess: addCommentSuccess
        )
        self.didCancel = didCancel
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                EditorWebView(
                    content: $content,
                    editorFocusAction: editorFocusAction
                )
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        tryToCancel()
                    } label: {
                        Text("Cancel")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        postAction()
                    } label: {
                        Text("Post")
                    }
                }
            }
            .background(UIColor.secondarySystemBackground.color)
            .navigationTitle("Add Comment")
            .navigationBarTitleDisplayMode(.inline)
        }
        .confirmationDialog("", isPresented: $showDeleteConfirmation, actions: {
            Button("Delete", role: .destructive) {
                didCancel()
            }
            Button("Cancel", role: .cancel) {}
        })
        .alert(isPresented: $viewModel.showError, error: viewModel.error, actions: {
            
        })
        .onAppear {
            // add delays to ensure editor is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                editorFocusAction.send(())
            }
        }
    }
    
    private func tryToCancel() {
        if content.isEmpty {
            didCancel()
        } else {
            showDeleteConfirmation = true
        }
    }
    
    private func postAction() {
        guard !content.isEmpty else { return }
        viewModel.addComment(content: content)
    }
}
