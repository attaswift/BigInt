// This file was written by LiarPrincess for Violet - Python VM written in Swift.
// https://github.com/LiarPrincess/Violet

import XCTest
@testable import BigInt

// MARK: - Asserts

internal func XCTAssertWords(_ value: BigInt,
                             _ expected: [UInt],
                             file: StaticString = #file,
                             line: UInt = #line) {
  XCTAssertWords(
    value: String(value, radix: 10, uppercase: false),
    words: Array(value.words),
    expected: expected,
    file: file,
    line: line
  )
}

private func XCTAssertWords(value: String,
                            words: [UInt],
                            expected: [UInt],
                            file: StaticString,
                            line: UInt) {
  XCTAssertEqual(words.count, expected.count, "Count for \(value)", file: file, line: line)
  guard words.count == expected.count else {
    return
  }

  // deconstruction nested in deconstruction? eh…
  for (index, (w, e)) in zip(words, expected).enumerated() {
    XCTAssertEqual(w, e, "Word \(index) for \(value)", file: file, line: line)
  }
}

// MARK: - Test cases

internal enum WordsTestCases {

  // MARK: - Zero

  internal static let zeroWords: [UInt] = [0]

  // MARK: - Int

  internal typealias IntTestCase = (value: Int, expected: [UInt])

  internal static let int: [IntTestCase] = {
    var result = [IntTestCase]()

    for int in generateIntValues(countButNotReally: 100) {
      let expected = Array(int.words)
      let tuple = IntTestCase(int, expected)
      result.append(tuple)
    }

    return result
  }()

  // MARK: - Heap positive

  internal typealias Word = BigInt.Word

  internal typealias HeapTestCase = (words: [Word], expected: [UInt])

  // words: 1000 0000
  internal static var heapPositive: [HeapTestCase] = {
    var result = [HeapTestCase]()

    for zeroWordCount in [1, 2] {
      let zeroWords = [Word](repeating: 0, count: zeroWordCount)

      for (_, value) in allPositivePowersOf2(type: Word.self) {
        let words = zeroWords + [value]

        let hasMsb1 = (value >> (Word.bitWidth - 1)) == 1
        let needsSignWord = hasMsb1
        let expectedWords = needsSignWord ? words + [0] : words

        let tuple = HeapTestCase(words, expectedWords)
        result.append(tuple)
      }
    }

    return result
  }()

  // MARK: - Heap negative

  // words:      1000 0000
  // invert:     0111 1111
  // complement: 1000 0000
  internal static var heapNegative_powerOf2: [HeapTestCase] = {
    var result = [HeapTestCase]()

    for zeroWordCount in [1, 2] {
      let zeroWords = [Word](repeating: 0, count: zeroWordCount)

      for (_, value) in allPositivePowersOf2(type: Word.self) {
        let words = zeroWords + [value]

        let valueCompliment = ~value + 1
        let expectedWords = zeroWords + [valueCompliment]

        let tuple = HeapTestCase(words, expectedWords)
        result.append(tuple)
      }
    }

    return result
  }()

  // case 1: most common
  // words:      0100 0001
  // invert:     1011 1110
  // complement: 1011 1111
  //
  // case 2: needs sign word
  // words:           1000 0001
  // invert:          0111 1110
  // complement: 1111 0111 1111
  internal static var heapNegative_notPowerOf2: [HeapTestCase] = {
    var result = [HeapTestCase]()

    for zeroWordCount in [1, 2] {
      // We are not power of '2', so we have to modify 'zeroWords'
      var zeroWords = [Word](repeating: 0, count: zeroWordCount)
      zeroWords[0] = 1

      let all1 = Word.max
      let complementWords = [Word](repeating: all1, count: zeroWordCount)

      for (_, value) in allPositivePowersOf2(type: Word.self) {
        let words = zeroWords + [value]

        let hasMsb1 = (value >> (Word.bitWidth - 1)) == 1
        let needsSignWord = hasMsb1
        let expectedWords = needsSignWord ?
          complementWords + [~value, all1] :
          complementWords + [~value]

        let tuple = HeapTestCase(words, expectedWords)
        result.append(tuple)
      }
    }

    return result
  }()
}

