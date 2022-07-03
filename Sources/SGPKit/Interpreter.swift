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

import SGPKitOBJC

private extension TLE {
	var asTLEWrapper: TLEWrapper {
		TLEWrapper(firstLine: firstLine, secondLine: secondLine)
	}
}

/// A class that calculates the satellite position, speed and altitude using a TLE set
public final class TLEInterpreter {

	/// Returns a SatelliteData instance calculated from a TLE set
	///
	/// - parameter tle: The TLE set
	/// - parameter date: Date for which we want to obtain information about the satellite
	/// - returns: A `SatelliteData` describing the satellite
	public func satelliteData(from tle: TLE, date: Date) -> SatelliteData {
		let wrapper = SGP4Wrapper()
		let result: SGPKitOBJC.SatelliteData = wrapper.getSatelliteData(from: tle.asTLEWrapper, date: date)
		return SatelliteData(latitude: result.latitude, longitude: result.longitude, speed: result.speed, altitude: result.altitude)
	}
}
