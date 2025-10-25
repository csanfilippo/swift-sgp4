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

/// A lightweight interpreter that propagates a TLE using the SGP4 model.
///
/// `TLEInterpreter` bridges to the underlying `SGPKitOBJC` implementation to
/// propagate a Two‑Line Element (TLE) to a specific moment in time and return
/// the result as geodetic latitude/longitude (degrees), altitude (km), and
/// speed (km/h).
///
/// Instances are stateless and inexpensive to create; you can construct and
/// reuse them across multiple calls. Input validation is not performed here—use
/// `TLEParser` to construct a validated `TLE`.
///
/// Thread safety
///  - This type is immutable and `Sendable`. Create and use instances from any
///    concurrency context. Each call constructs its own SGP4 engine internally.
///
/// Performance
///  - This API does not cache results. For repeated evaluations at different
///    times, call the method as needed or implement your own memoization if
///    appropriate for your use case.
///
/// - SeeAlso: `TLE`, `SatelliteData`, `TLEParser`
public final class TLEInterpreter: Sendable {
    
    /// Errors that can occur while interpreting a TLE.
    ///
    /// These errors map from underlying `SGPKitOBJC` failures into a
    /// Swift-friendly representation.
    public enum Error: Swift.Error, Equatable, Sendable {
        /// The provided TLE is invalid or cannot be parsed by the propagation engine.
        case tle
        /// The satellite state could not be computed due to a model or state error.
        case satellite
        /// An unspecified error occurred.
        case generic
    }

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
	/// - Throws: ``TLEInterpreter/Error`` when propagation fails.
	///   Specifically, this method throws:
	///   - ``TLEInterpreter/Error/tle`` when the TLE is invalid or unsupported.
	///   - ``TLEInterpreter/Error/satellite`` when the satellite state cannot be computed.
	///   - ``TLEInterpreter/Error/generic`` for any other unspecified failure.
	///
	/// - Discussion: This method constructs a new SGP4 engine on each call and does
	///   not cache results. If you need to evaluate many times in quick succession,
	///   consider reusing the interpreter instance; it is stateless and `Sendable`.
	///
	/// - Example:
	/// ```swift
	/// let interpreter = TLEInterpreter()
	/// let tle = try TLEParser().parse(lines: [line1, line2])
	/// let now = Date()
	/// let state = try interpreter.satelliteData(from: tle, date: now)
	/// print(state.latitude, state.longitude, state.altitude, state.speed)
	/// ```
	public func satelliteData(from tle: TLE, date: Date) throws -> SatelliteData {
        do {
            let wrapper = SGP4Wrapper()
            let result: SGPKitOBJC.SatelliteData = try wrapper.getSatelliteData(from: tle.asTLEWrapper, date: date)
            return result.asSatelliteData
        } catch let error as SGPKitError {
            switch error.code {
            case .TLE_ERROR:
                throw Error.tle
            case .SATELLITE_ERROR:
                throw Error.satellite
            case .GENERIC_ERROR:
                throw Error.generic
            @unknown default:
                throw Error.generic
            }
        }
	}
}

