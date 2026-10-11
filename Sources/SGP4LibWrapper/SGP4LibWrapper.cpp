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

#include "SGP4LibWrapper.h"
#include <CoordGeodetic.h>
#include <DateTime.h>
#include <Eci.h>
#include <SGP4.h>
#include <TimeSpan.h>
#include <Tle.h>
#include <Util.h>

// No exception may cross the extern "C" boundary: it would call std::terminate.
static SGP4Status propagate(const libsgp4::Tle &tle, int64_t unixMicroseconds, SGP4SatelliteState *state) {
    try {
        const libsgp4::SGP4 sgp4(tle);
        const libsgp4::Eci eci = sgp4.FindPosition(libsgp4::DateTime(libsgp4::kUNIX_EPOCH + unixMicroseconds));
        const libsgp4::CoordGeodetic geodetic = eci.ToGeodetic();

        state->latitude = libsgp4::Util::RadiansToDegrees(geodetic.latitude);
        state->longitude = libsgp4::Util::RadiansToDegrees(geodetic.longitude);
        state->altitude = geodetic.altitude;
        state->speed = eci.Velocity().Magnitude() * 3600.0;

        return SGP4StatusSuccess;
    } catch (...) {
        return SGP4StatusSatelliteError;
    }
}

SGP4Status SGP4Propagate(const char *title,
                         const char *firstLine,
                         const char *secondLine,
                         int64_t unixMicroseconds,
                         SGP4SatelliteState *state) {
    try {
        const libsgp4::Tle tle(title, firstLine, secondLine);
        return propagate(tle, unixMicroseconds, state);
    } catch (...) {
        return SGP4StatusTLEError;
    }
}
