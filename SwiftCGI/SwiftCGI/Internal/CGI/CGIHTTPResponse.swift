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


/// Implements the `HTTPResponse` protocol for responses in both CGI and FastCGI applications.
class CGIHTTPResponse: HTTPResponse, WriteNotifyingOutputStreamDelegate {

  var headers: HTTPHeaders
  var status: HTTPStatus
  let contentStream: OutputStream

  var contentLength: Int {
    get {
      if let value = headers["Content-Length"], length = Int(value) {
        return length
      }
      return 0
    }
    set {
      headers["Content-Length"] = String(newValue)
    }
  }

  var contentType: String {
    get {
      if let value = headers["Content-Type"] {
        return value
      }
      return ""
    }
    set {
      headers["Content-Type"] = newValue
    }
  }

  /// Creates a new response with the given content output stream.
  ///
  /// - Parameter contentStream: The output stream to which the response message will be written.
  init(contentStream: OutputStream) {
    headers = HTTPHeaders()
    headers["Content-Type"] = "text/plain;charset=utf8"
    status = .OK

    let notifyingStream = WriteNotifyingOutputStream(outputStream: contentStream)
    self.contentStream = notifyingStream
    notifyingStream.delegate = self
  }

  func outputStreamWillBeginWriting(outputStream: OutputStream) throws {
    // Write the HTTP header lines of the response message before any body content is written.
    try outputStream.write("Status: \(status.code)\n")
    for (header, value) in headers {
      try outputStream.write("\(header): \(value)\n")
    }
    try outputStream.write("\n")
  }
}
