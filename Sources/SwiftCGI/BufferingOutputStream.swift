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


/// An output stream that internally buffers the data written to it to improve performance before
/// writing it out in chunks to the underlying output stream.
public class BufferingOutputStream: OutputStream {

  /// The default size of the buffer.
  private static let defaultBufferSize = 16384

  /// The output stream to which this buffering stream writes its output.
  private let outputStream: OutputStream

  /// The buffer that holds data written to the stream before it is flushed to the underlying
  /// stream.
  private var outputBuffer: [UInt8]

  /// The index into the buffer at which the next data will be written.
  private var outputBufferOffset: Int

  /// Creates a new buffering output stream that writes to the given output stream, optionally
  /// specifying the internal buffer size.
  public init(
      outputStream: OutputStream, bufferSize: Int = BufferingOutputStream.defaultBufferSize) {
    self.outputStream = outputStream
    outputBuffer = [UInt8](count: bufferSize, repeatedValue: 0)
    outputBufferOffset = 0
  }

  deinit {
    // Only flush the underlying stream on deinitialization, rather than close it. If the underlying
    // stream wants to be closed, then it will handle that itself when its own deinitializer is
    // executed.
    flush()
  }

  public func write(buffer: [UInt8], offset: Int, count: Int) throws {
    if count > outputBuffer.count {
      // If the amount of data to write is larger than the buffer, flush the buffer and write the
      // new data directly to the underlying stream. This is acceptable behavior since the purpose
      // of the buffer is to reduce I/O thrashing for writes smaller than the buffer size.
      flush()
      try outputStream.write(buffer, offset: offset, count: count)
      return
    }

    // Flush the buffer if there's not enough room for the new data.
    if count > outputBuffer.count - outputBufferOffset {
      flush()
    }

    outputBuffer.replaceRange(
        outputBufferOffset..<(outputBufferOffset + count), with: buffer[offset..<(offset + count)])
    outputBufferOffset += count
  }

  public func seek(offset: Int, origin: SeekOrigin) throws -> Int {
    flush()
    return try outputStream.seek(offset, origin: origin)
  }

  public func flush() {
    guard outputBufferOffset > 0 else {
      return
    }

    do {
      try outputStream.write(outputBuffer, offset: 0, count: outputBufferOffset)
    } catch {
      // Ignore errors that occur during flushing, to avoid requiring flush and close to declare
      // that they throw.
    }

    outputBufferOffset = 0
    outputStream.flush()
  }

  public func close() {
    flush()
    outputStream.close()
  }
}
