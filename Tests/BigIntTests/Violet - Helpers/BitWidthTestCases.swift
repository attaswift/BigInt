// This file was written by LiarPrincess for Violet - Python VM written in Swift.
// https://github.com/LiarPrincess/Violet

@testable import BigInt

internal enum BitWidthTestCases {

  // MARK: - Smi

  internal typealias SmiTestCase = (value: Int, expected: Int)

  internal static let smi: [SmiTestCase] = [
    // zero
    (0, 1),
    // positive
    (1, 2),
    (2, 3),
    (3, 3),
    (4, 4),
    (5, 4),
    (6, 4),
    (7, 4),
    (8, 5),
    (9, 5),
    (10, 5),
    (11, 5),
    (12, 5),
    (13, 5),
    (14, 5),
    (15, 5),
    // negative
    (-1, 1),
    (-2, 2),
    (-3, 3),
    (-4, 3),
    (-5, 4),
    (-6, 4),
    (-7, 4),
    (-8, 4),
    (-9, 5),
    (-10, 5),
    (-11, 5),
    (-12, 5),
    (-13, 5),
    (-14, 5),
    (-15, 5)
  ]

  // MARK: - Powers of 2

  internal typealias PowerTestCase = (value: Int, power: Int, expected: Int)

  // +-----+-----------+-------+-------+
  // | dec |    bin    | power |  bit  |
  // |     |           |       | width |
  // +-----+-----------+-------+-------+
  // |   1 |      0001 |     0 |     2 |
  // |   2 |      0010 |     1 |     3 |
  // |   4 |      0100 |     2 |     4 |
  // |   8 | 0000 1000 |     3 |     5 |
  // +-----+-----------+-------+-------+
  // TLDR: bitWidth = power + 2
  internal static let positivePowersOf2Correction = 2

  internal static var positivePowersOf2: [PowerTestCase] = {
    var result = [PowerTestCase]()

    for (power, value) in allPositivePowersOf2(type: Int.self) {
      let bitWidth = power + Self.positivePowersOf2Correction
      let tuple = (value, power, bitWidth)
      result.append(tuple)
    }

    return result
  }()

  // +-----+------+-------+-------+
  // | dec | bin  | power |  bit  |
  // |     |      |       | width |
  // +-----+------+-------+-------+
  // |  -1 | 1111 |     0 |     1 |
  // |  -2 | 1110 |     1 |     2 |
  // |  -4 | 1100 |     2 |     3 |
  // |  -8 | 1000 |     3 |     4 |
  // +-----+------+-------+-------+
  // TLDR: bitWidth = power + 1
  internal static let negativePowersOf2Correction = 1

  internal static var negativePowersOf2: [PowerTestCase] = {
    var result = [PowerTestCase]()

    for (power, value) in allNegativePowersOf2(type: Int.self) {
      let bitWidth = power + Self.negativePowersOf2Correction
      let tuple = (value, power, bitWidth)
      result.append(tuple)
    }

    return result
  }()
}
