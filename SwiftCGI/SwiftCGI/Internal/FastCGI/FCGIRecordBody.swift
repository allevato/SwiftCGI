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


// The raw numeric types of FastCGI records.
private let FCGI_BEGIN_REQUEST: Int8 = 1
private let FCGI_ABORT_REQUEST: Int8 = 2
private let FCGI_END_REQUEST: Int8 = 3
private let FCGI_PARAMS: Int8 = 4
private let FCGI_STDIN: Int8 = 5
private let FCGI_STDOUT: Int8 = 6
private let FCGI_STDERR: Int8 = 7
private let FCGI_DATA: Int8 = 8
private let FCGI_GET_VALUES: Int8 = 9
private let FCGI_GET_VALUES_RESULT: Int8 = 10
private let FCGI_UNKNOWN_TYPE: Int8 = 11


/// Represents the type of a FastCGI record along with the body content associated with a record of
/// that type.
enum FCGIRecordBody {

  /// Sent by the web server to indicate the start of a new request.
  case BeginRequest(role: FCGIBeginRequestRole, flags: FCGIBeginRequestFlags)

  /// Sent by the web server to abort a request. The application should respond as soon as possible
  /// with an `EndRequest` record.
  case AbortRequest

  /// Sent to the web server to terminate a request, either because it has successfully finished
  /// responding to it or because the application has rejected the request.
  /// TODO: Add associated values.
  case EndRequest(appStatus: Int, protocolStatus: FCGIProtocolStatus)

  /// Sent by the web server to pass name-value pairs to the application. The content type for this
  /// record is a raw byte array because a server could send the name-value pairs using multiple
  /// records, even split in the middle of a name or value, so they must all be concatenated before
  /// parsing them.
  case Params(bytes: ContiguousArray<UInt8>)

  /// Sent by the web server to send a stream of input to the application.
  case Stdin(bytes: ContiguousArray<UInt8>)

  /// Sent to the web server to send output back from the application.
  case Stdout(bytes: ContiguousArray<UInt8>)

  /// Sent to the web server to send error logs back from the application.
  case Stderr(bytes: ContiguousArray<UInt8>)

  /// Sent by the web server to send a stream of additional data to the application.
  case Data(bytes: ContiguousArray<UInt8>)

  /// Sent by the web server to query specific variables within the application. The application
  /// should respond with a `GetValuesResult` record.
  case GetValues(bytes: ContiguousArray<UInt8>)

  /// Sent to the web server to convey the result of a `GetValues` request.
  case GetValuesResult(bytes: ContiguousArray<UInt8>)

  /// Sent to the web server when it receives a management record whose type it does not recognize.
  case UnknownType(type: Int8)

  /// Initializes an instance of `FCGIRecordBody` based on the given raw type, with its content read
  /// from the given input stream.
  ///
  /// - Parameter rawType: The raw type of the record read from the stream.
  /// - Parameter inputStream: The input stream from which to read the content of the record body.
  /// - Parameter contentLength: The length of the content of the record body.
  /// - Throws: `IOError` if an I/O error occurred.
  init(rawType: Int8, inputStream: InputStream, contentLength: Int) throws {
    switch rawType {
    case FCGI_BEGIN_REQUEST:
      let role = FCGIBeginRequestRole(rawValue: try inputStream.readInt16().bigEndian)!
      let flags = FCGIBeginRequestFlags(rawValue: try inputStream.readInt8())
      _ = try inputStream.readBytes(5)
      self = .BeginRequest(role: role, flags: flags)
    case FCGI_ABORT_REQUEST:
      self = .AbortRequest
    case FCGI_PARAMS:
      self = .Params(bytes: try inputStream.readBytes(contentLength))
    case FCGI_STDIN:
      self = .Stdin(bytes: try inputStream.readBytes(contentLength))
    case FCGI_DATA:
      self = .Data(bytes: try inputStream.readBytes(contentLength))
    case FCGI_GET_VALUES:
      self = .GetValues(bytes: try inputStream.readBytes(contentLength))
    default:
      fatalError("Record type \(rawType) cannot be read from the web server, only written")
    }
  }

  /// The numeric code representing the receiver's record type.
  var rawType: Int8 {
    switch self {
    case .BeginRequest: return FCGI_BEGIN_REQUEST
    case .AbortRequest: return FCGI_ABORT_REQUEST
    case .EndRequest: return FCGI_END_REQUEST
    case .Params: return FCGI_PARAMS
    case .Stdin: return FCGI_STDIN
    case .Stdout: return FCGI_STDOUT
    case .Stderr: return FCGI_STDERR
    case .Data: return FCGI_DATA
    case .GetValues: return FCGI_GET_VALUES
    case .GetValuesResult: return FCGI_GET_VALUES_RESULT
    case .UnknownType: return FCGI_UNKNOWN_TYPE
    }
  }

  /// The content length of the record body when written to an output stream.
  var contentLength: Int {
    switch self {
    case .BeginRequest: return 8
    case .EndRequest: return 8
    case .Params(let bytes): return bytes.count
    case .Stdin(let bytes): return bytes.count
    case .Data(let bytes): return bytes.count
    case .Stderr(let bytes): return bytes.count
    case .Stdout(let bytes): return bytes.count
    case .GetValues(let bytes): return bytes.count
    case .GetValuesResult(let bytes): return bytes.count
    case .UnknownType: return 8
    default: return 0
    }
  }

  /// Writes the record body to the given output stream.
  ///
  /// - Parameter outputStream: The output stream to which the record body should be written.
  /// - Throws: `IOError` if an I/O error occurred.
  func write(outputStream: OutputStream) throws {
    switch self {
    case .EndRequest(let appStatus, let protocolStatus):
      try outputStream.write(Int32(appStatus).bigEndian)
      try outputStream.write(protocolStatus.rawValue)
      try outputStream.write(ContiguousArray<UInt8>(count: 3, repeatedValue: 0))
    case .Stdout(let bytes):
      try outputStream.write(bytes)
    case .Stderr(let bytes):
      try outputStream.write(bytes)
    case .GetValuesResult(let bytes):
      try outputStream.write(bytes)
    case .UnknownType(let type):
      try outputStream.write(Int8(type))
      try outputStream.write(ContiguousArray<UInt8>(count: 7, repeatedValue: 0))
    default:
      fatalError("Records of type \(self) cannot be written from app to web server, only read")
    }
  }
}
