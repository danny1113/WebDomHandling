//
//  WDWebObject+extension.swift
//  
//
//  Created by Danny on 2022/2/4.
//

import WebKit


extension WDWebObject {
    
    enum DecodeError: Error {
        case CantConvertToData
    }
    
    /// Returns a value of the type you specify, decoded from a JSON object.
    /// - Parameters:
    ///     - type: The type of the value to decode from the supplied JSON object.
    ///     - from: The JSON object to decode.
    /// - Returns: A value of the specified type, if the decoder can parse the data.
    public func decode<T: Decodable>(_ type: T.Type = T.self, from data: Data) throws -> T {
        
        let result = try self.decoder.decode(T.self, from: data)
        
        return result
    }
    
    /// Returns a value of the type you specify, decoded from a JSON object.
    /// - Parameters:
    ///     - type: The type of the value to decode from the supplied JSON object.
    ///     - jsonString: The JSON object to decode.
    /// - Returns: A value of the specified type, if the decoder can parse the data.
    public func decode<T: Decodable>(_ type: T.Type = T.self, jsonString: String) throws -> T {
        guard let data = jsonString.data(using: .utf8) else {
            throw DecodeError.CantConvertToData
        }
        
        let result = try self.decoder.decode(T.self, from: data)
        
        return result
    }
    
    /// Remove cache from HTTPCookieStorage, URLCache, WKWebsiteDataStore
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
