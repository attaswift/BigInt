// This file was written by LiarPrincess for Violet - Python VM written in Swift.
// https://github.com/LiarPrincess/Violet

import XCTest
@testable import BigInt

// swiftlint:disable type_name

private typealias Word = BigInt.Word

// MARK: - Test case

/// `(x + a) + b = x + c`
private struct TestCase {

  fileprivate typealias Operation = (BigInt, BigInt) -> BigInt

  fileprivate let a: BigInt
  fileprivate let b: BigInt
  fileprivate let c: BigInt

  fileprivate init<A: BinaryInteger, B: BinaryInteger>(_ op: Operation, a: A, b: B) {
    self.a = BigInt(a)
    self.b = BigInt(b)
    self.c = op(self.a, self.b)
  }

  fileprivate init(_ op: Operation, a: String, b: String) {
    self.a = BigInt(a)!
    self.b = BigInt(b)!
    self.c = op(self.a, self.b)
  }
}

private func createTestCases(_ op: TestCase.Operation,
                             useBigNumbers: Bool = true) -> [TestCase] {
  var strings = [
    "0",
    "1", "-1",
    "2147483647", "-2147483647",
    "429496735", "-429496735",
    "214748371", "-214748371",
    "18446744073709551615", "-18446744073709551615"
  ]

  if useBigNumbers {
    strings.append(contentsOf: [
      "340282366920938463481821351505477763074",
      "-340282366920938463481821351505477763074",
      "6277101735386680764516354157049543343010657915253861384197",
      "-6277101735386680764516354157049543343010657915253861384197"
    ])
  }

  var result = [TestCase]()
  for (a, b) in allPossiblePairings(lhs: strings, rhs: strings) {
    let testCase = TestCase(op, a: a, b: b)
    result.append(testCase)
  }

  return result
}

// MARK: - Tests

/// Operation that applied 2 times can also be expressed as a single application.
/// For example: `(x + a) + b = x + (a + b)`.
///
/// This is not exactly associativity, because we will also do this for shifts:
/// `(x >> a) >> b = x >> (a + b)`.
class ApplyA_ApplyB_Equals_ApplyAB: XCTestCase {

  private lazy var values = generateBigIntValues(countButNotReally: 20)

  // MARK: - Add

  func test_add() {
    for raw in self.values {
      let int = self.create(raw)
      self.addTest(value: int)
    }
  }

  private let addTestCases = createTestCases(+)

  private func addTest(value: BigInt,
                       file: StaticString = #file,
                       line: UInt = #line) {
    for testCase in self.addTestCases {
      let a_b = value + testCase.a + testCase.b
      let ab = value + testCase.c

      XCTAssertEqual(
        a_b,
        ab,
        "\(value) + \(testCase.a) + \(testCase.b) vs \(value) + \(testCase.c)",
        file: file,
        line: line
      )

      var inoutA_B = value
      inoutA_B += testCase.a
      inoutA_B += testCase.b

      var inoutAB = value
      inoutAB += testCase.c
      assert(inoutAB == ab)

      XCTAssertEqual(
        inoutA_B,
        inoutAB,
        "inout: \(value) + \(testCase.a) + \(testCase.b) vs \(value) + \(testCase.c)",
        file: file,
        line: line
      )
    }
  }

  // MARK: - Sub

  func test_sub() {
    for raw in self.values {
      let int = self.create(raw)
      self.subTest(value: int)
    }
  }

  // '+' because we need to add a + b
  private let subTestCases = createTestCases(+)

  private func subTest(value: BigInt,
                       file: StaticString = #file,
                       line: UInt = #line) {
    for testCase in self.subTestCases {
      let a_b = value - testCase.a - testCase.b
      let ab = value - testCase.c

      XCTAssertEqual(
        a_b,
        ab,
        "\(value) - \(testCase.a) - \(testCase.b) vs \(value) - \(testCase.c)",
        file: file,
        line: line
      )

      var inoutA_B = value
      inoutA_B -= testCase.a
      inoutA_B -= testCase.b

      var inoutAB = value
      inoutAB -= testCase.c
      assert(inoutAB == ab)

      XCTAssertEqual(
        inoutA_B,
        inoutAB,
        "inout: \(value) - \(testCase.a) - \(testCase.b) vs \(value) - \(testCase.c)",
        file: file,
        line: line
      )
    }
  }

  // MARK: - Mul

  func test_mul() {
    for raw in self.values {
      let int = self.create(raw)
      self.mulTest(value: int)
    }
  }

  private let mulTestCases = createTestCases(*, useBigNumbers: false)

  private func mulTest(value: BigInt,
                       file: StaticString = #file,
                       line: UInt = #line) {
    for testCase in self.mulTestCases {
      let a_b = value * testCase.a * testCase.b
      let ab = value * testCase.c

      XCTAssertEqual(
        a_b,
        ab,
        "\(value) * \(testCase.a) * \(testCase.b) vs \(value) * \(testCase.c)",
        file: file,
        line: line
      )

      var inoutA_B = value
      inoutA_B *= testCase.a
      inoutA_B *= testCase.b

      var inoutAB = value
      inoutAB *= testCase.c
      assert(inoutAB == ab)

      XCTAssertEqual(
        inoutA_B,
        inoutAB,
        "inout: \(value) * \(testCase.a) * \(testCase.b) vs \(value) * \(testCase.c)",
        file: file,
        line: line
      )
    }
  }

