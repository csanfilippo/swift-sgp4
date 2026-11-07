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

/// Encodes a `TLE` model into ASCII `Data`.
///
/// The resulting `Data` is the title, first line and second line of the TLE, separated by
/// newlines and encoded as ASCII. If ASCII encoding fails, an error is thrown.
///
/// Usage:
/// ```swift
/// let encoder = TLEEncoder()
/// let data = try encoder.encode(tle)
/// ```
public final class TLEEncoder: Sendable {
    
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
    /// - Throws: `TLEEncoder.Error.cannotEncodeInASCII` if ASCII conversion fails.
    public func encode(_ tle: TLE) throws -> Data {
        let text = [tle.title, tle.firstLine, tle.secondLine].joined(separator: "\n")

        guard let data = text.data(using: .ascii) else {
            throw Error.cannotEncodeInASCII
        }

        return data
    }
}
