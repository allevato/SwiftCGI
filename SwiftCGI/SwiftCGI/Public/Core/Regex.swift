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


/// Represents a regular expression, providing operations to test for a match, find matches, split,
/// and perform replacements.
///
/// A `Regex` value is immutable and stateless; it is safe to use the same `Regex` from multiple
/// threads without synchronization. `Matches` themselves, on the other hand, are stateful and
/// cannot be safely used by multiple threads.
///
/// This type is currently implemented using the POSIX `regex.h` functions (`regcomp`, `regexec`,
/// and so forth), and thus has the same limitations.
public final class Regex {

  /// Options that alter the way regular expressions are interpreted or executed.
  public struct Options: OptionSetType {

    /// Indicates that lowercase and uppercase characters should be treated identically when
    /// matching.
    public static let IgnoreCase = Options(rawValue: REG_ICASE)

    /// Modifies the behavior of `^` and `$` to match the beginning and end of lines, respectively,
    /// rather than the beginning and end of the entire string, and prevents newlines from being
    /// matched by `.` or negated character classes.
    public static let Multiline = Options(rawValue: REG_NEWLINE)

    /// Use minimal (non-greedy) repetitions instead of greedy ones.
    public static let NonGreedy = Options(rawValue: REG_UNGREEDY)

    public let rawValue: Int32

    public init(rawValue: Int32) {
      self.rawValue = rawValue
    }
  }

  /// A sequence/generator that permits iterating over multiple matches on a string.
  public struct Matches: GeneratorType, SequenceType {

    public typealias Element = Match

    /// The regular expression that generated these matches.
    public let regex: Regex

    /// The string on which the regular expression was executed to generate these matches.
    public let string: String

    /// The offset at which the next match will be sought.
    private var offset: Int

    /// Creates a new match generator by executing the given regular expression on the string.
    ///
    /// - Parameter regex: The regular expression to execute.
    /// - Parameter string: The string on which to execute the regular expression.
    private init(regex: Regex, string: String) {
      self.regex = regex
      self.string = string
      offset = 0
    }

    public mutating func next() -> Match? {
      var regmatches = [regmatch_t](count: regex.regex.re_nsub + 1, repeatedValue: regmatch_t())

      return string.withCString { stringPtr in
        let stringPtrWithOffset = stringPtr.advancedBy(offset)

        let result = regexec(
          &regex.regex, stringPtrWithOffset, regex.regex.re_nsub + 1, &regmatches, 0)
        if result == 0 {
          // Map the C regmatch_t values to CaptureGroup values, extracting the matched portion of
          // the string for convenience (instead of just passing the indexes along).
          let captureGroups = regmatches.map { (regmatch: regmatch_t) -> CaptureGroup in
            let utf8StartIndex = string.utf8.startIndex.advancedBy(offset + Int(regmatch.rm_so))
            let characterStartIndex = utf8StartIndex.samePositionIn(string)!
            let utf8EndIndex = string.utf8.startIndex.advancedBy(offset + Int(regmatch.rm_eo))
            let characterEndIndex = utf8EndIndex.samePositionIn(string)!
            let capturedString = String(string.characters[characterStartIndex..<characterEndIndex])

            return CaptureGroup(
              startIndex: characterStartIndex, endIndex: characterEndIndex, string: capturedString)
          }

          // Advance the offset so the next match starts from that location.
          offset += Int(regmatches[0].rm_eo)

          return Match(groups: captureGroups)
        }

        return nil
      }
    }
  }

  /// Represents a single match in the sequence of \c Matches from a regular expression.
  ///
  /// For example, if the string "123-456-789" was matched against the regular expression "\d+", it
  /// would result in three \c Match values. Each \c Match may contain multiple capture groups: one
  /// for each parenthesis-pair in the expression, plus one for the entire expression itself.
  public struct Match {

    /// The capture groups matched by the regular expression. The number of groups in this array is
    /// one more than the `groupCount` property of the regular expression; the group at index 0 is
    /// the string matched by the entire regex, and the remaining groups represent the parenthesized
    /// subexpressions.
    public let groups: [CaptureGroup]

    /// A shorthand property that returns the full matched string. This is equivalent to writing
    ///
    ///     groups[0].string
    public var string: String {
      return groups[0].string
    }
  }

  /// Contains information about the position and contents of a capture group matched by a regular
  /// expression.
  public struct CaptureGroup {

    /// The index of the first character matched by the capture group.
    public let startIndex: String.Index

    /// The index one past the last character matched by the capture group.
    public let endIndex: String.Index

