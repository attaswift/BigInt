// This file was written by LiarPrincess for Violet - Python VM written in Swift.
// https://github.com/LiarPrincess/Violet

import XCTest
@testable import BigInt

private typealias Word = BigInt.Word

/// This class tests `BigInt -> Swift.Integer` inits!
/// Our `BigInt.inits` are quite trivial (because we can represent any number),
/// so we will not test them.
class BigIntIntegerInitTests: XCTestCase {

  // MARK: - Exactly

  func test_exactly_signed() {
    self.exactly_inRange(type: Int8.self)
    self.exactly_inRange(type: Int16.self)
    self.exactly_inRange(type: Int32.self)
    self.exactly_inRange(type: Int64.self)
    self.exactly_inRange(type: Int.self)
  }

  func test_exactly_unsigned() {
    self.exactly_inRange(type: UInt8.self)
    self.exactly_inRange(type: UInt16.self)
    self.exactly_inRange(type: UInt32.self)
    self.exactly_inRange(type: UInt64.self)
    self.exactly_inRange(type: UInt.self)
  }

  private func exactly_inRange<T: FixedWidthInteger>(
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    var values: [T] = [0, 42, T.max, T.max - 1, T.min, T.min + 1]
    values.append(contentsOf: allPositivePowersOf2(type: T.self).map { $0.value })

    if T.isSigned {
      values.append(-1)
      values.append(-42)
      values.append(contentsOf: allNegativePowersOf2(type: T.self).map { $0.value })
    }

    let typeName = String(describing: T.self)

    for value in values {
      let header = "\(typeName) \(value)"

      let bigInt = BigInt(value)

      // String representation should be equal - trivial test for value
      let bigIntString = String(bigInt, radix: 10, uppercase: false)
      let valueString = String(value, radix: 10, uppercase: false)
      XCTAssertEqual(bigIntString, valueString, "\(header) - String", file: file, line: line)

      // T -> BigInt -> T
      if let revert = T(exactly: bigInt) {
        let msg = "\(header) - \(typeName) -> BigInt -> \(typeName)"
        XCTAssertEqual(value, revert, msg, file: file, line: line)
      } else {
        XCTFail("\(header) - failed BigInt -> \(typeName)", file: file, line: line)
      }
    }
  }

  func test_exactly_signed_biggerThanMax_returnsNil() {
    self.exactly_biggerThanMax(type: Int8.self)
    self.exactly_biggerThanMax(type: Int16.self)
    self.exactly_biggerThanMax(type: Int32.self)
    self.exactly_biggerThanMax(type: Int64.self)
    self.exactly_biggerThanMax(type: Int.self)
  }

  func test_exactly_unsigned_biggerThanMax_returnsNil() {
    self.exactly_biggerThanMax(type: UInt8.self)
    self.exactly_biggerThanMax(type: UInt16.self)
    self.exactly_biggerThanMax(type: UInt32.self)
    self.exactly_biggerThanMax(type: UInt64.self)
    self.exactly_biggerThanMax(type: UInt.self)
  }

  private func exactly_biggerThanMax<T: FixedWidthInteger>(
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let max = type.max

    var maxPlus1 = BigInt(max)
    maxPlus1 += 1
    XCTAssertNil(T(exactly: maxPlus1), "\(max) + 1", file: file, line: line)

    let moreWordsHeap = BigIntPrototype(isNegative: false, words: [0, 1])
    let moreWords = moreWordsHeap.create()
    XCTAssertNil(T(exactly: moreWords), "\(moreWordsHeap)", file: file, line: line)
  }

  func test_exactly_signed_lessThanMin_returnsNil() {
    self.exactly_lessThanMin(type: Int8.self)
    self.exactly_lessThanMin(type: Int16.self)
    self.exactly_lessThanMin(type: Int32.self)
    self.exactly_lessThanMin(type: Int64.self)
    self.exactly_lessThanMin(type: Int.self)
  }

