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


/// Unit tests for the `CGIServer` class.
class CGIServerTest: XCTestCase {

  private var environment: [String: String]!
  private var requestStream: TestInputStream!
  private var responseStream: TestOutputStream!
  private var server: CGIServer!

  override func setUp() {
    environment = [
      "REQUEST_METHOD": "POST",
      "QUERY_STRING": "foo=bar",
      "PATH_INFO": "path/to/file",
      "PATH_TRANSLATED": "translated/path",
      "USER_AGENT": "Fake Browser",
      "CONTENT_LENGTH": "500",
      "CONTENT_TYPE": "foo/bar",
      "HTTP_FOO": "bar",
    ]

    requestStream = TestInputStream()
    requestStream.testData = [0x41, 0x42, 0x43]

    responseStream = TestOutputStream()

    server = CGIServer(
        environment: environment, requestStream: requestStream, responseStream: responseStream)
  }

  func testListen_shouldCallHandler_withCorrectRequest() {
    server.listen { request, response in
      XCTAssertEqual(request.method, HTTPMethod.POST)
      XCTAssertEqual(request.queryString, "foo=bar")
      XCTAssertEqual(request.path, "path/to/file")
      XCTAssertEqual(request.translatedPath, "translated/path")
      XCTAssertEqual(request.userAgent, "Fake Browser")
      XCTAssertEqual(request.contentLength, 500)
      XCTAssertEqual(request.contentType, "foo/bar")
      XCTAssertEqual(request.headers["Foo"], "bar")

      self.XCTAssertNoThrow {
        let bytes = try request.contentStream.readBytes(3)
        XCTAssertEqual(bytes, [0x41, 0x42, 0x43])
      }
    }
  }

  func testListen_whenWritingToResponse_writesToOutputStream() {
    let dataToWrite: [UInt8] = [0x41, 0x42, 0x43]
    server.listen { request, response in
      self.XCTAssertNoThrow {
        try response.contentStream.write(dataToWrite)
      }
    }

    let count = responseStream.testData.count
    XCTAssertEqual(responseStream.testData[count - 3..<count], dataToWrite[0..<3])
  }
}
