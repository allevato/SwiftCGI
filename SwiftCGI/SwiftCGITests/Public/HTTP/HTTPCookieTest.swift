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


/// Unit tests for the `HTTPCookie` struct.
class HTTPCookieTest: XCTestCase {

  func testInitializer_shouldSetDefaultValues() {
    let cookie = HTTPCookie(name: "name", value: "value")

    XCTAssertEqual(cookie.name, "name")
    XCTAssertEqual(cookie.value, "value")
    XCTAssertFalse(cookie.secure)
    XCTAssertNil(cookie.domain)
    XCTAssertNil(cookie.expirationTime)
    XCTAssertNil(cookie.path)
  }

  func testHeaderString_withNameAndValueOnly() {
    let cookie = HTTPCookie(name: "name", value: "value")
    XCTAssertEqual(cookie.headerString, "name=value")
  }

  // TODO: Add a test for all values once time zones are working.
}
