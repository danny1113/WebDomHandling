//
//  WebView.swift
//  
//
//  Created by Danny on 2022/1/25.
//

import SwiftUI
import WebKit


#if os(iOS)

extension WKWebObject {
    public struct WebView: UIViewRepresentable {
        
        let webView: WKWebView
        
        public init(webView: WKWebView = WKWebView()) {
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

#if os(macOS)

extension WKWebObject {
    public struct WebView: NSViewRepresentable {
        
        let webView: WKWebView
        
        public init(webView: WKWebView = WKWebView()) {
            self.webView = webView
        }
        
        public func makeNSView(context: Context) -> some NSView {
            return webView
        }
        
        public func updateNSView(_ nsView: NSViewType, context: Context) {
            
        }
    }
}

#endif
