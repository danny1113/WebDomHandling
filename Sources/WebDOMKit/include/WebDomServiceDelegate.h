//
//  WebDomServiceDelegate.h
//  
//
//  Created by Danny on 2022/2/28.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WebDomServiceDelegate <NSObject>

@required
- (void)webView:(WKWebView *)webView didFinishEvaluateJavaScript:(NSString *)result;
- (void)webView:(WKWebView *)webView didFailEvaluateJavaScript:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
