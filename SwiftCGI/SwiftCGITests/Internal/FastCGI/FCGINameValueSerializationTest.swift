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

import SwiftCGI
import XCTest


/// Unit tests for the FastCGI name-value serialization functions.
class FCGINameValueSerializationTest: XCTestCase {

  func testNameValueDictionaryFromBytes_shortNameAndValue() {
    let stream = TestOutputStream()
    do {
      try stream.write(UInt8(3))
      try stream.write(UInt8(6))
      try stream.write("foo", nullTerminated: false)
      try stream.write("barbaz", nullTerminated: false)
    } catch {}
    let dictionary = FCGINameValueDictionaryFromBytes(stream.testData)

    XCTAssertEqual(dictionary.count, 1)
    XCTAssertEqual(dictionary["foo"], "barbaz")
  }

  func testNameValueDictionaryFromBytes_longNameAndValue() {
    let stream = TestOutputStream()
    do {
      try stream.write(UInt32(0x80000003).bigEndian)
      try stream.write(UInt32(0x80000006).bigEndian)
      try stream.write("foo", nullTerminated: false)
      try stream.write("barbaz", nullTerminated: false)
    } catch {}
    let dictionary = FCGINameValueDictionaryFromBytes(stream.testData)

    XCTAssertEqual(dictionary.count, 1)
    XCTAssertEqual(dictionary["foo"], "barbaz")
  }

  func testNameValueDictionaryFromBytes_shortNameAndLongValue() {
    let stream = TestOutputStream()
    do {
      try stream.write(UInt8(3))
      try stream.write(UInt32(0x80000006).bigEndian)
      try stream.write("foo", nullTerminated: false)
      try stream.write("barbaz", nullTerminated: false)
    } catch {}
    let dictionary = FCGINameValueDictionaryFromBytes(stream.testData)

    XCTAssertEqual(dictionary.count, 1)
    XCTAssertEqual(dictionary["foo"], "barbaz")
  }

  func testNameValueDictionaryFromBytes_longNameAndShortValue() {
    let stream = TestOutputStream()
    do {
      try stream.write(UInt32(0x80000003).bigEndian)
      try stream.write(UInt8(6))
      try stream.write("foo", nullTerminated: false)
      try stream.write("barbaz", nullTerminated: false)
    } catch {}
    let dictionary = FCGINameValueDictionaryFromBytes(stream.testData)

    XCTAssertEqual(dictionary.count, 1)
    XCTAssertEqual(dictionary["foo"], "barbaz")
  }

  func testNameValueDictionaryFromBytes_multiplePairs() {
    let stream = TestOutputStream()
    do {
      try stream.write(UInt32(0x80000003).bigEndian)
      try stream.write(UInt32(0x80000006).bigEndian)
      try stream.write("foo", nullTerminated: false)
      try stream.write("barbaz", nullTerminated: false)
      try stream.write(UInt8(8))
      try stream.write(UInt8(4))
      try stream.write("Sterling", nullTerminated: false)
      try stream.write("Lana", nullTerminated: false)
    } catch {}
    let dictionary = FCGINameValueDictionaryFromBytes(stream.testData)

    XCTAssertEqual(dictionary.count, 2)
    XCTAssertEqual(dictionary["foo"], "barbaz")
    XCTAssertEqual(dictionary["Sterling"], "Lana")
  }

  func testBytesFromNameValueDictionary_shortNameAndValue() {
    let pairs = [ "foo": "barbaz" ]
    let bytes = FCGIBytesFromNameValueDictionary(pairs)

    let stream = TestOutputStream()
    do {
      try stream.write(UInt8(3))
      try stream.write(UInt8(6))
      try stream.write("foo", nullTerminated: false)
      try stream.write("barbaz", nullTerminated: false)
    } catch {}

    XCTAssertEqual(bytes, stream.testData)
  }

  func testBytesFromNameValueDictionary_longNameAndShortValue() {
    let longName = String(count: 200, repeatedValue: Character("X"))
    let pairs = [ longName: "barbaz" ]
    let bytes = FCGIBytesFromNameValueDictionary(pairs)

    let stream = TestOutputStream()
    do {
      try stream.write(UInt32(0x800000C8).bigEndian)
      try stream.write(UInt8(6))
      try stream.write(longName, nullTerminated: false)
      try stream.write("barbaz", nullTerminated: false)
    } catch {}

    XCTAssertEqual(bytes, stream.testData)
  }

  func testBytesFromNameValueDictionary_shortNameAndLongValue() {
    let longValue = String(count: 256, repeatedValue: Character("Y"))
    let pairs = [ "foo": longValue ]
    let bytes = FCGIBytesFromNameValueDictionary(pairs)

    let stream = TestOutputStream()
    do {
      try stream.write(UInt8(3))
      try stream.write(UInt32(0x80000100).bigEndian)
      try stream.write("foo", nullTerminated: false)
      try stream.write(longValue, nullTerminated: false)
    } catch {}

    XCTAssertEqual(bytes, stream.testData)
  }

  func testBytesFromNameValueDictionary_longNameAndValue() {
    let longName = String(count: 200, repeatedValue: Character("X"))
    let longValue = String(count: 256, repeatedValue: Character("Y"))
    let pairs = [ longName: longValue ]
    let bytes = FCGIBytesFromNameValueDictionary(pairs)

    let stream = TestOutputStream()
    do {
      try stream.write(UInt32(0x800000C8).bigEndian)
      try stream.write(UInt32(0x80000100).bigEndian)
      try stream.write(longName, nullTerminated: false)
      try stream.write(longValue, nullTerminated: false)
    } catch {}

    XCTAssertEqual(bytes, stream.testData)
  }

  func testBytesFromNameValueDictionary_multipleValues() {
    let longName = String(count: 200, repeatedValue: Character("X"))
    let longValue = String(count: 256, repeatedValue: Character("Y"))
    let pairs = [ longName: longValue, "Sterling": "Archer" ]
    let bytes = FCGIBytesFromNameValueDictionary(pairs)

    // TODO: This test depends on order of iteration in the dictionary. Make it more robust by
    // trying all permutations.
    let stream = TestOutputStream()
    do {
      try stream.write(UInt8(8))
      try stream.write(UInt8(6))
      try stream.write("Sterling", nullTerminated: false)
      try stream.write("Archer", nullTerminated: false)
      try stream.write(UInt32(0x800000C8).bigEndian)
      try stream.write(UInt32(0x80000100).bigEndian)
      try stream.write(longName, nullTerminated: false)
      try stream.write(longValue, nullTerminated: false)
    } catch {}

    XCTAssertEqual(bytes, stream.testData)
  }
}
