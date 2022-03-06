
import XCTest
import WebKit
import Combine
@testable import WebDomHandling
@testable import WebDOMKit


final class WebDOMKitTests: XCTestCase {
    
    var result: String?
    var expectation: XCTestExpectation?
    var service: WebDomService!
    
    
    override func setUp() {
        service = WebDomService()
        service.delegate = self
    }
    
    override func tearDown() {
        
    }
    
    func testWithReturnString() throws {
        expectation = expectation(description: "testWithReturnString")
        service.script = "function main() { return document.querySelector('#test').innerHTML } main();"
        service.loadHTMLString("<h1 id=\"test\">Hello, World</h1>", baseURL: nil)
        
        waitForExpectations(timeout: 1)
        
        let result = try XCTUnwrap(result)

        XCTAssertEqual(result, "Hello, World")
    }
    
    func testWithReturnInvaildValue() throws {
        expectation = expectation(description: "testWithReturnInvaildValue")
        service.script = "function main() { return true } main();"
        service.loadHTMLString("<h1 id=\"test\">Hello, World</h1>", baseURL: nil)
        
        waitForExpectations(timeout: 1)
    }
    
    func testPerformanceExample() throws {
        service.script = "function main() { return document.querySelector('#test').innerHTML } main();"
        
        measure {
            for _ in 0..<10 {
                expectation = expectation(description: "testPerformanceExample")
                service.loadHTMLString("<h1 id=\"test\">Hello, World!</h1>", baseURL: nil)
                
                waitForExpectations(timeout: 1)
            }
        }
    }
}

extension WebDOMKitTests: WebDomServiceDelegate {
    func webView(_ webView: WKWebView, didFinishEvaluateJavaScript result: String) {
        self.result = result
        print(result)
        expectation?.fulfill()
    }
    
    func webView(_ webView: WKWebView, didFailEvaluateJavaScript error: Error) {
        print(error)
        expectation?.fulfill()
    }
}



final class WebDomHandlingTests: XCTestCase {
    
    var result: String?
    var expectation: XCTestExpectation?
    var service: WDWebObject!
    
    var cancellable: AnyCancellable?
    
    override func setUp() {
        service = WDWebObject()
    }
    
    override func tearDown() {
        
    }
    
    func testWithReturnString() throws {
        expectation = expectation(description: "testWithReturnString")
        service.delegate = self
        service.script = "function main() { return document.querySelector('#test').innerHTML } main();"
        service.loadHTMLString("<h1 id=\"test\">Hello, World</h1>", baseURL: nil)
        
        waitForExpectations(timeout: 1)
        
        let result = try XCTUnwrap(result)

        XCTAssertEqual(result, "Hello, World")
    }
    
    func testWithReturnInvaildValue() throws {
        expectation = expectation(description: "testWithReturnInvaildValue")
        service.delegate = self
        service.script = "function main() { return true } main();"
        service.loadHTMLString("<h1 id=\"test\">Hello, World</h1>", baseURL: nil)
        
        waitForExpectations(timeout: 1)
    }
    
    func testPerformanceWithCombine() throws {
        service.script = "function main() { return document.querySelector('#test').innerHTML } main();"
        cancellable = service.finishEvaluatePublisher
            .sink(receiveValue: receiveValue)
        
        measure(measureBlock)
    }
    
    func testPerformanceWithDelegate() throws {
        service.delegate = self
        service.script = "function main() { return document.querySelector('#test').innerHTML } main();"
        
        measure(measureBlock)
    }
    
    
    private func measureBlock() {
        for _ in 0..<10 {
            expectation = expectation(description: "testPerformanceExample")
            service.loadHTMLString("<h1 id=\"test\">Hello, World!</h1>", baseURL: nil)
            
            waitForExpectations(timeout: 1)
        }
    }
    
    private func receiveValue(result: String?, error: Error?) {
        self.result = result
        print(result ?? error ?? "nil")
        expectation?.fulfill()
    }
}

extension WebDomHandlingTests: WDWebObjectDelegate {
    func webView(_ webView: WKWebView, didFinishEvaluateJavaScript result: String) {
        self.result = result
        print(result)
        expectation?.fulfill()
    }
    
    func webView(_ webView: WKWebView, didFailEvaluateJavaScript error: Error) {
        print(error)
        expectation?.fulfill()
    }
}