  func test_exactly_unsigned_lessThanMin_returnsNil() {
    self.exactly_lessThanMin(type: UInt8.self)
    self.exactly_lessThanMin(type: UInt16.self)
    self.exactly_lessThanMin(type: UInt32.self)
    self.exactly_lessThanMin(type: UInt64.self)
    self.exactly_lessThanMin(type: UInt.self)
  }

  private func exactly_lessThanMin<T: FixedWidthInteger>(
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let min = type.min

    var minMinus1 = BigInt(min)
    minMinus1 -= 1
    XCTAssertNil(T(exactly: minMinus1), "\(min) - 1", file: file, line: line)

    let moreWordsHeap = BigIntPrototype(isNegative: true, words: [0, 1])
    let moreWords = moreWordsHeap.create()
    XCTAssertNil(T(exactly: moreWords), "\(moreWordsHeap)", file: file, line: line)
  }

  // MARK: - Clamping

  func test_clamping_signed() {
    self.clamping_inRange(type: Int8.self)
    self.clamping_inRange(type: Int16.self)
    self.clamping_inRange(type: Int32.self)
    self.clamping_inRange(type: Int64.self)
    self.clamping_inRange(type: Int.self)
  }

  func test_clamping_unsigned() {
    self.clamping_inRange(type: UInt8.self)
    self.clamping_inRange(type: UInt16.self)
    self.clamping_inRange(type: UInt32.self)
    self.clamping_inRange(type: UInt64.self)
    self.clamping_inRange(type: UInt.self)
  }

  private func clamping_inRange<T: FixedWidthInteger>(
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) {

    var values: [T] = [0, 42, T.max, T.max - 1, T.min, T.min + 1]
    values.append(contentsOf: allPositivePowersOf2(type: T.self).map { $0.value })

    if T.isSigned {
      values.append(-1)
      values.append(-42)
      values.append(contentsOf: allNegativePowersOf2(type: T.self).map { $0.value })
    }

    let typeName = String(describing: T.self)

    for value in values {
      let header = "\(typeName) \(value)"

      let bigInt = BigInt(value)

      // String representation should be equal - trivial test for value
      let bigIntString = String(bigInt, radix: 10, uppercase: false)
      let valueString = String(value, radix: 10, uppercase: false)
      XCTAssertEqual(bigIntString, valueString, "\(header) - String", file: file, line: line)

      // T -> BigInt -> T
      let revert = T(clamping: bigInt)
      let msg = "\(header) - \(typeName) -> BigInt -> \(typeName)"
      XCTAssertEqual(value, revert, msg, file: file, line: line)
    }
  }

  func test_clamping_signed_biggerThanMax_returnsNil() {
    self.clamping_biggerThanMax(type: Int8.self)
    self.clamping_biggerThanMax(type: Int16.self)
    self.clamping_biggerThanMax(type: Int32.self)
    self.clamping_biggerThanMax(type: Int64.self)
    self.clamping_biggerThanMax(type: Int.self)
  }

  func test_clamping_unsigned_biggerThanMax_returnsNil() {
    self.clamping_biggerThanMax(type: UInt8.self)
    self.clamping_biggerThanMax(type: UInt16.self)
    self.clamping_biggerThanMax(type: UInt32.self)
    self.clamping_biggerThanMax(type: UInt64.self)
    self.clamping_biggerThanMax(type: UInt.self)
  }

  private func clamping_biggerThanMax<T: FixedWidthInteger>(
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let maxT = type.max
    let max = BigInt(maxT)

    do {
      let maxPlus1 = max + 1
      let clamped = T(clamping: maxPlus1)
      let clampedBigInt = BigInt(clamped)
      XCTAssertEqual(clampedBigInt, max, "\(max) + 1", file: file, line: line)
    }

    do {
      let moreWordsHeap = BigIntPrototype(isNegative: false, words: [0, 1])
      let moreWords = moreWordsHeap.create()

      let clamped = T(clamping: moreWords)
      let clampedBigInt = BigInt(clamped)
      XCTAssertEqual(clampedBigInt, max, "\(moreWordsHeap)", file: file, line: line)
    }
  }

