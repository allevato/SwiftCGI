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


/// HTTP status codes that can be sent in a response.
///
/// Values can be created with any numeric code, but an extension also provides pre-defined named
/// values for better readability.
public struct HTTPStatus: Equatable, Hashable {

  /// The numeric HTTP status code that this value represents.
  public let code: Int

  public var hashValue: Int {
    return code
  }
}


/// Returns true if the given instances of `HTTPStatus` have the same code.
///
/// - Parameter lhs: The first `HTTPStatus` to compare.
/// - Parameter rhs: The second `HTTPStatus` to compare.
/// - Returns: True if the two statuses have the same code.
public func ==(lhs: HTTPStatus, rhs: HTTPStatus) -> Bool {
  return lhs.code == rhs.code
}
