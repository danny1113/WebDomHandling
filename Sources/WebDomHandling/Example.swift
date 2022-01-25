//
//  Example.swift
//  
//
//  Created by Danny on 2022/1/25.
//

import WebKit


class ExampleSubClass: WKWebObject, WKWebObjectDelegate {
    
    override init() {
        super.init()
        
        // Set delegate to self.
        delegate = self
    }
    
    // Protocol 實作.
    func webView(_ webView: WKWebView, didFinish evaluateJavaScript: String) {
        
    }
    
    func webView(_ webView: WKWebView, didReceive javaScriptError: String) {
        
    }
}
