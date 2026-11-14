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

import Testing
import Foundation

@testable import SGPKit

@Suite("TLEDecoder")
struct TLEDecoderTests {

    @Test("should decode concurrently from tasks sharing one decoder")
    func sharedAcrossTasks() async throws {
        let decoder = TLEDecoder()
        let (data, expected) = TLETestUtils.loadValidTLEData()

        let results = try await withThrowingTaskGroup(of: TLE.self) { group in
            group.addTask { try decoder.decode(data) }
            group.addTask { try decoder.decode(data) }
            return try await group.reduce(into: []) { $0.append($1) }
        }

        #expect(results == [expected, expected])
    }

    @Test("should decode ascii-encoded single LTE")
    func asciiDecoding() throws {
        let decoder = TLEDecoder()
        
        let (data, expected) = TLETestUtils.loadValidTLEData()
        
        let result = try decoder.decode(data)
        
        #expect(result == expected)
    }
    
    @Test("should decode ascii-encoded multiple LTE")
    func asciiDecodingArray() throws {
        let decoder = TLEDecoder()
        
        let (data, expected) = TLETestUtils.loadThreeValidTLEData()
        
        let result = try decoder.decodeCollection(data)
        
        #expect(result == expected)
    }
    
    @Test("should raise an exception when decoding a malformed array of TLEs")
    func asciiDecodingArray2() throws {
        let decoder = TLEDecoder()
        
        let data = TLETestUtils.loadMultipleNotValidTLEData()
        
        #expect(throws: DecodingError.self) {
            try decoder.decodeCollection(data)
        }
    }
    
    @Test("should raise an exception when decoding utf8-encoded data")
    func utf8DecodingNotSupported() throws {
        let decoder = TLEDecoder()
        
        let data = TLETestUtils.loadUTF8InvalidTLEData()
        
        let thrownError = #expect(throws: DecodingError.self) {
            try decoder.decode(data)
        }
        
        Self.expectUnderlyingErrorToBe(decodingError: try #require(thrownError), expectedError: .encodingError)
    }
    
    @Test("should raise an exception when decoding a TLE with lines shorter than 69 characters")
    func lessThanSixtyNineCharactersNotSupported() throws {
        let decoder = TLEDecoder()
        
        let data = TLETestUtils.loadShorterLineLengthTLEData()
        
        let thrownError = #expect(throws: DecodingError.self) {
            try decoder.decode(data)
        }
        
        Self.expectUnderlyingErrorToBe(decodingError: try #require(thrownError), expectedError: .invalidLineLength)
    }
    
    @Test("should raise an exception when decoding a TLE with lines longer than 69 characters")
    func moreThanSixtyNineCharactersNotSupported() {
        let decoder = TLEDecoder()
        
        let data = TLETestUtils.loadLongerLineLengthTLEData()
        
        #expect(throws: DecodingError.self) {
            try decoder.decode(data)
        }
    }
    
    @Test("should raise an exception when decoding a malformed TLE")
    func malformedTLE() throws {
        let decoder = TLEDecoder()
        
        let data = TLETestUtils.loadOneLineTLEData()
        
        let thrownError = #expect(throws: DecodingError.self) {
            try decoder.decode(data)
        }
        
        Self.expectUnderlyingErrorToBe(decodingError: try #require(thrownError), expectedError: .wrongLineCount(1))
    }
    
    @Test("should raise an exception when decoding an empty TLE")
    func emptyTLE() throws {
        let decoder = TLEDecoder()
        
        let data = TLETestUtils.getEmptyTLEData()
        
        let thrownError = #expect(throws: DecodingError.self) {
            try decoder.decode(data)
        }
        
        Self.expectUnderlyingErrorToBe(decodingError: try #require(thrownError), expectedError: .wrongLineCount(0))
    }

    @Test("should raise an exception when decoding an empty array of TLEs")
    func emptyTLECollection() throws {
        let decoder = TLEDecoder()

        let data = TLETestUtils.getEmptyTLEData()

        let thrownError = #expect(throws: DecodingError.self) {
            try decoder.decodeCollection(data)
        }

        Self.expectUnderlyingErrorToBe(decodingError: try #require(thrownError), expectedError: .wrongLineCount(0))
    }

    @Test("should report the line count when decoding an array of TLEs with a wrong number of lines")
    func wrongLineCountInCollection() throws {
        let decoder = TLEDecoder()

        let data = TLETestUtils.loadMultipleNotValidTLEData()

        let thrownError = #expect(throws: DecodingError.self) {
            try decoder.decodeCollection(data)
        }

        Self.expectUnderlyingErrorToBe(decodingError: try #require(thrownError), expectedError: .wrongLineCount(8))
    }

    @Test("should raise an exception when decoding an array of TLEs from utf8-encoded data")
    func utf8CollectionDecodingNotSupported() throws {
        let decoder = TLEDecoder()

        let data = TLETestUtils.loadUTF8InvalidTLEData()

        let thrownError = #expect(throws: DecodingError.self) {
            try decoder.decodeCollection(data)
        }

        Self.expectUnderlyingErrorToBe(decodingError: try #require(thrownError), expectedError: .encodingError)
    }

    @Test("should raise an exception when decoding an array of TLEs with lines shorter than 69 characters")
    func lessThanSixtyNineCharactersInCollection() throws {
        let decoder = TLEDecoder()

        let data = TLETestUtils.loadShorterLineLengthTLEData()

        let thrownError = #expect(throws: DecodingError.self) {
            try decoder.decodeCollection(data)
        }

        Self.expectUnderlyingErrorToBe(decodingError: try #require(thrownError), expectedError: .invalidLineLength)
    }

    @Test("should raise an exception when decoding an array of TLEs with lines longer than 69 characters")
    func moreThanSixtyNineCharactersInCollection() throws {
        let decoder = TLEDecoder()

        let data = TLETestUtils.loadLongerLineLengthTLEData()

        let thrownError = #expect(throws: DecodingError.self) {
            try decoder.decodeCollection(data)
        }

        Self.expectUnderlyingErrorToBe(decodingError: try #require(thrownError), expectedError: .invalidLineLength)
    }

    @Test("should raise an exception when decoding more than one TLE as a single TLE")
    func multipleTLEsDecodedAsSingle() throws {
        let decoder = TLEDecoder()

        let (data, _) = TLETestUtils.loadThreeValidTLEData()

        let thrownError = #expect(throws: DecodingError.self) {
            try decoder.decode(data)
        }

        Self.expectUnderlyingErrorToBe(decodingError: try #require(thrownError), expectedError: .wrongLineCount(9))
    }

    @Test("should raise an exception when decoding an array of TLEs made only of blank lines")
    func blankLinesTLECollection() throws {
        let decoder = TLEDecoder()

        let data = TLETestUtils.getBlankLinesTLEData()

        let thrownError = #expect(throws: DecodingError.self) {
            try decoder.decodeCollection(data)
        }

        Self.expectUnderlyingErrorToBe(decodingError: try #require(thrownError), expectedError: .wrongLineCount(0))
    }

    private static func expectUnderlyingErrorToBe(decodingError: DecodingError, expectedError: TLEDecoder.Error) {
        if case let DecodingError.dataCorrupted(context) = decodingError, let error = context.underlyingError as? TLEDecoder.Error {
            #expect(error == expectedError)
        } else {
            Issue.record()
        }
    }
    
}

