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


/// Unit tests for the `FCGIRequestHandler` class.
class FCGIRequestHandlerTest: XCTestCase {

  private var recordStream: TestOutputStream!

  private var inputStream: TestInputStream!

  private var outputStream: TestOutputStream!

  override func setUp() {
    recordStream = TestOutputStream()
    inputStream = TestInputStream()
    outputStream = TestOutputStream()
  }

  func testStart_withRequestRecords_shouldWriteResponseRecords() {
    let headers = [ "HTTP_METHOD": "POST" ]
    addTestRecord(1, body: .BeginRequest(role: .Responder, flags: [ .KeepConnection ]))
    addTestRecord(1, body: .Params(bytes: FCGIBytesFromNameValueDictionary(headers)))
    addTestRecord(1, body: .Params(bytes: []))
    addTestRecord(1, body: .Stdin(bytes: Array("request body".utf8)))
    addTestRecord(1, body: .Stdin(bytes: []))
    inputStream.testData = recordStream.testData

    let requestHandler = FCGIRequestHandler(inputStream: inputStream, outputStream: outputStream) {
      (request: HTTPRequest, var response: HTTPResponse) in
      XCTAssertNoThrow {
        // Verify some request properties.
        XCTAssertEqual(request.method, HTTPMethod.GET)
        let requestBody = try request.contentStream.readString()
        XCTAssertEqual(requestBody, "request body")

        // Write some response data.
        response.contentType = "text/plain"
        try response.contentStream.write("response body")
      }
    }

    XCTAssertNoThrow {
      try requestHandler.start()
    }

    // Create records that mimic the expected output so we can test the outcome.
    recordStream = TestOutputStream()
    addTestRecord(1,
        body: .Stdout(bytes: Array("Status: 200\ncontent-type: text/plain\n\nresponse body".utf8)))
    addTestRecord(1, body: .Stdout(bytes: []))
    addTestRecord(1, body: .EndRequest(appStatus: 0, protocolStatus: .RequestComplete))
    XCTAssertEqual(outputStream.testData, recordStream.testData)
  }

  func testStart_withUnexpectedRecordType_shouldThrowUnexpectedRecordType() {
    addTestRecord(1, body: .BeginRequest(role: .Responder, flags: [ .KeepConnection ]))
    addTestRecord(1, body: .GetValuesResult(bytes: []))
    inputStream.testData = recordStream.testData

    let requestHandler = FCGIRequestHandler(inputStream: inputStream, outputStream: outputStream) {
      request, response in return
    }

    XCTAssertThrow(FCGIError.UnexpectedRecordType) {
      try requestHandler.start()
    }
  }

  func testStart_withMultipleBeginRequestRecords_shouldThrowUnexpectedRequestID() {
    addTestRecord(1, body: .BeginRequest(role: .Responder, flags: [ .KeepConnection ]))
    addTestRecord(1, body: .BeginRequest(role: .Responder, flags: [ .KeepConnection ]))
    inputStream.testData = recordStream.testData

    let requestHandler = FCGIRequestHandler(inputStream: inputStream, outputStream: outputStream) {
      request, response in return
    }

    XCTAssertThrow(FCGIError.UnexpectedRequestID) {
      try requestHandler.start()
    }
  }

  func testStart_withRecordsWithDifferentRequestIDs_shouldThrowUnexpectedRequestID() {
    addTestRecord(1, body: .BeginRequest(role: .Responder, flags: [ .KeepConnection ]))
    addTestRecord(2, body: .Params(bytes: []))
    inputStream.testData = recordStream.testData

    let requestHandler = FCGIRequestHandler(inputStream: inputStream, outputStream: outputStream) {
      request, response in return
    }

    XCTAssertThrow(FCGIError.UnexpectedRequestID) {
      try requestHandler.start()
    }
  }

  /// Writes a record with the given body to the test stream.
  ///
  /// - Parameter requestID: The request ID to include in the record.
  /// - Parameter body: The body of the record.
  /// - Throws: `IOError` if there was an error writing the record to the test stream.
  private func addTestRecord(requestID: Int, body: FCGIRecordBody) {
    let record = FCGIRecord(requestID: requestID, body: body)
    XCTAssertNoThrow {
      try record.write(recordStream)
    }
  }
}
