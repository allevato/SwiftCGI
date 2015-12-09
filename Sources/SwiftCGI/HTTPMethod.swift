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


/// Represents methods (or verbs) defined in HTTP, with a fallback `Other` option for interacting
/// with clients that define other methods not included here.
public enum HTTPMethod: Equatable, Hashable {
  case CONNECT
  case DELETE
  case GET
  case HEAD
  case OPTIONS
  case PATCH
  case POST
  case PUT
  case TRACE

  /// Supports arbitrary methods not defined in HTTP/1.1.
  case Other(String)

  /// Returns the `HTTPMethod` that corresponds to the given string.
  ///
  /// The lookup performed by this method is case-insensitive; that is, `GET`, `Get`, `get`, and
  /// `gEt` all return `.GET`. This is also true for methods that are not predefined; the string
  /// `foo` would return `.Other("FOO")`.
  ///
  /// - Parameter method: The string representation of the HTTP method.
  /// - Returns: One of the predefined method values for built-in HTTP methods (after uppercasing
  ///   the input string), or `.Other(method)` for methods not defined in HTTP/1.1.
  public init(method: String) {
    let methodUppercase = method.uppercaseString
    if let predefinedMethod = HTTPMethodMap[methodUppercase] {
      self = predefinedMethod
    } else {
      self = .Other(methodUppercase)
    }
  }

  /// The string representation of the HTTP method.
  public var stringValue: String {
    switch self {
    case .CONNECT: return "CONNECT"
    case .DELETE: return "DELETE"
    case .GET: return "GET"
    case .HEAD: return "HEAD"
    case .OPTIONS: return "OPTIONS"
    case .PATCH: return "PATCH"
    case .POST: return "POST"
    case .PUT: return "PUT"
    case .TRACE: return "TRACE"
    case .Other(let method): return method
    }
  }

  public var hashValue: Int {
    return stringValue.hashValue
  }
}


/// Returns true if the given `HTTPMethod` values are equal.
///
/// - Parameter lhs: The first value to compare.
/// - Parameter rhs: The second value to compare.
/// - Returns: True if the two values are equal.
public func ==(lhs: HTTPMethod, rhs: HTTPMethod) -> Bool {
  switch (lhs, rhs) {
  case (.CONNECT, .CONNECT),
    (.DELETE, .DELETE),
    (.GET, .GET),
    (.HEAD, .HEAD),
    (.OPTIONS, .OPTIONS),
    (.PATCH, .PATCH),
    (.POST, .POST),
    (.PUT, .PUT),
    (.TRACE, .TRACE):
    return true
  case (.Other(let lhsMethod), .Other(let rhsMethod)) where lhsMethod == rhsMethod:
    return true
  default:
    return false
  }
}


/// Provides a lookup for `HTTPMethod` values based on their string name.
private let HTTPMethodMap: [String: HTTPMethod] = [
  "CONNECT": .CONNECT,
  "DELETE": .DELETE,
  "GET": .GET,
  "HEAD": .HEAD,
  "OPTIONS": .OPTIONS,
  "PATCH": .PATCH,
  "POST": .POST,
  "PUT": .PUT,
  "TRACE": .TRACE,
]
