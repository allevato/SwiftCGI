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


/// Unit tests for the `BufferingInputStream` class.
class BufferingInputStreamTest: XCTestCase {

  /// The underlying input stream from which the buffering stream reads.
  private var underlyingStream: TestInputStream!

  /// The buffering input stream under test.
  private var bufferingStream: BufferingInputStream!

  override func setUp() {
    underlyingStream = TestInputStream()
    underlyingStream.testData = [ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09 ]
    bufferingStream = BufferingInputStream(inputStream: underlyingStream, bufferSize: 4)
  }

  func testRead_countLargerThanBuffer_shouldReadDirectlyFromUnderlyingStringIfZeroAligned() {
    XCTAssertNoThrow {
      let bytes = try bufferingStream.readBytes(5)
      XCTAssertEqual(bytes, [ 0x01, 0x02, 0x03, 0x04, 0x05 ])
    }
    XCTAssertEqual(underlyingStream.position, 5)
  }

  func testRead_countLargerThanBuffer_shouldUseBufferIfNotZeroAligned() {
    XCTAssertNoThrow {
      var bytes = try bufferingStream.readBytes(1)
      XCTAssertEqual(bytes, [ 0x01 ])
      bytes = try bufferingStream.readBytes(5)
      XCTAssertEqual(bytes, [ 0x02, 0x03, 0x04, 0x05, 0x06 ])
      bytes = try bufferingStream.readBytes(1)
      XCTAssertEqual(bytes, [ 0x07 ])
    }
    XCTAssertEqual(underlyingStream.position, 8)
  }

  func testRead_countLargerThanUnderlyingStream_shouldOnlyReadWhatIsAvailable() {
    XCTAssertNoThrow {
      let bytes = try bufferingStream.readBytes(underlyingStream.testData.count + 10)
      XCTAssertEqual(bytes, underlyingStream.testData)
    }
    XCTAssertEqual(underlyingStream.position, underlyingStream.testData.count)
  }

  func testRead_countSmallerThanBuffer_shouldNotRefillBufferUntilNeeded() {
    XCTAssertNoThrow {
      var byte = try bufferingStream.readUInt8()
      XCTAssertEqual(byte, 0x01)
      XCTAssertEqual(underlyingStream.position, 4)

      byte = try bufferingStream.readUInt8()
      XCTAssertEqual(byte, 0x02)
      XCTAssertEqual(underlyingStream.position, 4)

      byte = try bufferingStream.readUInt8()
      XCTAssertEqual(byte, 0x03)
      XCTAssertEqual(underlyingStream.position, 4)

      byte = try bufferingStream.readUInt8()
      XCTAssertEqual(byte, 0x04)
      XCTAssertEqual(underlyingStream.position, 4)

      byte = try bufferingStream.readUInt8()
      XCTAssertEqual(byte, 0x05)
      XCTAssertEqual(underlyingStream.position, 8)
    }
  }

  func testRead_readingAtEndOfBuffer_shouldHandleEOFCorrectly() {
    XCTAssertNoThrow {
      var bytes = try bufferingStream.readBytes(8)
      XCTAssertEqual(bytes, [ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08 ])

      bytes = try bufferingStream.readBytes(1)
      XCTAssertEqual(bytes, [ 0x09 ])
    }

    XCTAssertThrow(IOError.EOF) {
      try bufferingStream.readBytes(1)
    }
  }

  func testRead_readingPastEndOfBuffer_shouldHandleEOFCorrectly() {
    XCTAssertNoThrow {
      var bytes = try bufferingStream.readBytes(8)
      XCTAssertEqual(bytes, [ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08 ])

      bytes = try bufferingStream.readBytes(2)
      XCTAssertEqual(bytes, [ 0x09 ])
    }

    XCTAssertThrow(IOError.EOF) {
      try bufferingStream.readBytes(1)
    }
  }
}
