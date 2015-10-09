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


/// Unit tests for the extension methods that provide convenience implementations of functions
/// defined in the `OutputStream` protocol.
class OutputStream_PrimitivesTest: XCTestCase {

  /// The stream under test.
  private var stream: TestOutputStream!

  override func setUp() {
    stream = TestOutputStream()
  }

  func testWrite_takingInt8_shouldWrite1Byte() {
    XCTAssertNoThrow {
      try stream.write(Int8(-128))
      XCTAssertEqual(stream.testData, [ 0x80 ])
      XCTAssertEqual(stream.position, 1)
    }
  }

  func testWrite_takingUInt8_shouldWrite1Byte() {
    XCTAssertNoThrow {
      try stream.write(UInt8(0x80))
      XCTAssertEqual(stream.testData, [ 0x80 ])
      XCTAssertEqual(stream.position, 1)
    }
  }

  func testWrite_takingInt16_shouldWrite2Bytes() {
    XCTAssertNoThrow {
      try stream.write(Int16(-28544))
      XCTAssertEqual(stream.testData, [ 0x80, 0x90 ])
      XCTAssertEqual(stream.position, 2)
    }
  }

  func testWrite_takingUInt16_shouldWrite2Bytes() {
    XCTAssertNoThrow {
      try stream.write(UInt16(0x9080))
      XCTAssertEqual(stream.testData, [ 0x80, 0x90 ])
      XCTAssertEqual(stream.position, 2)
    }
  }

  func testWrite_takingInt32_shouldWrite4Bytes() {
    XCTAssertNoThrow {
      try stream.write(Int32(-1331654528))
      XCTAssertEqual(stream.testData, [ 0x80, 0x90, 0xA0, 0xB0 ])
      XCTAssertEqual(stream.position, 4)
    }
  }

  func testWrite_takingUInt32_shouldWrite4Bytes() {
    XCTAssertNoThrow {
      try stream.write(UInt32(0xB0A09080))
      XCTAssertEqual(stream.testData, [ 0x80, 0x90, 0xA0, 0xB0 ])
      XCTAssertEqual(stream.position, 4)
    }
  }

  func testWrite_takingOnlyAnArray_shouldWriteTheWholeArray() {
    XCTAssertNoThrow {
      try stream.write([ 0x01, 0x02, 0x03, 0x04 ])
      XCTAssertEqual(stream.testData, [ 0x01, 0x02, 0x03, 0x04 ])
      XCTAssertEqual(stream.position, 4)
    }
  }

  func testWritePrimitive_calledMultipleTimes_shouldWriteTheExpectedValues() {
    XCTAssertNoThrow {
      try stream.write(UInt8(0xBE))
      try stream.write(UInt16(0xFAEF))
      try stream.write(UInt8(0xCE))
      XCTAssertEqual(stream.testData, [ 0xBE, 0xEF, 0xFA, 0xCE ])
      XCTAssertEqual(stream.position, 4)
    }
  }
}


/// A stream that writes the data sent to it into a contiguous array of bytes for testing,
/// simulating a file stream with those contents.
private class TestOutputStream: OutputStream {

  /// The array of bytes that will be read by the stream.
  var testData = ContiguousArray<UInt8>()

  /// The current write position of the stream.
  var position: Int {
    return testData.count
  }

  /// Creates a new `TestOutputStream`.
  init() {}

  func write(buffer: ContiguousArray<UInt8>, offset: Int, count: Int) throws {
    testData.appendContentsOf(buffer[offset..<(offset + count)])
  }

  func seek(offset: Int, origin: SeekOrigin) throws -> Int {
    // The extension methods under test don't need seek support.
    throw IOError.Unsupported
  }

  func flush() {}

  func close() {}
}
