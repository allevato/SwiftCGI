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

import Darwin


/// The base year to which the C `tm` struct's `tm_year` value is added to get the calendar year.
let DateTimeComponentsCTMYearBase = 1900


/// Represents the broken down components of a `DateTime`, allowing users to directly access
/// properties such as the year, month, day, and so forth.
///
/// This type assumes the use of the Gregorian calendar; no work is planned to make it compatible
/// with other world calendars. The semantics are currently defined identically to the C's
/// `struct tm` (with the exception that years are returned as absolute values, not offsets from
/// 1900).
public struct DateTimeComponents: Equatable, Hashable {

  /// Represents the months of the year of the Gregorian calendar.
  public enum Month: Int {
    case January
    case February
    case March
    case April
    case May
    case June
    case July
    case August
    case September
    case October
    case November
    case December
  }

  /// Represents the days of the week of the Gregorian calendar.
  public enum Weekday: Int {
    case Sunday
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
  }

  /// The year in which the date/time falls.
  public var year: Int

  /// The month in which the date/time falls.
  public var month: Month

  /// The day of the month on which the date/time falls (1-31).
  public var dayOfMonth: Int

  /// The day of the year on which the date/time falls (0-365).
  public var dayOfYear: Int

  /// The day of the week on which the date/time falls.
  public var dayOfWeek: Weekday

  /// The hour of the day on which the date/time falls (0-23).
  public var hour: Int

  /// The minute on which the date/time falls (0-59).
  public var minute: Int

  /// The second on which the date/time falls (0-59, with 60 allowed for leap seconds).
  public var second: Int

  /// The millisecond on which the date/time falls (0-999).
  public var millisecond: Int

  /// The C `tm` value containing the components. Due to limitations in the C struct, millisecond
  /// information is not conveyed here.
  var cComponents: tm {
    var tmcomps = tm()
    tmcomps.tm_year = Int32(year - DateTimeComponentsCTMYearBase)
    tmcomps.tm_mon = Int32(month.rawValue)
    tmcomps.tm_mday = Int32(dayOfMonth)
    tmcomps.tm_yday = Int32(dayOfYear)
    tmcomps.tm_wday = Int32(dayOfWeek.rawValue)
    tmcomps.tm_hour = Int32(hour)
    tmcomps.tm_min = Int32(minute)
    tmcomps.tm_sec = Int32(second)
    return tmcomps
  }

  /// Creates a new value corresponding to a date/time of zero milliseconds since midnight on
  /// January 1, 1970 UTC. The purpose of this initializer is to quickly create a value with
  /// reasonable defaults that can be mutated and then converted back into a `DateTime`.
  public init() {
    self.init(dateTime: DateTime(millisecondsSince1970: 0))
  }

  /// Creates a new value with the given `DateTime`.
  ///
  /// - Parameter dateTime: The `DateTime` to break down into its components.
  public init(dateTime: DateTime) {
    var time = time_t(dateTime.millisecondsSince1970 / 1000)
    let millisecond = Int(dateTime.millisecondsSince1970 % 1000)

    var tmcomps = tm()
    gmtime_r(&time, &tmcomps)

    self.init(tmcomps: tmcomps, millisecond: millisecond)
  }

  /// Creates a new value with the given C `tm` struct and millisecond.
  ///
  /// - Parameter tmcomps: The C `tm` struct containing the components.
  /// - Parameter millisecond: The millisecond on which the date/time falls.
  init(tmcomps: tm, millisecond: Int) {
    year = Int(tmcomps.tm_year) + DateTimeComponentsCTMYearBase
    month = Month(rawValue: Int(tmcomps.tm_mon))!
    dayOfMonth = Int(tmcomps.tm_mday)
    dayOfYear = Int(tmcomps.tm_yday)
    dayOfWeek = Weekday(rawValue: Int(tmcomps.tm_wday))!
    hour = Int(tmcomps.tm_hour)
    minute = Int(tmcomps.tm_min)
    second = Int(tmcomps.tm_sec)
    self.millisecond = millisecond
  }

  // MARK: Hashable conformance

  public var hashValue: Int {
    var hasher = Hasher()
    hasher.add(year)
    hasher.add(month)
    hasher.add(dayOfMonth)
    hasher.add(dayOfYear)
    hasher.add(dayOfWeek)
    hasher.add(hour)
    hasher.add(minute)
    hasher.add(second)
    hasher.add(millisecond)
    return hasher.hashValue
  }
}

// MARK: Equatable conformance

public func ==(lhs: DateTimeComponents, rhs: DateTimeComponents) -> Bool {
  return lhs.year == rhs.year
      && lhs.month == rhs.month
      && lhs.dayOfMonth == rhs.dayOfMonth
      && lhs.dayOfYear == rhs.dayOfYear
      && lhs.dayOfWeek == rhs.dayOfWeek
      && lhs.hour == rhs.hour
      && lhs.minute == rhs.minute
      && lhs.second == rhs.second
      && lhs.millisecond == rhs.millisecond
}
