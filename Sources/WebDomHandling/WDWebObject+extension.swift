//
//  WDWebObject+extension.swift
//  
//
//  Created by Danny on 2022/2/4.
//

import WebKit


extension WDWebObject {
    
    public enum DecodeError: Error, LocalizedError {
        case CantConvertToData
        
        public var errorDescription: String? {
            switch self {
            case .CantConvertToData:
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
            throw DecodeError.CantConvertToData
        }
        
        return try self.decoder.decode(T.self, from: data)
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