extension TLEDecoderTests {

    @Suite("decodeValidSets")
    struct DecodeValidSets {

        @Test("should decode every set of a valid feed, in order, with no rejections")
        func validFeed() throws {
            let decoder = TLEDecoder()

            let (data, expected) = TLETestUtils.loadThreeValidTLEData()

            let report = try decoder.decodeValidSets(data)

            #expect(report.tles == expected)
            #expect(report.rejections.isEmpty)
        }

        @Test(
            "should decode an empty or blank feed to an empty report",
            arguments: [TLETestUtils.getEmptyTLEData(), TLETestUtils.getBlankLinesTLEData()]
        )
        func emptyFeed(data: Data) throws {
            let decoder = TLEDecoder()

            let report = try decoder.decodeValidSets(data)

            #expect(report.tles.isEmpty)
            #expect(report.rejections.isEmpty)
        }

        @Test("should throw a decoding error when decoding a non-ASCII feed")
        func nonASCIIFeed() throws {
            let decoder = TLEDecoder()

            let data = TLETestUtils.loadUTF8InvalidTLEData()

            let thrownError = #expect(throws: DecodingError.self) {
                try decoder.decodeValidSets(data)
            }

            TLEDecoderTests.expectUnderlyingErrorToBe(decodingError: try #require(thrownError), expectedError: .encodingError)
        }

