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

import XCTest

@testable import SGPKit

final class TLETests: XCTestCase {
    func testShouldNotHaveEmptyFirstLineOrSecondLine() throws {
        XCTAssertThrowsError(try TLE(firstLine: "", secondLine: "")) { error in
            XCTAssertEqual(error as? TLEError, .linesCannoteBeEmpty)
        }
    }
    
    func testShouldNotHaveLinesLongerThan69Characters() throws {
        XCTAssertThrowsError(try TLE(firstLine: String(repeating: "a", count: 70), secondLine: String(repeating: "a", count: 70))) { error in
            XCTAssertEqual(error as? TLEError, .linesMustBeSixNineCharactersLong)
        }
    }
    
    func testShouldNotHaveLinesShorterThan69Characters() throws {
        XCTAssertThrowsError(try TLE(firstLine: String(repeating: "a", count: 68), secondLine: String(repeating: "a", count: 67))) { error in
            XCTAssertEqual(error as? TLEError, .linesMustBeSixNineCharactersLong)
        }
    }
}

