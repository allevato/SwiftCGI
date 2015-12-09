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


/// Unit tests for the `FCGIRecord` struct.
class FCGIRecordTest: XCTestCase {

  func testInit_withPropertyParameters() {
    let record = FCGIRecord(requestID: 5, body: .Params(bytes: [ 1, 2, 3 ]))
    XCTAssertEqual(record.requestID, 5)
    switch record.body {
    case .Params(let bytes):
      XCTAssertEqual(bytes, [ 1, 2, 3 ])
    default:
      XCTFail("Expected body to be UnknownType but was \(record.body)")
    }
  }

  func testInit_withInputStream() {
    let stream = TestInputStream()
    stream.testData = [
      0x01, // version
      0x01, // raw type
      0x00, 0x05, // request ID
      0x00, 0x08, // content length
      0x02, // padding length
      0x00, // reserved byte
      0x00, 0x02, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, // body content
      0x00, 0x00 // padding
    ]

    XCTAssertNoThrow {
      let record = try FCGIRecord(inputStream: stream)
      XCTAssertEqual(record.requestID, 5)
      switch record.body {
      case .BeginRequest(let role, let flags):
        XCTAssertEqual(role, FCGIBeginRequestRole.Authorizer)
        XCTAssertEqual(flags, [ FCGIBeginRequestFlags.KeepConnection ])
      default:
        XCTFail("Expected body to be UnknownType but was \(record.body)")
      }
    }
  }

  func testWrite() {
    let record = FCGIRecord(requestID: 5, body: .Params(bytes: [ 1, 2, 3 ]))
    let stream = TestOutputStream()

    XCTAssertNoThrow {
      try record.write(stream)

      XCTAssertEqual(stream.testData, [
        0x01, // version
        0x04, // raw type
        0x00, 0x05, // request ID
        0x00, 0x03, // content length
        0x05, // padding length
        0x00, // reserved byte
        0x01, 0x02, 0x03, // body content
        0x00, 0x00, 0x00, 0x00, 0x00, // padding
      ])
    }
  }
}
