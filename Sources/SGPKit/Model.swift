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

import Foundation

/// Errors that can occur when constructing or validating a TLE.
public enum TLEError: Error {
    /// Thrown when either of the two data lines is empty.
    case linesCannoteBeEmpty
    /// Thrown when a data line is not exactly 69 characters long.
    case linesMustBeSixNineCharactersLong
}

/// A container for a Two‑Line Element (TLE) set.
///
/// A TLE consists of three lines: an optional title line followed by two
/// data lines that are each exactly 69 characters long.
/// This type now validates basic structural rules (non‑empty lines and exact
/// 69‑character length) during initialization and throws on failure.
///
/// - Note: Use `TLEParser` to parse a buffer into a `TLE` and perform
///   additional domain checks (for example, checksums).
/// - SeeAlso: `TLEParser`
public struct TLE: Sendable {

	/// The title (line 0) of the TLE set. May be empty.
	public let title: String

	/// The first TLE data line (line 1). Expected length: 69 characters.
	public let firstLine: String

	/// The second TLE data line (line 2). Expected length: 69 characters.
	public let secondLine: String

    /// Creates a validated `TLE` from its constituent lines.
    ///
    /// - Parameters:
    ///   - title: The title (line 0) of the TLE set. Pass an empty string if absent.
    ///   - firstLine: The first TLE data line (line 1). Must be exactly 69 characters.
    ///   - secondLine: The second TLE data line (line 2). Must be exactly 69 characters.
    /// - Throws: `TLEError.linesCannoteBeEmpty` if any data line is empty, or
    ///   `TLEError.linesMustBeSixNineCharactersLong` if a line is not 69 characters long.
    /// - Important: Only basic structural checks are performed here. Prefer using
    ///   `TLEParser` for checksum and field‑level validation.
    /// - Example:
    /// ```swift
    /// let tle = try TLE(
    ///     title: "ISS (ZARYA)",
    ///     firstLine: "1 25544U 98067A   24060.51736111  .00016717  00000-0  30270-3 0  9991",
    ///     secondLine: "2 25544  51.6431  57.2546 0004487  58.7657  56.7570 15.49688911439444"
    /// )
    /// ```
	public init(title: String, firstLine: String, secondLine: String) throws {
        
        guard !firstLine.isEmpty && !secondLine.isEmpty else {
            throw TLEError.linesCannoteBeEmpty
        }
        
        guard firstLine.count == 69 && secondLine.count == 69 else {
            throw TLEError.linesMustBeSixNineCharactersLong
        }
        
		self.title = title
		self.firstLine = firstLine
		self.secondLine = secondLine
	}

    /// Creates a validated `TLE` with an empty title.
    ///
    /// - Parameters:
    ///   - firstLine: The first TLE data line (line 1). Must be exactly 69 characters.
    ///   - secondLine: The second TLE data line (line 2). Must be exactly 69 characters.
    /// - Throws: The same errors as `init(title:firstLine:secondLine:)`.
    /// - SeeAlso: `init(title:firstLine:secondLine:)`
	public init(firstLine: String, secondLine: String) throws {
		try self.init(title: "", firstLine: firstLine, secondLine: secondLine)
	}
}

/// A snapshot of satellite state in geodetic coordinates (WGS‑84).
///
/// Values are expressed in display‑friendly units suitable for UI and basic
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

