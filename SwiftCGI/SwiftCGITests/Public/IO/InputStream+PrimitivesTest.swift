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
/// defined in the `InputStream` protocol.
class InputStream_PrimitivesTest: XCTestCase {

  /// The stream under test.
  private var stream: TestInputStream!

  override func setUp() {
    stream = TestInputStream()
    stream.testData = [0x80, 0x90, 0xA0, 0xB0]
  }

  func testReadInt8_shouldRead1ByteAndReturnValue() {
    XCTAssertNoThrow {
      let actual = try stream.readInt8()
      XCTAssertEqual(actual, -128)
      XCTAssertEqual(stream.position, 1)
    }
  }

  func testReadUInt8_shouldRead1ByteAndReturnValue() {
    XCTAssertNoThrow {
      let actual = try stream.readUInt8()
      XCTAssertEqual(actual, 0x80)
      XCTAssertEqual(stream.position, 1)
    }
  }

  func testReadInt16_shouldRead2BytesAndReturnValue() {
    XCTAssertNoThrow {
      let actual = try stream.readInt16()
      XCTAssertEqual(actual, -28544)
      XCTAssertEqual(stream.position, 2)
    }
  }

  func testReadUInt16_shouldRead2BytesAndReturnValue() {
    XCTAssertNoThrow {
      let actual = try stream.readUInt16()
      XCTAssertEqual(actual, 0x9080)
      XCTAssertEqual(stream.position, 2)
    }
  }

  func testReadInt32_shouldRead4BytesAndReturnValue() {
    XCTAssertNoThrow {
      let actual = try stream.readInt32()
      XCTAssertEqual(actual, -1331654528)
      XCTAssertEqual(stream.position, 4)
    }
  }

  func testReadUInt32_shouldRead4BytesAndReturnValue() {
    XCTAssertNoThrow {
      let actual = try stream.readUInt32()
      XCTAssertEqual(actual, 0xB0A09080)
      XCTAssertEqual(stream.position, 4)
    }
  }

  func testReadBytes_shouldReadTheGivenNumberOfBytesAndReturnAnArray() {
    XCTAssertNoThrow {
      let actual = try stream.readBytes(4)
      XCTAssertEqual(actual, [0x80, 0x90, 0xA0, 0xB0])
    }
  }

  func testReadBytes_givenHigherCountThanAvailable_shouldReadAsMuchAsPossibleButNotThrowEOF() {
    XCTAssertNoThrow {
      let actual = try stream.readBytes(100)
      XCTAssertEqual(actual, [0x80, 0x90, 0xA0, 0xB0])
    }
  }

  func testReadPrimitive_calledMultipleTimes_shouldReturnExpectedValues() {
    XCTAssertNoThrow {
      let actual0 = try stream.readUInt8()
      XCTAssertEqual(actual0, 0x80)
      XCTAssertEqual(stream.position, 1)

      let actual12 = try stream.readUInt16()
      XCTAssertEqual(actual12, 0xA090)
      XCTAssertEqual(stream.position, 3)

      let actual3 = try stream.readUInt8()
      XCTAssertEqual(actual3, 0xB0)
      XCTAssertEqual(stream.position, 4)
    }
  }

  func testReadPrimitive_calledAtEndOfStream_shouldThrowEOF() {
    XCTAssertNoThrow {
      try stream.readUInt32()
    }
    XCTAssertThrow(IOError.EOF) {
      try stream.readUInt8()
    }
  }

  func testReadPrimitive_calledSuchThatItWouldGoPastTheEndOfStream_shouldThrowEOF() {
    XCTAssertNoThrow {
      try stream.readUInt8()
    }
    XCTAssertThrow(IOError.EOF) {
      try stream.readUInt32()
    }
  }
}


/// A stream that lets its contents be set to a contiguous array of bytes for testing, simulating
/// a file stream with those contents.
private class TestInputStream: InputStream {

  /// The array of bytes that will be read by the stream.
  var testData = ContiguousArray<UInt8>() {
    didSet {
      position = 0
    }
  }

  /// The current read position of the stream.
  private(set) var position = 0

  /// Creates a new `TestInputStream`.
  init() {}

  func read(inout buffer: ContiguousArray<UInt8>, offset: Int, count: Int) throws -> Int {
    // If we're already at the end of the stream, bail out immediately.
    if position >= testData.count {
      throw IOError.EOF
    }

    let countToCopy = min(count, testData.count - position)
    buffer.replaceRange(offset..<(offset + countToCopy),
      with: testData[position..<(position + countToCopy)])

    position += countToCopy
    return countToCopy
  }

  func seek(offset: Int, origin: SeekOrigin) throws -> Int {
    // The extension methods under test don't need seek support.
    throw IOError.Unsupported
  }

  func close() {}
}
