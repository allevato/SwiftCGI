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


/// Wraps another output stream and provides a delegate that is notified when the first write
/// operation is made to the underlying stream.
class WriteNotifyingOutputStream: OutputStream {

  /// The output stream's delegate.
  weak var delegate: WriteNotifyingOutputStreamDelegate?

  /// The stream whose write operations will be monitored.
  private let outputStream: OutputStream

  /// Tracks whether the delegate's `outputStreamWillBeginWriting` method has been called.
  private var hasCalledWillBeginWriting = false

  /// Creates a new output stream that writes to the given file descriptor.
  ///
  /// When using this initializer, the returned stream will *not* be closed automatically if it is
  /// open when the stream is deallocated.
  ///
  /// - Parameter outputStream: The output stream whose write operations should be monitored.
  init(outputStream: OutputStream) {
    self.outputStream = outputStream
  }

  func write(buffer: [UInt8], offset: Int, count: Int) throws {
    if let delegate = delegate where !hasCalledWillBeginWriting {
      hasCalledWillBeginWriting = true
      try delegate.outputStreamWillBeginWriting(self)
    }
    try outputStream.write(buffer, offset: offset, count: count)
  }

  func seek(offset: Int, origin: SeekOrigin) throws -> Int {
    return try outputStream.seek(offset, origin: origin)
  }

  func close() {
    outputStream.close()
  }

  func flush() {
    outputStream.flush()
  }
}
