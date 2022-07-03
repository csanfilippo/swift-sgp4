import XCTest
@testable import SGPKit

private enum Error: Swift.Error {
	case invalidDate
	case invalidTimezone
}

final class SGPKitTests: XCTestCase {
    func testGeoPosition() throws {
		let firstLine = "1 25544U 98067A   13165.59097222  .00004759  00000-0  88814-4 0    47"
		let secondLine = "2 25544  51.6478 121.2152 0011003  68.5125 263.9959 15.50783143834295"
		let tle = TLE(firstLine: firstLine, secondLine: secondLine)
		let interpreter = TLEInterpreter()
		let data = interpreter.satelliteData(from: tle, date: try generateTestDate())

		let expectedLatitude = 45.2893067
		let expectedLongitude = -136.62764
		let expectedAltitude = 411.5672031

		let latitudeDiff = fabs(data.latitude - expectedLatitude)
		let longitudeDiff = fabs(data.longitude - expectedLongitude)
		let altitudeDiff = fabs(data.altitude - expectedAltitude)

		XCTAssertTrue(latitudeDiff <= 0.000001)
		XCTAssertTrue(longitudeDiff <= 0.000001)
		XCTAssertTrue(altitudeDiff <= 0.000001)
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

