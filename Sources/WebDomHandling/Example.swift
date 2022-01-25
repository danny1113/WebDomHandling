//
//  Example.swift
//  
//
//  Created by Danny on 2022/1/25.
//

import WebKit


class ExampleSubClass: WDWebObject, WDWebObjectDelegate {
    
    override init() {
        super.init()
        
        // Set delegate to self.
        delegate = self
    }
    
    // Protocol 實作.
    func webView(_ webView: WKWebView, didFinishEvaluateJavaScript result: String) {
        
    }
    
    func webView(_ webView: WKWebView, didFailEvaluateJavaScript error: String) {
        
    }
    
    
    /*
    func webView(_ webView: WKWebView, didFinish evaluateJavaScript: String) {
        
    }
    
    func webView(_ webView: WKWebView, didReceive javaScriptError: String) {
        
    }
    */
}
