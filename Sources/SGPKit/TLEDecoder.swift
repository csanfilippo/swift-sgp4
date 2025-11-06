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

import Foundation

/// A decoder that parses a Two-Line Element set (TLE) from an ASCII data buffer into a `TLE`.
///
/// A TLE consists of three lines:
/// 1. A title line (name)
/// 2. Line 1 (69 characters)
/// 3. Line 2 (69 characters)
///
/// This decoder validates the basic TLE constraints (ASCII encoding, line count, and line lengths)
/// and surfaces failures as `DecodingError` values whose underlying error is `TLEDecoder.Error`.
public final class TLEDecoder {
    
    /// Errors that can occur while validating raw TLE input.
    enum Error: Swift.Error, Equatable {

        /// The provided data buffer is not ASCII‑encoded.
        case encodingError

        /// The buffer contains the wrong number of lines (expected 3: title + 2 data lines).
        case wrongLineCount(Int)

        /// One or both TLE data lines are not exactly 69 characters in length.
        case invalidLineLength
    }
    
    /// Creates a new TLE decoder.
    public init() {}
    
    /// Decodes a single TLE from an ASCII buffer.
    ///
    /// - Parameter data: The raw ASCII-encoded bytes containing exactly three non-empty lines:
    ///   a title line followed by the two 69-character TLE lines.
    /// - Returns: A `TLE` parsed from the buffer.
    /// - Throws: `DecodingError` if the buffer cannot be decoded as ASCII, does not contain
    ///   exactly three lines, or if the TLE lines do not meet length constraints. The
    ///   underlying error is a `TLEDecoder.Error` describing the specific reason.
    public func decode(_ data: Data) throws -> TLE {
        let decoder = TLEDecoding(data: data)
        
        return try TLE(from: decoder)
    }
    
    /// Decodes one or more TLEs from an ASCII buffer.
    ///
    /// The buffer must contain a multiple of three non-empty lines, where each group of three
    /// represents a single TLE: a title line followed by two 69-character data lines.
    ///
    /// - Parameter data: The raw ASCII-encoded bytes containing one or more TLE triplets.
    /// - Returns: An array of `TLE` values parsed in order.
    /// - Throws: `DecodingError` if the buffer cannot be decoded as ASCII, the number of lines
    ///   is not a multiple of three, or any TLE line fails basic validation. The underlying
    ///   error is a `TLEDecoder.Error` describing the specific reason.
    public func decodeCollection(_ data: Data) throws -> [TLE] {
        let decoder = TLEDecoding(data: data)
        
        return try [TLE](from: decoder)
    }
}

private final class TLEDecoding: Decoder {
    var codingPath: [any CodingKey] = []
    
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    private let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        throw DecodingError.typeMismatch(
            KeyedDecodingContainer<Key>.self,
            .init(
                codingPath: codingPath,
                debugDescription: "TLEDecoding does not support keyed decoding."
            )
        )
    }
    
    func singleValueContainer() throws -> any SingleValueDecodingContainer {
        throw DecodingError.dataCorrupted(
            DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "TLEDecoding does not support single-value decoding."
            )
        )
    }
    
    func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
        try TLEDecodingUnkeyedContainer(data: data)
    }
}

private final class TLEDecodingUnkeyedContainer: UnkeyedDecodingContainer {
   
    private(set) var codingPath: [any CodingKey] = []
    
    let count: Int?
    
    private(set) var isAtEnd: Bool = false
    
    private(set) var currentIndex: Int = 0
    
    private let lines: [String]
    
    init(data: Data) throws {
                
        guard let parsed = String(data: data, encoding: .ascii) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data is not decodable to ascii.", underlyingError: TLEDecoder.Error.encodingError))
        }
        
        lines = parsed
            .split(whereSeparator: {$0.isNewline})
            .map({ String($0).trimmingCharacters(in: .whitespacesAndNewlines) })
            .filter { $0.count > 0 }
        
        guard lines.count % 3 == 0 else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data is not decodable to ascii.", underlyingError: TLEDecoder.Error.wrongLineCount(lines.count)))
        }
        
        count = lines.count / 3
    }
    
    func decodeNil() throws -> Bool {
        false
    }
    
    func decode(_ type: String.Type) throws -> String {
        
        guard lines.count == 3 else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data is not decodable.", underlyingError: TLEDecoder.Error.wrongLineCount(lines.count)))
        }
        
        let currentLine = lines[currentIndex]
        
        if currentIndex > 0 && currentLine.count != 69 {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data is not a valid TLE.", underlyingError: TLEDecoder.Error.invalidLineLength))
        }
        
        currentIndex += 1
        
        if let count, currentIndex == count {
            isAtEnd = true
        }
        
        return currentLine
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        
        guard type == TLE.self else {
            throw DecodingError.typeMismatch(type, .init(codingPath: [], debugDescription: "Unsupported type for TLE: \(type)"))
        }
        
        let title = lines[3 * currentIndex]
        let firstLine = lines[3 * currentIndex + 1]
        let secondLine = lines[3 * currentIndex + 2]
        
        guard firstLine.count == 69, secondLine.count == 69 else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "The provided data is not a valid TLE.", underlyingError: TLEDecoder.Error.invalidLineLength))
        }
        
        let tle = try TLE(
            title: title,
            firstLine: firstLine,
            secondLine: secondLine
        )
        
        currentIndex += 1
        
        if currentIndex == count! {
            isAtEnd = true
        }
        
        return tle as! T
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("Nested containers not supported for TLE")
    }
    
    func nestedUnkeyedContainer() throws -> any UnkeyedDecodingContainer {
        fatalError("Nested unkeyed containers not supported for TLE")
    }
    
    func superDecoder() throws -> any Decoder {
        fatalError("Nested containers not supported for TLE")
    }
}
