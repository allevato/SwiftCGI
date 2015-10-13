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


/// Unit tests for the CGI environment variable parsing extensions to `HTTPHeaders`.
class HTTPHeaders_CGIEnvironmentTest: XCTestCase {

  func testInit_withHTTPHeaders_shouldParseThemWithoutHTTPPrefix() {
    let headers = HTTPHeaders(environment: ["HTTP_FOO_BAR": "baz"])
    XCTAssertEqual(headers["Foo-Bar"], "baz")
  }

  func testInit_withKnownNamesOmittingHTTPPrefix_shouldParseThem() {
    let headers = HTTPHeaders(environment: ["CONTENT_TYPE": "foo", "CONTENT_LENGTH": "100"])
    XCTAssertEqual(headers["Content-Type"], "foo")
    XCTAssertEqual(headers["Content-Length"], "100")
  }

  func testInit_withUnknownNamesOmittingHTTPPrefix_shouldIgnoreThem() {
    let headers = HTTPHeaders(environment: ["FOO": "bar"])
    XCTAssertEqual(headers.headerNames.count, 0)
  }
}
