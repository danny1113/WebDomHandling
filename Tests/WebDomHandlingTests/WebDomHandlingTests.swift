
import XCTest
import WebKit
import Combine
@testable import WebDomHandling
@testable import WebDOMKit


let HTMLString = "<h1 id=\"test\">Hello, World</h1>"

let jsReturnString = "function main() { return document.querySelector('#test').innerHTML } main();"

let jsReturnInvaildValue = "function main() { return true } main();"

let jsReturnHTMLBody = "function main() { return document.documentElement.outerHTML } main();"

let PERFORMANCE_TEST_COUNT = 10


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
        service.script = jsReturnString
        service.loadHTMLString(HTMLString, baseURL: nil)
        
        waitForExpectations(timeout: 3)
        
        let result = try XCTUnwrap(result)

        XCTAssertEqual(result, "Hello, World")
    }
    
    func testWithReturnInvaildValue() throws {
        expectation = expectation(description: "testWithReturnInvaildValue")
        service.script = jsReturnInvaildValue
        service.loadHTMLString(HTMLString, baseURL: nil)
        
        waitForExpectations(timeout: 3)
    }
    
    func testRetainCycle() throws {
        expectation = expectation(description: "testRetainCycle")
        service.script = jsReturnString
        service.delegate = self
        service.loadHTMLString(HTMLString, baseURL: nil)
        
        waitForExpectations(timeout: 3)
        service = nil
        XCTAssertNil(service)
    }
    
    func testPerformanceExample() throws {
        service.script = jsReturnString
        
        measure {
            for _ in 0..<PERFORMANCE_TEST_COUNT {
                expectation = expectation(description: "testPerformanceExample")
                service.loadHTMLString(HTMLString, baseURL: nil)
                
                waitForExpectations(timeout: 3)
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
        service.script = jsReturnString
        service.loadHTMLString(HTMLString, baseURL: nil)
        
        waitForExpectations(timeout: 3)
        
        let result = try XCTUnwrap(result)

        XCTAssertEqual(result, "Hello, World")
    }
    
    func testWithReturnInvaildValue() throws {
        expectation = expectation(description: "testWithReturnInvaildValue")
        service.delegate = self
        service.script = jsReturnInvaildValue
        service.loadHTMLString(HTMLString, baseURL: nil)
        
        waitForExpectations(timeout: 3)
    }
    
    func testRetainCycle() throws {
        expectation = expectation(description: "testRetainCycle")
        service.script = jsReturnString
        cancellable = service.finishEvaluatePublisher
            .sink(receiveValue: receiveValue)
        service.loadHTMLString(HTMLString, baseURL: nil)
        
        waitForExpectations(timeout: 3)
        service = nil
        XCTAssertNil(service)
    }
    
    func testPerformanceWithCombine() throws {
        service.script = jsReturnString
        cancellable = service.finishEvaluatePublisher
            .sink(receiveValue: receiveValue)
        
        measure(measureBlock)
    }
    
    func testPerformanceWithDelegate() throws {
        service.delegate = self
        service.script = jsReturnString
        
        measure(measureBlock)
    }
    
    
    private func measureBlock() {
        for _ in 0..<PERFORMANCE_TEST_COUNT {
            expectation = expectation(description: "testPerformanceExample")
            service.loadHTMLString(HTMLString, baseURL: nil)
            
            waitForExpectations(timeout: 3)
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
