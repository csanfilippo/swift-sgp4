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
import CoreLocation

@testable import SGPKit

private enum Error: Swift.Error {
	case invalidDate
	case invalidTimezone
}

private let tolerance = 0.000001

final class SGPKitTests: QuickSpec {
	override func spec() {
		context("TLEInterpreter") {
			describe("when a TLE is passed") {
				it("should return the expected satellite data") {
					let firstLine = "1 25544U 98067A   13165.59097222  .00004759  00000-0  88814-4 0    47"
					let secondLine = "2 25544  51.6478 121.2152 0011003  68.5125 263.9959 15.50783143834295"
					let tle = TLE(title: "", firstLine: firstLine, secondLine: secondLine)
					let interpreter = TLEInterpreter()
					let data = interpreter.satelliteData(from: tle, date: try self.generateTestDate())

					let expectedLatitude = 45.2893067
					let expectedLongitude = -136.62764
					let expectedAltitude = 411.5672031

					let latitudeAbsoluteDiff = fabs(data.latitude - expectedLatitude)
					let longitudeAbsoluteDiff = fabs(data.longitude - expectedLongitude)
					let altitudeAbsoluteDiff = fabs(data.altitude - expectedAltitude)

					expect(latitudeAbsoluteDiff).to(beLessThanOrEqualTo(tolerance))
					expect(longitudeAbsoluteDiff).to(beLessThanOrEqualTo(tolerance))
					expect(altitudeAbsoluteDiff).to(beLessThanOrEqualTo(tolerance))
				}
                it("should return the expected look angles") {
                    let firstLine = "1 25544U 98067A   13165.59097222  .00004759  00000-0  88814-4 0    47"
                    let secondLine = "2 25544  51.6478 121.2152 0011003  68.5125 263.9959 15.50783143834295"
                    let tle = TLE(title: "", firstLine: firstLine, secondLine: secondLine)
                    let interpreter = TLEInterpreter()

                    let groundStationLatitude = 0.0
                    let groundStationLongitude = 0.0
                    let groundStationAltitude = 100.0
                    
                    let data = interpreter.lookAngles(from: tle, date: try self.generateTestDate(), coordinate: CLLocationCoordinate2D(latitude: groundStationLatitude, longitude: groundStationLongitude), altitude: groundStationAltitude)
                    
                    let expectedAzimuth = 325.622437
                    let expectedElevation = -59.695258
                    let expectedRange = 11531.663004
                    let expectedRangeRate = -3.530533
                    
                    let azimuthAbsoluteDiff = fabs(data.azimuth - expectedAzimuth)
                    let elevationAbsoluteDiff = fabs(data.elevation - expectedElevation)
                    let rangeAbsoluteDiff = fabs(data.range - expectedRange)
                    let rangeRateAbsoluteDiff = fabs(data.rangeRate - expectedRangeRate)
                    
                    expect(azimuthAbsoluteDiff).to(beLessThanOrEqualTo(tolerance))
                    expect(elevationAbsoluteDiff).to(beLessThanOrEqualTo(tolerance))
                    expect(rangeAbsoluteDiff).to(beLessThanOrEqualTo(tolerance))
                    expect(rangeRateAbsoluteDiff).to(beLessThanOrEqualTo(tolerance))
                }
			}
		}
	}

	private func generateTestDate() throws -> Date {
		var calendar = Calendar.current

		guard let utcTimezone = TimeZone(secondsFromGMT: 0) else {
			throw Error.invalidTimezone
		}

		calendar.timeZone = utcTimezone

		var components = DateComponents()

		components.year = 2013
		components.month = 6
		components.day = 15
		components.hour = 2
		components.minute = 57
		components.second = 7
		components.nanosecond = 200000 * 1000

		guard let date = calendar.date(from: components) else {
			throw Error.invalidDate
		}

		return date
	}
}

