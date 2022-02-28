//
//  WebDOMKitTests.m
//  
//
//  Created by Danny on 2022/2/28.
//

#import <XCTest/XCTest.h>
#import <WebKit/WebKit.h>

#import "WebDomServices.h"


@interface WebDOMKitTests : XCTestCase <WebDomServicesDelegate>

@property XCTestExpectation *expectation;
@property WebDomServices *service;
@property NSString *result;

@end

@implementation WebDOMKitTests

@synthesize service;
@synthesize expectation;
@synthesize result;


- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    service = [[WebDomServices alloc]init];
    service.delegate = self;
    service.script = @"function main() { return document.querySelector('#test').innerHTML } main();";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    expectation = [self expectationWithDescription:@"perform JS code"];
    [service loadHTMLString:@"<h1 id=\"test\">Hello, World!</h1>" baseURL:nil];
    
    [self waitForExpectations:@[expectation] timeout:5];
    XCTAssertEqualObjects(result, @"Hello, World!");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for (int i=0; i<500; i++) {
            expectation = [self expectationWithDescription:@"perform JS code"];
            [service loadHTMLString:@"<h1 id=\"test\">Hello, World!</h1>" baseURL:nil];
            [self waitForExpectations:@[expectation] timeout:5];
        }
    }];
}


// delegate implementation
- (void)webView:(WKWebView *)webView didFinishEvaluateJavaScript:(NSString *)result {
    self.result = result;
    [expectation fulfill];
}

- (void)webView:(WKWebView *)webView didFailEvaluateJavaScript:(NSError *)error {
    if (error)
        NSLog(@"%@", error);
    else
        NSLog(@"%@", @"error is nil.");
}

@end
