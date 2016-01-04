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
import Glibc
import SwiftCGI

let server = Server()
server.listen { request, response in
  // Read the request body.
  let requestBody: String
  do {
    requestBody = try request.contentStream.readString() ?? ""
  } catch {
    requestBody = ""
  }

  // Write the response content.
  let responseStream = response.contentStream
  do {
    try responseStream.write("Request headers:\n")
    try responseStream.write("----------------\n")
    for (header, value) in request.headers {
      try responseStream.write("• \(header): \(value)\n")
    }
    try responseStream.write("\n")

    try responseStream.write("Other request properties:\n")
    try responseStream.write("-------------------------\n")
    try responseStream.write("• Method: \(request.method)\n")
    try responseStream.write("• Path: \(request.path)\n")
    try responseStream.write("• Query: \(request.queryString)\n")
    try responseStream.write("• Referrer: \(request.referrer)\n")
    try responseStream.write("• Translated path: \(request.translatedPath)\n")
    try responseStream.write("\n")

    try responseStream.write("Request body:\n")
    try responseStream.write("-------------\n")
    try responseStream.write(requestBody)
  } catch {
    fatalError("Failed to write output to the response stream.")
  }
}

