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


/// A collection of HTTP headers and their values that can be read from a request or added to a
/// response.
public struct HTTPHeaders: SequenceType {

  /// The type that provides iteration over the headers.
  public typealias Generator = Array<(String, String)>.Generator

  /// The type of collection returned by the `headerNames` property.
  public typealias HeaderNameCollection = LazyMapCollection<[String: [String]], String>

  /// Internal dictionary containing the headers, with all lowercase keys.
  private var headers: [String: [String]]

  /// A collection containing the names of the headers in this collection.
  public var headerNames: HeaderNameCollection {
    return headers.keys
  }

  /// Creates an instance with an empty set of headers.
  public init() {
    self.headers = [:]
  }

  /// Gets or sets the value of an HTTP header as a string.
  ///
  /// Reading from this subscript returns a string with the array of header values for that the
  /// given name joined by commas.
  ///
  /// Assigning to this sets the value of the header to be an array containing the given string as
  /// its singleton element, even if it contains commas. This assignment does not attempt to do any
  /// parsing since some HTTP headers do not support multiple comma-separated values.
  public subscript(name: String) -> String? {
    get {
      if let values = headers[name.lowercaseString] {
        return values.joinWithSeparator(",")
      } else {
        return nil
      }
    }
    set {
      if let newValue = newValue {
        headers[name.lowercaseString] = [newValue]
      } else {
        headers[name.lowercaseString] = nil
      }
    }
  }

  /// Adds a value for the HTTP header with the given name. A header may have multiple values
  /// associated with it.
  ///
  /// - Parameter name: The name of the header to add.
  /// - Parameter value: The value of the header to add.
  public mutating func add(name: String, value: String) {
    var values = headers[name.lowercaseString] ?? []
    values.append(value)
    headers[name.lowercaseString] = values
  }

  /// Returns an array containing the values of the given HTTP header.
  ///
  /// This allows you to retrieve multiple header values (such as "Set-Cookie") directly without any
  /// string processing.
  ///
  /// - Parameter name: The name of the header to retrieve.
  /// - Returns: The values of the header as an array, or nil if the header is not present.
  public func getValues(name: String) -> [String]? {
    return headers[name.lowercaseString]
  }

  /// Removes the values for the HTTP header with the given name.
  ///
  /// - Parameter name: The name of the header to remove.
  /// - Returns: The previous values of the header as an array, or nil if the header was not'
  ///   present.
  public mutating func remove(name: String) -> [String]? {
    return headers.removeValueForKey(name.lowercaseString)
  }

  /// Returns a generator over the headers.
  ///
  /// The generator produces `(String, String)` tuples containing the header name and value,
  /// respectively. For headers with multiple values, each value is returned separately.
  ///
  /// - Returns: A generator over the headers.
  public func generate() -> Generator {
    let flattenedHeaders = headers.flatMap { (name, values) in
      values.map { value in (name, value) }
    }
    return flattenedHeaders.generate()
  }
}
