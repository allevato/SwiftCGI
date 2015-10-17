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


/// Unit tests for the `CGIHTTPResponse` class.
class CGIHTTPResponseTest: XCTestCase {

  func testContentStream_whenWritingContent_shouldWriteHeadersFirst() {
    let contentStream = TestOutputStream()
    let response = CGIHTTPResponse(contentStream: contentStream)

    response.headers["Foo"] = "bar"
    XCTAssertNoThrow {
      try response.contentStream.write("body content")
    }
    response.contentStream.flush()

    var writtenBytes = contentStream.testData

    // Append our own null terminator so we can convert it to a string for testing.
    writtenBytes.append(0)
    let writtenString = writtenBytes.withUnsafeBufferPointer { pointer in
      return String.fromCString(UnsafePointer<CChar>(pointer.baseAddress))
    }

    // Verify that the body content was written at the end of the stream.
    let bodyRange = writtenString!.rangeOfString("\n\nbody content")!
    XCTAssertEqual(bodyRange.endIndex, writtenString!.characters.endIndex)

    // Verify that the headers were written before the body content (their relative order does not
    // matter).
    XCTAssertLessThan(
        writtenString!.rangeOfString("Status: 200\n")!.startIndex, bodyRange.startIndex)
    XCTAssertLessThan(
        writtenString!.rangeOfString("content-type: text/plain;charset=utf8\n")!.startIndex,
        bodyRange.startIndex)
    XCTAssertLessThan(writtenString!.rangeOfString("foo: bar\n")!.startIndex, bodyRange.startIndex)
  }
}
