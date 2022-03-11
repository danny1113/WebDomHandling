//
//  WKWebObject.swift
//
//
//  Created by Danny on 2021/12/20.
//

import WebKit
import Combine



/// The parent object which defines the fundemental elements when handling codes between between JavaScript and Swift.
///
/// - Note: You have to set its delegate.
///
/// This object will setup the `webView` and set its `navigaitonDelegate` by default.
///
/// You can inherit this class and call ``loadJavaScriptString(forResource:)`` to load JavaScript code from `Bundle.main`.
open class WDWebObject: NSObject, ObservableObject, WKNavigationDelegate {
    
    /// Environment for JavaScript code to run in.
    public private(set) var webView: WKWebView!
    
    /// Variable stores the JavaScript source code.
    public var script: String = ""
    
    /// delegate for handling JavaScript evaluate result or error.
    public var delegate: WDWebObjectDelegate?
    
    
    /// When webView did finish navigation but no JavaScript code provided, this tag will be set to `true`.
    /// When JavaScript code loaded, webView will evaluate the code.
    private var shouldEvaluate = false
    
    /// decoder for decode JSON object.
    let decoder = JSONDecoder()
    
    private lazy var finishEvaluateSubject = PassthroughSubject<(String?, Error?), Never>()
    
    /// Publish result or error when webView finished evaluate JavaScript.
    public lazy var finishEvaluatePublisher = finishEvaluateSubject.eraseToAnyPublisher()
    
    /// Setup the webView.
    public override init() {
        super.init()
        
        setupWebView()
    }
    
    /// Setup the webView and load JavaScript code from `Bundle.main`.
    /// - Parameter forResource: path of the file (without extension).
    public init(forResource: String) {
        super.init()
        
        setupWebView()
        loadJavaScriptString(forResource: forResource)
    }
    
    /// Setup the webView, load JavaScript code from `Bundle.main` and load the specified URL.
    /// - Parameters:
    ///   - forResource: path of the file (without extension).
    ///   - url: website's URL.
    public init(forResource: String, url: String) {
        super.init()
        
        setupWebView()
        loadJavaScriptString(forResource: forResource)
        load(url)
    }
    
    /// Setup the webView, pass javaScript code and load the specified URL.
    /// - Parameters:
    ///   - javaScriptString: the JavaScript code.
    ///   - url: website's URL.
    public init(javaScriptString: String, url: String = "") {
        super.init()
        
        setupWebView()
        script = javaScriptString
        if !url.isEmpty {
            load(url)
        }
    }
    
    
    /// Initialize webView and assign its delegate.
    /// ```swift
    /// webView = WKWebView()
    /// webView.navigationDelegate = self
    /// webView.customUserAgent = "..."
    /// ```
    public func setupWebView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.2 Safari/605.1.15"
    }
    
    /**
     Load JavaScript file from `Bundle.main`.
     - Parameter forResource : path of the file (without extension).
     */
    public func loadJavaScriptString(forResource: String) {
        do {
            if let url = Bundle.main.url(forResource: forResource, withExtension: "js") {
                script = try String(contentsOf: url)
                
                if shouldEvaluate {
                    webView.evaluateJavaScript(script, completionHandler: evaluateResultHandler)
                }
            }
        } catch {
            print(error)
        }
    }
    
    
    /// Load JavaScript code referenced by the specified URL.
    /// - Parameter url: URL.
    public func loadJavaScriptString(url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let string = String(data: data, encoding: .utf8) else {
                return
            }
            
            self.script = string
            
            if self.shouldEvaluate {
                self.webView.evaluateJavaScript(string, completionHandler: self.evaluateResultHandler)
            }
        }
    }
    
    /// Loads the web content referenced by the specified URL request object and navigates to it.
    /// - Parameter urlString: URL.
    open func load(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let request = URLRequest(url: url)
        
        DispatchQueue.main.async {
            self.webView.load(request)
        }
    }
    
    /// Loads the web content referenced by the specified URL request object and navigates to it.
    /// - Parameters:
    ///     - urlString: URL
    ///     - allHTTPHeaderFields: HTTP Headers
    open func load(_ urlString: String, _ allHTTPHeaderFields: [String: String]) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = allHTTPHeaderFields
        
        DispatchQueue.main.async {
            self.webView.load(request)
        }
    }
    
    /// Loads the contents of the specified HTML string and navigates to it.
    ///
    /// Use this method to navigate to a webpage that you loaded or created yourself. For example, you might use this method to load HTML content that your app generates programmatically.
    ///
    /// - Parameters:
    ///   - string: The string to use as the contents of the webpage.
    ///   - baseURL: The base URL to use when resolving relative URLs within the HTML string.
    public func loadHTMLString(_ string: String, baseURL: URL? = nil) {
        webView.loadHTMLString(string, baseURL: baseURL)
    }
    
    /// When webView finished navigation and the JavaScript code isn't empty, webView will evaluate the JavaScript code.
    ///
    /// After webView evaluated the JavaScript code,
    /// - If `error` is `nil`, and `result` can be typecast as `String`, the delegate function ``WDWebObjectDelegate/webView(_:didFinishEvaluateJavaScript:)`` will be called.
    /// - If `error` is not `nil`, the delegate function ``WDWebObjectDelegate/webView(_:didFailEvaluateJavaScript:)`` will be called.
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        guard !script.isEmpty else {
            shouldEvaluate = true
            return
        }
        
        webView.evaluateJavaScript(script, completionHandler: evaluateResultHandler)
    }
    
    private func evaluateResultHandler(_ result: Any?, _ error: Error?) {
        if shouldEvaluate {
            shouldEvaluate = false
        }
        
        // An error occured.
        if let error = error {
            print(error)
            self.finishEvaluateSubject.send((nil, error))
            self.delegate?.webView(webView, didFailEvaluateJavaScript: error)
            return
        }
        // result can be typecast as String
        guard let result = result as? String else {
            let error = NSError(domain: "WKWebView", code: -1, userInfo: [NSLocalizedDescriptionKey: "Can't convert to String.\nIf you are returning a JSON from JavaScript, please use JSON.stringify() before data return to Swift."])
            self.finishEvaluateSubject.send((nil, error))
            self.delegate?.webView(webView, didFailEvaluateJavaScript: error)
            return
        }
        // did finished evaluate JavaScript code.
        self.finishEvaluateSubject.send((result, nil))
        self.delegate?.webView(webView, didFinishEvaluateJavaScript: result)
    }
}