  // MARK: - Div

  func test_div() {
    for raw in self.values {
      let int = self.create(raw)
      self.divTest(value: int)
    }
  }

  private let divTestCases = [
    TestCase(*, a: "3", b: "5"),
    TestCase(*, a: "3", b: "-5"),
    TestCase(*, a: "-3", b: "5"),
    TestCase(*, a: "-3", b: "-5")
  ]

  private func divTest(value: BigInt,
                       file: StaticString = #file,
                       line: UInt = #line) {
    for testCase in self.divTestCases {
      let a_b = value / testCase.a / testCase.b
      let ab = value / testCase.c

      XCTAssertEqual(
        a_b,
        ab,
        "\(value) / \(testCase.a) / \(testCase.b) vs \(value) / \(testCase.c)",
        file: file,
        line: line
      )

      var inoutA_B = value
      inoutA_B /= testCase.a
      inoutA_B /= testCase.b

      var inoutAB = value
      inoutAB /= testCase.c
      assert(inoutAB == ab)

      XCTAssertEqual(
        inoutA_B,
        inoutAB,
        "inout: \(value) / \(testCase.a) / \(testCase.b) vs \(value) / \(testCase.c)",
        file: file,
        line: line
      )
    }
  }

  // MARK: - Left shift

  func test_shiftLeft() {
    for raw in self.values {
      let int = self.create(raw)
      self.shiftLeftTest(value: int)
    }
  }

  func test_shiftLeft_heap() {
    for raw in self.values {
      let int = self.create(raw)
      self.shiftLeftTest(value: int)
    }
  }

  private let shiftLeftTestCases: [TestCase] = [
    TestCase(+, a: 1, b: 0),
    TestCase(+, a: 1, b: 1),
    TestCase(+, a: 3, b: 5),
    TestCase(+, a: 7, b: Word.bitWidth - 5),
    TestCase(+, a: Word.bitWidth - 5, b: 7)
  ]

  private func shiftLeftTest(value: BigInt,
                             file: StaticString = #file,
                             line: UInt = #line) {
    for testCase in self.shiftLeftTestCases {
      let a_b = (value << testCase.a) << testCase.b
      let ab = value << testCase.c

      XCTAssertEqual(
        a_b,
        ab,
        "(\(value) << \(testCase.a)) << \(testCase.b) vs \(value) << \(testCase.c)",
        file: file,
        line: line
      )

      var inoutA_B = value
      inoutA_B <<= testCase.a
      inoutA_B <<= testCase.b

      var inoutAB = value
      inoutAB <<= testCase.c
      assert(inoutAB == ab)

      XCTAssertEqual(
        inoutA_B,
        inoutAB,
        "inout: (\(value) << \(testCase.a)) << \(testCase.b) vs \(value) << \(testCase.c)",
        file: file,
        line: line
      )
    }
  }

  // MARK: - Right shift

  func test_shiftRight() {
    for raw in self.values {
      let int = self.create(raw)
      self.shiftRightTest(value: int)
    }
  }

  func test_shiftRight_heap() {
    for raw in self.values {
      let int = self.create(raw)
      self.shiftRightTest(value: int)
    }
  }

  // Right shift for more than 'Word.bitWidth' has a high probability
  // of shifting value into oblivion (0 or -1).
  private let shiftRightTestCases: [TestCase] = [
    TestCase(+, a: 1, b: 0),
    TestCase(+, a: 1, b: 1),
    TestCase(+, a: 3, b: 5),
    TestCase(+, a: 7, b: Word.bitWidth - 5),
    TestCase(+, a: Word.bitWidth - 5, b: 7)
  ]

  private func shiftRightTest(value: BigInt,
                              file: StaticString = #file,
                              line: UInt = #line) {
    for testCase in self.shiftRightTestCases {
      let a_b = (value >> testCase.a) >> testCase.b
      let ab = value >> testCase.c

      XCTAssertEqual(
        a_b,
        ab,
        "(\(value) >> \(testCase.a)) >> \(testCase.b) vs \(value) >> \(testCase.c)",
        file: file,
        line: line
      )

      var inoutA_B = value
      inoutA_B >>= testCase.a
      inoutA_B >>= testCase.b

      var inoutAB = value
      inoutAB >>= testCase.c
      assert(inoutAB == ab)

      XCTAssertEqual(
        inoutA_B,
        inoutAB,
        "inout: (\(value) >> \(testCase.a)) >> \(testCase.b) vs \(value) >> \(testCase.c)",
        file: file,
        line: line
      )
    }
  }

  // MARK: - Helpers

  private func create(_ p: BigIntPrototype) -> BigInt {
    return p.create()
  }
}
