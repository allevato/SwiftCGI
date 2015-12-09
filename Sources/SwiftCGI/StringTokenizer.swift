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


/// Allows a string to be tokenized by repeatedly pulling off substrings based on delimiters.
public struct StringTokenizer {

  /// True if the tokenizer has processed the entire string, or false if there are still characters
  /// remaining.
  public var done: Bool {
    return characters.count == 0
  }

  /// The character view of the portion of the string that has not yet been tokenized.
  private var characters: String.CharacterView

  /// Creates a new tokenizer over the given string.
  ///
  /// - Parameter string: The string to be tokenized.
  public init(string: String) {
    self.characters = string.characters
  }

  /// Return the substring from the current position up to the end of the string.
  ///
  /// - Returns: The string from the current position up to the end of the string.
  public mutating func tokenUpToEnd() -> String {
    let delimiterIndex = characters.endIndex
    return extractUpTo(delimiterIndex, delimiterLength: 0, inclusive: false)
  }

  /// Return the substring from the current position up to (and optionally including) the given
  /// delimiter.
  ///
  /// This method returns nil if the end of the string is reached before the delimiter is seen. If
  /// this occurs, the current position of the tokenizer is not changed.
  ///
  /// - Parameter delimiter: The string to use to end the search.
  /// - Parameter includeDelimiter: If true, the delimiter will be included in the returned string.
  ///   Defaults to false.
  /// - Returns: The string from the current position up to the delimiter, or nil if the end of the
  ///   string was reached without encountering the delimiter.
  public mutating func tokenUpToDelimiter(
      delimiter: String, includeDelimiter: Bool = false) -> String? {
    guard let delimiterIndex = characters.indexOfContentsOf(delimiter.characters) else {
      return nil
    }
    return extractUpTo(
        delimiterIndex, delimiterLength: delimiter.characters.count, inclusive: includeDelimiter)
  }
  
  /// Return the substring from the current position up to (and optionally including) the given
  /// delimiter or the end of the string.
  ///
  /// This method returns a tuple `(token: String, reachedDelimiter: Bool)`. The string `token` is
  /// always a valid string (including, possibly, the empty string). The boolean `reachedDelimiter`
  /// will be true if the tokenizer stopped because it encountered the delimiter; it will be false
  /// if the end of the string was encountered instead.
  ///
  /// - Parameter delimiter: The string to use to end the search.
  /// - Parameter includeDelimiter: If true, the delimiter will be included in the returned string.
  ///   Defaults to false.
  /// - Returns: The string from the current position up to the delimiter, or nil if the end of the
  ///   string was reached without encountering the delimiter.
  public mutating func tokenUpToDelimiterOrEnd(
      delimiter: String, includeDelimiter: Bool = false) ->
      (token: String, reachedDelimiter: Bool) {
    guard let delimiterIndex = characters.indexOfContentsOf(delimiter.characters) else {
      return (token: tokenUpToEnd(), reachedDelimiter: false)
    }

    let result = extractUpTo(
        delimiterIndex, delimiterLength: delimiter.characters.count, inclusive: includeDelimiter)
    return (token: result, reachedDelimiter: true)
  }

  /// Extracts a prefix up to (or through) the given index, removing it from the tokenizer's view of
  /// remaining characters in the string.
  ///
  /// - Parameter index: The index of the end of the prefix to extract.
  /// - Parameter inclusive: If true, the extracted string will include the character at `index`;
  ///   otherwise, it will end at the character before.
  /// - Returns: The string extracted from the tokenizer's character view.
  private mutating func extractUpTo(
      index: String.Index, delimiterLength: String.Index.Distance, inclusive: Bool) -> String {
    let prefixEndIndex = inclusive ? index.advancedBy(delimiterLength) : index
    let suffixStartIndex =
        (prefixEndIndex == characters.endIndex) ? prefixEndIndex : prefixEndIndex.successor()

    let result = characters.prefixUpTo(prefixEndIndex)
    characters = characters.suffixFrom(suffixStartIndex)
    return String(result)
  }
}
