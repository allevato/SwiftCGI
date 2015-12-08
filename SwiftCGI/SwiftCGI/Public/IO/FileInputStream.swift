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

import Foundation


/// An input stream that reads content from a file or file descriptor.
public class FileInputStream: InputStream {

  /// The file handle associated with the stream.
  private let fileHandle: NSFileHandle!

  /// Creates a new input stream that reads from the given file descriptor.
  ///
  /// When using this initializer, the returned stream will *not* be closed automatically if it is
  /// open when the stream is deallocated.
  ///
  /// - Parameter fileDescriptor: The POSIX file descriptor from which the stream will read.
  public init(fileDescriptor: Int32) {
    fileHandle = NSFileHandle(fileDescriptor: fileDescriptor, closeOnDealloc: false)
  }

  /// Creates a new input stream that reads from the file at the given path.
  ///
  /// When using this initializer, the returned stream *will* be closed automatically if it is open
  /// when the stream is deallocated.
  ///
  /// This initializer will fail if the file could not be opened.
  ///
  /// - Parameter path: The path to the file that should be opened.
  public init?(path: String) {
    fileHandle = NSFileHandle(forReadingAtPath: path)
    if fileHandle == nil {
      return nil
    }
  }

  public func read(inout buffer: [UInt8], offset: Int, count: Int) throws -> Int {
    if count == 0 {
      return 0
    }

    return try buffer.withUnsafeMutableBufferPointer {
      (inout buffer: UnsafeMutableBufferPointer<UInt8>) in
      let data = fileHandle.readDataOfLength(count)
      if data.length == 0 {
        throw IOError.EOF
      }
      // TODO: Handle errors other than EOF.

      let destination = buffer.baseAddress.advancedBy(offset)
      destination.assignFrom(UnsafeMutablePointer<UInt8>(data.bytes), count: data.length)
      return data.length
    }
  }

  public func seek(offset: Int, origin: SeekOrigin) throws -> Int {
    switch origin {
    case .Begin:
      fileHandle.seekToFileOffset(UInt64(offset))
    case .Current:
      fileHandle.seekToFileOffset(fileHandle.offsetInFile + UInt64(offset))
    case .End:
      fileHandle.seekToEndOfFile()
      fileHandle.seekToFileOffset(fileHandle.offsetInFile + UInt64(offset))
    }
    return Int(fileHandle.offsetInFile)
  }

  public func close() {
    fileHandle.closeFile()
  }
}
