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


/// Unit tests for the `indexOfContentsOf` extension to `CollectionType`.
class CollectionType_IndexOfCollectionTest: XCTestCase {

  private let source = [ 0, 1, 2, 3, 4 ]

  func testIndexOfContentsOf_whenBothAreEmpty_shouldReturnStartIndex() {
    let source: [Int] = []
    XCTAssertEqual(source.indexOfContentsOf([]), source.startIndex)
  }

  func testIndexOfContentsOf_whenBothAreOneElement_shouldReturnStartIndex() {
    let source = [ 0 ]
    XCTAssertEqual(source.indexOfContentsOf([ 0 ]), source.startIndex)
  }

  func testIndexOfContentsOf_whenTargetIsEmpty_shouldReturnStartIndex() {
    XCTAssertEqual(source.indexOfContentsOf([]), source.startIndex)
  }

  func testIndexOfContentsOf_whenTargetIsFirstElement_shouldReturnStartIndex() {
    XCTAssertEqual(source.indexOfContentsOf([ 0 ]), source.startIndex)
  }

  func testIndexOfContentsOf_whenTargetIsFirstElements_shouldReturnStartIndex() {
    XCTAssertEqual(source.indexOfContentsOf([ 0, 1, 2 ]), source.startIndex)
  }

  func testIndexOfContentsOf_whenTargetIsEntireSource_shouldReturnStartIndex() {
    XCTAssertEqual(source.indexOfContentsOf([ 0, 1, 2, 3, 4 ]), source.startIndex)
  }

  func testIndexOfContentsOf_whenTargetIsSupersequenceOfSource_shouldReturnNil() {
    XCTAssertNil(source.indexOfContentsOf([ 0, 1, 2, 3, 4, 5 ]))
  }

  func testIndexOfContentsOf_whenTargetIsLastElement_shouldReturnIndex() {
    XCTAssertEqual(source.indexOfContentsOf([ 4 ]), source.startIndex.advancedBy(4))
  }

  func testIndexOfContentsOf_whenTargetIsLastElements_shouldReturnIndex() {
    XCTAssertEqual(source.indexOfContentsOf([ 3, 4 ]), source.startIndex.advancedBy(3))
  }

  func testIndexOfContentsOf_whenTargetIsMiddleElements_shouldReturnIndex() {
    XCTAssertEqual(source.indexOfContentsOf([ 1, 2, 3 ]), source.startIndex.advancedBy(1))
  }

  func testIndexOfContentsOf_withStrings_shouldReturnIndex() {
    let string = "hello world"
    XCTAssertEqual(string.indexOfContentsOf("lo wo"), string.startIndex.advancedBy(3))
  }
}
