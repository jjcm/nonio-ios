import SwiftUI
import Combine

struct CommentEditorScreen: View {
    @Environment(\.colorScheme) var colorScheme
    private let getContentAction = PassthroughSubject<Void,Never>()
    private let editorFocusAction = PassthroughSubject<Void,Never>()
    
    let comment: Comment?
    let didCancel: (() -> Void)
    init(comment: Comment?, didCancel: @escaping () -> Void) {
        self.comment = comment
        self.didCancel = didCancel
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                EditorWebView(
                    editorFocusAction: editorFocusAction,
                    getContentAction: getContentAction,
                    didGetContent: {
                        content in
                        
                    })
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        didCancel()
                    } label: {
                        Text("Cancel")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        getContentAction.send(())
                    } label: {
                        Text("Post")
                    }
                }
            }
            .background(UIColor.secondarySystemBackground.color)
            .navigationTitle("Add Comment")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // add delays to ensure editor is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                editorFocusAction.send(())
            }
        }
    }
}

#Preview {
    CommentEditorScreen(comment: nil, didCancel: {})
}
