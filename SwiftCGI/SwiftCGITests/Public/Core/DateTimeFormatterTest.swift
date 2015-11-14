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

@testable import SwiftCGI
import XCTest


/// The Unix timestamp corresponding to the time Marty and Jennifer arrived in the future:
/// 21 Oct 2015 6:28 PDT (14:28 UTC).
private let BTTFMartyJenniferArriveFutureMillis = Int64(1445437680000)


/// Unit tests for the `DateTimeFormatter` struct.
class DateTimeFormatterTest: XCTestCase {

  /// The formatter under test.
  private var formatter: DateTimeFormatter!

  override func setUp() {
    formatter = DateTimeFormatter(formatString: "%Y-%m-%dT%H:%M:%S")
  }

  func testFormat_withDateTime() {
    let dateTime = DateTime(millisecondsSince1970: BTTFMartyJenniferArriveFutureMillis)
    let formatted = formatter.format(dateTime)
    XCTAssertEqual(formatted, "2015-10-21T14:28:00")
  }

  func testFormat_withComponents() {
    var components = DateTimeComponents()
    components.year = 2015
    components.month = .October
    components.dayOfMonth = 21
    components.hour = 14
    components.minute = 28
    let formatted = formatter.format(components)
    XCTAssertEqual(formatted, "2015-10-21T14:28:00")
  }

  func testParseDateTime() {
    let dateTime = formatter.parseDateTime("2015-10-21T14:28:00")
    let expected = DateTime(millisecondsSince1970: BTTFMartyJenniferArriveFutureMillis)
    XCTAssertEqual(dateTime, expected)
  }

  func testParseComponents() {
    let components = formatter.parseComponents("2015-10-21T14:28:00")
    XCTAssertNotNil(components)
    if let components = components {
      XCTAssertEqual(components.year, 2015)
      XCTAssertEqual(components.month, DateTimeComponents.Month.October)
      XCTAssertEqual(components.dayOfMonth, 21)
      XCTAssertEqual(components.hour, 14)
      XCTAssertEqual(components.minute, 28)
    }
  }
}
