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

@testable import SwiftCGI
import XCTest


/// Unit tests for the `Regex` class.
class RegexTest: XCTestCase {

  func testMatches_() {
    XCTAssertNoThrow {
      let regex = try Regex(pattern: "(\\d+)-(\\d+)", options: [])
      let matches = regex.matches("The number is 123-4567.")

      let matchArray = Array(matches)
      XCTAssertEqual(matchArray.count, 1)
      XCTAssertEqual(matchArray[0].groups.count, 3)
      XCTAssertEqual(matchArray[0].groups[0].string, "123-4567")
      XCTAssertEqual(matchArray[0].groups[1].string, "123")
      XCTAssertEqual(matchArray[0].groups[2].string, "4567")
    }
  }

  func testMatches_withMultipleMatches_shouldFindAllMatches() {
    XCTAssertNoThrow {
      let regex = try Regex(pattern: "(\\d+-\\d+)", options: [])
      var matches = regex.matches("The numbers are 123-4567, 987-6543, 111-X999, and 000-1111.")

      var match = matches.next()!
      XCTAssertEqual(match.groups[0].string, "123-4567")

      match = matches.next()!
      XCTAssertEqual(match.groups[0].string, "987-6543")

      match = matches.next()!
      XCTAssertEqual(match.groups[0].string, "000-1111")

      XCTAssertNil(matches.next())
    }
  }
  
  func testMatchesInside_whenGivenAnExactMatch_shouldReturnTrue() {
    XCTAssertNoThrow {
      let regex = try Regex(pattern: "foo.*bar", options: [])
      let result = regex.matchesInside("foo_to_the_bar")
      XCTAssertTrue(result)
    }
  }

  func testMatchesInside_whenGivenAnExactMatchWithUnicodeCharacters_shouldReturnTrue() {
    XCTAssertNoThrow {
      let regex = try Regex(pattern: "foo.*b💩r", options: [])
      let result = regex.matchesInside("foo_💩_b💩r")
      XCTAssertTrue(result)
    }
  }

  func testMatchesInside_whenGivenAPartialMatch_shouldReturnTrue() {
    XCTAssertNoThrow {
      let regex = try Regex(pattern: "foo.*bar", options: [])
      let result = regex.matchesInside("a_foo_to_the_bar_baz")
      XCTAssertTrue(result)
    }
  }

  func testMatchesInside_whenGivenAPartialMatchWithUnicodeCharacters_shouldReturnTrue() {
    XCTAssertNoThrow {
      let regex = try Regex(pattern: "foo.*b💩r", options: [])
      let result = regex.matchesInside("💩_foo_💩_b💩r_baz")
      XCTAssertTrue(result)
    }
  }

  func testMatchesExactly_whenGivenAnExactMatch_shouldReturnTrue() {
    XCTAssertNoThrow {
      let regex = try Regex(pattern: "foo.*bar", options: [])
      let result = regex.matchesExactly("foo_to_the_bar")
      XCTAssertTrue(result)
    }
  }

  func testMatchesExactly_whenGivenAnExactMatchWithUnicodeCharacters_shouldReturnTrue() {
    XCTAssertNoThrow {
      let regex = try Regex(pattern: "foo.*b💩r", options: [])
      let result = regex.matchesExactly("foo_💩_b💩r")
      XCTAssertTrue(result)
    }
  }

  func testMatchesExactly_whenGivenAPartialMatch_shouldReturnFalse() {
    XCTAssertNoThrow {
      let regex = try Regex(pattern: "foo.*bar", options: [])
      let result = regex.matchesExactly("foo_to_the_bar_baz")
      XCTAssertFalse(result)
    }
  }

  func testMatchesExactly_whenGivenAPartialMatchWithUnicodeCharacters_shouldReturnFalse() {
    XCTAssertNoThrow {
      let regex = try Regex(pattern: "foo.*b💩r", options: [])
      let result = regex.matchesExactly("foo_💩_b💩r_baz")
      XCTAssertFalse(result)
    }
  }
}
