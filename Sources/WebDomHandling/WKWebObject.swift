//
//  WKWebObject.swift
//  THSR
//
//  Created by 龐達業 on 2021/12/20.
//

import Foundation
import SwiftUI
import WebKit

/// The parent object which defines the fundemental of WebObject.
open class WKWebObject: NSObject, ObservableObject, WKNavigationDelegate {
    
    public var webView: WKWebView!
    
    /// variable stores the JavaScript source code.
    public var script: String = ""
    
    public let decoder = JSONDecoder()
    
    /// setup the webView.
    public override init() {
        super.init()
        
        setupWebView()
    }
    
    /// Initialize webView and assign its delegate to class.
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
     Load JavaScript string from `Bundle.main`.
     - Parameter forResource : path of the file (without extension)
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
    /// - Parameters:
    ///     - urlString: URL
    ///     - allHTTPHeaderFields: HTTP Headers
    open func load(_ urlString: String, _ allHTTPHeaderFields: [String: String]? = nil) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        if let allHTTPHeaderFields = allHTTPHeaderFields {
            request.allHTTPHeaderFields = allHTTPHeaderFields
        }
        
        webView.load(request)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript(script) { result, error in
            guard error == nil, let result = result as? String else {
                if let error = error {
                    print(error)
                    self.webView(webView, didReceive: error.localizedDescription)
                }
                return
            }
            
            self.webView(webView, didFinish: result)
        }
    }
    
    /// Gets called when `func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)` is called.
    /// - Note:
    ///     Initially this function won't do anything. You have to override it.
    /// - Parameter evaluateJavaScript: the string value return value from JavaScript
    open func webView(_ webView: WKWebView, didFinish evaluateJavaScript: String) {
        
    }
    
    /// Gets called when `webView.evaluateJavaScript(script)` passed an error.
    /// - Note:
    ///     Initially this function won't do anything. You have to override it.
    /// - Parameter javaScriptError: error message.
    open func webView(_ webView: WKWebView, didReceive javaScriptError: String) {
        
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

#if os(iOS)

extension WKWebObject {
    public struct WebView: UIViewRepresentable {
        
        let webView: WKWebView
        
        public init(webView: WKWebView) {
            self.webView = webView
        }
        
        public func makeUIView(context: Context) -> some UIView {
            return webView
        }
        
        public func updateUIView(_ uiView: UIViewType, context: Context) {
            
        }
    }
}

#endif
