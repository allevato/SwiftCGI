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


/// Implements the `HTTPRequest` protocol for CGI and FastCGI requests by parsing headers from a
/// dictionary containing environment variables (or in the case of FastCGI, a dictionary containing
/// values that look like environment variables read from `PARAM` records).
class CGIHTTPRequest: HTTPRequest {

  let headers: HTTPHeaders
  let contentStream: InputStream
  let method: HTTPMethod
  let userAgent: String
  let path: String?
  let translatedPath: String?
  let queryString: String?

  var contentLength: Int {
    if let contentLength = headers["Content-Length"] {
      return Int(contentLength) ?? 0
    }
    return 0
  }

  var contentType: String {
    return headers["Content-Type"] ?? ""
  }

  var referrer: String? {
    return headers["Referer"]
  }

  /// Creates a new request from the given environment variables and content stream.
  ///
  /// - Parameter environment: The dictionary containing the environment variables from which the
  ///   request headers and other information will be pulled.
  /// - Parameter contentStream: The input stream from which the request's body can be read.
  init(environment: [String: String], contentStream: InputStream) {
    self.headers = HTTPHeaders(environment: environment)
    self.contentStream = contentStream

    if let methodName = environment["REQUEST_METHOD"] {
      method = HTTPMethod(method: methodName)
    } else {
      method = .GET
    }

    queryString = environment["QUERY_STRING"]
    path = environment["PATH_INFO"]
    translatedPath = environment["PATH_TRANSLATED"]
    userAgent = environment["USER_AGENT"] ?? ""
  }
}
