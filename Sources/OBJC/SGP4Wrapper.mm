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

#import "SGP4Wrapper.h"
#import <Foundation/Foundation.h>
#import <iostream>
#import <SGP4.h>
#import <Tle.h>
#import <DateTime.h>
#import <CoordGeodetic.h>
#import <Eci.h>
using namespace std;

@implementation SGP4Wrapper

- (SatelliteData* _Nonnull) getSatelliteDataFrom:(TLEWrapper*) tleWrapper date:(NSDate*) date {
	SGP4 (^getSGP4)(void) = ^{

		string first(tleWrapper.title.UTF8String);
		string second(tleWrapper.firstLine.UTF8String);
		string third(tleWrapper.secondLine.UTF8String);

		Tle tle(first, second, third);
		SGP4 sgp4(tle);
		return sgp4;
	};

	SGP4 sgp4 = getSGP4();

    DateTime currentTime = [self dateTimeFrom: date];

	SatelliteData *data = [self issDataFromSgp4:sgp4 Date:currentTime];

	return data;
}

- (DateTime) dateTimeFrom:(NSDate*) date {

	NSCalendar *calendar = [NSCalendar currentCalendar];
	calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];

	int day = static_cast<int>([calendar component:NSCalendarUnitDay fromDate:date]);
	int month = static_cast<int>([calendar component:NSCalendarUnitMonth fromDate:date]);
	int year = static_cast<int>([calendar component:NSCalendarUnitYear fromDate:date]);
	int hour = static_cast<int>([calendar component:NSCalendarUnitHour fromDate:date]);
	int minute = static_cast<int>([calendar component:NSCalendarUnitMinute fromDate:date]);
	int second = static_cast<int>([calendar component:NSCalendarUnitSecond fromDate:date]);
	int micro = static_cast<int>([calendar component:NSCalendarUnitNanosecond fromDate:date] / 1000);

    DateTime time = DateTime(year, month, day, hour, minute, second);
	time.Initialise(year, month, day, hour, minute, second, micro);
	return time;
}

- (SatelliteData *) issDataFromSgp4:(SGP4) sgp4 Date:(DateTime) date {
	Eci eci = sgp4.FindPosition(date);
	CoordGeodetic geo = eci.ToGeodetic();

	double velocity = eci.Velocity().Magnitude() * 3600.0;
	return [[SatelliteData alloc] initWithLatitude:geo.latitude * 180.0 / M_PI longitude:geo.longitude * 180.0 / M_PI speed:velocity altitude:geo.altitude];
}

@end
