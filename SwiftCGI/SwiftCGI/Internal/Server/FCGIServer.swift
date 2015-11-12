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


/// The number of threads to run concurrently to process incoming requests.
/// TODO: Make this configurable by the user.
private let NumberOfThreads = 4


/// The server implementation used when the application is running as a FastCGI process.
class FCGIServer: ServerProtocol {

  /// The array of threads currently running to process requests.
  var threads = [Thread]()

  /// Creates a new FastCGI server implementation.
  init() {}

  func listen(handler: (HTTPRequest, HTTPResponse) -> Void) {
    threads = [Thread]((0..<NumberOfThreads).map { _ in
      threaded(self.listenOnThread(handler))
    })

    // Wait for the threads to exit before returning (which, assuming the user does nothing else
    // after calling `Server.listen`, would end the process). Depending on how the web server treats
    // the connection socket, this may never actually complete.
    for thread in threads {
      thread.join()
    }
  }

  /// Returns a function that listens repeatedly for incoming requests on the current thread and
  /// dispatches them to the given handler as they arrive. The function runs indefinitely, stopping
  /// only if the web server closes the connection.
  ///
  /// Note the signature of this function; it is a higher-order function that captures the given
  /// request handler function and returns a `Void -> Void` function that can be used as a thread
  /// procedure.
  ///
  /// - Parameter handler: The user's handler to be called when the request is ready.
  /// - Returns: A no-argument function that listens for incoming requests and calls the given
  ///   handler when they are ready to be processed.
  private func listenOnThread(handler: (HTTPRequest, HTTPResponse) -> Void)() {
    while let socket = accept() {
      let socketInputStream = FileInputStream(fileDescriptor: socket)
      let socketOutputStream = FileOutputStream(fileDescriptor: socket)

      let requestHandler = FCGIRequestHandler(
          inputStream: socketInputStream, outputStream: socketOutputStream, handler: handler)
      do {
        try requestHandler.start()
      } catch {
        // TODO: Log the error.
      }
    }
  }

  /// Extracts the first connection request from the queue of pending connections and returns the
  /// socket's file descriptor, blocking if there are no connections pending.
  ///
  /// - Returns: The socket's file descriptor, or nil if an error occurred.
  private func accept() -> Int32? {
    var address = sockaddr()
    var addressLen = socklen_t()
    let socket = Darwin.accept(0, &address, &addressLen)
    if socket > 0 {
      return socket
    } else {
      return nil
    }
  }
}
