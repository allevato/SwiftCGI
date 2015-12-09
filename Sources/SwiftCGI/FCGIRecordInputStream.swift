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


/// An input stream that reads its data from FastCGI records (of type `Stdin` or `Data`) read from
/// its underlying stream.
class FCGIRecordInputStream: InputStream {

  /// Denotes whether the records read from the underlying stream are expected to have bodies of
  /// type `Stdin` or `Data`.
  enum BodyType {
    /// Expect `FCGIRecordBody.Stdin` for the records read from the underlying stream.
    case Stdin

    /// Expect `FCGIRecordBody.Data` for the records read from the underlying stream.
    case Data
  }

  /// The underlying stream from which the FastCGI records will be read.
  private let inputStream: InputStream

  /// The expected body type of records read from the underlying stream.
  private let bodyType: BodyType

  /// The buffer that holds data read from the most recent record.
  private var inputBuffer: [UInt8]

  /// The index into the buffer at which the next data will be read.
  private var inputBufferOffset: Int

  /// Indicates whether the final empty record denoting the end of the stream has been read.
  private var endOfStreamReached = false

  /// Creates an input stream that reads FastCGI records from another input stream with the given
  /// expected body type.
  ///
  /// - Parameter inputStream: The input stream from which the FastCGI records will be read.
  /// - Parameter bodyType: The expected body type of records read from the underlying stream.
  init(inputStream: InputStream, bodyType: BodyType) {
    self.inputStream = inputStream
    self.bodyType = bodyType
    inputBuffer = []
    inputBufferOffset = 0
  }

  func read(inout buffer: [UInt8], offset: Int, count: Int) throws -> Int {
    if count == 0 {
      return 0
    }

    if endOfStreamReached {
      throw IOError.EOF
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

  /// Seeking is not supported on FCGI input streams.
  func seek(offset: Int, origin: SeekOrigin) throws -> Int {
    throw IOError.Unsupported
  }

  func close() {
    inputStream.close()
  }

  /// Reads data at most once from the underlying stream.
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
    var available = inputBuffer.count - inputBufferOffset
    if available == 0 {
      // Fill the buffer by reading from the underlying stream.
      inputBuffer = try readNextRecord()
      inputBufferOffset = 0
      available = inputBuffer.count
    }

    let countToCopy = (available < count) ? available : count
    buffer.replaceRange(offset..<offset + countToCopy,
      with: inputBuffer[inputBufferOffset..<inputBufferOffset + countToCopy])
    inputBufferOffset += countToCopy
    return countToCopy
  }

  /// Reads the next record from the stream, verifies that it is the expected type, and returns its
  /// byte array.
  ///
  /// - Returns: The byte array from the body of the next record.
  /// - Throws: `FCGIError.UnexpectedRecordType` if an unexpected record (for example, `.Data` when
  ///   expecting `.Stdin`) is encountered.
  private func readNextRecord() throws -> [UInt8] {
    let record = try FCGIRecord(inputStream: inputStream)
    let buffer: [UInt8]

    switch (record.body, bodyType) {
    case (.Stdin(let bytes), .Stdin):
      buffer = bytes
    case (.Data(let bytes), .Data):
      buffer = bytes
    default:
      throw FCGIError.UnexpectedRecordType
    }

    // The end of the stream is denoted by a final record with no content.
    endOfStreamReached = (buffer.count == 0)
    if endOfStreamReached {
      throw IOError.EOF
    }

    return buffer
  }
}
