// This file was written by LiarPrincess for Violet - Python VM written in Swift.
// https://github.com/LiarPrincess/Violet

import XCTest
@testable import BigInt

private typealias Word = BigInt.Word
private typealias WordsExpected = (words: [Word], expected: String)

private typealias TestCase = StringTestCases.TestCase
private typealias BinaryTestCases = StringTestCases.Binary
private typealias QuinaryTestCases = StringTestCases.Quinary
private typealias OctalTestCases = StringTestCases.Octal
private typealias DecimalTestCases = StringTestCases.Decimal
private typealias HexTestCases = StringTestCases.Hex

class BigIntStringInitTests: XCTestCase {

  // MARK: - Empty

  func test_empty_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "", radix: radix)
      XCTAssertNil(result, "Radix: \(radix)")
    }
  }

  func test_onlyPlusSign_withoutDigits_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "+", radix: 10)
      XCTAssertNil(result, "Radix: \(radix)")
    }
  }

  func test_onlyMinusSign_withoutDigits_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "-", radix: 10)
      XCTAssertNil(result, "Radix: \(radix)")
    }
  }

  // MARK: - Zero

  func test_zero_single() {
    let zero = BigInt()

    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "0", radix: radix)
      XCTAssertEqual(result, zero)
    }
  }

  func test_zero_single_plus() {
    let zero = BigInt()

    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "+0", radix: radix)
      XCTAssertEqual(result, zero)
    }
  }

  func test_zero_single_minus() {
    let zero = BigInt()

    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "-0", radix: radix)
      XCTAssertEqual(result, zero)
    }
  }

  func test_zero_multiple() {
    let zero = BigInt()
    let input = String(repeating: "0", count: 42)

    for radix in [2, 4, 7, 32] {
      let result = self.create(string: input, radix: radix)
      XCTAssertEqual(result, zero)
    }
  }

  // MARK: - Smi

  func test_smi_decimal() {
    let radix = 10

    for smi in generateIntValues(countButNotReally: 100) {
      let expected = BigInt(smi)

      let lowercase = String(smi, radix: radix, uppercase: false)
      let lowercaseResult = self.create(string: lowercase, radix: radix)
      XCTAssertEqual(lowercaseResult, expected)

      let uppercase = String(smi, radix: radix, uppercase: true)
      let uppercaseResult = self.create(string: uppercase, radix: radix)
      XCTAssertEqual(uppercaseResult, expected)
    }
  }

  // MARK: - Binary

  func test_binary_singleWord() {
    self.run(
      cases: BinaryTestCases.singleWord,
      radix: 2
    )
  }

  func test_binary_twoWords() {
    self.run(
      cases: BinaryTestCases.twoWords,
      radix: 2
    )
  }

  // MARK: - Quinary

  func test_quinary_singleWord() {
    self.run(
      cases: QuinaryTestCases.singleWord,
      radix: 5
    )
  }

  func test_quinary_twoWords() {
    self.run(
      cases: QuinaryTestCases.twoWords,
      radix: 5
    )
  }

  // MARK: - Octal

  func test_octal_singleWord() {
    self.run(
      cases: OctalTestCases.singleWord,
      radix: 8
    )
  }

  func test_octal_twoWords() {
    self.run(
      cases: OctalTestCases.twoWords,
      radix: 8
    )
  }

  func test_octal_threeWords() {
    self.run(
      cases: OctalTestCases.threeWords,
      radix: 8
    )
  }

  // MARK: - Decimal

  func test_decimal_singleWord() {
    self.run(
      cases: DecimalTestCases.singleWord,
      radix: 10
    )
  }

  func test_decimal_twoWords() {
    self.run(
      cases: DecimalTestCases.twoWords,
      radix: 10
    )
  }

  func test_decimal_threeWords() {
    self.run(
      cases: DecimalTestCases.threeWords,
      radix: 10
    )
  }

  func test_decimal_fourWords() {
    self.run(
      cases: DecimalTestCases.fourWords,
      radix: 10
    )
  }

  // MARK: - Hex

  func test_hex_singleWord() {
    self.run(
      cases: HexTestCases.singleWord,
      radix: 16
    )
  }

  func test_hex_twoWords() {
    self.run(
      cases: HexTestCases.twoWords,
      radix: 16
    )
  }

  func test_hex_threeWords() {
    self.run(
      cases: HexTestCases.threeWords,
      radix: 16
    )
  }

  // MARK: - Underscore

