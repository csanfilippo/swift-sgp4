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

/// The sets of a TLE feed, recognized by line content rather than position: a line starting with
/// `1 ` or `2 ` is a data line, and any other line is a title.
struct TLEFeed {

    struct Line {
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

    struct CandidateSet {
        enum Outcome {
            case decoded(TLE)
            case rejected(TLEDecodingReport.RejectedSet)
        }

        let title: Line?
        let dataLines: [Line]

        /// A set always has a title or at least one data line, so it starts on one of them.
        var lineNumber: Int {
            title?.lineNumber ?? dataLines[0].lineNumber
        }

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

    let candidateSets: [CandidateSet]

    init(lines: [Line]) {
        var candidateSets: [CandidateSet] = []

        var cursor = 0

        while cursor < lines.count {
            let title = lines[cursor].kind == .title ? lines[cursor] : nil
            if title != nil { cursor += 1 }

            var dataLines: [Line] = []

            while let currentLine = Self.dataLine(at: cursor, in: lines),
                  !dataLines.map(\.kind).contains(currentLine.kind) {
                dataLines.append(currentLine)

                cursor += 1
            }

            candidateSets.append(.init(title: title, dataLines: dataLines))
        }

        self.candidateSets = candidateSets
    }

    private static func dataLine(at cursor: Int, in lines: [Line]) -> Line? {
        guard cursor < lines.count, lines[cursor].kind != .title else {
            return nil
        }

        return lines[cursor]
    }
}
