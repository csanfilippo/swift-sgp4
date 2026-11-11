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

public struct TLEDecodingReport: Sendable {

    public struct RejectedSet: Sendable {

        public enum Reason: Sendable {
            case invalidLineLength
            case missingSecondLine
        }

        public let reason: Reason
    }

    public let tles: [TLE]
    public let rejections: [RejectedSet]
}

/// A decoder that parses a Two-Line Element set (TLE) from an ASCII data buffer into a `TLE`.
///
/// A TLE consists of three lines:
/// 1. A title line (name)
/// 2. Line 1 (69 characters)
/// 3. Line 2 (69 characters)
///
/// This decoder validates the basic TLE constraints (ASCII encoding, line count, and line lengths)
/// and surfaces failures as `DecodingError` values whose underlying error is `TLEDecoder.Error`.
public final class TLEDecoder: Sendable {

    private struct CandidateSet {
        let title: String
        let firstLine: String?
        let secondLine: String?
    }

    /// Errors that can occur while validating raw TLE input.
    public enum Error: Swift.Error, Equatable {

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
        let lines = try textLines(in: data)

        guard lines.count == 3 else {
            throw corruptedData(.wrongLineCount(lines.count))
        }

        return try tle(title: lines[0], firstLine: lines[1], secondLine: lines[2])
    }
    
    /// Decodes one or more TLEs from an ASCII buffer.
    ///
    /// The buffer must contain a multiple of three non-empty lines, where each group of three
    /// represents a single TLE: a title line followed by two 69-character data lines.
    ///
    /// - Parameter data: The raw ASCII-encoded bytes containing one or more TLE triplets.
    /// - Returns: An array of `TLE` values parsed in order.
    /// - Throws: `DecodingError` if the buffer cannot be decoded as ASCII, contains no lines,
    ///   the number of lines is not a multiple of three, or any TLE line fails basic validation.
    ///   The underlying error is a `TLEDecoder.Error` describing the specific reason.
    public func decodeCollection(_ data: Data) throws -> [TLE] {
        let lines = try textLines(in: data)

        guard !lines.isEmpty, lines.count % 3 == 0 else {
            throw corruptedData(.wrongLineCount(lines.count))
        }

        return try stride(from: 0, to: lines.count, by: 3).map { start in
            try tle(title: lines[start], firstLine: lines[start + 1], secondLine: lines[start + 2])
        }
    }

    private func line(at cursor: Int, in lines: [String], withPrefix prefix: String) -> String? {
        guard cursor < lines.count else {
            return nil
        }

        let line = lines[cursor]

        return line.hasPrefix(prefix) ? line : nil
    }

    private func candidateSets(in lines: [String]) -> [CandidateSet] {
        var candidateSets: [CandidateSet] = []

        var cursor = 0

        repeat {
            let title = lines[cursor]

            cursor += 1

            let firstLine = line(at: cursor, in: lines, withPrefix: "1 ")
            if firstLine != nil { cursor += 1 }
            let secondLine = line(at: cursor, in: lines, withPrefix: "2 ")
            if secondLine != nil { cursor += 1 }

            candidateSets.append(.init(title: title, firstLine: firstLine, secondLine: secondLine))
        } while cursor < lines.count

        return candidateSets
    }

    public func decodeValidSets(_ data: Data) throws -> TLEDecodingReport {
        let lines = try textLines(in: data)

        guard !lines.isEmpty else {
            return .init(tles: [], rejections: [])
        }

        var rejections: [TLEDecodingReport.RejectedSet] = []
        var tles: [TLE] = []

        for candidateSet in candidateSets(in: lines) {
            do {
                if candidateSet.secondLine == nil {
                    rejections.append(.init(reason: .missingSecondLine))
                    continue
                }

                if let firstLine = candidateSet.firstLine, let secondLine = candidateSet.secondLine {
                    let tle = try TLE(title: candidateSet.title, firstLine: firstLine, secondLine: secondLine)
                    tles.append(tle)
                }
            } catch TLEError.linesMustBeSixNineCharactersLong {
                rejections.append(.init(reason: .invalidLineLength))
            }
        }

        return .init(tles: tles, rejections: rejections)
    }

    private func textLines(in data: Data) throws -> [String] {
        guard let text = String(data: data, encoding: .ascii) else {
            throw corruptedData(.encodingError)
        }

        return text
            .split(whereSeparator: { $0.isNewline })
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func tle(title: String, firstLine: String, secondLine: String) throws -> TLE {
        do {
            return try TLE(title: title, firstLine: firstLine, secondLine: secondLine)
        } catch TLEError.linesMustBeSixNineCharactersLong {
            throw corruptedData(.invalidLineLength)
        }
    }

    private func corruptedData(_ reason: Error) -> DecodingError {
        .dataCorrupted(.init(codingPath: [], debugDescription: "The provided data is not a valid TLE.", underlyingError: reason))
    }
}
