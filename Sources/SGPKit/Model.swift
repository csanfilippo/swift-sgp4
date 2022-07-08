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

import Foundation

/// An object describing a TLE set
public struct TLE {

	/// The title line of the TLE set
	public let title: String

	/// The first line of the TLE set
	public let firstLine: String

	/// The first line of the TLE set
	public let secondLine: String

	/// Create a TLE
	///
	/// - Parameters:
	///   - title: The title of the TLE set
	///   - firstLine: the first line of the TLE set
	///   - secondLine: the second line of the TLE set
	public init(title: String, firstLine: String, secondLine: String) {
		self.title = title
		self.firstLine = firstLine
		self.secondLine = secondLine
	}

	/// A convenience initializer for creating a TLE with an empty title
	///
	/// - Parameters:
	///   - firstLine: the first line of the TLE set
	///   - secondLine: the second line of the TLE set
	public convenience init(firstLine: String, secondLine: String) {
		self.init(title: "", firstLine: firstLine, secondLine: secondLine)
	}
}

/// A model describing a satellite using geodetic coordinates
public struct SatelliteData {

	/// The geodetic latitude of the satellite
	public let latitude: Double

	/// The geodetic longitude of the satellite
	public let longitude: Double

	/// Satellite's speed expressed in km/h
	public let speed: Double

	/// The altitude expressed in km
	public let altitude: Double
}
