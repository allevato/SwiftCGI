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


/// Unit tests for the extension methods for reading strings defined in the `InputStream` protocol.
class InputStream_StringsTest: XCTestCase {

  /// The stream under test.
  private var stream: TestInputStream!

  override func setUp() {
    stream = TestInputStream()
    stream.testData = [ 0x41, 0x62, 0x63, 0xF0, 0x9F, 0x90, 0xB1, 0x00, 0x33 ]
  }

  func testReadString_shouldReadToNullByteAndReturnString() {
    XCTAssertNoThrow {
      let string = try stream.readString()
      XCTAssertEqual(string, "Abc🐱")
      XCTAssertEqual(stream.position, 8)
    }
  }

  func testReadString_withCount_shouldReadThatManyBytesAndReturnString() {
    XCTAssertNoThrow {
      let string = try stream.readString(3)
      XCTAssertEqual(string, "Abc")
      XCTAssertEqual(stream.position, 3)
    }
  }

  func testReadString_withCountTooHigh_shouldThrowEOF() {
    XCTAssertThrow(IOError.EOF) {
      try stream.readString(100)
    }
  }
}
