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

import Foundation

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

