
import XCTest
import WebKit
@testable import WebDomHandling


final class WebDomHandlingTests: XCTestCase {
    
    var result: String?
    var expectation: XCTestExpectation?
    var webObject: WDWebObject!
    
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        webObject = WDWebObject()
        webObject.script = "function main() { return document.querySelector('#test').innerHTML } main();"
        webObject.delegate = self
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        expectation = expectation(description: "perform JS code")
        webObject.loadHTMLString("<h1 id=\"test\">Hello, World!</h1>")
        
        waitForExpectations(timeout: 5)
        
        let result = try XCTUnwrap(result)
        
        XCTAssertEqual(result, "Hello, World!")
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            for _ in 0..<500 {
                expectation = expectation(description: "perform JS code")
                webObject.loadHTMLString("<h1 id=\"test\">Hello, World!</h1>")
                
                waitForExpectations(timeout: 5)
            }
        }
    }
}

extension WebDomHandlingTests: WDWebObjectDelegate {
    func webView(_ webView: WKWebView, didFinishEvaluateJavaScript result: String) {
        self.result = result
        expectation?.fulfill()
    }
    
    func webView(_ webView: WKWebView, didFailEvaluateJavaScript error: String) {
        self.result = error
        expectation?.fulfill()
        expectation = nil
    }
}
