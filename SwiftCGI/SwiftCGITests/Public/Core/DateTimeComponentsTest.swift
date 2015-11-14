// Copyright 2015 Tony Allevato
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Darwin
@testable import SwiftCGI
import XCTest


/// The Unix timestamp corresponding to the time Doc Brown sent Einstein back in time one minute:
/// 26 Nov 1985 1:22 PDT (8:22 UTC).
private let BTTFEinsteinDepartsMillis = Int64(499162920000)


/// Unit tests for the `DateTimeComponents` struct.
class DateTimeComponentsTest: XCTestCase {

  func testInit_withDateTimeWithoutMilliseconds() {
    let dateTime = DateTime(millisecondsSince1970: BTTFEinsteinDepartsMillis)
    let components = DateTimeComponents(dateTime: dateTime)
    XCTAssertEqual(components.year, 1985)
    XCTAssertEqual(components.month, DateTimeComponents.Month.October)
    XCTAssertEqual(components.dayOfMonth, 26)
    XCTAssertEqual(components.dayOfWeek, DateTimeComponents.Weekday.Saturday)
    XCTAssertEqual(components.dayOfYear, 298)
    XCTAssertEqual(components.hour, 8)
    XCTAssertEqual(components.minute, 22)
    XCTAssertEqual(components.second, 0)
    XCTAssertEqual(components.millisecond, 0)
  }

  func testInit_withDateTimeWithMilliseconds() {
    let dateTime = DateTime(millisecondsSince1970: BTTFEinsteinDepartsMillis + 789)
    let components = DateTimeComponents(dateTime: dateTime)
    XCTAssertEqual(components.millisecond, 789)
  }
}
