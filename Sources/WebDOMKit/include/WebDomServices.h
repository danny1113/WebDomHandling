//
//  WebDomServices.h
//  
//
//  Created by Danny on 2022/2/28.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#import "WebDomServicesDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebDomServices: NSObject <WKNavigationDelegate>

@property (nonatomic, readonly, copy, nonnull) WKWebView *webView;
@property (nonatomic, weak, nullable) id<WebDomServicesDelegate> delegate;

@property (nonatomic) NSString *script;

// initializer
- (instancetype)init;
- (instancetype)initWithResource:(NSString *)resource;
- (instancetype)initWithResource:(NSString *)resource url:(NSString *)url;
- (instancetype)initWithJavaScriptString:(NSString *)script url:(NSString * _Nullable)url;


- (void)setupWebView;

- (void)loadURLString:(NSString *)urlString;
- (void)loadHTMLString:(NSString *)htmlString baseURL:(NSURL * _Nullable)base;

- (void)evaluateCompletionHandler:(id _Nullable)result error:(NSError * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
