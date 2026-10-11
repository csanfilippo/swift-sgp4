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

#ifndef SGP4LibWrapper_h
#define SGP4LibWrapper_h

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum __attribute__((enum_extensibility(closed))) SGP4Status {
    SGP4StatusSuccess,
    /// libsgp4 rejected the TLE (`TleException`).
    SGP4StatusTLEError,
    /// The model could not be initialised or propagated (`SatelliteException`, `DecayedException`).
    SGP4StatusSatelliteError
} SGP4Status;

typedef struct SGP4SatelliteState {
    /// Degrees, geodetic WGS-84.
    double latitude;
    /// Degrees, geodetic WGS-84.
    double longitude;
    /// Kilometres above the WGS-84 ellipsoid.
    double altitude;
    /// Kilometres per hour.
    double speed;
} SGP4SatelliteState;

/// Propagates the TLE to the given instant. `state` is written only when the result is `SGP4StatusSuccess`.
SGP4Status SGP4Propagate(const char *title,
                         const char *firstLine,
                         const char *secondLine,
                         int64_t unixMicroseconds,
                         SGP4SatelliteState *state);

#ifdef __cplusplus
}
#endif

#endif /* SGP4LibWrapper_h */
