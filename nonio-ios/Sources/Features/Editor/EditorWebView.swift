import SwiftUI
import WebKit
import Combine

struct EditorWebView: UIViewRepresentable {
    
    private var cancellables: Set<AnyCancellable> = []
    private let htmlFilename = "quill"
    private let editorFocusAction: PassthroughSubject<Void, Never>
    @Binding private var content: String
    
    init(
        content: Binding<String>,
        editorFocusAction: PassthroughSubject<Void,Never>
    ) {
        _content = content
        self.editorFocusAction = editorFocusAction
    }
    
    func makeCoordinator() -> Coordinator {
        let webView = WKWebView()
        let coordinator = Coordinator(
            content: $content,
            webView: webView,
            editorFocusAction: editorFocusAction
        )
        return coordinator
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = context.coordinator.webView
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.bouncesZoom = false
        setupWebView(webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.navigationDelegate = context.coordinator
        context.coordinator.setContent(content)
    }
    
    func setupWebView(_ webView: WKWebView) {
        if let filePath = Bundle.main.path(forResource: htmlFilename, ofType: "html"),
           let htmlString = try? String(contentsOfFile: filePath, encoding: .utf8) {
            webView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
        }
        
        let viewportScriptString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); meta.setAttribute('initial-scale', '1.0'); meta.setAttribute('maximum-scale', '1.0'); meta.setAttribute('minimum-scale', '1.0'); meta.setAttribute('user-scalable', 'no'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let disableSelectionScriptString = "document.documentElement.style.webkitUserSelect='none';"
        let disableCalloutScriptString = "document.documentElement.style.webkitTouchCallout='none';"
        
        let viewportScript = WKUserScript(
            source: viewportScriptString,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        let disableSelectionScript = WKUserScript(
            source: disableSelectionScriptString,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        let disableCalloutScript = WKUserScript(
            source: disableCalloutScriptString,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        
        webView.configuration.userContentController.addUserScript(viewportScript)
        webView.configuration.userContentController.addUserScript(disableSelectionScript)
        webView.configuration.userContentController.addUserScript(disableCalloutScript)
    }
}

extension EditorWebView {
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        struct MessageName {
            static let getContent = "getContent"
            static let editorFocus = "editorFocus"
            static let contentDidChange = "contentDidChange"
            static let setContent = "setContent"
        }
        private var cancellables: Set<AnyCancellable> = []

        @Binding private var content: String
        var webView: WKWebView
        let editorFocusAction: PassthroughSubject<Void, Never>
        init(
            content: Binding<String>,
            webView: WKWebView,
            editorFocusAction: PassthroughSubject<Void, Never>
        ) {
            _content = content
            self.webView = webView
            self.editorFocusAction = editorFocusAction
            super.init()      
            
            editorFocusAction.eraseToAnyPublisher().sink { [weak self] content in
                guard let self else { return }
                self.setEditorFocus()
            }
            .store(in: &cancellables)
            
            webView.configuration.userContentController.add(self, name: MessageName.getContent)
            webView.configuration.userContentController.add(self, name: MessageName.editorFocus)
            webView.configuration.userContentController.add(self, name: MessageName.contentDidChange)
            webView.configuration.userContentController.add(self, name: MessageName.setContent)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {}
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {}
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == MessageName.getContent, let content = message.body as? String {
                self.content = content
            } else if message.name == MessageName.contentDidChange, let content = message.body as? String {
                self.content = content
            }
        }
        
        func getContent() {
            webView.evaluateJavaScript("\(MessageName.getContent)()") { _, error in
                if let error {
                    debugPrint("evaluateJavaScript error: \(error)")
                }
            }
        }
        
        func setEditorFocus() {
            webView.evaluateJavaScript("\(MessageName.editorFocus)()") { _, error in
                if let error {
                    debugPrint("evaluateJavaScript error: \(error)")
                }
            }
        }
        
        func setContent(_ content: String) {
            webView.evaluateJavaScript("\(MessageName.setContent)('\(content)';") { _, error in
                if let error {
                    debugPrint("evaluateJavaScript error: \(error)")
                }
            }
        }
    }
}

