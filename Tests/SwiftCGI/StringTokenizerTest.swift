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


/// Unit tests for the `StringTokenizer` struct.
class StringTokenizerTest: XCTestCase {

  /// The tokenizer under test.
  private var tokenizer: StringTokenizer!

  override func setUp() {
    tokenizer = StringTokenizer(string: "foo=bar;baz;quux")
  }

  func testTokenUpToEnd() {
    let token = tokenizer.tokenUpToEnd()
    XCTAssertEqual(token, "foo=bar;baz;quux")
    XCTAssertTrue(tokenizer.done)
  }

  func testTokenUpToDelimiter_whenExcludingDelimiter_shouldReturnNextToken() {
    let token = tokenizer.tokenUpToDelimiter("=")
    XCTAssertEqual(token, "foo")
    XCTAssertFalse(tokenizer.done)
  }

  func testTokenUpToDelimiter_whenIncludingDelimiter_shouldReturnNextTokenAndDelimiter() {
    let token = tokenizer.tokenUpToDelimiter("=", includeDelimiter: true)
    XCTAssertEqual(token, "foo=")
    XCTAssertFalse(tokenizer.done)
  }

  func testTokenUpToDelimiter_whenExcludingLongDelimiter_shouldReturnNextToken() {
    let token = tokenizer.tokenUpToDelimiter("=bar;")
    XCTAssertEqual(token, "foo")
    XCTAssertFalse(tokenizer.done)
  }

  func testTokenUpToDelimiter_whenIncludingLongDelimiter_shouldReturnNextTokenAndDelimiter() {
    let token = tokenizer.tokenUpToDelimiter("=bar;", includeDelimiter: true)
    XCTAssertEqual(token, "foo=bar;")
    XCTAssertFalse(tokenizer.done)
  }
  
  func testTokenUpToDelimiter_whenDelimiterNotFound_shouldReturnNilAndNotMoveIndex() {
    var token = tokenizer.tokenUpToDelimiter("?")
    XCTAssertNil(token)
    XCTAssertFalse(tokenizer.done)

    // The next token should start with "foo" because the index should not have moved.
    token = tokenizer.tokenUpToDelimiter("=")
    XCTAssertEqual(token, "foo")
  }

  func testTokenUpToDelimiterOrEnd_whenExcludingDelimiter_shouldReturnNextToken() {
    let result = tokenizer.tokenUpToDelimiterOrEnd("=")
    XCTAssertEqual(result.token, "foo")
    XCTAssertTrue(result.reachedDelimiter)
    XCTAssertFalse(tokenizer.done)
  }

  func testTokenUpToDelimiterOrEnd_whenIncludingDelimiter_shouldReturnNextTokenAndDelimiter() {
    let result = tokenizer.tokenUpToDelimiterOrEnd("=", includeDelimiter: true)
    XCTAssertEqual(result.token, "foo=")
    XCTAssertTrue(result.reachedDelimiter)
    XCTAssertFalse(tokenizer.done)
  }

  func testTokenUpToDelimiterOrEnd_whenDelimiterNotFound_shouldReturnRestOfString() {
    let result = tokenizer.tokenUpToDelimiterOrEnd("?")
    XCTAssertEqual(result.token, "foo=bar;baz;quux")
    XCTAssertFalse(result.reachedDelimiter)
    XCTAssertTrue(tokenizer.done)
  }

  func testExhaustion() {
    tokenizer = StringTokenizer(string: "foo=bar.baz;quux;floggler")

    var token = tokenizer.tokenUpToDelimiter("=")
    XCTAssertEqual(token, "foo")
    XCTAssertFalse(tokenizer.done)

    token = tokenizer.tokenUpToDelimiter(";")
    XCTAssertEqual(token, "bar.baz")
    XCTAssertFalse(tokenizer.done)

    token = tokenizer.tokenUpToDelimiter(";")
    XCTAssertEqual(token, "quux")
    XCTAssertFalse(tokenizer.done)

    token = tokenizer.tokenUpToDelimiterOrEnd(";").token
    XCTAssertEqual(token, "floggler")
    XCTAssertTrue(tokenizer.done)

    // Once done is true, further calls will return the empty string.
    token = tokenizer.tokenUpToDelimiterOrEnd(";").token
    XCTAssertEqual(token, "")
  }
}
