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


/// Represents errors that can be thrown during I/O operations.
public enum IOError: ErrorType {

  /// A read operation went past the end of the stream/file.
  case EOF

  /// An I/O operation was unsupported (for example, attempting to seek on a stream that doesn't
  /// allow it).
  case Unsupported
}
