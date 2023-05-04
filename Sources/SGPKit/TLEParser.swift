/*
 MIT License

 Copyright (c) 2022 Calogero Sanfilippo

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

/// A TLE parser
public final class TLEParser {

    /// Describes all the possible errors that can be thrown while parsing
    public enum Error: Swift.Error {

        /// Raised if the buffer is empty
        case empty

        /// Raised if the buffer is not ASCII encoded
        case encodingError

        /// Raised if the TLE set contains the wrong number of lines
        case wrongLineCount(Int)

        /// Raised if the line length of the TLE is not 69
        case invalidLineLength
    }

    /// Parses a buffer into a TLE model
    ///
    /// - Parameter data: the buffer to parse
    /// - Returns: a TLE model
    /// - Throws: TLEParser.Error
    public func parse(_ data: Data) throws -> TLE {
        guard !data.isEmpty else {
            throw Error.empty
        }

        guard let string = String(data: data, encoding: .ascii) else {
            throw Error.encodingError
        }

        let lines = string
            .components(separatedBy: "\n")
            .map({ String($0).trimmingCharacters(in: .whitespacesAndNewlines) })
            .filter { $0.count > 0 }

        guard lines.count == 3  else {
            throw Error.wrongLineCount(lines.count)
        }

		let allSatisfyingLineLength = lines[1...].allSatisfy { $0.count == 69 }

        guard allSatisfyingLineLength else {
            throw Error.invalidLineLength
        }

        return TLE(
            title: lines[0],
            firstLine: lines[1],
            secondLine: lines[2]
        )
    }

    public func parseCollection(_ data: Data, encoding: String.Encoding = .ascii) throws -> [TLE] {
        guard !data.isEmpty else { throw Error.empty }
        guard let dataString = String(data: data, encoding: encoding) else {
            throw Error.encodingError
        }

        let lines = dataString
            .split(whereSeparator: { elem in
                elem.isNewline
            })
            .map({ String($0).trimmingCharacters(in: .whitespacesAndNewlines) })
            .filter { $0.count > 0 }

        if lines.count % 3 != 0 { throw Error.invalidLineLength }
        
        let elements = lines.chunked(into: 3)
        let tles = elements.map({ TLE(title: $0[0], firstLine: $0[1], secondLine: $0[2]) })
        return tles
    }
}
