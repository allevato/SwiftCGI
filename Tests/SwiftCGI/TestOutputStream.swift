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


/// A stream that writes the data sent to it into an array of bytes for testing, simulating a file
/// stream with those contents.
class TestOutputStream: OutputStream {

  /// The array of bytes that will be read by the stream.
  var testData = [UInt8]()

  /// The current write position of the stream.
  var position: Int {
    return testData.count
  }

  /// Creates a new `TestOutputStream`.
  init() {}

  func write(buffer: [UInt8], offset: Int, count: Int) throws {
    testData.appendContentsOf(buffer[offset..<(offset + count)])
  }

  func seek(offset: Int, origin: SeekOrigin) throws -> Int {
    // The extension methods under test don't need seek support.
    throw IOError.Unsupported
  }

  func flush() {}

  func close() {}
}
