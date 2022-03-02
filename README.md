
# WebDomHandling

WebDomHandling is a Swift Package for handling JavaScript code between WebKit and Swift implemented by WebKit.


# Quick Start

> **Important:** You have to set delegate to able to handle the result and error return from `WKWebView`.

You can initialize the webObject for JavaScript environment by calling:

```swift
import WebDomHandling

let webObject = WDWebObject()
webObject.delegate = self
```

Or yu can call initialize it with a source of JavaScript code and website URL:

```swift
let webObject = WDWebObject(
    forResource: "path/of/your/JavaScript-Code",
    url: "https://url/to/your/websites")
```

> **Note:** `forResource` **doesn't need extension name.**
> You just need to type your filename.
>
> **Example:** `WDWebObject(forResource: "script")`

You can use `finishEvaluatePublisher` or use [`WDWebObjectDelegate`](#WDWebObjectDelegate) to receive value and error return from JavaScript:

```swift
cancellable = service.finishEvaluatePublisher
    .sink { (result, error) in
        if let error = error {
            print(error)
            return
        }
        
        if let result = result {
            self.result = result
        }
    }
```

You can also create a subclass with the following code:

```swift
class ExampleWebObject: WDWebObject, WDWebObjectDelegate {
    
    override init() {
        super.init()
        
        delegate = self

        loadJavaScriptString(forResource: "script")
        load("https://url/to/your/websites")
    }

    // Protocol implementation.
    func webView(_ webView: WKWebView, didFinishEvaluateJavaScript result: String) {
        // handle result...
    }
    
    func webView(_ webView: WKWebView, didFailEvaluateJavaScript error: String) {
        // handle error...
    }
}
```

## WDWebObjectDelegate

`WDWebObjectDelegate` is a protocol for handling result and error return from the WKWebView’s JavaScript environment. And it has 2 functions:

- `func webView(_ webView: WKWebView, didFinishEvaluateJavaScript result: String)` for handling result return from `WKWebView`.
- `func webView(_ webView: WKWebView, didFailEvaluateJavaScript error: String)` for handling error return from `WKWebView`.

> **Note:** For example of delegate implementation, check [Example.swift](Sources/WebDomHandling/Example.swift), this example shows how to implement delegation in SwiftUI.
