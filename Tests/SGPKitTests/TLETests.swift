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

@testable import SGPKit

@Suite("TLE")
struct TLETests {
    @Test func `should not have empty first line or second line`() async throws {
        #expect(throws: TLEError.linesCannoteBeEmpty) {
            try TLE(firstLine: "", secondLine: "")
        }
    }
    
    @Test func `should not have empty lines longer than 69 characters`() async throws {
        #expect(throws: TLEError.linesMustBeSixNineCharactersLong) {
            try TLE(firstLine: String(repeating: "a", count: 70), secondLine: String(repeating: "a", count: 70))
        }
    }
    
    @Test func `should not have empty lines shorter than 69 characters`() async throws {
        #expect(throws: TLEError.linesMustBeSixNineCharactersLong) {
            try TLE(firstLine: String(repeating: "a", count: 68), secondLine: String(repeating: "a", count: 67))
        }
    }
}
