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
import Testing
import Foundation

@testable import SGPKit

@Suite("TLEEncoder")
struct TLEEncoderTests {
    
    @Test("should return a valid encoded buffer when encoding a TLE")
    func encoding() throws {
        let tle = try TLE(
            title: "ISS (ZARYA)",
            firstLine: "1 11416U 79057A   80003.44366214  .00000727  00000-0  33454-3 0   878",
            secondLine: "2 11416  98.7309  35.7226 0013335  92.0280 268.2428 14.22474848 27074"
        )
        
        let encoder = TLEEncoder()
        let encoded = try encoder.encode(tle)
        
        let (expected, _) = TLETestUtils.loadValidTLEData()
        
        #expect(encoded == expected)
    }
}
