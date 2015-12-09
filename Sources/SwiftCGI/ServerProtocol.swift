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


/// Provides the common interface for the CGI and FastCGI server implementation.
protocol ServerProtocol {

  /// Listens for requests from the web server and calls the given handler to handle them.
  ///
  /// - Parameter handler: The function that will be called to handle a request.
  func listen(handler: (HTTPRequest, HTTPResponse) -> Void)
}
