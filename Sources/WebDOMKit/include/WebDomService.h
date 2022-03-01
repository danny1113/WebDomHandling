//
//  WebDomService.h
//  
//
//  Created by Danny on 2022/2/28.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#import "WebDomServiceDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebDomService: NSObject <WKNavigationDelegate>

@property (nonatomic, readonly, copy, nonnull) WKWebView *webView;
@property (nonatomic, weak, nullable) id<WebDomServiceDelegate> delegate;

@property (nonatomic) NSString *script;


// initializer
- (instancetype)init;
- (instancetype)initWithResource:(NSString *)resource;

- (void)setupWebView;

- (void)loadJavaScriptStringForResource:(NSString *)resource;
- (void)load:(NSString *)urlString;
- (void)loadHTMLString:(NSString *)htmlString baseURL:(NSURL * _Nullable)base;

- (void)evaluateCompletionHandler:(id _Nullable)result error:(NSError * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
