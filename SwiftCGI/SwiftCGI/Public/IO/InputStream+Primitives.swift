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


/// Defines convenience methods for reading common primitive values.
public extension InputStream {

  /// Reads a signed 8-bit integer from the stream.
  ///
  /// - Returns: The value read from the stream.
  /// - Throws: `IOError` if the opreation would read past the end of the stream.
  public func readInt8() throws -> Int8 {
    var value = Int8(0)
    try read(&value)
    return value
  }

  /// Reads an unsigned 8-bit integer from the stream.
  ///
  /// - Returns: The value read from the stream.
  /// - Throws: `IOError` if the operation would read past the end of the stream.
  public func readUInt8() throws -> UInt8 {
    var value = UInt8(0)
    try read(&value)
    return value
  }

  /// Reads a signed 16-bit integer from the stream.
  ///
  /// - Returns: The value read from the stream.
  /// - Throws: `IOError` if the opreation would read past the end of the stream.
  public func readInt16() throws -> Int16 {
    var value = Int16(0)
    try read(&value)
    return value
  }

  /// Reads an unsigned 16-bit integer from the stream.
  ///
  /// - Returns: The value read from the stream.
  /// - Throws: `IOError` if the operation would read past the end of the stream.
  public func readUInt16() throws -> UInt16 {
    var value = UInt16(0)
    try read(&value)
    return value
  }

  /// Reads a signed 32-bit integer from the stream.
  ///
  /// - Returns: The value read from the stream.
  /// - Throws: `IOError` if the opreation would read past the end of the stream.
  public func readInt32() throws -> Int32 {
    var value = Int32(0)
    try read(&value)
    return value
  }

  /// Reads an unsigned 32-bit integer from the stream.
  ///
  /// - Returns: The value read from the stream.
  /// - Throws: `IOError` if the operation would read past the end of the stream.
  public func readUInt32() throws -> UInt32 {
    var value = UInt32(0)
    try read(&value)
    return value
  }

  /// Reads `count` bytes from the stream and returns them in a contiguous array.
  ///
  /// If it was not possible to read the given number of bytes (for example, the end of the stream
  /// was reached first), then the length of the returned array will be less than `count`. If the
  /// stream has reached the end before this method is called, then the returned array will be
  /// empty.
  ///
  /// This method serves as a convenience for one-off calls where it isn't necessary to allocate a
  /// reusable buffer. It is less efficient in the end-of-stream case because the buffer it
  /// allocates internally may need to be truncated if the number of bytes available is less than
  /// the number requested.
  ///
  /// - Parameter count: The maximum number of bytes to read.
  /// - Returns: A contiguous array containing the bytes that were read.
  /// - Throws: `IOError` if the operation failed for a reason other than reaching the end of the
  ///   stream.
  public func readBytes(count: Int) throws -> ContiguousArray<UInt8> {
    var buffer = ContiguousArray<UInt8>(count: count, repeatedValue: 0)
    let bytesRead = try read(&buffer, offset: 0, count: count)
    if bytesRead < count {
      buffer.replaceRange(bytesRead..<count, with: [])
    }
    return buffer
  }

  /// Generic helper method that reads data from the stream directly into the memory at the given
  /// pointer, where the amount read is equal to the byte size of the generic type.
  ///
  /// - Parameter pointer: The pointer to the memory where the read data will be stored.
  /// - Throws: `IOError` if the operation would read past the end of the stream.
  private func read<Memory>(pointer: UnsafeMutablePointer<Memory>) throws {
    let count = sizeof(Memory)
    var bytes = ContiguousArray<UInt8>(count: count, repeatedValue: 0)
    let bytesRead = try read(&bytes, offset: 0, count: count)
    if bytesRead < count {
      throw IOError.EOF
    }

    bytes.withUnsafeMutableBufferPointer {
      (inout byteBufferPtr: UnsafeMutableBufferPointer<UInt8>) in
      pointer.assignFrom(UnsafeMutablePointer<Memory>(byteBufferPtr.baseAddress), count: 1)
      return
    }
  }
}
