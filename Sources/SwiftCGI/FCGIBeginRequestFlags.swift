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


/// Flags that control how the application should control shutdown of the connection after
/// responding to the request.
struct FCGIBeginRequestFlags: OptionSetType {

  /// The application should not close the connection after responding to this request.
  static let KeepConnection = FCGIBeginRequestFlags(rawValue: 1)

  /// The raw byte value of the flags.
  let rawValue: Int8
}
