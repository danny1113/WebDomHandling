//
//  WebDOMKitTests.m
//  
//
//  Created by Danny on 2022/2/28.
//

#import <XCTest/XCTest.h>
#import <WebKit/WebKit.h>

#import "WebDomService.h"


#define HTMLString @"<h1 id=\"test\">Hello, World</h1>"

#define javaScriptReturnNSString @"function main() { return document.querySelector('#test').innerHTML } main();"

#define javaScriptReturnInvaildValue @"function main() { return true } main();"

#define javaScriptReturnHTMLBody @"function main() { return document.documentElement.outerHTML } main();"

#define PERFORMANCE_TEST_COUNT 10


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
    [service setScript:javaScriptReturnNSString];
    [service loadHTMLString:HTMLString baseURL:nil];
    
    [self waitForExpectations:@[expectation] timeout:3];
    XCTAssertEqualObjects(result, @"Hello, World");
}

- (void)testWithReturnInvaildValue {
    expectation = [self expectationWithDescription:@"testWithReturnInvaildValue"];
    [service setScript:javaScriptReturnInvaildValue];
    [service loadHTMLString:HTMLString baseURL:nil];
    
    [self waitForExpectations:@[expectation] timeout:3];
}

- (void)testRetainCycle {
    expectation = [self expectationWithDescription:@"testRetainCycle"];
    [service setScript:javaScriptReturnInvaildValue];
    [service loadHTMLString:HTMLString baseURL:nil];
    
    [self waitForExpectations:@[expectation] timeout:3];
    
    service = nil;
    XCTAssertNil(service);
}

- (void)testWithRemoteURL {
    expectation = [self expectationWithDescription:@"testWithRemoteURL"];
    [service setScript:javaScriptReturnHTMLBody];
    [service load:@"https://www.google.com"];
    
    [self waitForExpectations:@[expectation] timeout:10];
}

- (void)testPerformanceExample {
    [service setScript:javaScriptReturnNSString];
    
    [self measureBlock:^{
        for (int i=0; i<PERFORMANCE_TEST_COUNT; i++) {
            expectation = [self expectationWithDescription:@"testPerformanceExample"];
            [service loadHTMLString:HTMLString baseURL:nil];
            
            [self waitForExpectations:@[expectation] timeout:3];
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
