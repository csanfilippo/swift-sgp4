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

import Testing
import Foundation

@testable import SGPKit

@Suite("TLEParser")
struct TLEParserTestsSuite {
    @Test func `when parsing an empty buffer should throw an exception`() async throws {
        let emptyBuffer = Data()
        let parser = TLEParser()

        #expect(throws: TLEParser.Error.empty) {
            try parser.parse(emptyBuffer)
        }
    }
    
    @Test func `when parsing a not empty buffer if the buffer contains valid data should return a TLE model`() async throws {
        let parser = TLEParser()
        let validData = self.loadValidTLEData()

        let expectedTLE = try TLE(
            title: "ISS (ZARYA)",
            firstLine: "1 11416U 79057A   80003.44366214  .00000727  00000-0  33454-3 0   878",
            secondLine: "2 11416  98.7309  35.7226 0013335  92.0280 268.2428 14.22474848 27074"
        )
        
        let tle = try parser.parse(validData)
        #expect(tle.title == expectedTLE.title)
        #expect(tle.firstLine == expectedTLE.firstLine)
        #expect(tle.secondLine == expectedTLE.secondLine)
    }
    
    @Test func `when parsing a not empty buffer if the buffer if the encoded TLE doesn't have 3 lines should raise an exception`() async throws {
        let parser = TLEParser()
        let invalidData = self.loadOneLineTLEData()
        
        #expect(throws: TLEParser.Error.wrongLineCount(1)) {
            _ = try parser.parse(invalidData)
        }
    }
    
    @Test func `when parsing a not empty buffer if not all the lines of the TLE have 69 characters should raise an exception`() async throws {
        let parser = TLEParser()
        let invalidData = self.loadInvalidLineLengthTLEData()
        
        #expect(throws: TLEParser.Error.invalidLineLength) {
            _ = try parser.parse(invalidData)
        }
    }
    
    private func loadValidTLEData() -> Data {
        let url = Bundle.module.url(
            forResource: "valid_tle",
            withExtension: "txt",
            subdirectory: "Mocks"
        )!

        return try! Data(contentsOf: url)
    }

    private func loadOneLineTLEData() -> Data {
        let url = Bundle.module.url(
            forResource: "one_line_invalid_tle",
            withExtension: "txt",
            subdirectory: "Mocks"
        )!

        return try! Data(contentsOf: url)
    }

    private func loadInvalidLineLengthTLEData() -> Data {
        let url = Bundle.module.url(
            forResource: "invalid_line_length_tle",
            withExtension: "txt",
            subdirectory: "Mocks"
        )!

        return try! Data(contentsOf: url)
    }
}
