// This file was written by LiarPrincess for Violet - Python VM written in Swift.
// https://github.com/LiarPrincess/Violet

import Testing
@testable import BigInt

// swiftlint:disable type_name

private typealias Word = BigInt.Word

/// Operations for which exists 'reverse' operation that undoes its effect.
/// For example for addition it is subtraction: `(n + x) - x = n`.
@Suite
struct ApplyA_UndoA {

  // MARK: - Tests

  @Test
  func addSub() {
    let values = generateBigIntValues(countButNotReally: 20)
    let pairs = allPossiblePairings(lhs: values, rhs: values)
    
    for (lhsRaw, rhsRaw) in pairs {
      let lhs = create(lhsRaw)
      let rhs = create(rhsRaw)

      let expectedLhs = (lhs + rhs) - rhs
      #expect(lhs == expectedLhs, "\(lhs) +- \(rhs)")
    }
  }

  @Test
  func mulDiv() {
    let values = generateBigIntValues(countButNotReally: 20)
    let pairs = allPossiblePairings(lhs: values, rhs: values)
    
    for (lhsRaw, rhsRaw) in pairs {
      if rhsRaw.isZero {
        continue
      }

      let lhs = create(lhsRaw)
      let rhs = create(rhsRaw)

      let expectedLhs = (lhs * rhs) / rhs
      #expect(lhs == expectedLhs, "\(lhs) */ \(rhs)")
    }
  }

  @Test
  func shiftLeftRight() {
    let values = generateBigIntValues(countButNotReally: 20)
    
    for raw in values {
      let value = create(raw)

      let lessThanWord = 5
      let word = Word.bitWidth
      let moreThanWord = Word.bitWidth + Word.bitWidth - 7

      for count in [lessThanWord, word, moreThanWord] {
        let result = (value << count) >> count
        #expect(result == value, "\(value) <<>> \(count)")
      }
    }
  }

  @Test
  func toStringInit() {
    let values = generateBigIntValues(countButNotReally: 20)
    
    for raw in values {
      let value = create(raw)

      for radix in [2, 5, 10, 16] {
        let string = String(value, radix: radix)
        guard let int = BigInt(string, radix: radix) else {
          Issue.record("string: \(string), radix: \(radix)")
          continue
        }

        #expect(int == value, "string: \(string)")
      }
    }
  }

  // MARK: - Helpers

  private func create(_ p: BigIntPrototype) -> BigInt {
    return p.create()
  }
}
