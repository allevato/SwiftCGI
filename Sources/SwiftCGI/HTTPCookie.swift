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

import Foundation


/// The formatter used to format the expiration time of a cookie when written as an HTTP header.
private let CookieDateTimeFormatter = { () -> NSDateFormatter in
  let formatter = NSDateFormatter()
  formatter.dateFormat = "EEEE', 'dd'-'MMM'-'yyyy' 'HH':'mm':'ss' 'ZZZZ"
  return formatter
}()


/// Represents a cookie in an HTTP request or response.
///
/// TODO: Fully implement various cookie specifications: the original Netscape specification,
/// RFC 2109, and RFC 2965.
public struct HTTPCookie {

  /// The name of the cookie.
  public var name: String

  /// The value associated with the cookie.
  public var value: String

  /// The time at which the cookie expires.
  public var expirationTime: NSDate?

  /// The path that specifies the subset of URLs for which the cookie is valid.
  public var path: String?

  /// Specifies the domain names for which the cookie is valid.
  public var domain: String?

  /// If true, the cookie will only be sent over secure (HTTPS) connections.
  public var secure = false

  /// The formatted string that is used to transmit the cookie in an HTTP response `Set-Cookie`
  /// header.
  public var headerString: String {
    var string = "\(name.URLEncodedString)=\(value.URLEncodedString)"

    if let expirationTime = expirationTime {
      let formattedDate = CookieDateTimeFormatter.stringFromDate(expirationTime)
      string.appendContentsOf("; expires=\(formattedDate)")
    }
    if let path = path {
      string.appendContentsOf("; path=\(path)")
    }
    if let domain = domain {
      string.appendContentsOf("; domain=\(domain)")
    }
    if secure {
      string.appendContentsOf("; secure")
    }

    return string
  }

  /// Creates a cookie with the given name and value.
  ///
  /// - Parameter name: The name of the cookie.
  /// - Parameter value: The value of the cookie.
  public init(name: String, value: String) {
    self.name = name
    self.value = value
  }

  /// Creates a cookie by parsing the given HTTP request `Cookie` header string.
  ///
  /// This initializer will fail (returning nil) if the header string is malformed.
  ///
  /// - Parameter headerString: The HTTP request `Cookie` header to parse.
  public init?(headerString: String) {
    let chars = headerString.characters
    guard let equalIndex = chars.indexOf("=") else {
      return nil
    }
    guard let name = String(chars[chars.startIndex..<equalIndex]).URLDecodedString else {
      return nil
    }
    guard let value = String(chars[equalIndex.successor()..<chars.endIndex]).URLDecodedString else {
      return nil
    }

    self.name = name
    self.value = value

    // TODO: Parse other values?
  }
}
