/*
 MIT License

 Copyright (c) 2022-2025 Calogero Sanfilippo

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

private let tolerance = 0.000001

@Suite("TLEInterpreter")
struct TLEInterpreterTests {
    
    @Test("should return satellite data")
    func testItShouldReturnTheExpectedSatelliteData() throws {
        let firstLine = "1 25544U 98067A   13165.59097222  .00004759  00000-0  88814-4 0    47"
        let secondLine = "2 25544  51.6478 121.2152 0011003  68.5125 263.9959 15.50783143834295"
        let tle = try TLE(title: "", firstLine: firstLine, secondLine: secondLine)
        let interpreter = TLEInterpreter()
        let data = try interpreter.satelliteData(from: tle, date: try self.generateTestDate())

        let expectedLatitude = 45.2893067
        let expectedLongitude = -136.62764
        let expectedAltitude = 411.5672031

        let latitudeAbsoluteDiff = fabs(data.latitude - expectedLatitude)
        let longitudeAbsoluteDiff = fabs(data.longitude - expectedLongitude)
        let altitudeAbsoluteDiff = fabs(data.altitude - expectedAltitude)

        #expect(latitudeAbsoluteDiff <= tolerance)
        #expect(longitudeAbsoluteDiff <= tolerance)
        #expect(altitudeAbsoluteDiff <= tolerance)
    }
    
    private func generateTestDate() throws -> Date {
        var calendar = Calendar.current

        let utcTimezone = TimeZone(secondsFromGMT: 0)!

        calendar.timeZone = utcTimezone

        var components = DateComponents()

        components.year = 2013
        components.month = 6
        components.day = 15
        components.hour = 2
        components.minute = 57
        components.second = 7
        components.nanosecond = 200000 * 1000

        return calendar.date(from: components)!
    }
}
