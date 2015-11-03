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


/// Unit tests for the `FCGIRecordBody` enum.
class FCGIRecordBodyTest: XCTestCase {

  func testInit_withBeginRequest() {
    let stream = TestInputStream()
    stream.testData = [
      0x00, 0x01, // role
      0x01, // flags
      0x00, 0x00, 0x00, 0x00, 0x00 // reserved
    ]

    XCTAssertNoThrow {
      let body = try FCGIRecordBody(
          rawType: 0x01, inputStream: stream, contentLength: stream.testData.count)
      XCTAssertEqual(body.rawType, 1)
      XCTAssertEqual(body.contentLength, 8)

      switch body {
      case .BeginRequest(let role, let flags):
        XCTAssertEqual(role, FCGIBeginRequestRole.Responder)
        XCTAssertTrue(flags.contains(.KeepConnection))
      default:
        XCTFail("Expected BeginRequest but was \(body)")
      }
    }
  }

  func testInit_withAbortRequest() {
    let stream = TestInputStream()

    XCTAssertNoThrow {
      let body = try FCGIRecordBody(
        rawType: 0x02, inputStream: stream, contentLength: stream.testData.count)
      XCTAssertEqual(body.rawType, 2)
      XCTAssertEqual(body.contentLength, 0)

      switch body {
      case .AbortRequest:
        break
      default:
        XCTFail("Expected BeginRequest but was \(body)")
      }
    }
  }

  func testInit_withParams() {
    let stream = TestInputStream()
    stream.testData = [
      0xBE, 0xEF, 0xFA, 0xCE
    ]

    XCTAssertNoThrow {
      let body = try FCGIRecordBody(
        rawType: 0x04, inputStream: stream, contentLength: stream.testData.count)
      XCTAssertEqual(body.rawType, 4)
      XCTAssertEqual(body.contentLength, stream.testData.count)

      switch body {
      case .Params(let bytes):
        XCTAssertEqual(bytes, [ 0xBE, 0xEF, 0xFA, 0xCE ])
      default:
        XCTFail("Expected BeginRequest but was \(body)")
      }
    }
  }

  func testInit_withStdin() {
    let stream = TestInputStream()
    stream.testData = [
      0xBE, 0xEF, 0xFA, 0xCE
    ]

    XCTAssertNoThrow {
      let body = try FCGIRecordBody(
        rawType: 0x05, inputStream: stream, contentLength: stream.testData.count)
      XCTAssertEqual(body.rawType, 5)
      XCTAssertEqual(body.contentLength, stream.testData.count)

      switch body {
      case .Stdin(let bytes):
        XCTAssertEqual(bytes, [ 0xBE, 0xEF, 0xFA, 0xCE ])
      default:
        XCTFail("Expected BeginRequest but was \(body)")
      }
    }
  }

  func testInit_withData() {
    let stream = TestInputStream()
    stream.testData = [
      0xBE, 0xEF, 0xFA, 0xCE
    ]

    XCTAssertNoThrow {
      let body = try FCGIRecordBody(
        rawType: 0x08, inputStream: stream, contentLength: stream.testData.count)
      XCTAssertEqual(body.rawType, 8)
      XCTAssertEqual(body.contentLength, stream.testData.count)

      switch body {
      case .Data(let bytes):
        XCTAssertEqual(bytes, [ 0xBE, 0xEF, 0xFA, 0xCE ])
      default:
        XCTFail("Expected BeginRequest but was \(body)")
      }
    }
  }

  func testInit_withGetValues() {
    let stream = TestInputStream()
    stream.testData = [
      0xBE, 0xEF, 0xFA, 0xCE
    ]

    XCTAssertNoThrow {
      let body = try FCGIRecordBody(
        rawType: 0x09, inputStream: stream, contentLength: stream.testData.count)
      XCTAssertEqual(body.rawType, 9)
      XCTAssertEqual(body.contentLength, stream.testData.count)

      switch body {
      case .GetValues(let bytes):
        XCTAssertEqual(bytes, [ 0xBE, 0xEF, 0xFA, 0xCE ])
      default:
        XCTFail("Expected BeginRequest but was \(body)")
      }
    }
  }

  func testWrite_withEndRequest() {
    let stream = TestOutputStream()

    XCTAssertNoThrow {
      let body = FCGIRecordBody.EndRequest(appStatus: 123, protocolStatus: .RequestComplete)
      try body.write(stream)
      XCTAssertEqual(stream.testData, [ 0x00, 0x00, 0x00, 0x7B, 0x00, 0x00, 0x00, 0x00 ])
      XCTAssertEqual(body.contentLength, 8)
      XCTAssertEqual(body.rawType, 3)
    }
  }

  func testWrite_withStdout() {
    let stream = TestOutputStream()

    XCTAssertNoThrow {
      let body = FCGIRecordBody.Stdout(bytes: [ 0xBE, 0xEF, 0xFA, 0xCE ])
      try body.write(stream)
      XCTAssertEqual(stream.testData, [ 0xBE, 0xEF, 0xFA, 0xCE ])
      XCTAssertEqual(body.contentLength, stream.testData.count)
      XCTAssertEqual(body.rawType, 6)
    }
  }

  func testWrite_withStderr() {
    let stream = TestOutputStream()

    XCTAssertNoThrow {
      let body = FCGIRecordBody.Stderr(bytes: [ 0xBE, 0xEF, 0xFA, 0xCE ])
      try body.write(stream)
      XCTAssertEqual(stream.testData, [ 0xBE, 0xEF, 0xFA, 0xCE ])
      XCTAssertEqual(body.contentLength, stream.testData.count)
      XCTAssertEqual(body.rawType, 7)
    }
  }

  func testWrite_withGetValuesResult() {
    let stream = TestOutputStream()

    XCTAssertNoThrow {
      let body = FCGIRecordBody.GetValuesResult(bytes: [ 0xBE, 0xEF, 0xFA, 0xCE ])
      try body.write(stream)
      XCTAssertEqual(stream.testData, [ 0xBE, 0xEF, 0xFA, 0xCE ])
      XCTAssertEqual(body.contentLength, stream.testData.count)
      XCTAssertEqual(body.rawType, 10)
    }
  }

  func testWrite_withUnknownType() {
    let stream = TestOutputStream()

    XCTAssertNoThrow {
      let body = FCGIRecordBody.UnknownType(type: 1)
      try body.write(stream)
      XCTAssertEqual(stream.testData, [ 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ])
      XCTAssertEqual(body.contentLength, 8)
      XCTAssertEqual(body.rawType, 11)
    }
  }
}
