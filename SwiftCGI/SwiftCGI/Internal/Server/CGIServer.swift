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

import Foundation


/// The server implementation used when the application is running as a CGI process.
class CGIServer: ServerProtocol {

  /// The environment variable dictionary that contains the headers for the request.
  private let environment: [String: String]

  /// The input stream from which the request body can be read.
  private let requestStream: InputStream

  /// The output stream to which the response body can be written.
  private let responseStream: OutputStream

  /// Creates a new server with the given environment, request stream, and response stream.
  ///
  /// This initializer exists primarily for testing.
  ///
  /// - Parameter environment: The dictionary containing the environment variables from which the
  ///   request headers will be read.
  /// - Parameter requestStream: The input stream from which the request body can be read.
  /// - Parameter responseStream: The output stream to which the response body can be written.
  init(environment: [String: String], requestStream: InputStream, responseStream: OutputStream) {
    self.environment = environment
    self.requestStream = requestStream
    self.responseStream = responseStream
  }

  /// Creates a new server that takes its environment from the process's environment and that uses
  /// the `stdin` and `stdout` file descriptors as its request and response streams, respectively.
  convenience init() {
    // TODO: Eliminate this dependency on Foundation. Would be nice if the POSIX "environ" variable
    // were exposed to Swift.
    let process = NSProcessInfo.processInfo()
    let environment = process.environment

    let requestStream = FileInputStream(fileDescriptor: STDIN_FILENO)
    let responseStream =
        BufferingOutputStream(outputStream: FileOutputStream(fileDescriptor: STDOUT_FILENO))

    self.init(
        environment: environment, requestStream: requestStream, responseStream: responseStream)
  }

  func listen(handler: (HTTPRequest, HTTPResponse) -> Void) {
    let request = CGIHTTPRequest(environment: environment, contentStream: requestStream)
    let response = CGIHTTPResponse(contentStream: responseStream)

    handler(request, response)

    responseStream.flush()
  }
}
