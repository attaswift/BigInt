// This file was written by LiarPrincess for Violet - Python VM written in Swift.
// https://github.com/LiarPrincess/Violet

import XCTest
@testable import BigInt

// swiftlint:disable type_name

private typealias Word = BigInt.Word

/// Operations for which exists 'reverse' operation that undoes its effect.
/// For example for addition it is subtraction: `(n + x) - x = n`.
class ApplyA_UndoA: XCTestCase {

  private lazy var values = generateBigIntValues(countButNotReally: 20)
  private lazy var pairs = allPossiblePairings(lhs: self.values, rhs: self.values)

  // MARK: - Tests

  func test_addSub() {
    for (lhsRaw, rhsRaw) in self.pairs {
      let lhs = self.create(lhsRaw)
      let rhs = self.create(rhsRaw)

      let expectedLhs = (lhs + rhs) - rhs
      XCTAssertEqual(lhs, expectedLhs, "\(lhs) +- \(rhs)")
    }
  }

  func test_mulDiv() {
    for (lhsRaw, rhsRaw) in self.pairs {
      if rhsRaw.isZero {
        continue
      }

      let lhs = self.create(lhsRaw)
      let rhs = self.create(rhsRaw)

      let expectedLhs = (lhs * rhs) / rhs
      XCTAssertEqual(lhs, expectedLhs, "\(lhs) */ \(rhs)")
    }
  }

  func test_shiftLeftRight() {
    for raw in self.values {
      let value = self.create(raw)

      let lessThanWord = 5
      let word = Word.bitWidth
      let moreThanWord = Word.bitWidth + Word.bitWidth - 7

      for count in [lessThanWord, word, moreThanWord] {
        let result = (value << count) >> count
        XCTAssertEqual(result, value, "\(value) <<>> \(count)")
      }
    }
  }

  func test_toStringInit() {
    for raw in self.values {
      let value = self.create(raw)

      for radix in [2, 5, 10, 16] {
        let string = String(value, radix: radix)
        guard let int = BigInt(string, radix: radix) else {
          XCTFail("string: \(string), radix: \(radix)")
          continue
        }

        XCTAssertEqual(int, value, "string: \(string)")
      }
    }
  }

  // MARK: - Helpers

  private func create(_ p: BigIntPrototype) -> BigInt {
    return p.create()
  }
}
