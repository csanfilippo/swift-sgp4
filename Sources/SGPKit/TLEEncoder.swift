/*
 MIT License

 Copyright (c) 2025 Calogero Sanfilippo

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
*/

/// TLEEncoder
///
/// Provides an `Encoder` implementation specialized for Two-Line Element (TLE) sets.
/// `TLEEncoder` produces ASCII-encoded `Data` consisting of the lines emitted by a `TLE` value
/// conforming to `Encodable`. The encoder collects line strings from keyed containers and joins
/// them with newlines. Arrays and single value containers are intentionally unsupported.
import Foundation

/// Encodes a `TLE` model into ASCII `Data`.
///
/// This encoder expects the `TLE` type to encode itself using a keyed container that writes
/// fully formatted TLE lines as `String` values. The resulting `Data` is the newline-separated
/// concatenation of those strings, encoded as ASCII. If ASCII encoding fails, an error is thrown.
///
/// Usage:
/// ```swift
/// let encoder = TLEEncoder()
/// let data = try encoder.encode(tle)
/// ```
public final class TLEEncoder {
    
    /// Errors that can occur during TLE encoding.
    public enum Error: Swift.Error {
        /// The produced string could not be represented using ASCII encoding.
        case cannotEncodeInASCII
    }
    
    /// Creates a new TLE encoder.
    public init() { }
    
    /// Encodes the given `TLE` value into ASCII data.
    ///
    /// - Parameter tle: The TLE instance to encode.
    /// - Returns: Newline-separated ASCII `Data` representing the encoded TLE lines.
    /// - Throws: `TLEEncoder.Error.cannotEncodeInASCII` if ASCII conversion fails, or any error thrown by the `TLE` while encoding itself.
    public func encode(_ tle: TLE) throws -> Data {
        
        let encoding = TLEEncoding()
        
        try tle.encode(to: encoding)
        
        guard let data: Data = encoding.data.strings.joined(separator: "\n").data(using: .ascii) else {
            throw Error.cannotEncodeInASCII
        }
        
        return data
    }
}

/// Internal `Encoder` that collects string lines for TLE output.
///
/// Only keyed containers are supported; unkeyed and single-value containers will trap.
private struct TLEEncoding: Encoder {
    var codingPath: [any CodingKey] = []
    
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    /// Accumulates encoded TLE lines prior to joining into the final payload.
    final class Data {
        private(set) var strings: [String] = []
        
        /// Appends a single TLE line string.
        func encode(value: String) {
            strings.append(value)
        }
    }
    
    var data: Data
    
    init(to encodedData: Data = Data()) {
        self.data = encodedData
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = TLEEncodingContainer<Key>(to: data)
        container.codingPath = codingPath
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> any UnkeyedEncodingContainer {
        // TLE format is line-based and does not support arrays.
        fatalError("TLEEncoding does not support unkeyed containers (arrays).")
    }
    
    func singleValueContainer() -> any SingleValueEncodingContainer {
        // TLE format requires keyed lines; single values are not supported.
        fatalError("TLEEncoding does not support single value containers.")
    }
}


/// Keyed encoding container that records only `String` values as lines.
/// Other value types are ignored, and unsupported container operations will trap.
private final class TLEEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    
    var codingPath: [any CodingKey] = []
    
    private let data: TLEEncoding.Data
    
    init(to data: TLEEncoding.Data) {
        self.data = data
    }
    
    func encodeNil(forKey key: Key) throws {}
    
    /// Records a line by appending the provided string to the output.
    func encode(_ value: String, forKey key: Key) throws {
        data.encode(value: value)
    }
    func encode(_ value: Bool, forKey key: Key) throws {}
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable { }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        // Nested keyed containers are not meaningful for flat TLE output.
        fatalError("Unkeyed encoding not implemented")
    }

    func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
        // Unkeyed containers (arrays) are not supported in TLE output.
        fatalError("Unkeyed encoding not implemented")
    }
    
    func superEncoder() -> any Encoder {
        // Super encoding is not applicable for this flat encoding format.
        fatalError("superEncoder not implemented")
    }
    
    func superEncoder(forKey key: Key) -> any Encoder {
        // Super encoding with key is not applicable for this flat encoding format.
        fatalError("superEncoder(forKey:) not implemented")
    }
    
}

