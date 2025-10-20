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

/// A parser for Two‑Line Element (TLE) sets.
///
/// This parser accepts an ASCII‑encoded buffer that contains exactly three lines:
/// a title line followed by two TLE lines. It validates that each of the two
/// TLE lines has a length of 69 characters, as specified by the TLE format, and
/// returns a `TLE` value on success or throws a `TLEParser.Error` on failure.
public final class TLEParser: Sendable {

    /// Errors that can be thrown while parsing a TLE set.
    public enum Error: Swift.Error {

        /// The provided data buffer is empty.
        case empty

        /// The provided data buffer is not ASCII‑encoded.
        case encodingError

        /// The buffer contains the wrong number of lines. Expected 3 (title + 2 data lines).
        case wrongLineCount(Int)

        /// One or both TLE data lines do not have the required length of 69 characters.
        case invalidLineLength
    }

    /// Parses an ASCII buffer containing a single TLE set into a `TLE` value.
    ///
    /// The input must contain exactly three newline‑separated lines:
    /// 1) a title line, 2) line 1 of the TLE, and 3) line 2 of the TLE. The two TLE lines
    /// must each be exactly 69 characters long. Leading and trailing newlines in the buffer
    /// are ignored.
    ///
    /// - Parameter data: The raw buffer to parse. Must be ASCII‑encoded.
    /// - Returns: A fully‑validated `TLE` containing the title and both TLE lines.
    /// - Throws: A `TLEParser.Error` describing the validation failure:
    ///   - `.empty` if `data` is empty
    ///   - `.encodingError` if `data` is not ASCII‑encoded
    ///   - `.wrongLineCount` if the buffer does not contain exactly three lines
    ///   - `.invalidLineLength` if either TLE line is not exactly 69 characters
    ///
    /// - Note: This method does not verify TLE checksums or semantic content beyond
    ///   line count and line length; perform additional validation if required.
    ///
    /// - Example:
    /// ```swift
    /// let parser = TLEParser()
    /// let tle = try parser.parse(tleData)
    /// print(tle.title)
    /// ```
    public func parse(_ data: Data) throws -> TLE {
        guard !data.isEmpty else {
            throw Error.empty
        }

        guard let string = String(data: data, encoding: .ascii) else {
            throw Error.encodingError
        }

        let lines = string
            .trimmingCharacters(in: .newlines)
			.split(separator: "\n")
			.map({ String($0) })

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
}
