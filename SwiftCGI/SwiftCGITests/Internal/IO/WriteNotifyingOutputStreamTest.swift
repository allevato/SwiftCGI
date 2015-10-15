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


/// Unit tests for the `WriteNotifyingOutputStream` class.
class WriteNotifyingOutputStreamTest: XCTestCase {

  /// A test output stream that the notifying stream under test wraps.
  private var underlyingStream: TestOutputStream!

  /// The `WriteNotifyingOutputStream` under test.
  private var notifyingStream: WriteNotifyingOutputStream!

  /// The stream delegate that tracks calls to its methods.
  private var delegate: TestDelegate!

  override func setUp() {
    underlyingStream = TestOutputStream()
    notifyingStream = WriteNotifyingOutputStream(outputStream: underlyingStream)
    delegate = TestDelegate()
    notifyingStream.delegate = delegate
  }

  func testWrite_shouldNotifyDelegate() {
    XCTAssertNoThrow {
      try notifyingStream.write([1,2,3], offset: 0, count: 3)
      XCTAssertEqual(delegate.outputStreamWillBeginWritingCallCount, 1)
    }
  }

  func testWrite_whenCalledMultipleTimes_shouldNotifyDelegateOnlyOnce() {
    XCTAssertNoThrow {
      try notifyingStream.write([1,2,3], offset: 0, count: 3)
      try notifyingStream.write([4,5,6], offset: 0, count: 3)
      XCTAssertEqual(delegate.outputStreamWillBeginWritingCallCount, 1)
    }
  }
}

/// A test delegate for the output stream that tracks calls to its methods.
private class TestDelegate: WriteNotifyingOutputStreamDelegate {

  /// The number of times `outputStreamWillBeginWriting` is called.
  var outputStreamWillBeginWritingCallCount = 0

  func outputStreamWillBeginWriting(outputStream: OutputStream) {
    outputStreamWillBeginWritingCallCount++
  }
}
