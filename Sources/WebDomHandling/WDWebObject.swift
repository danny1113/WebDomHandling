//
//  WKWebObject.swift
//
//
//  Created by Danny on 2021/12/20.
//

import WebKit


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
    
    /// decoder for decode JSON object.
    private let decoder = JSONDecoder()
    
    /// Setup the webView.
    public override init() {
        super.init()
        
        setupWebView()
    }
    
    /// Setup the webView and load JavaScript code from `Bundle.main`.
    /// - Parameter forResource: path of the file (without extension).
    public init(javaScriptString forResource: String) {
        super.init()
        
        setupWebView()
        loadJavaScriptString(forResource: forResource)
    }
    
    /// Setup the webView, load JavaScript code from `Bundle.main` and load the specified URL.
    /// - Parameters:
    ///   - forResource: path of the file (without extension).
    ///   - url: website's URL
    public init(javaScriptString forResource: String, url: String) {
        super.init()
        
        setupWebView()
        loadJavaScriptString(forResource: forResource)
        load(url)
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
            }
        } catch {
            print(error)
        }
    }
    
    /// Loads the web content referenced by the specified URL request object and navigates to it.
    /// - Parameter urlString: URL
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
    
    /// When webView finished navigation and the JavaScript code isn't empty, webView will evaluate the JavaScript code.
    ///
    /// After webView evaluated the JavaScript code,
    /// - If `error` is `nil`, and `result` can be typecast as `String`, the delegate function ``WDWebObjectDelegate/webView(_:didFinishEvaluateJavaScript:)`` will be called.
    /// - If `error` is not `nil`, the delegate function ``WDWebObjectDelegate/webView(_:didFailEvaluateJavaScript:)`` will be called.
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        guard !script.isEmpty else {
            return
        }
        
        webView.evaluateJavaScript(script) { result, error in
            // An error occured.
            if let error = error {
                self.delegate?.webView(webView, didFailEvaluateJavaScript: error.localizedDescription)
                return
            }
            // result can be typecast as String
            guard let result = result as? String else {
                self.delegate?.webView(webView, didFailEvaluateJavaScript: "Can't convert to String.\nIf you are returning a JSON from JavaScript, please use JSON.stringify() before data return to Swift.")
                return
            }
            // did finished evaluate JavaScript code.
            self.delegate?.webView(webView, didFinishEvaluateJavaScript: result)
        }
        
        // print("didFinish navigation.")
    }
}

extension WDWebObject {
    
    enum DecodeError: Error {
        case CantConvertToData
    }
    
    /// Returns a value of the type you specify, decoded from a JSON object.
    /// - Parameters:
    ///     - type: The type of the value to decode from the supplied JSON object.
    ///     - from: The JSON object to decode.
    /// - Returns: A value of the specified type, if the decoder can parse the data.
    public func decode<T: Decodable>(_ type: T.Type = T.self, from data: Data) throws -> T {
        
        let result = try self.decoder.decode(T.self, from: data)
        
        return result
    }
    
    /// Returns a value of the type you specify, decoded from a JSON object.
    /// - Parameters:
    ///     - type: The type of the value to decode from the supplied JSON object.
    ///     - jsonString: The JSON object to decode.
    /// - Returns: A value of the specified type, if the decoder can parse the data.
    public func decode<T: Decodable>(_ type: T.Type = T.self, jsonString: String) throws -> T {
        guard let data = jsonString.data(using: .utf8) else {
            throw DecodeError.CantConvertToData
        }
        
        let result = try self.decoder.decode(T.self, from: data)
        
        return result
    }
    
    /// Remove cache from HTTPCookieStorage, URLCache, WKWebsiteDataStore
    public func removeCache() {
        /// old API cookies
        for cookie in HTTPCookieStorage.shared.cookies ?? [] {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
        /// URL cache
        URLCache.shared.removeAllCachedResponses()
        /// WebKit cache
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: date,
            completionHandler: {}
        )
    }
}


public protocol WDWebObjectDelegate {
    /// Gets called when `func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)` is called.
    /// - Parameter evaluateJavaScript: the string value return value from JavaScript
    func webView(_ webView: WKWebView, didFinishEvaluateJavaScript result: String)
    
    /// Gets called when `webView.evaluateJavaScript(script)` passed an error.
    /// - Parameter javaScriptError: the error message generated by webView.
    func webView(_ webView: WKWebView, didFailEvaluateJavaScript error: String)
}
