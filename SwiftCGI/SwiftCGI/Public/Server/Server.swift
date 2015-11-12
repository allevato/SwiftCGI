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

import Darwin


/// Listens to incoming requests and dispatches them to a handler function.
///
/// To start the request/response process for the application, create an instance of this class and
/// call its `listen` method, passing it a function or closure that will be called to handle an
/// incoming HTTP request from the web server:
///
///     let server = Server()
///     server.listen { request, response in
///       // Read values from request
///       // Write content to response
///     }
///
/// If running as a CGI process, the `listen` method will handle a single request and then return,
/// allowing the application to terminate. The handler is called on the same thread as the rest of
/// the application.
///
/// If running as a FastCGI process, the `listen` method may start multiple threads to
/// simultaneously handle multiple requests. If there are no requests ready to be handled, the
/// `listen` method blocks until there is an incoming request. In this situation, `listen` never
/// returns (unless the web server closes the socket). When running in FastCGI mode, request
/// handlers must take care to synchronize access to shared data.
public class Server {

  /// The concrete server implementation.
  private let impl: ServerProtocol

  /// Returns a value indicating whether the web server is running this application as a CGI process
  /// or as a FastCGI process.
  ///
  /// A FastCGI process will have file descriptor 0 (stdin) as a socket; a CGI process will have it
  /// as a regular file.
  ///
  /// - Returns: True if the server is running the application as a CGI process, or false if it is
  ///   running it as a FastCGI process.
  private static func isCGI() -> Bool {
    var address = sockaddr()
    var address_len = socklen_t()
    let result = getpeername(0, &address, &address_len)
    return result == -1 && (errno == ENOTSOCK || errno == EINVAL)
  }

  /// Creates a new server.
  public init() {
    if Server.isCGI() {
      impl = CGIServer()
    } else {
      impl = FCGIServer()
    }
  }

  /// Listens for requests from the web server and calls the given handler to handle them.
  ///
  /// - Parameter handler: The function that will be called to handle a request.
  public func listen(handler: (HTTPRequest, HTTPResponse) -> Void) {
    impl.listen(handler)
  }
}
