import SwiftUI
import WebKit
import Combine

struct EditorWebView: UIViewRepresentable {
    private var cancellables: Set<AnyCancellable> = []
    private let htmlFilename = "quill"
    private let getContentAction: PassthroughSubject<Void, Never>
    private let editorFocusAction: PassthroughSubject<Void, Never>
    private let didGetContent: ((String) -> Void)
    
    init(
        editorFocusAction: PassthroughSubject<Void,Never>,
        getContentAction: PassthroughSubject<Void, Never>,
        didGetContent: @escaping ((String) -> Void)
    ) {
        self.editorFocusAction = editorFocusAction
        self.getContentAction = getContentAction
        self.didGetContent = didGetContent
    }
    
    func makeCoordinator() -> Coordinator {
        let webView = WKWebView()
        let coordinator = Coordinator(
            webView: webView,
            editorFocusAction: editorFocusAction,
            getContentAction: getContentAction,
            didGetContent: didGetContent
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

        if let filePath = Bundle.main.path(forResource: htmlFilename, ofType: "html"),
           let htmlString = try? String(contentsOfFile: filePath, encoding: .utf8) {
            uiView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
        }
    }
    
    func setupWebView(_ webView: WKWebView) {
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
        }
        private var cancellables: Set<AnyCancellable> = []

        var webView: WKWebView
        let editorFocusAction: PassthroughSubject<Void, Never>
        let getContentAction: PassthroughSubject<Void, Never>
        let didGetContent: ((String) -> Void)
        init(
            webView: WKWebView,
            editorFocusAction: PassthroughSubject<Void, Never>,
            getContentAction: PassthroughSubject<Void, Never>,
            didGetContent: @escaping ((String) -> Void)
        ) {
            self.webView = webView
            self.editorFocusAction = editorFocusAction
            self.getContentAction = getContentAction
            self.didGetContent = didGetContent
            super.init()
            
            getContentAction.eraseToAnyPublisher().sink { [weak self] content in
                guard let self else { return }
                self.getContent()
            }
            .store(in: &cancellables)
            
            editorFocusAction.eraseToAnyPublisher().sink { [weak self] content in
                guard let self else { return }
                self.setEditorFocus()
            }
            .store(in: &cancellables)
            
            webView.configuration.userContentController.add(self, name: MessageName.getContent)
            webView.configuration.userContentController.add(self, name: MessageName.editorFocus)
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {}
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {}
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == MessageName.getContent, let content = message.body as? String {
                didGetContent(content)
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
    }
}

