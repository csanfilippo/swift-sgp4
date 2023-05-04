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

import Quick
import Nimble
import Foundation

@testable import SGPKit

final class TLEParserTests: QuickSpec {
    override func spec() {
        describe("TLEParser") {
            context("when parsing an empty buffer") {
                it("should throw an exception") {
                    let emptyBuffer = Data()

                    expect { try TLEParser.parse(emptyBuffer) }.to(throwError(TLEParser.Error.empty))
                }
            }

            context("when parsing a not empty buffer") {
                context("if the buffer contains valid data") {
                    it("should return a TLE model") {
                        let validData = self.loadValidTLEData()

						let expectedTLE = TLE(
                            title: "ISS (ZARYA)",
                            firstLine: "1 11416U 79057A   80003.44366214  .00000727  00000-0  33454-3 0   878",
                            secondLine: "2 11416  98.7309  35.7226 0013335  92.0280 268.2428 14.22474848 27074"
                        )

                        do {
                            let tle = try TLEParser.parse(validData)
                            expect(tle.title).to(equal(expectedTLE.title))
                            expect(tle.firstLine).to(equal(expectedTLE.firstLine))
                            expect(tle.secondLine).to(equal(expectedTLE.secondLine))
                        } catch {
                            fail()
                        }
                    }
                }

                context("if the encoded TLE doesn't have 3 lines") {
                    it("should raise an exception") {
						let invalidData = self.loadOneLineTLEData()

                        do {
                            _ = try TLEParser.parse(invalidData)
                            fail()
                        } catch let tleParserError as TLEParser.Error {
                            if case let TLEParser.Error.wrongLineCount(count) = tleParserError {
                                expect(count).to(equal(1))
                            } else {
                                fail()
                            }
                        } catch {
                            fail()
                        }
                    }
                }

                context("if not all the lines of the TLE have 69 characters") {
                    it("should raise an exception") {
						let invalidData = self.loadInvalidLineLengthTLEData()

                        do {
                            _ = try TLEParser.parse(invalidData)
                            fail()
                        } catch let tleParserError as TLEParser.Error {
                            if case TLEParser.Error.invalidLineLength = tleParserError {
                                _ = succeed()
                            } else {
                                fail()
                            }
                        } catch {
                            fail()
                        }
                    }
                }
            }
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