    /// The text matched by the capture group.
    public let string: String

    /// Creates a new capture group with the given start index, end index, and string.
    ///
    /// - Parameter startIndex: The index of the first character matched by the capture group.
    /// - Parameter endIndex: The index one past the last character matched by the capture group.
    /// - Parameter string: The text matched by the capture group.
    private init(startIndex: String.Index, endIndex: String.Index, string: String) {
      self.startIndex = startIndex
      self.endIndex = endIndex
      self.string = string
    }
  }

  /// The number of parenthesized subexpressions (groups) in the regular expression.
  public var groupCount: Int {
    return regex.re_nsub
  }

  /// The internal compiled regular expression.
  private var regex: regex_t

  /// Creates a new regular expression with the given pattern and options.
  ///
  /// - Parameter pattern: The regular expression pattern.
  /// - Parameter options: The set of options that alter the way the regular expression is
  ///   interpreted or executed.
  /// - Throws: `RegexError` if an error occurs while compiling the regular expression.
  public init(pattern: String, options: Options = []) throws {
    regex = regex_t()
    let result = regcomp(&regex, pattern, options.rawValue | REG_EXTENDED | REG_ENHANCED)
    if result != 0 {
      throw RegexError(rawValue: result)!
    }
  }

  deinit {
    regfree(&regex)
  }

  /// Returns a sequence that can be used to iterate over the matches in the given string.
  ///
  ///     let numberRegex = Regex(pattern: "\\d+")
  ///     for match in numberRegex.matches("The numbers are 4, 92, 78, and 15.") {
  ///       // Do something with the matches
  ///     }
  ///
  /// - Parameter string: The string within which to find matches from the regular expression.
  /// - Returns: A `Regex.Matches` sequence that can be used to iterate over any matches that are
  ///   found.
  public func matches(string: String) -> Matches {
    return Matches(regex: self, string: string)
  }

  /// A convenience function that returns true if the regular expression matches somewhere inside
  /// the given string.
  ///
  /// - Parameter string: The string to match against the regular expression.
  /// - Returns: True if the regular expression matches somewhere inside the given string.
  public func matchesInside(string: String) -> Bool {
    let result = regexec(&regex, string, 0, nil, 0)

    if result == 0 {
      return true
    }
    return false
  }

  /// A convenience function that returns true if the regular expression matches the given string
  /// exactly.
  ///
  /// - Parameter string: The string to match against the regular expression.
  /// - Returns: True if the regular expression matches the given string exactly.
  public func matchesExactly(string: String) -> Bool {
    var match = regmatch_t()
    let result = regexec(&regex, string, 1, &match, 0)

    if result == 0 {
      return match.rm_so == 0 && match.rm_eo == Int64(string.utf8.count)
    }
    return false
  }
}

/// Denotes errors that can be thrown when creating a regular expression.
public enum RegexError: Int32, ErrorType {

  /// The regular expression pattern was invalid.
  case InvalidPattern = 2

  /// The regular expression contained an invalid collating element.
  case InvalidCollatingElement = 3

  /// The regular expression contained an invalid character class.
  case InvalidCharacterClass = 4

  /// The regular expression contained a backslash ('\') applied to an unescapable character.
  case InvalidEscape = 5

  /// The regular expression contained an invalid backreference number.
  case InvalidBackreferenceNumber = 6

  /// The regular expression contained unbalanced brackets '`[ ]`'.
  case UnbalancedBrackets = 7

  /// The regular expression contained unbalanced parentheses '`( )`'.
  case UnbalancedParentheses = 8

  /// The regular expression contained unbalanced braces '`{ }`'.
  case UnbalancedBraces = 9

  /// The regular expression contained an invalid repetition count inside '`{ }`'.
  case InvalidRepetitionCounts = 10

  /// The regular expression contained an invalid character range inside '`[ ]`'.
  case InvalidCharacterRange = 11

  /// The regular expression compiler ran out of memory.
  case OutOfMemory = 12

  /// The regular expression contained an invalid '`?`', '`*`', or '`+`' operand.
  case InvalidRepetition = 13

  /// The regular expression contained an empty subexpression.
  case EmptySubexpression = 14

  /// An internal error occurred that indicates a bug in the regular expression library.
  case InternalError = 15

  /// A call to a regular expression method had an invalid argument.
  case InvalidArgument = 16

  /// The regular expression contained an invalid byte sequence (for example, an invalid multi-byte
  /// character).
  case InvalidByteSequence = 17
}
