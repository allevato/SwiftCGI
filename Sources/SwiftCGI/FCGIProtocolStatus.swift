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


/// Protocol-level status codes for FastCGI requests.
enum FCGIProtocolStatus: Int8 {

  /// Indicates the normal end of a request.
  case RequestComplete = 0

  /// Indicates that the application is rejecting the request because it can only handle one request
  /// at a time per connection.
  case CannotMultiplex = 1

  /// Indicates that the application is rejecting the request because it has run out of a resource,
  /// such as database connections.
  case Overloaded = 2

  /// Indicates that the application is rejecting the request because the web server has specified a
  /// role that the application does not understand.
  case UnknownRole = 3
}
