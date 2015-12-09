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


/// Encapsulates information about an HTTP request received by the server.
public protocol HTTPRequest {

  /// The raw headers associated with the request.
  var headers: HTTPHeaders { get }

  /// The HTTP method of the request.
  var method: HTTPMethod { get }

  /// The length of the request body, in bytes.
  var contentLength: Int { get }

  /// The content type of the request body.
  var contentType: String { get }

  /// The input stream from which the request body can be read.
  var contentStream: InputStream { get }

  /// The referrer of the request.
  var referrer: String? { get }

  /// The user agent string of the application making the request.
  var userAgent: String { get }

  /// The path associated with the request, or nil if there is no path.
  var path: String? { get }

  /// Represents extra path information after the application name but before the query string,
  /// translated to a real file system path.
  var translatedPath: String? { get }

  /// The query string passed as part of the request, or nil if there was none.
  var queryString: String? { get }
}
