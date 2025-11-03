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

import SGP4LibWrapper
import Foundation

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
    }
    
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
	/// - Throws: ``TLEInterpreter/Error`` when propagation fails.
	///   Specifically, this method throws:
	///   - ``TLEInterpreter/Error/tle`` when the TLE is invalid or unsupported.
	///   - ``TLEInterpreter/Error/satellite`` when the satellite state cannot be computed.
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
	public func satelliteData(from nativeTLE: TLE, date: Date) throws -> SatelliteData {
        
        let tle = createTLE(
            std.string(nativeTLE.title),
            std.string(nativeTLE.firstLine),
            std.string(nativeTLE.secondLine)
        )
        
        guard let tleValue = tle.value else {
            throw Error.tle
        }
        
        let sgp4 = libsgp4.SGP4(tleValue)
        
        
        let currentTime = dateTimeFrom(date)
        
        
        return try satelliteDataFrom(sgp4: sgp4, date: currentTime)
	}
    
    private func satelliteDataFrom(sgp4: libsgp4.SGP4, date: libsgp4.DateTime) throws -> SatelliteData {
        let maybeEci = createEci(sgp4, date)
        
        guard let eci = maybeEci.value else {
            throw Error.satellite
        }
        
        let geo = eci.ToGeodetic()
        
        let velocity = eci.Velocity().Magnitude() * 3600.0
        
        let latitude = geo.latitude * 180.0 / .pi
        let longitude = geo.longitude * 180.0 / .pi
        let altitude = geo.altitude
        
        return .init(latitude: latitude, longitude: longitude, speed: velocity, altitude: altitude)
        
    }
    
    private func dateTimeFrom(_ date: Date) -> libsgp4.DateTime {
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
        
        let year = Int32(components.year ?? 0)
        let month = Int32(components.month ?? 0)
        let day = Int32(components.day ?? 0)
        let hour = Int32(components.hour ?? 0)
        let minute = Int32(components.minute ?? 0)
        let second = Int32(components.second ?? 0)
        let micro = Int32(components.nanosecond ?? 0) / 1000
        
        var dateTime = libsgp4.DateTime(
            year,
            month,
            day,
            hour,
            minute,
            second
        )
        
        dateTime.Initialise(year, month, day, hour, minute, second, micro)
        
        
        return dateTime
    }
}

