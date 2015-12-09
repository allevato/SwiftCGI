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


/// Manages the logic of reading FastCGI records from the connection, constructing the headers and
/// request from those records, and then translating the user's response to records send back to the
/// web server.
class FCGIRequestHandler {

  /// The input stream from which records will be read.
  private let inputStream: InputStream

  /// The output stream to which records will be written.
  private let outputStream: OutputStream

  /// The user's handler that will be invoked when the request is ready to be processed.
  private let handler: (HTTPRequest, HTTPResponse) -> Void

  /// The ID number of the FastCGI request being handled.
  private var requestID = 0

  /// A buffer used to build up the data from the `PARAMS` records so that they can be deserialized
  /// into a dictionary.
  private var paramsBuffer = [UInt8]()

  /// Indicates whether the application should close the connection based on the flags in the
  /// `BEGIN_REQUEST` record.
  private var closeConnectionWhenDone = false

  /// Creates a new request handler with the given input stream, output stream, and handler.
  ///
  /// - Parameter inputStream: The input stream from which records will be read.
  /// - Parameter outputStream: The output stream to which records will be written.
  /// - Parameter handler: The user's handler that will be invoked when the request is ready to be
  ///   processed.
  init(inputStream: InputStream, outputStream: OutputStream,
      handler: (HTTPRequest, HTTPResponse) -> Void) {
    self.inputStream = inputStream
    self.outputStream = outputStream
    self.handler = handler
  }

  /// Begins reading records from the input stream and processing the request.
  func start() throws {
    while let record = nextRecord() {
      switch record.body {
      case .BeginRequest(let role, let flags):
        try handleBeginRequest(record, role: role, flags: flags)
      case .AbortRequest:
        try handleAbortRequest(record)
      case .GetValues(let bytes):
        try handleGetValues(record, bytes: bytes)
      case .Params(let bytes):
        let complete = try handleParams(record, bytes: bytes)
        if complete {
          try invokeUserHandler()
        }
      default:
        throw FCGIError.UnexpectedRecordType
      }
    }
  }

  /// Sets up the input and output streams for the request and response and invokes the user's
  /// request handler associated with the receiver.
  ///
  /// - Throws: If there is an error exhausting the input stream or ending the request.
  private func invokeUserHandler() throws {
    // Get the request headers by constructing an environment from the data in the Params records.
    let environment = FCGINameValueDictionaryFromBytes(paramsBuffer)

    // Create a buffering stream that joins the Stdin records into a single data stream.
    let recordInputStream = FCGIRecordInputStream(inputStream: inputStream, bodyType: .Stdin)
    let bufferingInputStream = BufferingInputStream(inputStream: recordInputStream)
    let request = CGIHTTPRequest(environment: environment, contentStream: bufferingInputStream)

    // Create a buffering stream that writes chunks of data to Stdout records.
    let recordOutputStream =
        FCGIRecordOutputStream(outputStream: outputStream, requestID: requestID, bodyType: .Stdout)
    let bufferingOutputStream = BufferingOutputStream(outputStream: recordOutputStream)
    let response = CGIHTTPResponse(contentStream: bufferingOutputStream)

    // Invoke the user's handler.
    handler(request, response)

    // Flush any remaining buffered output records.
    bufferingOutputStream.flush()
    try recordOutputStream.terminate()

    // Notify the web server that we've finished processing the request.
    try endRequest()
  }

  /// Reads the next FastCGI record from the socket.
  ///
  /// - Returns: The next record or nil if there was an error or the server closed the connection.
  private func nextRecord() -> FCGIRecord? {
    let record = try? FCGIRecord(inputStream: inputStream)
    return record
  }

  /// Handles a `BEGIN_REQUEST` record from the web server.
  ///
  /// - Parameter record: The record read from the server.
  /// - Parameter role: The FastCGI role of the request.
  /// - Parameter flags: Flags that determine how the connection should be treated.
  /// - Throws: `FCGIError.UnexpectedRequestID` if this handler has already received a
  ///   `BEGIN_REQUEST` record.
  private func handleBeginRequest(
      record: FCGIRecord, role: FCGIBeginRequestRole, flags: FCGIBeginRequestFlags) throws {
    guard requestID == 0 else {
      throw FCGIError.UnexpectedRequestID
    }

    requestID = record.requestID
    closeConnectionWhenDone = !flags.contains(.KeepConnection)
  }

  /// Handles an `ABORT_REQUEST` record from the web server.
  ///
  /// - Parameter record: The record read from the server.
  /// - Throws: `FCGIError.UnexpectedRequestID` if the request ID of the given record does not match
  ///   that already been processed by the handler.
  private func handleAbortRequest(record: FCGIRecord) throws {
    guard record.requestID == requestID else {
      throw FCGIError.UnexpectedRequestID
    }

    // TODO: Implement this method.
  }

  /// Handles a `GET_VALUES` record from the web server.
  ///
  /// - Parameter record: The record read from the server.
  private func handleGetValues(record: FCGIRecord, bytes: [UInt8]) throws {
    // TODO: Implement this method.
  }

  /// Handles a `PARAMS` record from the web server.
  ///
  /// - Parameter record: The record read from the server.
  /// - Parameter bytes: The raw bytes of the request body.
  /// - Returns: True if the parameters have been completely read, or false if there are still
  ///   parameter records to be processed.
  /// - Throws: `FCGIError.UnexpectedRequestID` if the request ID of the given record does not match
  ///   that already been processed by the handler.
  private func handleParams(record: FCGIRecord, bytes: [UInt8]) throws -> Bool {
    guard record.requestID == requestID else {
      throw FCGIError.UnexpectedRequestID
    }

    if bytes.count > 0 {
      paramsBuffer.appendContentsOf(bytes)
      return false
    }

    // The web server sends a PARAMS record with no content to signify that all parameters have been
    // sent. At this point we can notify the caller that the user handler should be invoked.
    return true
  }

  /// Sends an `END_REQUEST` record to notify the web server that the application has finished
  /// processing the request and closes the connection if necessary.
  private func endRequest() throws {
    let endRecordBody = FCGIRecordBody.EndRequest(appStatus: 0, protocolStatus: .RequestComplete)
    let endRecord = FCGIRecord(requestID: requestID, body: endRecordBody)
    try endRecord.write(outputStream)

    if closeConnectionWhenDone {
      inputStream.close()
    }
  }
}
