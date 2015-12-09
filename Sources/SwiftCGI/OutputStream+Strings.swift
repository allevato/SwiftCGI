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


/// Defines convenience methods for writing strings.
public extension OutputStream {

  /// Writes the given string to the stream using UTF-8 encoding.
  ///
  /// - Parameter value: The string to write.
  /// - Parameter nullTerminated: If true, a null-terminating byte will be written to the stream
  ///   after the string. The default value is false.
  /// - Throws: `IOError` if an error other than reaching the end of the stream occurs.
  func write(value: String, nullTerminated: Bool = false) throws {
    try write(value, codec: UTF8.self, nullTerminated: nullTerminated)
  }

  /// Writes the given string to the stream, encoded with a specific codec.
  ///
  /// - Parameter value: The string to write.
  /// - Parameter codec: The codec to use to encode the characters in the string. The codec must
  ///   encode its characters as bytes; that is, its `CodeUnit` type must be `UInt8` (or an
  ///   equivalent type alias).
  /// - Parameter nullTerminated: If true, a null-terminating byte will be written to the stream
  ///   after the string. The default value is false.
  /// - Throws: `IOError` if an error other than reaching the end of the stream occurs.
  func write<Codec: UnicodeCodecType where Codec.CodeUnit == UInt8>(
    value: String, codec: Codec.Type, nullTerminated: Bool = false) throws {
    var codeUnits = Array<Codec.CodeUnit>()
    for unicodeScalar in value.unicodeScalars {
      codec.encode(unicodeScalar) { codeUnit in
        codeUnits.append(codeUnit)
      }
    }
    if nullTerminated {
      codeUnits.append(0)
    }
    try write(codeUnits)
  }
}
