
import XCTest
import WebKit
@testable import WebDomHandling
@testable import WebDOMKit


final class WebDomHandlingTests: XCTestCase {
    
    var result: String?
    var expectation: XCTestExpectation?
    var service: WebDomService!
    
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        service = WebDomService()
        service.delegate = self
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testWithReturnString() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        expectation = expectation(description: "perform JS code")
        service.script = "function main() { return document.querySelector('#test').innerHTML } main();"
        service.loadHTMLString("<h1 id=\"test\">Hello, World</h1>", baseURL: nil)
        
        waitForExpectations(timeout: 5)
        
        let result = try XCTUnwrap(result)

        XCTAssertEqual(result, "Hello, World")
    }
    
    func testWithReturnBool() throws {
        expectation = expectation(description: "perform JS code")
        service.script = "function main() { return true } main();"
        service.loadHTMLString("<h1 id=\"test\">Hello, World</h1>", baseURL: nil)
        
        waitForExpectations(timeout: 5)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        service.script = "function main() { return document.querySelector('#test').innerHTML } main();"
        
        measure {
            for _ in 0..<10 {
                expectation = expectation(description: "perform JS code")
                service.loadHTMLString("<h1 id=\"test\">Hello, World!</h1>", baseURL: nil)
                
                waitForExpectations(timeout: 5)
            }
        }
    }
}


extension WebDomHandlingTests: WebDomServiceDelegate {
    func webView(_ webView: WKWebView, didFinishEvaluateJavaScript result: String) {
        self.result = result
        expectation?.fulfill()
    }
    
    func webView(_ webView: WKWebView, didFailEvaluateJavaScript error: Error) {
        print(error.localizedDescription)
        expectation?.fulfill()
    }
}
