// This file was written by LiarPrincess for Violet - Python VM written in Swift.
// https://github.com/LiarPrincess/Violet

import Testing
@testable import BigInt

private typealias Word = BigInt.Word
private typealias WordsExpected = (words: [Word], expected: String)

private typealias TestCase = StringTestCases.TestCase
private typealias BinaryTestCases = StringTestCases.Binary
private typealias QuinaryTestCases = StringTestCases.Quinary
private typealias OctalTestCases = StringTestCases.Octal
private typealias DecimalTestCases = StringTestCases.Decimal
private typealias HexTestCases = StringTestCases.Hex

@Suite
struct BigIntStringInitTests {

  // MARK: - Empty

  @Test
  func empty_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "", radix: radix)
      #expect(result == nil, "Radix: \(radix)")
    }
  }

  @Test
  func onlyPlusSign_withoutDigits_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "+", radix: 10)
      #expect(result == nil, "Radix: \(radix)")
    }
  }

  @Test
  func onlyMinusSign_withoutDigits_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "-", radix: 10)
      #expect(result == nil, "Radix: \(radix)")
    }
  }

  // MARK: - Zero

  @Test
  func zero_single() {
    let zero = BigInt()

    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "0", radix: radix)
      #expect(result == zero)
    }
  }

  @Test
  func zero_single_plus() {
    let zero = BigInt()

    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "+0", radix: radix)
      #expect(result == zero)
    }
  }

  @Test
  func zero_single_minus() {
    let zero = BigInt()

    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "-0", radix: radix)
      #expect(result == zero)
    }
  }

  @Test
  func zero_multiple() {
    let zero = BigInt()
    let input = String(repeating: "0", count: 42)

    for radix in [2, 4, 7, 32] {
      let result = self.create(string: input, radix: radix)
      #expect(result == zero)
    }
  }

  // MARK: - Smi

  @Test
  func smi_decimal() {
    let radix = 10

    for smi in generateIntValues(countButNotReally: 100) {
      let expected = BigInt(smi)

      let lowercase = String(smi, radix: radix, uppercase: false)
      let lowercaseResult = self.create(string: lowercase, radix: radix)
      #expect(lowercaseResult == expected)

      let uppercase = String(smi, radix: radix, uppercase: true)
      let uppercaseResult = self.create(string: uppercase, radix: radix)
      #expect(uppercaseResult == expected)
    }
  }

  // MARK: - Binary

  @Test
  func binary_singleWord() {
    self.run(
      cases: BinaryTestCases.singleWord,
      radix: 2
    )
  }

  @Test
  func binary_twoWords() {
    self.run(
      cases: BinaryTestCases.twoWords,
      radix: 2
    )
  }

  // MARK: - Quinary

  @Test
  func quinary_singleWord() {
    self.run(
      cases: QuinaryTestCases.singleWord,
      radix: 5
    )
  }

  @Test
  func quinary_twoWords() {
    self.run(
      cases: QuinaryTestCases.twoWords,
      radix: 5
    )
  }

  // MARK: - Octal

  @Test
  func octal_singleWord() {
    self.run(
      cases: OctalTestCases.singleWord,
      radix: 8
    )
  }

  @Test
  func octal_twoWords() {
    self.run(
      cases: OctalTestCases.twoWords,
      radix: 8
    )
  }

  @Test
  func octal_threeWords() {
    self.run(
      cases: OctalTestCases.threeWords,
      radix: 8
    )
  }

  // MARK: - Decimal

  @Test
  func decimal_singleWord() {
    self.run(
      cases: DecimalTestCases.singleWord,
      radix: 10
    )
  }

  @Test
  func decimal_twoWords() {
    self.run(
      cases: DecimalTestCases.twoWords,
      radix: 10
    )
  }

  @Test
  func decimal_threeWords() {
    self.run(
      cases: DecimalTestCases.threeWords,
      radix: 10
    )
  }

  @Test
  func decimal_fourWords() {
    self.run(
      cases: DecimalTestCases.fourWords,
      radix: 10
    )
  }

  // MARK: - Hex

  @Test
  func hex_singleWord() {
    self.run(
      cases: HexTestCases.singleWord,
      radix: 16
    )
  }

  @Test
  func hex_twoWords() {
    self.run(
      cases: HexTestCases.twoWords,
      radix: 16
    )
  }

  @Test
  func hex_threeWords() {
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

  @Test
  func underscore_prefix_withoutSign_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "_0101", radix: radix)
      #expect(result == nil, "Radix: \(radix)")
    }
  }

  @Test
  func underscore_before_plusSign_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "_+0101", radix: radix)
      #expect(result == nil, "Radix: \(radix)")
    }
  }

  @Test
  func underscore_before_minusSign_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "_+0101", radix: radix)
      #expect(result == nil, "Radix: \(radix)")
    }
  }

  @Test
  func underscore_after_plusSign_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "+_0101", radix: radix)
      #expect(result == nil, "Radix: \(radix)")
    }
  }

  @Test
  func underscore_after_minusSign_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "-_0101", radix: radix)
      #expect(result == nil, "Radix: \(radix)")
    }
  }

  @Test
  func underscore_suffix_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "0101_", radix: radix)
      #expect(result == nil, "Radix: \(radix)")
    }
  }

  @Test
  func underscore_double_fails() {
    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "01__01", radix: radix)
      #expect(result == nil, "Radix: \(radix)")
    }
  }

  // MARK: - Invalid digit

  @Test
  func invalidDigit_emoji_fails() {
    let emoji = "😊"

    for radix in [2, 4, 7, 32] {
      let result = self.create(string: "01\(emoji)01", radix: radix)
      #expect(result == nil, "Radix: \(radix)")
    }
  }

  @Test
  func invalidDigit_biggerThanRadix_fails() {
    let cases: [(Int, UnicodeScalar)] = [
      (2, "2"),
      (4, "4"),
      (7, "7"),
      (10, "a"),
      (16, "g")
    ]

    for (radix, biggerThanRadix) in cases {
      let result = self.create(string: "01\(biggerThanRadix)01", radix: radix)
      #expect(result == nil, "Radix: \(radix)")
    }
  }

  // MARK: - Helpers

  /// Abstraction over `BigInt.init(_:radix:)`.
  private func create(string: String, radix: Int) -> BigInt? {
    return BigInt(string, radix: radix)
  }

  private func run(cases: [StringTestCases.TestCase],
                   radix: Int) {
    for (words, input) in cases {
      // lowercased
      do {
        let result = self.create(string: input.lowercased(), radix: radix)
        let heap = BigIntPrototype(isNegative: false, words: words)
        let expected = heap.create()
        #expect(result == expected, Comment(rawValue: input))
      }

      // uppercased
      do {
        let result = self.create(string: input.uppercased(), radix: radix)
        let heap = BigIntPrototype(isNegative: false, words: words)
        let expected = heap.create()
        #expect(result == expected, Comment(rawValue: input))
      }

      // '+' sign
      do {
        let result = self.create(string: "+" + input, radix: radix)
        let heap = BigIntPrototype(isNegative: false, words: words)
        let expected = heap.create()
        #expect(result == expected, Comment(rawValue: input))
      }

      // '-' sign
      do {
        assert(!words.isEmpty, "-0 should be handled differently")
        let result = self.create(string: "-" + input, radix: radix)
        let heap = BigIntPrototype(isNegative: true, words: words)
        let expected = heap.create()
        #expect(result == expected, Comment(rawValue: input))
      }
    }
  }
}
