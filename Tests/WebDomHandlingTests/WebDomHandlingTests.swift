import XCTest
import WebKit
@testable import WebDomHandling

final class WebDomHandlingTests: XCTestCase {
    
    var result: String?
    var expectation: XCTestExpectation?
    var webObject = WDWebObject()
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        expectation = expectation(description: "Load webView")
        webObject.script = "function main() { return document.querySelector('#test').innerHTML } main();"
        webObject.delegate = self
        webObject.loadHTMLString("<h1 id=\"test\">Hello, World!</h1>")
        
        waitForExpectations(timeout: 10)
        
        let result = try XCTUnwrap(result)
        
        XCTAssertEqual(result, "Hello, World!")
    }
}

extension WebDomHandlingTests: WDWebObjectDelegate {
    func webView(_ webView: WKWebView, didFinishEvaluateJavaScript result: String) {
        print(result)
        self.result = result
        expectation?.fulfill()
        expectation = nil
    }
    
    func webView(_ webView: WKWebView, didFailEvaluateJavaScript error: String) {
        self.result = error
        expectation?.fulfill()
        expectation = nil
    }
}