  func test_clamping_signed_lessThanMin_returnsNil() {
    self.clamping_lessThanMin(type: Int8.self)
    self.clamping_lessThanMin(type: Int16.self)
    self.clamping_lessThanMin(type: Int32.self)
    self.clamping_lessThanMin(type: Int64.self)
    self.clamping_lessThanMin(type: Int.self)
  }

  func test_clamping_unsigned_lessThanMin_returnsNil() {
    self.clamping_lessThanMin(type: UInt8.self)
    self.clamping_lessThanMin(type: UInt16.self)
    self.clamping_lessThanMin(type: UInt32.self)
    self.clamping_lessThanMin(type: UInt64.self)
    self.clamping_lessThanMin(type: UInt.self)
  }

  private func clamping_lessThanMin<T: FixedWidthInteger>(
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let minT = type.min
    let min = BigInt(minT)

    do {
      let minMinus1 = min - 1
      let clamped = T(clamping: minMinus1)
      let clampedBigInt = BigInt(clamped)
      XCTAssertEqual(clampedBigInt, min, "\(min) - 1", file: file, line: line)
    }

    do {
      let moreWordsHeap = BigIntPrototype(isNegative: true, words: [0, 1])
      let moreWords = moreWordsHeap.create()

      let clamped = T(clamping: moreWords)
      let clampedBigInt = BigInt(clamped)
      XCTAssertEqual(clampedBigInt, min, "\(moreWordsHeap)", file: file, line: line)
    }
  }

  // MARK: - Truncating if needed

  func test_truncatingIfNeeded_signed() {
    self.truncatingIfNeeded_inRange(type: Int8.self)
    self.truncatingIfNeeded_inRange(type: Int16.self)
    self.truncatingIfNeeded_inRange(type: Int32.self)
    self.truncatingIfNeeded_inRange(type: Int64.self)
    self.truncatingIfNeeded_inRange(type: Int.self)
  }

  func test_truncatingIfNeeded_unsigned() {
    self.truncatingIfNeeded_inRange(type: UInt8.self)
    self.truncatingIfNeeded_inRange(type: UInt16.self)
    self.truncatingIfNeeded_inRange(type: UInt32.self)
    self.truncatingIfNeeded_inRange(type: UInt64.self)
    self.truncatingIfNeeded_inRange(type: UInt.self)
  }

  private func truncatingIfNeeded_inRange<T: FixedWidthInteger>(
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) {

    var values: [T] = [0, 42, T.max, T.max - 1, T.min, T.min + 1]
    values.append(contentsOf: allPositivePowersOf2(type: T.self).map { $0.value })

    if T.isSigned {
      values.append(-1)
      values.append(-42)
      values.append(contentsOf: allNegativePowersOf2(type: T.self).map { $0.value })
    }

    let typeName = String(describing: T.self)

    for value in values {
      let header = "\(typeName) \(value)"

      let bigInt = BigInt(value)

      // String representation should be equal - trivial test for value
      let bigIntString = String(bigInt, radix: 10, uppercase: false)
      let valueString = String(value, radix: 10, uppercase: false)
      XCTAssertEqual(bigIntString, valueString, "\(header) - String", file: file, line: line)

      // T -> BigInt -> T
      let revert = T(truncatingIfNeeded: bigInt)
      let msg = "\(header) - \(typeName) -> BigInt -> \(typeName)"
      XCTAssertEqual(value, revert, msg, file: file, line: line)
    }
  }

  func test_truncatingIfNeeded_signed_biggerThanMax_returnsNil() {
    self.truncatingIfNeeded_biggerThanMax(type: Int8.self)
    self.truncatingIfNeeded_biggerThanMax(type: Int16.self)
    self.truncatingIfNeeded_biggerThanMax(type: Int32.self)
    self.truncatingIfNeeded_biggerThanMax(type: Int64.self)
    self.truncatingIfNeeded_biggerThanMax(type: Int.self)
  }

