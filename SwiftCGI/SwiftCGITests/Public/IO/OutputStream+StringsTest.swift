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


/// Unit tests for the extension methods for writing strings defined in the `OutputStream` protocol.
class OutputStream_StringsTest: XCTestCase {

  /// The stream under test.
  private var stream: TestOutputStream!

  override func setUp() {
    stream = TestOutputStream()
  }

  func testWrite_takingStringAndDefaultNullTermination_shouldWriteUTF8WithNoNullByte() {
    XCTAssertNoThrow {
      try stream.write("Abc🐱")
      XCTAssertEqual(stream.testData, [ 0x41, 0x62, 0x63, 0xF0, 0x9F, 0x90, 0xB1 ])
    }
  }

  func testWrite_takingStringAndFalseNullTermination_shouldWriteUTF8WithNoNullByte() {
    XCTAssertNoThrow {
      try stream.write("Abc🐱", nullTerminated: false)
      XCTAssertEqual(stream.testData, [ 0x41, 0x62, 0x63, 0xF0, 0x9F, 0x90, 0xB1 ])
    }
  }

  func testWrite_takingStringAndTrueNullTermination_shouldWriteUTF8WithNullByte() {
    XCTAssertNoThrow {
      try stream.write("Abc🐱", nullTerminated: true)
      XCTAssertEqual(stream.testData, [ 0x41, 0x62, 0x63, 0xF0, 0x9F, 0x90, 0xB1, 0x00 ])
    }
  }
}
