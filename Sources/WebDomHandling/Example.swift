//
//  Example.swift
//  
//
//  Created by Danny on 2022/1/25.
//

import WebKit
import SwiftUI


final class ExampleWebObject: WDWebObject {
    
    override init() {
        super.init()
        
        loadJavaScriptString(forResource: "script")
        load("https://url/to/your/websites")
    }
}

struct ExampleView: View, WDWebObjectDelegate {
    
    @StateObject var webObject = ExampleWebObject()
    @State private var data = [String]()
    
    var body: some View {
        List(data, id: \.self) { item in
            Text(item)
        }
        .onAppear(perform: setDelegate)
    }
    
    private func setDelegate() {
        if webObject.delegate is Self {
            print("delegate is already set.")
        } else {
            webObject.delegate = self
        }
    }
    
    // Protocol implementation.
    func webView(_ webView: WKWebView, didFinishEvaluateJavaScript result: String) {
        do {
            let data: [String] = try webObject.decode(jsonString: result)
            self.data = data
        } catch {
            print(error)
        }
    }
    
    func webView(_ webView: WKWebView, didFailEvaluateJavaScript error: String) {
        print(error)
    }
    
}
