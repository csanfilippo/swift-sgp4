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
		TLEWrapper(title: title, firstLine: firstLine, secondLine: secondLine)
	}
}

private extension SGPKitOBJC.SatelliteData {
	var asSatelliteData: SatelliteData {
		SatelliteData(latitude: latitude, longitude: longitude, speed: speed, altitude: altitude)
	}
}

/// Interprets a TLE and computes satellite state using the SGP4 model.
///
/// This type bridges to the underlying `SGPKitOBJC` implementation to propagate
/// a Two‑Line Element (TLE) to a specific moment in time and returns the result
/// as geodetic latitude/longitude (degrees), altitude (km), and speed (km/h).
///
/// Instances are lightweight and stateless; you can create and reuse them across
/// calls. Input validation is not performed here—use `TLEParser` to construct a
/// validated `TLE`.
///
/// - SeeAlso: `TLE`, `SatelliteData`, `TLEParser`
public final class TLEInterpreter {

	/// Creates a new, stateless interpreter.
	public init() {}

	/// Computes satellite geodetic position, altitude, and speed for a given date.
	///
	/// Uses the SGP4 propagation model via `SGPKitOBJC` to evaluate the provided
	/// TLE at the specified moment.
	///
	/// - Parameters:
	///   - tle: The TLE to propagate. Prefer a value produced by `TLEParser`.
	///   - date: The instant for which to compute the satellite state. `Date` is an
	///           absolute timestamp; results correspond to that exact moment.
	/// - Returns: A `SatelliteData` snapshot with:
	///   - `latitude`/`longitude` in degrees (geodetic, WGS‑84),
	///   - `altitude` in kilometers above the WGS‑84 ellipsoid,
	///   - `speed` in kilometers per hour.
	/// - Note: This method does not cache results and constructs a new SGP4 engine
	///   per call. For repeated evaluations, reuse the interpreter instance.
	/// - Example:
	/// ```swift
	/// let interpreter = TLEInterpreter()
	/// let state = interpreter.satelliteData(from: tle, date: Date())
	/// print(state.latitude, state.longitude)
	/// ```
	public func satelliteData(from tle: TLE, date: Date) -> SatelliteData {
		let wrapper = SGP4Wrapper()
		let result: SGPKitOBJC.SatelliteData = wrapper.getSatelliteData(from: tle.asTLEWrapper, date: date)
		return result.asSatelliteData
	}
}

