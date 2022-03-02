
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


extension WebDOMKitTests: WebDomServiceDelegate {
    func webView(_ webView: WKWebView, didFinishEvaluateJavaScript result: String) {
        self.result = result
        expectation?.fulfill()
    }
    
    func webView(_ webView: WKWebView, didFailEvaluateJavaScript error: Error) {
        print(error.localizedDescription)
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
        cancellable = service.finishEvaluatePublisher
            .sink { [weak self] (result, error) in
                self?.result = result
                self?.expectation?.fulfill()
                print("result: \(result ?? error?.localizedDescription ?? "nil")")
            }
    }
    
    override func tearDown() {
        
    }
    
    func testWithReturnString() throws {
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
        service.script = "function main() { return document.querySelector('#test').innerHTML } main();"
        
        measure {
//            for _ in 0..<10 {
                expectation = expectation(description: "perform JS code")
                service.loadHTMLString("<h1 id=\"test\">Hello, World!</h1>", baseURL: nil)
                
                waitForExpectations(timeout: 5)
//            }
        }
    }
}
