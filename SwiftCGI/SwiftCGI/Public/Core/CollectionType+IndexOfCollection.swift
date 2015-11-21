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


/// Adds support for searching for a target collection within another collection.
///
/// In order to use this method, the following constraints must be satisfied:
///
/// 1. The elements in the collection must be `Equatable`.
/// 2. The elements of the receiver and the target must be the same type.
/// 3. The distance types of the receiver's and target's index types must be the same.
///
/// In other words, the receiver and target do not have to have the same type, nor do their indexes,
/// as long as the above properties are true.
public extension CollectionType where Generator.Element: Equatable {

  /// Searches for the given target collection within the receiver, returning the earliest index
  /// where it occurs if found.
  ///
  /// - Parameter target: The collection to search for within the receiver.
  /// - Returns: The earliest index where the target is found, or nil if the target is not found in
  ///   the receiver.
  public func indexOfContentsOf<
      C: CollectionType where C.Generator.Element == Generator.Element,
      Index.Distance == C.Index.Distance>(target: C) -> Index? {
    // If the target is larger than the receiver, we can trivially bail out early.
    if target.count > count {
      return nil
    }

    // The first occurrence of the empty sequence is the start of the receiving sequence.
    guard let first = target.first else {
      return startIndex
    }

    // The current index in the receiver where we look for the first element of the target sequence.
    var receiverStart = startIndex

    // The element in the receiving sequence where we can stop looking, because there are fewer
    // elements after it than there are in the target subsequence.
    let receiverStop = startIndex.advancedBy(count - target.count).successor()

    while receiverStart != receiverStop {
      // Scan the receiver looking for the first element in the target sequence.
      if self[receiverStart] != first {
        while ++receiverStart != receiverStop && self[receiverStart] != first {}
      }

      // Search for the rest of the target collection.
      if receiverStart != receiverStop {
        var receiverCurrent = receiverStart.successor()
        // The index in the receiver where the last element in the target sequence should be.
        let receiverLast = receiverCurrent.advancedBy(target.count - 1)

        // Compare each element in the target sequence to the corresponding element in the receiver.
        var targetCurrent = target.startIndex.successor()
        while receiverCurrent != receiverLast && self[receiverCurrent] == target[targetCurrent] {
          receiverCurrent++
          targetCurrent++
        }

        // If we didn't exit the above loop prematurely, then we found the target sequence.
        if receiverCurrent == receiverLast {
          return receiverStart
        }
      }

      // Try again from the next element, if we haven't exhausted the receiver already.
      if receiverStart != receiverStop {
        receiverStart++
      }
    }

    // The target sequence was not found.
    return nil
  }
}


/// Adds a convenience method for searching for a string inside another string, implemented in terms
/// of the underlying `characters` collection.
public extension String {

  /// Searches for the given target substring within the receiver, returning the earliest index
  /// where it occurs if found.
  ///
  /// - Parameter target: The substring to search for within the receiver.
  /// - Returns: The earliest index where the substring is found, or nil if the target is not found
  ///   in the receiver.
  public func indexOfContentsOf(target: String) -> Index? {
    return characters.indexOfContentsOf(target.characters)
  }
}
