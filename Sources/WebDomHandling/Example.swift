//
//  Example.swift
//  
//
//  Created by Danny on 2022/1/25.
//

import WebKit
import SwiftUI
import Combine


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
    @State private var cancellable: AnyCancellable?
    
    var body: some View {
        List(data, id: \.self) { item in
            Text(item)
        }
        .onAppear(perform: connect)
    }
    
    // use Combine framework to receive data
    private func connect() {
        cancellable = webObject.finishEvaluatePublisher
            .compactMap { (result, _) -> Data? in
                if let result = result {
                    return result.data(using: .utf8)
                }
                return nil
            }
            .decode(type: [String].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .sink { result in
                self.data = result
                print("result: \(result)")
            }
    }
    
    // Use delegate to receive data
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
    
    func webView(_ webView: WKWebView, didFailEvaluateJavaScript error: Error) {
        print(error)
    }
    
}
