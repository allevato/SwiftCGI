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


/// Encapsulates information about an HTTP response returned by the application to the server.
public protocol HTTPResponse {

  /// The headers to send with the response.
  ///
  /// - Note: The headers cannot be modified once data has been written to `contentStream`. Any
  ///   changes to the headers after this point will be ignored.
  var headers: HTTPHeaders { get set }

  /// The HTTP status code to send with the response. This is equivalent to setting the "Status"
  /// header.
  ///
  /// - Note: This property cannot be modified once data has been written to `contentStream`. Any
  ///   changes to this property after this point will be ignored.
  var status: HTTPStatus { get set }

  /// The MIME type of the content in the response. This is equivalent to setting the "Content-Type"
  /// header.
  ///
  /// - Note: This property cannot be modified once data has been written to `contentStream`. Any
  ///   changes to this property after this point will be ignored.
  var contentType: String { get set }

  /// The length of the body in the response in bytes. This is equivalent to setting the
  /// "Content-Length" header.
  ///
  /// - Note: This property cannot be modified once data has been written to `contentStream`. Any
  ///   changes to this property after this point will be ignored.
  var contentLength: Int { get set }

  /// The output stream used to write the body of the response.
  var contentStream: OutputStream { get }
}
