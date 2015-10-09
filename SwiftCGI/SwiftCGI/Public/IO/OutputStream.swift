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


/// Defines basic output functions for writing data to a destination, such as a file.
///
/// This protocol is modeled after similar interfaces from Java and .NET. It uses `ContiguousArray`
/// for its storage instead of `Array` so that the unsafe pointer to the underlying memory can be
/// easily accessed in implementations. (For example, streams for POSIX files can pass the pointer
/// directly into the low-level file functions.)
public protocol OutputStream {

  /// Writes `count` bytes from the array `buffer` starting at `offset` to the stream.
  ///
  /// - Parameter buffer: The contiguous array from which the data should be written.
  /// - Parameter offset: The byte offset in `buffer` from which to start reading data.
  /// - Parameter count: The maximum number of bytes to write to the stream.
  /// - Throws: `IOError` if an error other than reaching the end of the stream occurs.
  func write(buffer: ContiguousArray<UInt8>, offset: Int, count: Int) throws

  /// Seeks to a new position in the stream.
  ///
  /// - Parameter offset: The number of bytes to seek forward by.
  /// - Returns: The new position in the stream.
  /// - Throws: `IOError.Unsupported` if the stream does not support seeking.
  func seek(offset: Int, origin: SeekOrigin) throws -> Int

  /// Closes the stream, releasing any resources used by it.
  func close()

  /// Flushes any buffered content to its destination.
  func flush()
}
