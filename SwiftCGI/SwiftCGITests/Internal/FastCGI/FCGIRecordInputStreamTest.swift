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


/// Unit tests for the `FCGIRecordInputStream` class.
class FCGIRecordInputStreamTest: XCTestCase {

  private var recordStream: TestOutputStream!

  private var underlyingStream: TestInputStream!

  private var inputStream: FCGIRecordInputStream!

  override func setUp() {
    recordStream = TestOutputStream()
    underlyingStream = TestInputStream()
    inputStream = FCGIRecordInputStream(inputStream: underlyingStream, bodyType: .Stdin)
  }

  func testRead_withEmptyRecord_shouldThrowEOF() {
    XCTAssertNoThrow {
      try addTestRecord(.Stdin(bytes: [ 0xBE, 0xEF, 0xFA, 0xCE ]))
      try addTestRecord(.Stdin(bytes: []))
      underlyingStream.testData = recordStream.testData

      let bytes = try inputStream.readBytes(4)
      XCTAssertEqual(bytes, [ 0xBE, 0xEF, 0xFA, 0xCE ])
    }

    XCTAssertThrow(IOError.EOF) {
      try inputStream.readBytes(1)
    }
  }

  func testRead_withReadSizesAlignedToRecord_shouldReadAllData() {
    XCTAssertNoThrow {
      try addTestRecord(.Stdin(bytes: [ 0xBE, 0xEF ]))
      try addTestRecord(.Stdin(bytes: [ 0xFA, 0xCE ]))
      try addTestRecord(.Stdin(bytes: []))
      underlyingStream.testData = recordStream.testData

      var bytes = try inputStream.readBytes(2)
      XCTAssertEqual(bytes, [ 0xBE, 0xEF ])
      bytes = try inputStream.readBytes(2)
      XCTAssertEqual(bytes, [ 0xFA, 0xCE ])
    }

    XCTAssertThrow(IOError.EOF) {
      try inputStream.readBytes(1)
    }
  }
  
  func testRead_withReadSizeSpanningMultipleRecords_shouldReadAllData() {
    XCTAssertNoThrow {
      try addTestRecord(.Stdin(bytes: [ 0xBE ]))
      try addTestRecord(.Stdin(bytes: [ 0xEF, 0xFA, 0xCE ]))
      try addTestRecord(.Stdin(bytes: []))
      underlyingStream.testData = recordStream.testData

      let bytes = try inputStream.readBytes(4)
      XCTAssertEqual(bytes, [ 0xBE, 0xEF, 0xFA, 0xCE ])
    }
  }

  func testRead_withReadSizesSmallerThanARecord_shouldExhaustRecordBeforeReadingNextOne() {
    XCTAssertNoThrow {
      try addTestRecord(.Stdin(bytes: [ 0xBE, 0xEF, 0xFA, 0xCE, 0x01, 0x02 ]))
      try addTestRecord(.Stdin(bytes: [ 0x03, 0x04 ]))
      try addTestRecord(.Stdin(bytes: []))
      underlyingStream.testData = recordStream.testData

      var bytes = try inputStream.readBytes(3)
      XCTAssertEqual(bytes, [ 0xBE, 0xEF, 0xFA ])
      bytes = try inputStream.readBytes(1)
      XCTAssertEqual(bytes, [ 0xCE ])
      bytes = try inputStream.readBytes(4)
      XCTAssertEqual(bytes, [ 0x01, 0x02, 0x03, 0x04 ])
    }
  }
  
  func testRead_withDataRecords_shouldAlsoReadCorrectly() {
    inputStream = FCGIRecordInputStream(inputStream: underlyingStream, bodyType: .Data)
    XCTAssertNoThrow {
      try addTestRecord(.Data(bytes: [ 0xBE, 0xEF, 0xFA, 0xCE ]))
      try addTestRecord(.Data(bytes: []))
      underlyingStream.testData = recordStream.testData

      let bytes = try inputStream.readBytes(4)
      XCTAssertEqual(bytes, [ 0xBE, 0xEF, 0xFA, 0xCE ])
    }
  }

  func testRead_withUnexpectedBodyType_shouldThrow() {
    XCTAssertNoThrow {
      try addTestRecord(.Data(bytes: [ 0xBE, 0xEF, 0xFA, 0xCE ]))
      try addTestRecord(.Data(bytes: []))
      underlyingStream.testData = recordStream.testData
    }

    XCTAssertThrow(FCGIError.UnexpectedRecordType) {
      try inputStream.readBytes(4)
    }
  }
  
  /// Writes a record with the given body to the test stream.
  ///
  /// - Throws: `IOError` if there was an error writing the record to the test stream.
  private func addTestRecord(body: FCGIRecordBody) throws {
    let record = FCGIRecord(requestID: 1, body: body)
    try record.write(recordStream)
  }
}