  func test_truncatingIfNeeded_unsigned_biggerThanMax_returnsNil() {
    self.truncatingIfNeeded_biggerThanMax(type: UInt8.self)
    self.truncatingIfNeeded_biggerThanMax(type: UInt16.self)
    self.truncatingIfNeeded_biggerThanMax(type: UInt32.self)
    self.truncatingIfNeeded_biggerThanMax(type: UInt64.self)
    self.truncatingIfNeeded_biggerThanMax(type: UInt.self)
  }

  private func truncatingIfNeeded_biggerThanMax<T: FixedWidthInteger>(
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let maxT = type.max
    let max = BigInt(maxT)
    let minT = type.min
    let min = BigInt(minT)
    let zero = BigInt()

    do {
      // signed:   0111 + 1 =   1000 -> min
      // unsigned: 1111 + 1 = 1 0000 -> 0
      let maxPlus1 = max + 1
      let truncated = T(truncatingIfNeeded: maxPlus1)
      let truncatedBigInt = BigInt(truncated)

      let expected = T.isSigned ? min : zero
      XCTAssertEqual(truncatedBigInt, expected, "\(max) + 1", file: file, line: line)
    }

    do {
      let lowWord = Word(12)
      let moreWordsHeap = BigIntPrototype(isNegative: false, words: [lowWord, 1])
      let moreWords = moreWordsHeap.create()

      let truncated = T(truncatingIfNeeded: moreWords)
      let truncatedBigInt = BigInt(truncated)

      let expected = BigInt(lowWord)
      XCTAssertEqual(truncatedBigInt, expected, "\(moreWordsHeap)", file: file, line: line)
    }
  }

  func test_truncatingIfNeeded_signed_lessThanMin_returnsNil() {
    self.truncatingIfNeeded_lessThanMin(type: Int8.self)
    self.truncatingIfNeeded_lessThanMin(type: Int16.self)
    self.truncatingIfNeeded_lessThanMin(type: Int32.self)
    self.truncatingIfNeeded_lessThanMin(type: Int64.self)
    self.truncatingIfNeeded_lessThanMin(type: Int.self)
  }

  func test_truncatingIfNeeded_unsigned_lessThanMin_returnsNil() {
    self.truncatingIfNeeded_lessThanMin(type: UInt8.self)
    self.truncatingIfNeeded_lessThanMin(type: UInt16.self)
    self.truncatingIfNeeded_lessThanMin(type: UInt32.self)
    self.truncatingIfNeeded_lessThanMin(type: UInt64.self)
    self.truncatingIfNeeded_lessThanMin(type: UInt.self)
  }

  private func truncatingIfNeeded_lessThanMin<T: FixedWidthInteger>(
    type: T.Type,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let maxT = type.max
    let max = BigInt(maxT)
    let minT = type.min
    let min = BigInt(minT)

    do {
      // signed:   1000 - 1 = 0111 = max
      // unsigned: 0000 - 1 = 1111 = max
      let minMinus1 = min - 1
      let truncated = T(truncatingIfNeeded: minMinus1)
      let truncatedBigInt = BigInt(truncated)

      let expected = max
      XCTAssertEqual(truncatedBigInt, expected, "\(min) - 1", file: file, line: line)
    }

    do {
      // signed:   -12 = (1111) 0100 = -12
      // unsigned: -12 = (1111) 0100 = ?
      // 11110100
      let lowWord = Word(12)
      let moreWordsHeap = BigIntPrototype(isNegative: true, words: [lowWord, 1])
      let moreWords = moreWordsHeap.create()

      let truncated = T(truncatingIfNeeded: moreWords)
      let truncatedBigInt = BigInt(truncated)

      let complement = ~lowWord + 1 // no overflow possible
      let expected = BigInt(T(truncatingIfNeeded: complement))
      XCTAssertEqual(truncatedBigInt, expected, "\(moreWordsHeap)", file: file, line: line)
    }
  }
}
