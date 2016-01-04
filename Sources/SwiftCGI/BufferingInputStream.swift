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


/// An input stream that internally loads chunks of data into an internal buffer and serves read
/// requests from it to improve performance.
public class BufferingInputStream: InputStream {

  /// The default size of the buffer.
  private static let defaultBufferSize = 16384

  /// The input stream from which this buffering stream reads its input.
  private let inputStream: InputStream

  /// The buffer that holds data read from the underlying stream.
  private var inputBuffer: [UInt8]

  /// The number of bytes in the input buffer that are actually filled with valid data.
  private var inputBufferCount: Int

  /// The index into the buffer at which the next data will be read.
  private var inputBufferOffset: Int

  /// Creates a new buffering input stream that reads from the given input stream, optionally
  /// specifying the internal buffer size.
  public init(
      inputStream: InputStream, bufferSize: Int = BufferingInputStream.defaultBufferSize) {
    self.inputStream = inputStream
    inputBuffer = [UInt8](count: bufferSize, repeatedValue: 0)
    inputBufferCount = 0
    inputBufferOffset = 0
  }

  public func read(inout buffer: [UInt8], offset: Int, count: Int) throws -> Int {
    if count == 0 {
      return 0
    }

    // Repeatedly read from the stream until we've gotten the requested number of bytes or reached
    // the end of the stream.
    var readSoFar = 0
    while readSoFar < count {
      let remaining = count - readSoFar

      do {
        let readThisTime = try readFromUnderlyingStream(
            &buffer, offset: offset + readSoFar, count: remaining)

        readSoFar += readThisTime
        if readThisTime == 0 {
          return readSoFar
        }
      } catch IOError.EOF {
        // Only allow EOF to be thrown if it's the first time we're trying to read. If we get an EOF
        // from the underlying stream after successfully reading some data, we just return the count
        // that was actually read.
        if readSoFar > 0 {
          return readSoFar
        }
        throw IOError.EOF
      }
    }

    return readSoFar
  }

  public func seek(offset: Int, origin: SeekOrigin) throws -> Int {
    // TODO: Support seeking.
    throw IOError.Unsupported
  }

  public func close() {
//    inputStream.close()
  }

  /// Reads data at most once from the underlying stream, filling the buffer if necessary.
  ///
  /// - Parameter buffer: The array into which the data should be written.
  /// - Parameter offset: The byte offset in `buffer` into which to start writing data.
  /// - Parameter count: The maximum number of bytes to read from the stream.
  /// - Returns: The number of bytes that were actually read. This can be less than the requested
  ///   number of bytes if that many bytes are not available, or 0 if the end of the stream is
  ///   reached.
  /// - Throws: `IOError` if an error other than reaching the end of the stream occurs.
  private func readFromUnderlyingStream(
      inout buffer: [UInt8], offset: Int, count: Int) throws -> Int {
    var available = inputBufferCount - inputBufferOffset
    if available == 0 {
      // If there is nothing currently in the buffer and the requested count is at least as large as
      // the buffer, then just read the data directly from the underlying stream. This is acceptable
      // since the purpose of the buffer is to reduce I/O thrashing, and breaking a larger read into
      // multiple smaller ones would have the opposite effect.
      if count >= inputBuffer.count {
        return try inputStream.read(&buffer, offset: offset, count: count)
      }

      // Fill the buffer by reading from the underlying stream.
      inputBufferCount = try inputStream.read(&inputBuffer, offset: 0, count: inputBuffer.count)
      inputBufferOffset = 0
      available = inputBufferCount

      if inputBufferCount == 0 {
        throw IOError.EOF
      }
    }

    let countToCopy = (available < count) ? available : count
    buffer.replaceRange(offset..<offset + countToCopy,
        with: inputBuffer[inputBufferOffset..<inputBufferOffset + countToCopy])
    inputBufferOffset += countToCopy
    return countToCopy
  }
}
