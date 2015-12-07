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

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

import XCTest


/// Unit tests for the `DateTime` struct.
class DateTimeTest: XCTestCase {

  func testInit_withMillisecondsSince1970() {
    let x = DateTime(millisecondsSince1970: 4)
    XCTAssertEqual(x.millisecondsSince1970, 4)
  }

  func testInit_withTimeval() {
    let tv = timeval(tv_sec: 4, tv_usec: 123456)
    let x = DateTime(tv: tv)
    XCTAssertEqual(x.millisecondsSince1970, 4123)
  }

  func testEqual_whenValuesAreEqual_shouldBeTrue() {
    let x = DateTime(millisecondsSince1970: 4)
    let y = DateTime(millisecondsSince1970: 4)
    XCTAssertTrue(x == y)
  }

  func testEqual_whenValuesAreNotEqual_shouldBeFalse() {
    let x = DateTime(millisecondsSince1970: 4)
    let y = DateTime(millisecondsSince1970: 8)
    XCTAssertFalse(x == y)
  }

  func testLessThan_whenLhsIsLessThanRhs_shouldBeTrue() {
    let x = DateTime(millisecondsSince1970: 4)
    let y = DateTime(millisecondsSince1970: 8)
    XCTAssertTrue(x < y)
  }

  func testLessThan_whenLhsIsNotLessThanRhs_shouldBeFalse() {
    let x = DateTime(millisecondsSince1970: 8)
    let y = DateTime(millisecondsSince1970: 4)
    XCTAssertFalse(x < y)
  }

  func testHashValue_whenValuesAreEqual_shouldBeEqual() {
    let x = DateTime(millisecondsSince1970: 4)
    let y = DateTime(millisecondsSince1970: 4)
    XCTAssertEqual(x.hashValue, y.hashValue)
  }

  func testAdvanceBy() {
    let x = DateTime(millisecondsSince1970: 4)
    let y = x.advancedBy(10)
    XCTAssertEqual(y.millisecondsSince1970, 14)
  }

  func testDistanceTo() {
    let x = DateTime(millisecondsSince1970: 4)
    let y = DateTime(millisecondsSince1970: 14)
    XCTAssertEqual(x.distanceTo(y), 10)
  }
}
