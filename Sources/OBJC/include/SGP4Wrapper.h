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

#import <Foundation/Foundation.h>
#import "SatelliteData.h"
#import "TLEWrapper.h"

NS_ASSUME_NONNULL_BEGIN

const NSErrorDomain SGPKitErrorDomain = @"it.calogerosanfilippo.SPGKitError";

typedef NS_ERROR_ENUM(SGPKitErrorDomain, SGPKitErrorCode) {
    TLE_ERROR = 0,
    SATELLITE_ERROR = 1,
    GENERIC_ERROR = 2
};

@interface SGP4Wrapper : NSObject

- (SatelliteData* _Nullable) getSatelliteDataFrom:(TLEWrapper* _Nonnull) tle date:(NSDate* _Nonnull) date error: (NSError **) error;

@end

NS_ASSUME_NONNULL_END
