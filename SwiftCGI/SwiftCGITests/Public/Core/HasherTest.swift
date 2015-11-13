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


/// Unit tests for the `Hasher` struct.
class HasherTest: XCTestCase {

  func testInit_withNoArguments_usesKAndRValues_0() {
    let hasher = Hasher()
    XCTAssertEqual(hasher.hashValue, 0)
  }

  func testInit_withNoArguments_usesKAndRValues_1() {
    let v1 = HashValue(hashValue: 10)
    var hasher = Hasher()
    hasher.add(v1)
    XCTAssertEqual(hasher.hashValue, 10 + 31 * 0)
  }

  func testInit_withNoArguments_usesKAndRValues_2() {
    let v1 = HashValue(hashValue: 10)
    let v2 = HashValue(hashValue: 30)
    var hasher = Hasher()
    hasher.add(v1)
    hasher.add(v2)
    XCTAssertEqual(hasher.hashValue, 30 + 31 * (10 + 31 * 0))
  }

  func testInit_withNoArguments_usesKAndRValues_3() {
    let v1 = HashValue(hashValue: 10)
    let v2 = HashValue(hashValue: 30)
    let v3 = HashValue(hashValue: 50)
    var hasher = Hasher()
    hasher.add(v1)
    hasher.add(v2)
    hasher.add(v3)
    XCTAssertEqual(hasher.hashValue, 50 + 31 * (30 + 31 * (10 + 31 * 0)))
  }

  func testInit_withArguments_usesThoseValues_0() {
    let hasher = Hasher(initialValue: 5381, multiplier: 33)
    XCTAssertEqual(hasher.hashValue, 5381)
  }

  func testInit_withArguments_usesThoseValues_1() {
    let v1 = HashValue(hashValue: 10)
    var hasher = Hasher(initialValue: 5381, multiplier: 33)
    hasher.add(v1)
    XCTAssertEqual(hasher.hashValue, 10 + 33 * 5381)
  }

  func testInit_withArguments_usesThoseValues_2() {
    let v1 = HashValue(hashValue: 10)
    let v2 = HashValue(hashValue: 30)
    var hasher = Hasher(initialValue: 5381, multiplier: 33)
    hasher.add(v1)
    hasher.add(v2)
    XCTAssertEqual(hasher.hashValue, 30 + 33 * (10 + 33 * 5381))
  }

  func testInit_withArguments_usesThoseValues_3() {
    let v1 = HashValue(hashValue: 10)
    let v2 = HashValue(hashValue: 30)
    let v3 = HashValue(hashValue: 50)
    var hasher = Hasher(initialValue: 5381, multiplier: 33)
    hasher.add(v1)
    hasher.add(v2)
    hasher.add(v3)
    XCTAssertEqual(hasher.hashValue, 50 + 33 * (30 + 33 * (10 + 33 * 5381)))
  }
}

/// A type that allows its hash value to be set explicitly, for testing.
private struct HashValue: Hashable {
  var hashValue: Int
}

private func ==(lhs: HashValue, rhs: HashValue) -> Bool {
  return lhs.hashValue == rhs.hashValue
}
