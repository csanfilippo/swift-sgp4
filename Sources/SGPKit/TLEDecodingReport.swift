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

/// The outcome of decoding a TLE feed with ``TLEDecoder/decodeValidSets(_:)``: the sets that
/// decoded, and the sets that were rejected.
public struct TLEDecodingReport: Sendable {

    /// A TLE set from the feed that could not be decoded.
    public struct RejectedSet: Sendable {

        /// Why a set was rejected. A set has one reason; a missing or misplaced line outranks an
        /// invalid line length.
        public enum Reason: Sendable {
            /// A data line is not exactly 69 characters long.
            case invalidLineLength
            /// The set has a title and line 2, but no line 1.
            case missingFirstLine
            /// The set has a title and line 1, but no line 2.
            case missingSecondLine
            /// The set's data lines have no title line before them.
            case missingTitle
            /// Line 2 appears before line 1.
            case dataLinesOutOfOrder
            /// A title line is followed by no data lines.
            case missingDataLines
        }

        /// Why the set was rejected.
        public let reason: Reason
        /// The set's title line, or `nil` when the set has none.
        public let title: String?
        /// The 1-based line in the input where the set starts, counting blank lines.
        public let lineNumber: Int
    }

    /// The sets that decoded, in feed order.
    public let tles: [TLE]
    /// The sets that were rejected, in feed order.
    public let rejections: [RejectedSet]
}
