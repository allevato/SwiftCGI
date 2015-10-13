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


/// Unit tests for the `CGIHTTPRequest` class.
class CGIHTTPRequestTest: XCTestCase {

  let contentStream = TestInputStream()

  func testInit_shouldPopulateValuesFromEnvironment() {
    let environment = [
      "REQUEST_METHOD": "POST",
      "QUERY_STRING": "foo=bar",
      "PATH_INFO": "path/to/file",
      "PATH_TRANSLATED": "translated/path",
      "USER_AGENT": "Fake Browser",
      "CONTENT_LENGTH": "500",
      "CONTENT_TYPE": "foo/bar",
      "HTTP_FOO": "bar",
    ]
    let request = CGIHTTPRequest(environment: environment, contentStream: contentStream)

    XCTAssertEqual(request.method, HTTPMethod.POST)
    XCTAssertEqual(request.queryString, "foo=bar")
    XCTAssertEqual(request.path, "path/to/file")
    XCTAssertEqual(request.translatedPath, "translated/path")
    XCTAssertEqual(request.userAgent, "Fake Browser")
    XCTAssertEqual(request.contentLength, 500)
    XCTAssertEqual(request.contentType, "foo/bar")
    XCTAssertEqual(request.headers["Foo"], "bar")
  }

  func testInit_withMissingEnvironmentVariables_shouldPopulateValuesWithDefaults() {
    let request = CGIHTTPRequest(environment: [:], contentStream: contentStream)

    XCTAssertEqual(request.method, HTTPMethod.GET)
    XCTAssertNil(request.queryString)
    XCTAssertNil(request.path)
    XCTAssertNil(request.translatedPath)
    XCTAssertEqual(request.userAgent, "")
    XCTAssertEqual(request.contentLength, 0)
    XCTAssertEqual(request.contentType, "")
    XCTAssertEqual(request.headers.headerNames.count, 0)
  }
}
