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


/// Unit tests for the `FCGIRecordOutputStream` class.
class FCGIRecordOutputStreamTest: XCTestCase {

  private var underlyingStream: TestOutputStream!

  private var outputStream: FCGIRecordOutputStream!

  override func setUp() {
    underlyingStream = TestOutputStream()
    outputStream =
        FCGIRecordOutputStream(outputStream: underlyingStream, requestID: 1, bodyType: .Stdout)
  }

  func testWrite_shouldWriteRecordWithExpectedContent() {
    XCTAssertNoThrow {
      try outputStream.write([ 0xBE, 0xEF, 0xFA, 0xCE ])
    }

    XCTAssertEqual(underlyingStream.testData, [
      0x01, // version
      0x06, // FCGI_STDOUT
      0x00, 0x01, // request ID
      0x00, 0x04, // body content length
      0x00, // padding length
      0x00, // reserved
      0xBE, 0xEF, 0xFA, 0xCE
    ])
  }

  func testWrite_withMultipleWrites_shouldWriteMultipleRecords() {
    XCTAssertNoThrow {
      try outputStream.write([ 0xBE ])
      try outputStream.write([ 0xEF, 0xFA, 0xCE ])
    }

    XCTAssertEqual(underlyingStream.testData, [
      0x01, // version
      0x06, // FCGI_STDOUT
      0x00, 0x01, // request ID
      0x00, 0x01, // body content length
      0x00, // padding length
      0x00, // reserved
      0xBE,
      0x01, // version
      0x06, // FCGI_STDOUT
      0x00, 0x01, // request ID
      0x00, 0x03, // body content length
      0x00, // padding length
      0x00, // reserved
      0xEF, 0xFA, 0xCE
    ])
  }
  
  func testWrite_withStderrBodyType_shouldWriteRecordWithExpectedContent() {
    outputStream =
      FCGIRecordOutputStream(outputStream: underlyingStream, requestID: 1, bodyType: .Stderr)

    XCTAssertNoThrow {
      try outputStream.write([ 0xBE, 0xEF, 0xFA, 0xCE ])
    }

    XCTAssertEqual(underlyingStream.testData, [
      0x01, // version
      0x07, // FCGI_STDERR
      0x00, 0x01, // request ID
      0x00, 0x04, // body content length
      0x00, // padding length
      0x00, // reserved
      0xBE, 0xEF, 0xFA, 0xCE
    ])
  }

  func testWrite_withBufferedWriter() {
    let recordStream =
      FCGIRecordOutputStream(outputStream: underlyingStream, requestID: 1, bodyType: .Stdout)
    let outputStream = BufferingOutputStream(outputStream: recordStream)

    XCTAssertNoThrow {
      try outputStream.write([ 0xBE, 0xEF ])
      try outputStream.write([ 0xFA, 0xCE ])
      outputStream.flush()
    }

    XCTAssertEqual(underlyingStream.testData, [
      0x01, // version
      0x06, // FCGI_STDOUT
      0x00, 0x01, // request ID
      0x00, 0x04, // body content length
      0x00, // padding length
      0x00, // reserved
      0xBE, 0xEF, 0xFA, 0xCE,
      0x01, // version
      0x06, // FCGI_STDOUT
      0x00, 0x01, // request ID
      0x00, 0x00, // body content length
      0x00, // padding length
      0x00, // reserved
    ])
  }

  func testFlush_shouldWriteEmptyRecord() {
    outputStream.flush()

    XCTAssertEqual(underlyingStream.testData, [
      0x01, // version
      0x06, // FCGI_STDOUT
      0x00, 0x01, // request ID
      0x00, 0x00, // body content length
      0x00, // padding length
      0x00, // reserved
    ])
  }
}
