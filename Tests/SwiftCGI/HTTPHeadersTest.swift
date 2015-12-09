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


/// Unit tests for the `HTTPHeaders` struct.
class HTTPHeadersTest: XCTestCase {

  /// The instance of `HTTPHeaders` under test.
  private var headers: HTTPHeaders!

  override func setUp() {
    headers = HTTPHeaders()
  }

  func testAdd_shouldAddValue() {
    headers.add("foo", value: "bar")
    XCTAssertEqual(headers["foo"], "bar")
    XCTAssertEqual(headers.getValues("foo")!, ["bar"])
  }

  func testAdd_withSameHeaderName_shouldAddAllValues() {
    headers.add("foo", value: "bar")
    headers.add("foo", value: "baz")
    XCTAssertEqual(headers["foo"], "bar,baz")
    XCTAssertEqual(headers.getValues("foo")!, ["bar", "baz"])
  }

  func testRemove_shouldRemoveAndReturnOldValues() {
    headers.add("foo", value: "bar")
    let removed = headers.remove("foo")
    XCTAssertEqual(headers["foo"], nil)
    XCTAssertEqual(removed!, ["bar"])
  }

  func testRemove_withNonPresentHeader_shouldReturnNil() {
    headers.add("foo", value: "bar")
    let removed = headers.remove("not_foo")
    XCTAssertNil(removed)
  }

  func testHeaderNames_containsAllUniqueHeaderNames() {
    headers.add("foo", value: "bar")
    headers.add("foo", value: "baz")
    headers.add("baz", value: "quux")

    let names = headers.headerNames
    XCTAssertEqual(names.count, 2)
    XCTAssertTrue(names.contains("foo"))
    XCTAssertTrue(names.contains("baz"))
  }

  func testGenerate_shouldReturnMultiValuedHeaderInOrderTheyWereAdded() {
    headers.add("foo", value: "1")
    headers.add("foo", value: "2")
    headers.add("foo", value: "3")

    var generator = headers.generate()

    var next = generator.next()!
    XCTAssertEqual(next.0, "foo")
    XCTAssertEqual(next.1, "1")

    next = generator.next()!
    XCTAssertEqual(next.0, "foo")
    XCTAssertEqual(next.1, "2")

    next = generator.next()!
    XCTAssertEqual(next.0, "foo")
    XCTAssertEqual(next.1, "3")

    XCTAssertNil(generator.next())
  }
}
