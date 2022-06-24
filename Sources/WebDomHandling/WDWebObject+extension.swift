//
//  WDWebObject+extension.swift
//  
//
//  Created by Danny on 2022/2/4.
//

import WebKit


extension WDWebObject {
    
    public enum WDError: Error, LocalizedError {
        
        case cantConvertToURL
        case cantConvertResultToString
        case cantConvertToData
        
        public var errorDescription: String? {
            switch self {
            case .cantConvertToURL:
                return NSLocalizedString("Can't convert String to URL.", comment: "Can't convert String to URL.")
            case .cantConvertResultToString:
                return NSLocalizedString("Can't convert to String.\nIf you are returning a JSON from JavaScript, please use JSON.stringify() before data return to Swift.", comment: "Can't convert to String.\nIf you are returning a JSON from JavaScript, please use JSON.stringify() before data return to Swift.")
            case .cantConvertToData:
                return NSLocalizedString("An error occured when convert String to Data.", comment: "Can't convert String to Data.")
            }
        }
    }
    
    /// Returns a value of the type you specify, decoded from a JSON object.
    /// - Parameters:
    ///     - type: The type of the value to decode from the supplied JSON object.
    ///     - from: The JSON object to decode.
    /// - Returns: A value of the specified type, if the decoder can parse the data.
    @inlinable
    public func decode<T: Decodable>(_ type: T.Type = T.self, from data: Data) throws -> T {
        return try self.decoder.decode(T.self, from: data)
    }
    
    /// Returns a value of the type you specify, decoded from a JSON object.
    /// - Parameters:
    ///     - type: The type of the value to decode from the supplied JSON object.
    ///     - jsonString: The JSON object to decode.
    /// - Returns: A value of the specified type, if the decoder can parse the data.
    @inlinable
    public func decode<T: Decodable>(_ type: T.Type = T.self, jsonString: String) throws -> T {
        guard let data = jsonString.data(using: .utf8) else {
            throw WDError.cantConvertToData
        }
        
        return try self.decoder.decode(T.self, from: data)
    }
    
    /// Remove cache from HTTPCookieStorage, URLCache, WKWebsiteDataStore
    @MainActor
    public func removeCache() {
        /// old API cookies
        for cookie in HTTPCookieStorage.shared.cookies ?? [] {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
        /// URL cache
        URLCache.shared.removeAllCachedResponses()
        /// WebKit cache
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: date,
            completionHandler: {}
        )
    }
    
}


// MARK: -

extension WDWebObject {
    static public let GetHTMLString = "function main() { return document.documentElement.outerHTML } main();"
}