//  not yet implemented
//  
//  func test_underscore_binary() {
//    let cases: [TestCase] = BinaryTestCases.twoWords.map { words, string in
//      let s = self.insertUnderscores(string: string)
//      return (words, s)
//    }
//
//    self.run(
//      cases: cases,
//      radix: 2
//    )
//  }

//  not yet implemented
//
//  func test_underscore_decimal() {
//    let cases: [TestCase] = DecimalTestCases.twoWords.map { words, string in
//      let s = self.insertUnderscores(string: string)
//      return (words, s)
//    }
//
//    self.run(
//      cases: cases,
//      radix: 10
//    )
//  }

  private func insertUnderscores(string: String) -> String {
    // We could create pseudo-random algorithm to select underscore location.
    // Or we could just insert underscore after every 3rd digit.
    let underscoreAfterEvery = 3

    var result = ""
    result.reserveCapacity(string.count + string.count / underscoreAfterEvery)

    for (index, char) in string.enumerated() {
      assert(char != "_")
      result.append(char)

      // Suffix underscore is prohibited
      let shouldHaveUnderscore = index.isMultiple(of: underscoreAfterEvery)
      let isLast = index == string.count - 1

      if shouldHaveUnderscore && !isLast {
        result.append("_")
      }
    }

    return result
  }

  func test_underscore_prefix_withoutSign_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "_0101", radix: radix)
      XCTAssertNil(result, "Radix: \(radix)")
    }
  }

  func test_underscore_before_plusSign_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "_+0101", radix: radix)
      XCTAssertNil(result, "Radix: \(radix)")
    }
  }

  func test_underscore_before_minusSign_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "_+0101", radix: radix)
      XCTAssertNil(result, "Radix: \(radix)")
    }
  }

  func test_underscore_after_plusSign_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "+_0101", radix: radix)
      XCTAssertNil(result, "Radix: \(radix)")
    }
  }

  func test_underscore_after_minusSign_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "-_0101", radix: radix)
      XCTAssertNil(result, "Radix: \(radix)")
    }
  }

  func test_underscore_suffix_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "0101_", radix: radix)
      XCTAssertNil(result, "Radix: \(radix)")
    }
  }

  func test_underscore_double_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "01__01", radix: radix)
      XCTAssertNil(result, "Radix: \(radix)")
    }
  }

  // MARK: - Invalid digit

  func test_invalidDigit_emoji_fails() {
    let emoji = "😊"

    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "01\(emoji)01", radix: radix)
      XCTAssertNil(result, "Radix: \(radix)")
    }
  }

  func test_invalidDigit_biggerThanRadix_fails() {
    let cases: [(Int, UnicodeScalar)] = [
      (2, "2"),
      (4, "4"),
      (7, "7"),
      (10, "a"),
      (16, "g")
    ]

    for (radix, biggerThanRadix) in cases {
      let result = self.create(string: "01\(biggerThanRadix)01", radix: radix)
      XCTAssertNil(result, "Radix: \(radix)")
    }
  }

  // MARK: - Helpers

  /// Abstraction over `BigInt.init(_:radix:)`.
  private func create(string: String, radix: Int) -> BigInt? {
    return BigInt(string, radix: radix)
  }

  private func run(cases: [StringTestCases.TestCase],
                   radix: Int,
                   file: StaticString = #file,
                   line: UInt = #line) {
    for (words, input) in cases {
      // lowercased
      do {
        let result = self.create(string: input.lowercased(), radix: radix)
        let heap = BigIntPrototype(isNegative: false, words: words)
        let expected = heap.create()
        XCTAssertEqual(result, expected, input, file: file, line: line)
      }

      // uppercased
      do {
        let result = self.create(string: input.uppercased(), radix: radix)
        let heap = BigIntPrototype(isNegative: false, words: words)
        let expected = heap.create()
        XCTAssertEqual(result, expected, input, file: file, line: line)
      }

      // '+' sign
      do {
        let result = self.create(string: "+" + input, radix: radix)
        let heap = BigIntPrototype(isNegative: false, words: words)
        let expected = heap.create()
        XCTAssertEqual(result, expected, input, file: file, line: line)
      }

      // '-' sign
      do {
        assert(!words.isEmpty, "-0 should be handled differently")
        let result = self.create(string: "-" + input, radix: radix)
        let heap = BigIntPrototype(isNegative: true, words: words)
        let expected = heap.create()
        XCTAssertEqual(result, expected, input, file: file, line: line)
      }
    }
  }
}
