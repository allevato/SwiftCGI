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


/// Unit tests for the `BufferingOutputStream` class.
class BufferingOutputStreamTest: XCTestCase {

  /// The underlying output stream to which the buffering stream writes.
  private var underlyingStream: TestOutputStream!

  /// The buffering output stream under test.
  private var bufferingStream: BufferingOutputStream!

  override func setUp() {
    underlyingStream = TestOutputStream()
    bufferingStream = BufferingOutputStream(outputStream: underlyingStream, bufferSize: 4)
  }

  func testWrite_withoutFillingBuffer_shouldNotWriteToUnderlyingStream() {
    XCTAssertNoThrow {
      try bufferingStream.write([ 0x41, 0x42, 0x43 ])
    }
    XCTAssertEqual(underlyingStream.position, 0)
  }

  func testWrite_fillingBufferExactly_shouldNotWriteToUnderlyingStream() {
    XCTAssertNoThrow {
      try bufferingStream.write([ 0x41, 0x42, 0x43, 0x44 ])
    }
    XCTAssertEqual(underlyingStream.position, 0)
  }

  func testWrite_fillingBufferAndThenWritingAgain_shouldFlushOriginalWriteToUnderlyingStream() {
    XCTAssertNoThrow {
      try bufferingStream.write([ 0x41, 0x42, 0x43, 0x44 ])
      try bufferingStream.write([ 0x45 ])
    }
    XCTAssertEqual(underlyingStream.position, 4)
  }

  func testWrite_dataLargerThanBuffer_shouldWriteDirectlyToUnderlyingStream() {
    XCTAssertNoThrow {
      try bufferingStream.write([ 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48 ])
    }
    XCTAssertEqual(underlyingStream.position, 8)
  }

  func testFlush_afterWriting_shouldWriteToUnderlyingStream() {
    XCTAssertNoThrow {
      try bufferingStream.write([ 0x41, 0x42, 0x43 ])
    }
    bufferingStream.flush()
    XCTAssertEqual(underlyingStream.position, 3)
  }

  func testClose_shouldFlushStream() {
    XCTAssertNoThrow {
      try bufferingStream.write([ 0x41, 0x42, 0x43 ])
    }
    bufferingStream.close()
    XCTAssertEqual(underlyingStream.position, 3)
  }
}
