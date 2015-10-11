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

import SwiftCGI
import XCTest


/// Unit tests for the `HTTPStatus` struct and pre-defined named codes.
public class HTTPStatusTest: XCTestCase {

  public func testEquality_valuesWithSameCode_shouldBeEqualAndHaveSameHashCode() {
    let value1 = HTTPStatus(code: 404)
    let value2 = HTTPStatus(code: 404)
    XCTAssertTrue(value1 == value2)
    XCTAssertEqual(value1.hashValue, value2.hashValue)
  }

  public func
      testEquality_namedValueAndValueWithSameCode_shouldBeEqualAndHaveSameHashCode() {
    let value1 = HTTPStatus(code: 404)
    let value2 = HTTPStatus.NotFound
    XCTAssertTrue(value1 == value2)
    XCTAssertEqual(value1.hashValue, value2.hashValue)
  }

  public func testEquality_valuesWithDifferentCodes_shouldNotBeEqual() {
    let value1 = HTTPStatus(code: 404)
    let value2 = HTTPStatus(code: 405)
    XCTAssertFalse(value1 == value2)
  }
}
