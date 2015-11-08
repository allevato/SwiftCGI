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


/// An output stream that writes its data in the form of FastCGI records (of type `Stdout` or
/// `Stderr`) to its underlying stream.
class FCGIRecordOutputStream: OutputStream {

  /// Denotes whether the records written to the underlying stream have bodies of type `Stdout` or
  /// `Stderr`.
  enum BodyType {
    /// Use `FCGIRecordBody.Stdout` for the records written to the underlying stream.
    case Stdout

    /// Use `FCGIRecordBody.Stderr` for the records written to the underlying stream.
    case Stderr
  }

  /// The underlying stream to which the FastCGI records will be written.
  private let outputStream: OutputStream

  /// The request ID that will be set on each of the written records.
  private let requestID: Int

  /// The body type of records written to the underlying stream.
  private let bodyType: BodyType

  /// Creates an output stream that writes FastCGI records to another output stream with the given
  /// request ID and body type.
  ///
  /// - Parameter outputStream: The output stream to which the FastCGI records will be written.
  /// - Parameter requestID: The request ID that will be set on each of the written records.
  /// - Parameter bodyType: The body type of records written to the underlying stream.
  init(outputStream: OutputStream, requestID: Int, bodyType: BodyType) {
    self.outputStream = outputStream
    self.requestID = requestID
    self.bodyType = bodyType
  }

  func write(buffer: ContiguousArray<UInt8>, offset: Int, count: Int) throws {
    let subsequence = buffer[offset..<(offset + count)]
    let record = recordWithBytes(ContiguousArray(subsequence))
    try record.write(outputStream)
  }

  func close() {
    flush()
    outputStream.close()
  }

  func flush() {
    let record = recordWithBytes([])

    // Ignore errors when flushing.
    do {
      try record.write(outputStream)
    } catch {}

    outputStream.flush()
  }

  /// Seeking is not supported on FCGI output streams.
  func seek(offset: Int, origin: SeekOrigin) throws -> Int {
    throw IOError.Unsupported
  }

  /// Returns a new FCGI record with the given bytes. The record's body type is determined by the
  /// record type of the stream.
  ///
  /// - Parameter bytes: The bytes to write in the FCGI record.
  /// - Returns: A new FCGI record with the given data.
  private func recordWithBytes(bytes: ContiguousArray<UInt8>) -> FCGIRecord {
    let recordBody: FCGIRecordBody
    switch bodyType {
    case .Stdout: recordBody = .Stdout(bytes: bytes)
    case .Stderr: recordBody = .Stderr(bytes: bytes)
    }
    return FCGIRecord(requestID: requestID, body: recordBody, paddingLength: 0)
  }
}
