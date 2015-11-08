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


/// Defines convenience methods for reading strings.
public extension InputStream {

  /// Reads from the stream until a null byte or the end of the stream is encountered, then returns
  /// the result of decoding those bytes as a UTF-8 string.
  ///
  /// - Returns: The decoded string, or nil if the string was not properly encoded.
  /// - Throws: `IOError` if an error other than reaching the end of the stream occurs.
  func readString() throws -> String? {
    return try readString(UTF8())
  }

  /// Reads from the stream until a null byte or the end of the stream is encountered, then returns
  /// the result of decoding those bytes with the given codec.
  ///
  /// - Parameter codec: The codec to use to decode the string. The codec must encode its characters
  ///   as bytes; that is, its `CodeUnit` type must be `UInt8` (or an equivalent type alias).
  /// - Returns: The decoded string, or nil if the string was not properly encoded.
  /// - Throws: `IOError` if an error other than reaching the end of the stream occurs.
  func readString<Codec: UnicodeCodecType where Codec.CodeUnit == UInt8>(codec: Codec)
      throws -> String? {
    var codeUnits = [UInt8]()
    var codeUnit = try readUInt8()
    while codeUnit != 0 {
      codeUnits.append(codeUnit)
      do {
        codeUnit = try readUInt8()
      } catch IOError.EOF {
        codeUnit = 0
      }
    }
    return decodeString(codeUnits, codec: codec)
  }

  /// Reads the given number of bytes from the stream and returns the result of decoding those bytes
  /// as a UTF-8 string.
  ///
  /// - Parameter count: The number of bytes to read.
  /// - Returns: The decoded string, or nil if the string was not properly encoded.
  /// - Throws: `IOError` if an error, including reaching the end of the stream, occurs.
  func readString(count: Int) throws -> String? {
    return try readString(count, codec: UTF8())
  }

  /// Reads from the stream until a null byte or the end of the stream is encountered, then returns
  /// the result of decoding those bytes with the given codec.
  ///
  /// - Parameter codec: The codec to use to decode the string. The codec must encode its characters
  ///   as bytes; that is, its `CodeUnit` type must be `UInt8` (or an equivalent type alias).
  /// - Returns: The decoded string, or nil if the string was not properly encoded.
  /// - Throws: `IOError` if an error other than reaching the end of the stream occurs.
  func readString<Codec: UnicodeCodecType where Codec.CodeUnit == UInt8>(count: Int, codec: Codec)
      throws -> String? {
    let codeUnits = try readBytes(count)
    if codeUnits.count < count {
      throw IOError.EOF
    }
    return decodeString(codeUnits, codec: codec)
  }
  
  /// Helper function to decode a string from an array of code units.
  ///
  /// - Parameter codeUnits: The array of code units to be decoded.
  /// - Parameter codec: The codec to use to decode the string.
  /// - Returns: The decoded string, or nil if the string was not properly encoded.
  private func decodeString<Codec: UnicodeCodecType where Codec.CodeUnit == UInt8>(
      codeUnits: [UInt8], var codec: Codec) -> String? {
    var generator = codeUnits.generate()
    var decoded = ""

    var decoding = true
    while decoding {
      let result = codec.decode(&generator)
      switch result {
      case .Result(let unicodeScalar):
        decoded.append(unicodeScalar)
      case .EmptyInput:
        decoding = false
      case .Error:
        return nil
      }
    }

    return decoded
  }
}
