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


/// Defines basic input functions for reading from a data stream, such as a file.
///
/// This protocol is modeled after similar interfaces from Java and .NET. It uses `ContiguousArray`
/// for its storage instead of `Array` so that the unsafe pointer to the underlying memory can be
/// easily accessed in implementations. (For example, streams for POSIX files can pass the pointer
/// directly into the low-level file functions.)
public protocol InputStream {

  /// Reads `count` bytes from the stream into the array `buffer` starting at `offset`.
  ///
  /// - Parameter buffer: The contiguous array into which the data should be written.
  /// - Parameter offset: The byte offset in `buffer` into which to start writing data.
  /// - Parameter count: The maximum number of bytes to read from the stream.
  /// - Returns: The number of bytes that were actually read. This can be less than the requested
  ///   number of bytes if that many bytes are not available, or 0 if the end of the stream is
  ///   reached.
  /// - Throws: `IOError` if an error other than reaching the end of the stream occurs.
  func read(inout buffer: ContiguousArray<UInt8>, offset: Int, count: Int) throws -> Int

  /// Seeks to a new position in the stream.
  ///
  /// - Parameter offset: The number of bytes to seek forward by.
  /// - Returns: The new position in the stream.
  /// - Throws: `IOError.Unsupported` if the stream does not support seeking.
  func seek(offset: Int, origin: SeekOrigin) throws -> Int

  /// Closes the stream, releasing any resources used by it.
  func close()
}
