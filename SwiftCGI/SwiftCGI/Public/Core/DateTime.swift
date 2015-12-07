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


/// A value denoting a date and time, represented as the number of milliseconds since midnight on
/// January 1, 1970 UTC (a Unix timestamp).
///
/// Support for basic arithmetic on `DateTime`s is provided by the `Strideable` protocol, which
/// provides addition (of a date/time and a number of milliseconds) and subtraction (of two
/// date/times) operations.
public struct DateTime: Hashable, Strideable {

  /// The number of milliseconds since midnight on January 1, 1970 UTC.
  public let millisecondsSince1970: Int64

  /// Creates a new value representing the current date and time.
  public init() {
    var tv = timeval()
    gettimeofday(&tv, nil)
    self.init(tv: tv)
  }

  /// Creates a new value representing the date and time that is the given number of milliseconds
  /// since midnight on January 1, 1970 UTC.
  ///
  /// - Parameter millisecondsSince1970: The number of milliseconds since midnight on January 1,
  ///   1970 UTC.
  public init(millisecondsSince1970: Int64) {
    self.millisecondsSince1970 = millisecondsSince1970
  }

  /// Creates a new value representing the date and time with the given components.
  ///
  /// - Parameter components: The `DateTimeComponents` to use to create the new value.
  public init(components: DateTimeComponents) {
    var tmcomps = components.cComponents
    let seconds = timegm(&tmcomps)
    self.init(millisecondsSince1970: Int64(seconds) * 1000 + components.millisecond)
  }

  /// Creates a new value representing the date and time of the given POSIX `timeval`.
  ///
  /// - Parameter tv: The `timeval` from which to determine the date and time.
  init(tv: timeval) {
    let millis = Int64(tv.tv_sec) * 1000 + Int64(tv.tv_usec) / 1000
    self.init(millisecondsSince1970: millis)
  }

  // MARK: Strideable conformance

  public typealias Stride = Int64

  public func advancedBy(n: Stride) -> DateTime {
    return DateTime(millisecondsSince1970: millisecondsSince1970 + n)
  }

  public func distanceTo(other: DateTime) -> Stride {
    return other.millisecondsSince1970 - millisecondsSince1970
  }

  // MARK: Hashable conformance

  public var hashValue: Int {
    return millisecondsSince1970.hashValue
  }
}

// MARK: Equatable conformance

public func ==(lhs: DateTime, rhs: DateTime) -> Bool {
  return lhs.millisecondsSince1970 == rhs.millisecondsSince1970
}

// MARK: Comparable conformance

public func <(lhs: DateTime, rhs: DateTime) -> Bool {
  return lhs.millisecondsSince1970 < rhs.millisecondsSince1970
}
