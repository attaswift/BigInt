// This file was written by LiarPrincess for Violet - Python VM written in Swift.
// https://github.com/LiarPrincess/Violet

import Testing
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
@Suite
struct ApplyA_ApplyB_Equals_ApplyAB {

  // MARK: - Add

  @Test
  func add() {
    let values = generateBigIntValues(countButNotReally: 20)
    for raw in values {
      let int = create(raw)
      addTest(value: int)
    }
  }

  private static let addTestCases = createTestCases(+)

  private func addTest(value: BigInt) {
    for testCase in Self.addTestCases {
      let a_b = value + testCase.a + testCase.b
      let ab = value + testCase.c

      #expect(a_b == ab, Comment(rawValue: "\(value) + \(testCase.a) + \(testCase.b) vs \(value) + \(testCase.c)"))

      var inoutA_B = value
      inoutA_B += testCase.a
      inoutA_B += testCase.b

      var inoutAB = value
      inoutAB += testCase.c
      assert(inoutAB == ab)

      #expect(inoutA_B == inoutAB, Comment(rawValue: "inout: \(value) + \(testCase.a) + \(testCase.b) vs \(value) + \(testCase.c)"))
    }
  }

  // MARK: - Sub

  @Test
  func sub() {
    let values = generateBigIntValues(countButNotReally: 20)
    for raw in values {
      let int = create(raw)
      subTest(value: int)
    }
  }

  // '+' because we need to add a + b
  private static let subTestCases = createTestCases(+)

  private func subTest(value: BigInt) {
    for testCase in Self.subTestCases {
      let a_b = value - testCase.a - testCase.b
      let ab = value - testCase.c

      #expect(a_b == ab, Comment(rawValue: "\(value) - \(testCase.a) - \(testCase.b) vs \(value) - \(testCase.c)"))

      var inoutA_B = value
      inoutA_B -= testCase.a
      inoutA_B -= testCase.b

      var inoutAB = value
      inoutAB -= testCase.c
      assert(inoutAB == ab)

      #expect(inoutA_B == inoutAB, Comment(rawValue: "inout: \(value) - \(testCase.a) - \(testCase.b) vs \(value) - \(testCase.c)"))
    }
  }

  // MARK: - Mul

  @Test
  func mul() {
    let values = generateBigIntValues(countButNotReally: 20)
    for raw in values {
      let int = create(raw)
      mulTest(value: int)
    }
  }

  private static let mulTestCases = createTestCases(*, useBigNumbers: false)

  private func mulTest(value: BigInt) {
    for testCase in Self.mulTestCases {
      let a_b = value * testCase.a * testCase.b
      let ab = value * testCase.c

      #expect(a_b == ab, Comment(rawValue: "\(value) * \(testCase.a) * \(testCase.b) vs \(value) * \(testCase.c)"))

      var inoutA_B = value
      inoutA_B *= testCase.a
      inoutA_B *= testCase.b

      var inoutAB = value
      inoutAB *= testCase.c
      assert(inoutAB == ab)

      #expect(inoutA_B == inoutAB, Comment(rawValue: "inout: \(value) * \(testCase.a) * \(testCase.b) vs \(value) * \(testCase.c)"))
    }
  }

  // MARK: - Div

  @Test
  func div() {
    let values = generateBigIntValues(countButNotReally: 20)
    for raw in values {
      let int = create(raw)
      divTest(value: int)
    }
  }

  private static let divTestCases = [
    TestCase(*, a: "3", b: "5"),
    TestCase(*, a: "3", b: "-5"),
    TestCase(*, a: "-3", b: "5"),
    TestCase(*, a: "-3", b: "-5")
  ]

  private func divTest(value: BigInt) {
    for testCase in Self.divTestCases {
      let a_b = value / testCase.a / testCase.b
      let ab = value / testCase.c

      #expect(a_b == ab, Comment(rawValue: "\(value) / \(testCase.a) / \(testCase.b) vs \(value) / \(testCase.c)"))

      var inoutA_B = value
      inoutA_B /= testCase.a
      inoutA_B /= testCase.b

      var inoutAB = value
      inoutAB /= testCase.c
      assert(inoutAB == ab)

      #expect(inoutA_B == inoutAB, Comment(rawValue: "inout: \(value) / \(testCase.a) / \(testCase.b) vs \(value) / \(testCase.c)"))
    }
  }

  // MARK: - Left shift

  @Test
  func shiftLeft() {
    let values = generateBigIntValues(countButNotReally: 20)
    for raw in values {
      let int = create(raw)
      shiftLeftTest(value: int)
    }
  }

  @Test
  func shiftLeft_heap() {
    let values = generateBigIntValues(countButNotReally: 20)
    for raw in values {
      let int = create(raw)
      shiftLeftTest(value: int)
    }
  }

  private static let shiftLeftTestCases: [TestCase] = [
    TestCase(+, a: 1, b: 0),
    TestCase(+, a: 1, b: 1),
    TestCase(+, a: 3, b: 5),
    TestCase(+, a: 7, b: Word.bitWidth - 5),
    TestCase(+, a: Word.bitWidth - 5, b: 7)
  ]

  private func shiftLeftTest(value: BigInt) {
    for testCase in Self.shiftLeftTestCases {
      let a_b = (value << testCase.a) << testCase.b
      let ab = value << testCase.c

      #expect(a_b == ab, Comment(rawValue: "(\(value) << \(testCase.a)) << \(testCase.b) vs \(value) << \(testCase.c)"))

      var inoutA_B = value
      inoutA_B <<= testCase.a
      inoutA_B <<= testCase.b

      var inoutAB = value
      inoutAB <<= testCase.c
      assert(inoutAB == ab)

      #expect(inoutA_B == inoutAB, Comment(rawValue: "inout: (\(value) << \(testCase.a)) << \(testCase.b) vs \(value) << \(testCase.c)"))
    }
  }

  // MARK: - Right shift

  @Test
  func shiftRight() {
    let values = generateBigIntValues(countButNotReally: 20)
    for raw in values {
      let int = create(raw)
      shiftRightTest(value: int)
    }
  }

  @Test
  func shiftRight_heap() {
    let values = generateBigIntValues(countButNotReally: 20)
    for raw in values {
      let int = create(raw)
      shiftRightTest(value: int)
    }
  }

  // Right shift for more than 'Word.bitWidth' has a high probability
  // of shifting value into oblivion (0 or -1).
  private static let shiftRightTestCases: [TestCase] = [
    TestCase(+, a: 1, b: 0),
    TestCase(+, a: 1, b: 1),
    TestCase(+, a: 3, b: 5),
    TestCase(+, a: 7, b: Word.bitWidth - 5),
    TestCase(+, a: Word.bitWidth - 5, b: 7)
  ]

  private func shiftRightTest(value: BigInt) {
    for testCase in Self.shiftRightTestCases {
      let a_b = (value >> testCase.a) >> testCase.b
      let ab = value >> testCase.c

      #expect(a_b == ab, Comment(rawValue: "(\(value) >> \(testCase.a)) >> \(testCase.b) vs \(value) >> \(testCase.c)"))

      var inoutA_B = value
      inoutA_B >>= testCase.a
      inoutA_B >>= testCase.b

      var inoutAB = value
      inoutAB >>= testCase.c
      assert(inoutAB == ab)

      #expect(inoutA_B == inoutAB, Comment(rawValue: "inout: (\(value) >> \(testCase.a)) >> \(testCase.b) vs \(value) >> \(testCase.c)"))
    }
  }

  // MARK: - Helpers

  private func create(_ p: BigIntPrototype) -> BigInt {
    return p.create()
  }
}
