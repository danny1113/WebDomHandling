//
//  WebDOMKitTests.m
//  
//
//  Created by Danny on 2022/2/28.
//

#import <XCTest/XCTest.h>
#import <WebKit/WebKit.h>

#import "WebDomService.h"


@interface WebDOMKitTests : XCTestCase <WebDomServiceDelegate>

@property (nonatomic) XCTestExpectation *expectation;
@property (nonatomic) WebDomService *service;
@property (nonatomic) NSString *result;

@end

@implementation WebDOMKitTests

@synthesize service;
@synthesize expectation;
@synthesize result;


- (void)setUp {
    service = [[WebDomService alloc]init];
    service.delegate = self;
}

- (void)tearDown {
    
}

- (void)testWithReturnNSString {
    expectation = [self expectationWithDescription:@"testWithReturnNSString"];
    [service setScript:@"function main() { return document.querySelector('#test').innerHTML } main();"];
    [service loadHTMLString:@"<h1 id=\"test\">Hello, World</h1>" baseURL:nil];
    
    [self waitForExpectations:@[expectation] timeout:1];
    XCTAssertEqualObjects(result, @"Hello, World");
}

- (void)testWithReturnInvaildValue {
    expectation = [self expectationWithDescription:@"testWithReturnInvaildValue"];
    [service setScript:@"function main() { return true } main();"];
    [service loadHTMLString:@"<h1 id=\"test\">Hello, World</h1>" baseURL:nil];
    
    [self waitForExpectations:@[expectation] timeout:1];
}

- (void)testWithRemoteURL {
    expectation = [self expectationWithDescription:@"testWithRemoteURL"];
    [service setScript:@"function main() { return document.documentElement.outerHTML } main();"];
    [service load:@"https://www.google.com"];
    
    [self waitForExpectations:@[expectation] timeout:10];
}

- (void)testPerformanceExample {
    [service setScript:@"function main() { return document.querySelector('#test').innerHTML } main();"];
    
    [self measureBlock:^{
        for (int i=0; i<10; i++) {
            expectation = [self expectationWithDescription:@"testPerformanceExample"];
            [service loadHTMLString:@"<h1 id=\"test\">Hello, World!</h1>" baseURL:nil];
            
            [self waitForExpectations:@[expectation] timeout:1];
        }
    }];
}


// delegate implementation
- (void)webView:(WKWebView *)webView didFinishEvaluateJavaScript:(NSString *)result {
    self.result = result;
    NSLog(@"%@", result);
    [expectation fulfill];
}

- (void)webView:(WKWebView *)webView didFailEvaluateJavaScript:(NSError *)error {
    if (error)
        NSLog(@"%@", error);
    else
        NSLog(@"%@", @"error is nil.");
    [expectation fulfill];
}

@end
