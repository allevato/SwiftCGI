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


/// The initial value for the multiplicative hasher's accumulator.
private let KernighanRitchieInitialValue = 0


/// The multiplier used for each element added to the hasher.
private let KernighanRitchieMultiplier = 31


/// Computes a multiplicative hash function cumulatively by allowing multiple elements to be added
/// into it.
///
/// Despite having a `hashValue` property, the hasher itself does not conform to `Hashable`. This
/// is to avoid requiring the hasher to be equatable, which could be problematic if one tried to use
/// the hasher as the key in a hashed collection (without storing the elements themselves, it would
/// not be possible to distinguish two hashers with different elements that resolved to the same
/// hash value).
public struct Hasher {

  /// The accumulated hash value.
  public private(set) var hashValue: Int

  /// The multiplier applied to the accumulated hash each time an element is added into it.
  private let multiplier: Int

  /// Creates a new multiplier hasher that uses Kernighan and Ritchie's initial value and multiplier
  /// from *The C Programming Language*.
  public init() {
    self.init(initialValue: KernighanRitchieInitialValue, multiplier: KernighanRitchieMultiplier)
  }

  /// Creates a new multiplier hasher that uses the given initial value and multiplier.
  ///
  /// - Parameter initialValue: The initial value of the accumulated hash.
  /// - Parameter multiplier: The multiplier applied to the accumulated hash each time an element is
  ///   added into it.
  public init(initialValue: Int, multiplier: Int) {
    hashValue = initialValue
    self.multiplier = multiplier
  }

  /// Adds the given element's hash value into the hasher's accumulated hash value.
  ///
  /// - Parameter element: An element whose hash value will be added into the hasher's hash value.
  public mutating func add<Element: Hashable>(element: Element) {
    hashValue = multiplier &* hashValue &+ element.hashValue
  }
}
