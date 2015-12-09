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


/// Unit tests for the `HTTPMethod` enumeration.
class HTTPMethodTest: XCTestCase {

  func testInit_withBuildInMethodName_shouldReturnCorrectPredefinedValue() {
    XCTAssertEqual(HTTPMethod(method: "CONNECT"), HTTPMethod.CONNECT)
    XCTAssertEqual(HTTPMethod(method: "DELETE"), HTTPMethod.DELETE)
    XCTAssertEqual(HTTPMethod(method: "GET"), HTTPMethod.GET)
    XCTAssertEqual(HTTPMethod(method: "HEAD"), HTTPMethod.HEAD)
    XCTAssertEqual(HTTPMethod(method: "OPTIONS"), HTTPMethod.OPTIONS)
    XCTAssertEqual(HTTPMethod(method: "PATCH"), HTTPMethod.PATCH)
    XCTAssertEqual(HTTPMethod(method: "POST"), HTTPMethod.POST)
    XCTAssertEqual(HTTPMethod(method: "PUT"), HTTPMethod.PUT)
    XCTAssertEqual(HTTPMethod(method: "TRACE"), HTTPMethod.TRACE)
  }

  func testInit_withNonBuiltInMethodName_shouldReturnOther() {
    XCTAssertEqual(HTTPMethod(method: "NOT_BUILT_IN"), HTTPMethod.Other("NOT_BUILT_IN"))
  }

  func testInit_withNonUppercaseBuiltInMethodName_shouldReturnCorrectPredefinedValue() {
    XCTAssertEqual(HTTPMethod(method: "get"), HTTPMethod.GET)
    XCTAssertEqual(HTTPMethod(method: "gEt"), HTTPMethod.GET)
    XCTAssertEqual(HTTPMethod(method: "GeT"), HTTPMethod.GET)
  }

  func testInit_withNonUppercaseNonBuiltInMethodName_shouldReturnOtherWithUppercaseString() {
    XCTAssertEqual(HTTPMethod(method: "nOt_BuIlT_iN"), HTTPMethod.Other("NOT_BUILT_IN"))
  }
}
