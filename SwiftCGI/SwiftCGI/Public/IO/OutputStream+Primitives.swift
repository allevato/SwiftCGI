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


/// Defines convenience methods for writing common primitive values.
public extension OutputStream {

  /// Writes the given 8-bit signed integer to the stream.
  ///
  /// - Parameter value: The 8-bit signed integer to write.
  /// - Throws: `IOError` if an error other than reaching the end of the stream occurs.
  func write(var value: Int8) throws {
    try write(&value)
  }

  /// Writes the given 8-bit unsigned integer to the stream.
  ///
  /// - Parameter value: The 8-bit signed integer to write.
  /// - Throws: `IOError` if an error other than reaching the end of the stream occurs.
  func write(var value: UInt8) throws {
    try write(&value)
  }

  /// Writes the given 16-bit signed integer to the stream.
  ///
  /// - Parameter value: The 16-bit signed integer to write.
  /// - Throws: `IOError` if an error other than reaching the end of the stream occurs.
  func write(var value: Int16) throws {
    try write(&value)
  }

  /// Writes the given 16-bit unsigned integer to the stream.
  ///
  /// - Parameter value: The 16-bit signed integer to write.
  /// - Throws: `IOError` if an error other than reaching the end of the stream occurs.
  func write(var value: UInt16) throws {
    try write(&value)
  }

  /// Writes the given 32-bit signed integer to the stream.
  ///
  /// - Parameter value: The 32-bit signed integer to write.
  /// - Throws: `IOError` if an error other than reaching the end of the stream occurs.
  func write(var value: Int32) throws {
    try write(&value)
  }

  /// Writes the given 32-bit unsigned integer to the stream.
  ///
  /// - Parameter value: The 32-bit signed integer to write.
  /// - Throws: `IOError` if an error other than reaching the end of the stream occurs.
  func write(var value: UInt32) throws {
    try write(&value)
  }

  /// Writes the entire contents of `buffer` to the output stream.
  ///
  /// This method is equivalent to `write(buffer, offset: 0, count: buffer.count)`.
  ///
  /// - Parameter buffer: The array from which the data should be written.
  /// - Throws: `IOError` if an error other than reaching the end of the stream occurs.
  func write(buffer: [UInt8]) throws {
    try write(buffer, offset: 0, count: buffer.count)
  }

  /// Generic helper method that reads data from the stream directly into the memory at the given
  /// pointer, where the amount read is equal to the byte size of the generic type.
  ///
  /// - Parameter pointer: The pointer to the memory where the read data will be stored.
  /// - Throws: `IOError` if the operation would read past the end of the stream.
  private func write<Memory>(pointer: UnsafeMutablePointer<Memory>) throws {
    let count = sizeof(Memory)
    var bytes = [UInt8](count: count, repeatedValue: 0)
    bytes.withUnsafeMutableBufferPointer {
      (inout byteBufferPtr: UnsafeMutableBufferPointer<UInt8>) in
      UnsafeMutablePointer<Memory>(byteBufferPtr.baseAddress).assignFrom(pointer, count: 1)
      return
    }

    try write(bytes, offset: 0, count: count)
  }
}