        @Test("should reject a set with a data line that is not 69 characters and decode the sets around it")
        func setWithInvalidLineLength() throws {
            let decoder = TLEDecoder()

            let (data, expected) = TLETestUtils.loadFeedWithShortLineTLEData()

            let report = try decoder.decodeValidSets(data)

            #expect(report.tles == expected)
            #expect(report.rejections.map(\.reason) == [.invalidLineLength])
        }

        @Test("should reject a set missing line 2 and decode the set after it")
        func setMissingSecondLine() throws {
            let decoder = TLEDecoder()

            let (data, expected) = TLETestUtils.loadFeedWithMissingSecondLineTLEData()

            let report = try decoder.decodeValidSets(data)

            #expect(report.tles == expected)
            #expect(report.rejections.map(\.reason) == [.missingSecondLine])
        }

        @Test("should reject a set missing line 2 at the end of the feed")
        func lastSetMissingSecondLine() throws {
            let decoder = TLEDecoder()

            let (data, expected) = TLETestUtils.loadFeedEndingWithMissingSecondLineTLEData()

            let report = try decoder.decodeValidSets(data)

            #expect(report.tles == expected)
            #expect(report.rejections.map(\.reason) == [.missingSecondLine])
        }

        @Test("should reject a set missing line 1 and decode the set after it")
        func setMissingFirstLine() throws {
            let decoder = TLEDecoder()

            let (data, expected) = TLETestUtils.loadFeedWithMissingFirstLineTLEData()

            let report = try decoder.decodeValidSets(data)

            #expect(report.tles == expected)
            #expect(report.rejections.map(\.reason) == [.missingFirstLine])
        }

        @Test("should reject data lines with no title before them as missing a title")
        func setMissingTitle() throws {
            let decoder = TLEDecoder()

            let (data, expected) = TLETestUtils.loadFeedWithMissingTitleTLEData()

            let report = try decoder.decodeValidSets(data)

            #expect(report.tles == expected)
            #expect(report.rejections.map(\.reason) == [.missingTitle])
        }

        @Test("should reject data lines with no title at the end of the feed as missing a title")
        func lastSetMissingTitle() throws {
            let decoder = TLEDecoder()

            let (data, expected) = TLETestUtils.loadFeedEndingWithMissingTitleTLEData()

            let report = try decoder.decodeValidSets(data)

            #expect(report.tles == expected)
            #expect(report.rejections.map(\.reason) == [.missingTitle])
        }

        @Test("should reject a set whose line 2 comes before line 1 as out of order")
        func setWithDataLinesOutOfOrder() throws {
            let decoder = TLEDecoder()

            let (data, expected) = TLETestUtils.loadFeedWithDataLinesOutOfOrderTLEData()

            let report = try decoder.decodeValidSets(data)

            #expect(report.tles == expected)
            #expect(report.rejections.map(\.reason) == [.dataLinesOutOfOrder])
        }

        @Test("should reject a title followed directly by another title as missing both data lines")
        func loneTitle() throws {
            let decoder = TLEDecoder()

            let (data, expected) = TLETestUtils.loadFeedWithLoneTitleTLEData()

            let report = try decoder.decodeValidSets(data)

            #expect(report.tles == expected)
            #expect(report.rejections.map(\.reason) == [.missingDataLines])
        }
    }
}
