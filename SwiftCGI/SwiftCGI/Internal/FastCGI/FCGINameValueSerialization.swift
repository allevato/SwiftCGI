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


/// Parses a serialized byte array of FCGI name/value pairs and returns them in a dictionary.
///
/// - Parameter bytes: The byte array containing the serialized FCGI name/value pairs.
/// - Returns: A dictionary with the deserialized name/value pairs.
func FCGINameValueDictionaryFromBytes(bytes: [UInt8]) -> [String: String] {
  var index = 0
  var dictionary = [String:String]()

  while index < bytes.count {
    let nameLength = readLength(bytes, index: &index)
    let valueLength = readLength(bytes, index: &index)
    let name = readString(bytes, length: nameLength, index: &index)
    let value = readString(bytes, length: valueLength, index: &index)

    if let name = name, value = value {
      dictionary[name] = value
    }
  }

  return dictionary
}

/// Serializes a dictionary into a byte array of FCGI name/value pairs.
///
/// - Parameter dictionary: A dictionary whose keys and values are strings.
/// - Returns: A byte array containing the serialized FCGI name/value pairs.
func FCGIBytesFromNameValueDictionary(dictionary: [String: String]) -> [UInt8] {
  var bytes = [UInt8]()
  for (name, value) in dictionary {
    writeLength(&bytes, length: name.utf8.count)
    writeLength(&bytes, length: value.utf8.count)
    writeString(&bytes, string: name)
    writeString(&bytes, string: value)
  }
  return bytes
}

/// Reads an integer representing the length of a name or value, automatically handling both
/// 8-bit and 32-bit length values.
///
/// - Parameter bytes: The byte array from which to read the length.
/// - Parameter index: The position in the array from which to read the length; this value will be
///   advanced the appropriate amount once the length has been read.
/// - Returns: The length value read from the byte array.
private func readLength(bytes: [UInt8], inout index: Int) -> Int {
  let firstByte = bytes[index++]
  if firstByte & 0x80 == 0 {
    return Int(firstByte)
  } else {
    let lengthB3 = Int(firstByte & 0x7F)
    let lengthB2 = Int(bytes[index++])
    let lengthB1 = Int(bytes[index++])
    let lengthB0 = Int(bytes[index++])
    return lengthB0 | lengthB1 << 8 | lengthB2 << 16 | lengthB3 << 24
  }
}

/// Reads a UTF-8-encoded string of the given length.
///
/// - Parameter bytes: The byte array from which to read the string.
/// - Parameter length: The length of the string, in bytes.
/// - Parameter index: The position in the buffer from which to read the string; this value will be
///   advanced the appropriate amount once the string has been read.
/// - Returns: The string read from the byte array, or nil if there was a problem decoding the UTF-8
///   data.
private func readString(bytes: [UInt8], length: Int, inout index: Int) -> String? {
  var chars = bytes[index..<(index + length)]
  chars.append(0)
  index += length

  return chars.withUnsafeBufferPointer { pointer in
    String.fromCString(UnsafePointer<CChar>(pointer.baseAddress))
  }
}

/// Writes an integer representing a length of a name or value, automatically handling both 8-bit
/// and 32-bit length values.
///
/// - Parameter bytes: The byte array to which the length should be written.
/// - Parameter length: The length value to write to the byte array.
private func writeLength(inout bytes: [UInt8], length: Int) {
  if length > 127 {
    bytes.append(UInt8((length >> 24 & 0xFF) | 0x80))
    bytes.append(UInt8(length >> 16 & 0xFF))
    bytes.append(UInt8(length >> 8 & 0xFF))
    bytes.append(UInt8(length & 0xFF))
  } else {
    bytes.append(UInt8(length))
  }
}

/// Writes a UTF-8-encoding string to the given byte array. The string is not nil-terminated in the
/// destination array.
///
/// - Parameter bytes: The byte array to which the string should be written.
/// - Parameter string: The string to be written to the byte array.
private func writeString(inout bytes: [UInt8], string: String) {
  for byte in string.utf8 {
    bytes.append(byte)
  }
}
