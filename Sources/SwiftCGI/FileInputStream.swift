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

#if os(Linux)
import Glibc
let posix_close = Glibc.close
let posix_read = Glibc.read
#else
import Darwin
let posix_close = Darwin.close
let posix_read = Darwin.read
#endif


/// An input stream that reads content from a file or file descriptor.
public class FileInputStream: InputStream {

  /// The file descriptor associated with the stream.
  private let fileDescriptor: Int32

  /// Indicates whether the underlying file descriptor should be closed, if it isn't already, when
  /// the stream is deallocated.
  private var closeOnDeinit: Bool

  /// Creates a new input stream that reads from the given file descriptor.
  ///
  /// When using this initializer, the returned stream will *not* be closed automatically if it is
  /// open when the stream is deallocated.
  ///
  /// - Parameter fileDescriptor: The POSIX file descriptor from which the stream will read.
  public init(fileDescriptor: Int32) {
    self.fileDescriptor = fileDescriptor
    closeOnDeinit = false
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
    fileDescriptor = path.withCString { cString in open(cString, 0) }
    closeOnDeinit = true
    if fileDescriptor == -1 {
      return nil
    }
  }

  deinit {
    if closeOnDeinit {
      close()
    }
  }

  public func read(inout buffer: [UInt8], offset: Int, count: Int) throws -> Int {
    if count == 0 {
      return 0
    }

    return try buffer.withUnsafeMutableBufferPointer {
      (inout buffer: UnsafeMutableBufferPointer<UInt8>) in
      let pointer = buffer.baseAddress.advancedBy(offset)
      let bytesRead = posix_read(fileDescriptor, pointer, count)
      if bytesRead == 0 {
        throw IOError.EOF
      }
      // TODO: Handle errors other than EOF.
      return bytesRead
    }
  }

  public func seek(offset: Int, origin: SeekOrigin) throws -> Int {
    let whence = lseekWhenceForSeekOrigin(origin)
    let newOffset = lseek(fileDescriptor, off_t(offset), whence)
    return Int(newOffset)
  }

  public func close() {
    posix_close(fileDescriptor)
    closeOnDeinit = false
  }

  /// Returns the `whence` argument for `lseek` that corresponds to the given `SeekOrigin`.
  ///
  /// - Parameter origin: The `SeekOrigin` value.
  /// - Returns: The corresponding `whence` argument.
  private func lseekWhenceForSeekOrigin(origin: SeekOrigin) -> Int32 {
    switch origin {
    case .Begin:
      return SEEK_SET
    case .Current:
      return SEEK_CUR
    case .End:
      return SEEK_END
    }
  }
}

