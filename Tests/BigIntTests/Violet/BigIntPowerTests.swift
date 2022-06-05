// This file was written by LiarPrincess for Violet - Python VM written in Swift.
// https://github.com/LiarPrincess/Violet

import XCTest
@testable import BigInt

class BigIntPowerTests: XCTestCase {

  // MARK: - Trivial base

  /// 0 ^ n = 0 (or sometimes 1)
//  func test_base_zero() {
//    let zero = BigInt(0)
//    let one = BigInt(1)
//
//    for exponent in generateIntValues(countButNotReally: 100) {
//      let result = zero.power(exponent)
//
//      // 0 ^ 0 = 1, otherwise 0
//      let expected = exponent == 0 ? one : zero
//      XCTAssertEqual(result, expected, "0 ^ \(exponent)")
//    }
//  }

  /// 1 ^ n = 1
  func test_base_one() {
    let one = BigInt(1)

    for exponent in generateIntValues(countButNotReally: 100) {
      let result = one.power(exponent)
      let expected = one
      XCTAssertEqual(result, expected, "1 ^ \(exponent)")
    }
  }

  /// (-1) ^ n = (-1) or 1
  func test_base_minusOne() {
    let plusOne = BigInt(1)
    let minusOne = BigInt(-1)

    for exponent in generateIntValues(countButNotReally: 100) {
      let result = minusOne.power(exponent)

      let expected = exponent.isMultiple(of: 2) ? plusOne : minusOne
      XCTAssertEqual(result, expected, "(-1) ^ \(exponent)")
    }
  }

  // MARK: - Trivial exponent

  /// n ^ 0 = 1
  func test_exponent_zero() {
    let zero = 0
    let one = BigInt(1)

    for smi in generateIntValues(countButNotReally: 100) {
      let base = BigInt(smi)
      let result = base.power(zero)

      let expected = one
      XCTAssertEqual(result, expected, "\(smi) ^ 1")
    }
  }

  /// n ^ 1 = n
  func test_exponent_one() {
    let one = 1

    for smi in generateIntValues(countButNotReally: 100) {
      let base = BigInt(smi)
      let result = base.power(one)

      let expected = base
      XCTAssertEqual(result, expected, "\(smi) ^ 1")
    }
  }

  func test_exponent_two() {
    let two = 2

    for p in generateBigIntValues(countButNotReally: 2) {
      let baseHeap = BigIntPrototype(isNegative: false, words: p.words)
      let base = baseHeap.create()
      let result = base.power(two)

      let expected = base * base
      XCTAssertEqual(result, expected, "\(base) ^ 2")
    }
  }

  func test_exponent_three() {
    let three = 3

    for p in generateBigIntValues(countButNotReally: 2) {
      let baseHeap = BigIntPrototype(isNegative: false, words: p.words)
      let base = baseHeap.create()
      let result = base.power(three)

      let expected = base * base * base
      XCTAssertEqual(result, expected, "\(base) ^ 3")
    }
  }

  // MARK: - Smi

  func test_againstFoundationPow() {
    // THIS IS NOT A PERFECT TEST!
    // It is 'good enough' to be usable, but don't think about it too much!
    let mantissaCount = Double.significandBitCount // well… technically '+1'
    let maxExactlyRepresentable = UInt(pow(Double(2), Double(mantissaCount)))

    // 'Int32 ^ 2' has greater possibility of being in 'Double' range than 'Int'
    var values = [Int32]()

    for value in generateIntValues(countButNotReally: 20) {
      if let i32 = Int32(exactly: value) {
        values.append(i32)
      }
    }

    for i in -10...10 {
      values.append(Int32(i))
    }

    for (baseSmi, expSmiSigned) in allPossiblePairings(values: values) {
      let expSmi = expSmiSigned.magnitude

      guard let baseDouble = Double(exactly: baseSmi),
            let expDouble = Double(exactly: expSmi) else {
          continue
      }

      let expectedDouble = pow(baseDouble, expDouble)
      guard let expectedInt = Int(exactly: expectedDouble),
                expectedInt.magnitude < maxExactlyRepresentable else {
        continue
      }

      // Some tests will actually get here, not a lot, but some
      let base = BigInt(baseSmi)
      let exp = Int(expSmi)
      let result = base.power(exp)

      let expected = BigInt(expectedInt)
      XCTAssertEqual(result, expected, "\(baseSmi) ^ \(expSmi)")
    }
  }
}
