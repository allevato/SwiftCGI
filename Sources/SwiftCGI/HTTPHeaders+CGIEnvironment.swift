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


/// Adds support to `HTTPHeaders` for parsing headers from CGI environment variables.
extension HTTPHeaders {

  /// Creates a new `HTTPHeaders` by parsing the given environment variables containing headers in
  /// the form passed by CGI.
  ///
  /// - Parameter environment: The environment variables from which to parse the headers.
  init(environment: [String: String]) {
    self.init()

    for (name, value) in environment {
      if name.hasPrefix(environmentVariablePrefix) {
        let headerStart = name.startIndex.advancedBy(environmentVariablePrefix.characters.count)
        let headerNoPrefix = name[headerStart..<name.endIndex]
        let headerName = replaceUnderscoresWithHyphens(headerNoPrefix)
        self[headerName] = value
      } else if headersWithoutHTTPPrefix.contains(name) {
        let headerName = replaceUnderscoresWithHyphens(name)
        self[headerName] = value
      }
    }
  }
}


/// Prefix used to identify HTTP headers stored in environment variables.
private let environmentVariablePrefix = "HTTP_"


/// HTTP headers that CGI defines without the "HTTP_" prefix.
private let headersWithoutHTTPPrefix: Set<String> = ["CONTENT_LENGTH", "CONTENT_TYPE"]


/// Returns a string that has the underscores in the given string replaced with hyphens.
///
/// - Parameter string: The string whose underscores should be replaced.
/// - Returns: The string with underscores replaced by hyphens.
private func replaceUnderscoresWithHyphens(string: String) -> String {
  let components = string.characters.split("_").map(String.init)
  return components.joinWithSeparator("-")
}
