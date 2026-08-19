// This file was written by LiarPrincess for Violet - Python VM written in Swift.
// https://github.com/LiarPrincess/Violet

import Testing
@testable import BigInt

private typealias Word = BigInt.Word

@Suite
struct BigIntPropertyTests {

  // MARK: - Description

  @Test
  func description() {
    for int in generateIntValues(countButNotReally: 100) {
      let value = BigInt(int)
      #expect(value.description == int.description, "\(int)")
    }
  }

  // MARK: - Words

//  func test_words_zero() {
//    let value = BigInt(0)
//    expectWords(value, WordsTestCases.zeroWords)
//  }
//
//  func test_words_int() {
//    for (value, expected) in WordsTestCases.int {
//      let bigInt = BigInt(value)
//      expectWords(bigInt, expected)
//    }
//  }

  @Test
  func words_multipleWords_positive() {
    for (words, expected) in WordsTestCases.heapPositive {
      let heap = BigIntPrototype(isNegative: false, words: words)
      let bigInt = heap.create()
      expectWords(bigInt, expected)
    }
  }

//  func test_words_multipleWords_negative_powerOf2() {
//    for (words, expected) in WordsTestCases.heapNegative_powerOf2 {
//      let heap = BigIntPrototype(isNegative: true, words: words)
//      let bigInt = heap.create()
//      expectWords(bigInt, expected)
//    }
//  }

  @Test
  func words_multipleWords_negative_notPowerOf2() {
    for (words, expected) in WordsTestCases.heapNegative_notPowerOf2 {
      let heap = BigIntPrototype(isNegative: true, words: words)
      let bigInt = heap.create()
      expectWords(bigInt, expected)
    }
  }

  // MARK: - Bit width

//  func test_bitWidth_trivial() {
//    let zero = BigInt(0)
//    XCTAssertEqual(zero.bitWidth, 1) //  0 is just 0
//
//    let plus1 = BigInt(1)
//    XCTAssertEqual(plus1.bitWidth, 2) // 1 needs '0' prefix -> '01'
//
//    let minus1 = BigInt(-1)
//    XCTAssertEqual(minus1.bitWidth, 1) // -1 is just 1
//  }

  @Test
  func bitWidth_positivePowersOf2() {
    for (int, power, expected) in BitWidthTestCases.positivePowersOf2 {
      let bigInt = BigInt(int)
      #expect(bigInt.bitWidth == expected, "for \(int) (2^\(power))")
    }
  }

//  func test_bitWidth_negativePowersOf2() {
//    for (int, power, expected) in BitWidthTestCases.negativePowersOf2 {
//      let bigInt = BigInt(int)
//      XCTAssertEqual(bigInt.bitWidth, expected, "for \(int) (2^\(power))")
//    }
//  }
//
//  func test_bitWidth_smiTestCases() {
//    for (value, expected) in BitWidthTestCases.smi {
//      let bigInt = BigInt(value)
//      XCTAssertEqual(bigInt.bitWidth, expected, "\(value)")
//    }
//  }

  @Test
  func bitWidth_multipleWords_positivePowersOf2() {
    let correction = BitWidthTestCases.positivePowersOf2Correction

    for zeroWordCount in [1, 2] {
      let zeroWords = [Word](repeating: 0, count: zeroWordCount)
      let zeroWordsBitWidth = zeroWordCount * Word.bitWidth

      for (power, value) in allPositivePowersOf2(type: Word.self) {
        let words = zeroWords + [value]
        let heap = BigIntPrototype(isNegative: false, words: words)
        let bigInt = heap.create()

        let expected = power + correction + zeroWordsBitWidth
        #expect(bigInt.bitWidth == expected, "\(heap)")
      }
    }
  }

//  func test_bitWidth_multipleWords_negativePowersOf2() {
//    let correction = BitWidthTestCases.negativePowersOf2Correction
//
//    for zeroWordCount in [1, 2] {
//      let zeroWords = [Word](repeating: 0, count: zeroWordCount)
//      let zeroWordsBitWidth = zeroWordCount * Word.bitWidth
//
//      for (power, value) in allPositivePowersOf2(type: Word.self) {
//        let words = zeroWords + [value]
//        let heap = BigIntPrototype(isNegative: true, words: words)
//        let bigInt = heap.create()
//
//        let expected = power + correction + zeroWordsBitWidth
//        XCTAssertEqual(bigInt.bitWidth, expected, "\(heap)")
//      }
//    }
//  }

  // MARK: - Trailing zero bit count

  @Test
  func trailingZeroBitCount_zero() {
    let zero = BigInt(0)
    #expect(zero.trailingZeroBitCount == 0)
  }

  @Test
  func trailingZeroBitCount_int() {
    for raw in generateIntValues(countButNotReally: 100) {
      if raw == 0 {
        continue
      }

      let int = BigInt(raw)
      let result = int.trailingZeroBitCount

      let expected = raw.trailingZeroBitCount
      #expect(result == expected)
    }
  }

  @Test
  func trailingZeroBitCount_heap_nonZeroFirstWord() {
    for p in generateBigIntValues(countButNotReally: 100, maxWordCount: 3) {
      if p.isZero {
        continue
      }

      // We have separate test for numbers that have '0' last word
      if p.words[0] == 0 {
        continue
      }

      let int = p.create()
      let result = int.trailingZeroBitCount

      let expected = p.words[0].trailingZeroBitCount
      #expect(result == expected)
    }
  }

  @Test
  func trailingZeroBitCount_heap_zeroFirstWord() {
    for p in generateBigIntValues(countButNotReally: 100, maxWordCount: 3) {
      if p.isZero {
        continue
      }

      guard p.words.count > 1 else {
        continue
      }

      var words = p.words
      words[0] = 0

      let heap = BigIntPrototype(isNegative: p.isNegative, words: words)
      let int = heap.create()
      let result = int.trailingZeroBitCount

      let expected = Word.bitWidth + p.words[1].trailingZeroBitCount
      #expect(result == expected)
    }
  }

  // MARK: - Magnitude

  @Test
  func magnitude_int() {
    for raw in generateIntValues(countButNotReally: 100) {
      let int = BigInt(raw)
      let magnitude = int.magnitude

      let expected = raw.magnitude
      #expect(magnitude == expected, "\(raw)")
    }
  }

  @Test
  func magnitude_heap() {
    for p in generateBigIntValues(countButNotReally: 100) {
      if p.isZero {
        continue
      }

      let positiveHeap = BigIntPrototype(isNegative: false, words: p.words)
      let positive = positiveHeap.create()

      let negativeHeap = BigIntPrototype(isNegative: true, words: p.words)
      let negative = negativeHeap.create()

      #expect(positive.magnitude == negative.magnitude)
    }
  }
}
