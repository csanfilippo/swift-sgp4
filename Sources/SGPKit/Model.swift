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

/// A container for a Two‑Line Element (TLE) set.
///
/// A TLE consists of three lines: an optional title line followed by two
/// data lines that are each exactly 69 characters long. This type stores the
/// raw lines as parsed; it does not perform validation itself.
///
/// - Note: Use `TLEParser` to parse and validate a buffer into a `TLE`.
/// - SeeAlso: `TLEParser`
public struct TLE: Sendable {

	/// The title (line 0) of the TLE set. May be empty.
	public let title: String

	/// The first TLE data line (line 1). Expected length: 69 characters.
	public let firstLine: String

	/// The second TLE data line (line 2). Expected length: 69 characters.
	public let secondLine: String

	/// Creates a `TLE` from its constituent lines.
	///
	/// - Parameters:
	///   - title: The title (line 0) of the TLE set. Pass an empty string if absent.
	///   - firstLine: The first TLE data line (line 1), typically 69 characters.
	///   - secondLine: The second TLE data line (line 2), typically 69 characters.
	/// - Important: This initializer does not validate line lengths or checksums.
	///   Prefer using `TLEParser` for validated construction.
	/// - Example:
	/// ```swift
	/// let tle = TLE(
	///     title: "ISS (ZARYA)",
	///     firstLine: "1 25544U 98067A   24060.51736111  .00016717  00000-0  30270-3 0  9991",
	///     secondLine: "2 25544  51.6431  57.2546 0004487  58.7657  56.7570 15.49688911439444"
	/// )
	/// ```
	public init(title: String, firstLine: String, secondLine: String) {
		self.title = title
		self.firstLine = firstLine
		self.secondLine = secondLine
	}

	/// Creates a `TLE` with an empty title.
	///
	/// - Parameters:
	///   - firstLine: The first TLE data line (line 1), typically 69 characters.
	///   - secondLine: The second TLE data line (line 2), typically 69 characters.
	/// - SeeAlso: `init(title:firstLine:secondLine:)`
	public init(firstLine: String, secondLine: String) {
		self.init(title: "", firstLine: firstLine, secondLine: secondLine)
	}
}

/// A snapshot of satellite state in geodetic coordinates (WGS‑84).
///
/// Values are expressed in common units suitable for display and basic
/// computations. This type is a simple data container and performs no
/// validation.
///
/// - Note: Latitude and longitude are in degrees. Altitude is measured
///   along the ellipsoidal normal (geodetic height).
public struct SatelliteData: Sendable {

	/// Geodetic latitude in degrees. Range: −90…90.
	public let latitude: Double

	/// Geodetic longitude in degrees. Range: −180…180.
	public let longitude: Double

	/// Instantaneous speed magnitude in kilometers per hour (km/h).
	public let speed: Double

	/// Geodetic altitude above the WGS‑84 reference ellipsoid, in kilometers (km).
	public let altitude: Double
}

