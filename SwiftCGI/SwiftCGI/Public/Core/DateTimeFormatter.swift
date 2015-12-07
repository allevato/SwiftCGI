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

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif


/// Provides operations to format date/times to strings and parse strings into date/times.
///
/// The formatting and parsing operations are implemented on top of `strftime` and `strptime`, so
/// the conversion specifications (that is, the % placeholders) are identical to the ones defined by
/// those functions:
///
/// TODO: Duplicate the description of the conversion specifications here.
public struct DateTimeFormatter {

  /// The format string used to format date/times or to interpret them when parsing.
  private let formatString: String

  /// Creates a new formatter with the given format string.
  ///
  /// - Parameter formatString: The format string that determines how date/times should be formatted
  ///   or interpreted.
  public init(formatString: String) {
    self.formatString = formatString
  }

  /// Returns the string representation of the given `DateTime` formatted according to the
  /// receiver's format string.
  ///
  /// - Parameter dateTime: The `DateTime` to be formatted.
  /// - Returns: The formatted date/time, or nil if an error occurred.
  public func format(dateTime: DateTime) -> String? {
    let components = DateTimeComponents(dateTime: dateTime)
    return format(components)
  }

  /// Returns the string representation of the given `DateTimeComponents` formatted according to the
  /// receiver's format string.
  ///
  /// - Parameter components: The `DateTimeComponents` to be formatted.
  /// - Returns: The formatted date/time, or nil if an error occurred.
  public func format(components: DateTimeComponents) -> String? {
    var tmcomps = components.cComponents

    // Unfortunately there is no way to have strftime report the actual amount of space that it
    // needs, so we have to make an educated guess. Twice the length of the format string plus an
    // additional 1KB of space should be plenty for most sane format strings.
    let maxSize = formatString.utf8.count * 2 + 1024
    var buffer = [Int8](count: maxSize + 1, repeatedValue: 0)

    return buffer.withUnsafeMutableBufferPointer {
      (inout bufferPtr: UnsafeMutableBufferPointer<Int8>) -> String? in
      if strftime(bufferPtr.baseAddress, maxSize, formatString, &tmcomps) > 0 {
        return String.fromCString(bufferPtr.baseAddress)
      } else {
        return nil
      }
    }
  }

  /// Returns the `DateTime` that is equivalent to the given string parsed according to the
  /// receiver's format string.
  ///
  /// - Parameter string: The date string to parse.
  /// - Returns: The `DateTime` if it was successfully parsed, or nil if there was an error.
  public func parseDateTime(string: String) -> DateTime? {
    if let components = parseComponents(string) {
      return DateTime(components: components)
    }
    return nil
  }

  /// Returns the `DateTimeComponents` that are equivalent to the given string parsed according to
  /// the receiver's format string.
  ///
  /// - Parameter string: The date string to parse.
  /// - Returns: The `DateTimeComponents` if it was successfully parsed, or nil if there was an
  ///   error.
  public func parseComponents(string: String) -> DateTimeComponents? {
    var tmcomps = tm()
    let bufferEnd = strptime(string, formatString, &tmcomps)
    if bufferEnd == nil {
      return nil
    }
    return DateTimeComponents(tmcomps: tmcomps, millisecond: 0)
  }
}
