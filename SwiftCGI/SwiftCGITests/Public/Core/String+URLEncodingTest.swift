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


/// Unit tests for the URL encoding extensions to the `String` struct.
class String_URLEncodingTest: XCTestCase {

  func testURLEncodedString_shouldReturnSameStringIfOnlyContainsUnreservedCharacters() {
    let string = "AbCdE0369_-.~"
    XCTAssertEqual(string.URLEncodedString, string)
  }

  func testURLEncodedString_shouldReturnStringWithPercentEncodingIfContainsReservedCharacters() {
    XCTAssertEqual("a%0$".URLEncodedString, "a%250%24")
  }

  func testURLEncodedString_shouldHandleUTF8EncodingCorrectly() {
    XCTAssertEqual("d💩b".URLEncodedString, "d%F0%9F%92%A9b")
  }

  func testURLDecodedString_shouldReturnDecodedString() {
    XCTAssertEqual("%25".URLDecodedString, "%")
    XCTAssertEqual("A%25B".URLDecodedString, "A%B")
    XCTAssertEqual("%21%23%24%25%26%27%28%29%2A%2B%2C%2F%3A%3B%3D%3F%40%5B%5D".URLDecodedString,
        "!#$%&'()*+,/:;=?@[]")
    XCTAssertEqual("%21%23%24%25%26%27%28%29%2a%2b%2c%2f%3a%3b%3d%3f%40%5b%5d".URLDecodedString,
        "!#$%&'()*+,/:;=?@[]")
    XCTAssertEqual("%7e".URLDecodedString, "~")
  }

  func testURLDecodedString_shouldReturnNilWhenPercentIsFollowedByNonHexDigits() {
    XCTAssertNil("%G4".URLDecodedString)
    XCTAssertNil("%4G".URLDecodedString)
    XCTAssertNil("%25%G4".URLDecodedString)
    XCTAssertNil("%25%4G".URLDecodedString)
  }

  func testURLDecodedString_shouldReturnNilWhenStringEndsEarly() {
    XCTAssertNil("%".URLDecodedString)
    XCTAssertNil("%2".URLDecodedString)
    XCTAssertNil("%25%".URLDecodedString)
    XCTAssertNil("%25%2".URLDecodedString)
  }

  func testURLDecodedString_shouldHandleUTF8EncodingCorrectly() {
    XCTAssertEqual("d%F0%9F%92%A9b".URLDecodedString, "d💩b")
  }
}
