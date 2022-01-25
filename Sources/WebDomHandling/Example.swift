//
//  Example.swift
//  
//
//  Created by Danny on 2022/1/25.
//

import Foundation

protocol Delegate {
    func message()
}

class Example {
    var delegate: Delegate?
    
    var classA = ExampleA()
    var classB = ExampleB()
    
    func setDelegate() {
        delegate = classA
        delegate?.message()
        // print "class A"
        
        delegate = classB
        delegate?.message()
        // print "class B"
    }
}

class ExampleA: Delegate {
    
    func message() {
        print("class A")
    }
}

class ExampleB: Delegate {
    
    func message() {
        print("class B")
    }
}




/*
func webView(_ webView: WKWebView, didFinish evaluateJavaScript: String) {
    
}

func webView(_ webView: WKWebView, didReceive javaScriptError: String) {
    
}
*/
