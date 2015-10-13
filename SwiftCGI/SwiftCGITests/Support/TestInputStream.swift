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


/// A stream that lets its contents be set to a contiguous array of bytes for testing, simulating
/// a file stream with those contents.
class TestInputStream: InputStream {

  /// The array of bytes that will be read by the stream.
  var testData = ContiguousArray<UInt8>() {
    didSet {
      position = 0
    }
  }

  /// The current read position of the stream.
  private(set) var position = 0

  /// Creates a new `TestInputStream`.
  init() {}

  func read(inout buffer: ContiguousArray<UInt8>, offset: Int, count: Int) throws -> Int {
    // If we're already at the end of the stream, bail out immediately.
    if position >= testData.count {
      throw IOError.EOF
    }

    let countToCopy = min(count, testData.count - position)
    buffer.replaceRange(offset..<(offset + countToCopy),
      with: testData[position..<(position + countToCopy)])

    position += countToCopy
    return countToCopy
  }

  func seek(offset: Int, origin: SeekOrigin) throws -> Int {
    // The extension methods under test don't need seek support.
    throw IOError.Unsupported
  }
  
  func close() {}
}
