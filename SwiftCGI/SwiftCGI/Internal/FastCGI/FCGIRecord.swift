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


/// The version of the FastCGI specification that we implement.
private let FCGI_VERSION = 1


/// A FastCGI record received by or sent to the web server as part of the request/response process.
struct FCGIRecord {

  /// The version of the FastCGI specification used to create this record.
  let version: Int

  /// The numeric ID of the request, which is used to distinguish it from other contemporaneous
  /// requests.
  let requestID: Int

  /// The record's body, which also encodes its type.
  let body: FCGIRecordBody

  /// The amount of padding, in bytes, following the record body.
  let paddingLength: Int

  /// Creates a new FastCGI record read from the given input stream.
  ///
  /// - Parameter inputStream: The input stream from which to read the record.
  /// - Throws: `IOError` if an I/O error occurs.
  init(inputStream: InputStream) throws {
    version = Int(try inputStream.readInt8())
    let rawType = try inputStream.readInt8()
    requestID = Int(try inputStream.readInt16().bigEndian)
    let contentLength = Int(try inputStream.readInt16().bigEndian)
    paddingLength = Int(try inputStream.readInt8())
    _ = try inputStream.readInt8() // reserved byte

    body = try FCGIRecordBody(
      rawType: rawType, inputStream: inputStream, contentLength: contentLength)
    try inputStream.readBytes(paddingLength)
  }

  /// Creates a new FastCGI with the given properties.
  ///
  /// - Parameter requestID: The numeric ID of the request.
  /// - Parameter body: The record's body.
  /// - Parameter paddingLength: The amount of padding to write after the body content.
  init(requestID: Int, body: FCGIRecordBody, paddingLength: Int) {
    version = FCGI_VERSION
    self.requestID = requestID
    self.body = body
    self.paddingLength = paddingLength
  }

  /// Writes the record to the given output stream.
  ///
  /// - Parameter outputStream: The output stream to which to write the record.
  /// - Throws: `IOError` if an I/O error occurs.
  func write(outputStream: OutputStream) throws {
    try outputStream.write(Int8(version))
    try outputStream.write(Int8(body.rawType))
    try outputStream.write(Int16(requestID).bigEndian)
    try outputStream.write(Int16(body.contentLength).bigEndian)
    try outputStream.write(Int8(paddingLength))
    try outputStream.write(Int8(0)) // reserved byte

    try body.write(outputStream)
    if paddingLength > 0 {
      try outputStream.write([UInt8](count: paddingLength, repeatedValue: 0))
    }
  }
}
