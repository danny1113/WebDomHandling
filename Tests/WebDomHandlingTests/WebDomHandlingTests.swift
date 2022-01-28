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
        webObject.script = "function main() { return 'Hello, World!' } main();"
        webObject.delegate = self
        webObject.load("https://www.google.com")
        
        waitForExpectations(timeout: 10)
        
        let result = try XCTUnwrap(result)
        
//        XCTAssertEqual(result, "Hello, World!")
        XCTAssertTrue(result.starts(with: "Hello"))
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
