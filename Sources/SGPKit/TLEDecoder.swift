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
/// A TLE consists of up to three lines:
/// 1. An optional title line (name)
/// 2. Line 1 (69 characters)
/// 3. Line 2 (69 characters)
///
/// This decoder validates the basic TLE constraints (ASCII encoding, line count, and line lengths)
/// and surfaces failures as `DecodingError` values whose underlying error is `TLEDecoder.Error`.
public final class TLEDecoder: Sendable {

    private struct Line {
        enum Kind {
            case title, firstLine, secondLine
        }

        let value: String
        /// The 1-based line in the input, counting blank lines.
        let lineNumber: Int

        var kind: Kind {
            if value.hasPrefix("1 ") { return .firstLine }
            if value.hasPrefix("2 ") { return .secondLine }
            return .title
        }
    }

    private struct CandidateSet {
        enum Outcome {
            case decoded(TLE)
            case rejected(TLEDecodingReport.RejectedSet)
        }

        let title: Line?
        let dataLines: [Line]
        let lineNumber: Int

        func decode() -> Outcome {
            switch (title, firstLine, secondLine) {
            case (_?, nil, nil):
                return rejected(for: .missingDataLines)
            case (_, nil, _):
                return rejected(for: .missingFirstLine)
            case (_, _, nil):
                return rejected(for: .missingSecondLine)
            case (_, _?, _?) where isOutOfOrder:
                return rejected(for: .dataLinesOutOfOrder)
            case let (title, firstLine?, secondLine?):
                do {
                    return .decoded(try TLE(title: title?.value ?? "", firstLine: firstLine.value, secondLine: secondLine.value))
                } catch {
                    return rejected(for: .invalidLineLength)
                }
            }
        }

        private var firstLine: Line? {
            dataLines.first { $0.kind == .firstLine }
        }

        private var secondLine: Line? {
            dataLines.first { $0.kind == .secondLine }
        }

        private var isOutOfOrder: Bool {
            dataLines.first?.kind == .secondLine && firstLine != nil
        }

        private func rejected(for reason: TLEDecodingReport.RejectedSet.Reason) -> Outcome {
            .rejected(.init(reason: reason, title: title?.value, lineNumber: lineNumber))
        }
    }

    /// Errors that can occur while validating raw TLE input.
    public enum Error: Swift.Error, Equatable {

        /// The provided data buffer is not ASCII‑encoded.
        case encodingError

        /// The buffer contains the wrong number of lines: ``TLEDecoder/decode(_:)`` expects 2 or 3,
        /// ``TLEDecoder/decodeCollection(_:)`` a non-zero multiple of 3.
        case wrongLineCount(Int)

        /// One or both TLE data lines are not exactly 69 characters in length.
        case invalidLineLength
    }
    
    /// Creates a new TLE decoder.
    public init() {}
    
    /// Decodes a single TLE from an ASCII buffer.
    ///
    /// - Parameter data: The raw ASCII-encoded bytes containing either three non-empty lines,
    ///   a title line followed by the two 69-character TLE lines, or just the two TLE lines.
    ///   Without a title line, the decoded TLE's ``TLE/title`` is empty.
    /// - Returns: A `TLE` parsed from the buffer.
    /// - Throws: `DecodingError` if the buffer cannot be decoded as ASCII, does not contain
    ///   two or three lines, or if the TLE lines do not meet length constraints. The
    ///   underlying error is a `TLEDecoder.Error` describing the specific reason.
    public func decode(_ data: Data) throws -> TLE {
        let lines = try textLines(in: data)

        switch lines.count {
        case 2:
            return try tle(title: "", firstLine: lines[0], secondLine: lines[1])
        case 3:
            return try tle(title: lines[0], firstLine: lines[1], secondLine: lines[2])
        default:
            throw corruptedData(.wrongLineCount(lines.count))
        }
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

    private func dataLine(at cursor: Int, in lines: [Line]) -> Line? {
        guard cursor < lines.count, lines[cursor].kind != .title else {
            return nil
        }

        return lines[cursor]
    }

    private func candidateSets(in lines: [Line]) -> [CandidateSet] {
        var candidateSets: [CandidateSet] = []

        var cursor = 0

        while cursor < lines.count {
            let lineNumber = lines[cursor].lineNumber
            let title = lines[cursor].kind == .title ? lines[cursor] : nil
            if title != nil { cursor += 1 }

            var dataLines: [Line] = []

            while let currentLine = dataLine(at: cursor, in: lines),
                  !dataLines.map(\.kind).contains(currentLine.kind) {
                dataLines.append(currentLine)

                cursor += 1
            }

            candidateSets.append(.init(title: title, dataLines: dataLines, lineNumber: lineNumber))
        }

        return candidateSets
    }

    /// Decodes every valid TLE set in a feed and reports the sets that could not be decoded.
    ///
    /// Unlike ``decodeCollection(_:)``, a damaged set doesn't fail the whole feed: it is skipped
    /// and reported in ``TLEDecodingReport/rejections``, and the sets around it still decode.
    ///
    /// Sets are recognized by their content, not their position: a line starting with `1 ` or
    /// `2 ` is a data line, and any other non-blank line is a title. A title that starts with
    /// `1 ` or `2 ` is therefore read as a data line. A set without a title line decodes with an
    /// empty ``TLE/title``, so feeds in Space-Track's two-line format decode too.
    ///
    /// - Parameter data: The raw ASCII-encoded bytes of the feed. Empty or blank input yields an
    ///   empty report.
    /// - Returns: The decoded TLEs and the rejected sets, both in feed order.
    /// - Throws: `DecodingError` whose underlying error is ``Error/encodingError`` if the data
    ///   is not ASCII. A single non-ASCII byte anywhere in the feed fails the whole feed.
    public func decodeValidSets(_ data: Data) throws -> TLEDecodingReport {
        let lines = try numberedLines(in: data)

        var rejections: [TLEDecodingReport.RejectedSet] = []
        var tles: [TLE] = []

        for candidateSet in candidateSets(in: lines) {
            switch candidateSet.decode() {
            case .decoded(let tle):
                tles.append(tle)
            case .rejected(let rejection):
                rejections.append(rejection)
            }
        }

        return .init(tles: tles, rejections: rejections)
    }

    private func numberedLines(in data: Data) throws -> [Line] {
        guard let text = String(data: data, encoding: .ascii) else {
            throw corruptedData(.encodingError)
        }

        return text
            .split(omittingEmptySubsequences: false, whereSeparator: { $0.isNewline })
            .enumerated()
            .map { offset, line in
                Line(value: line.trimmingCharacters(in: .whitespaces), lineNumber: offset + 1)
            }
            .filter { !$0.value.isEmpty }
    }

    private func textLines(in data: Data) throws -> [String] {
        try numberedLines(in: data).map(\.value)
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
