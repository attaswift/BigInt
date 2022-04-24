// This file was written by LiarPrincess for Violet - Python VM written in Swift.
// https://github.com/LiarPrincess/Violet

// MARK: - Pair values

internal struct PossiblePairings<T, V>: Sequence {

  internal typealias Element = (T, V)

  internal struct Iterator: IteratorProtocol {

    private let lhsValues: [T]
    private let rhsValues: [V]

    private var lhsIndex = 0
    private var rhsIndex = 0

    fileprivate init(lhs: [T], rhs: [V]) {
      self.lhsValues = lhs
      self.rhsValues = rhs
    }

    internal mutating func next() -> Element? {
      if self.lhsIndex == self.lhsValues.count {
        return nil
      }

      let lhs = self.lhsValues[self.lhsIndex]
      let rhs = self.rhsValues[self.rhsIndex]

      self.rhsIndex += 1
      if self.rhsIndex == self.rhsValues.count {
        self.lhsIndex += 1
        self.rhsIndex = 0
      }

      return (lhs, rhs)
    }
  }

  private let lhsValues: [T]
  private let rhsValues: [V]

  fileprivate init(lhs: [T], rhs: [V]) {
    self.lhsValues = lhs
    self.rhsValues = rhs
  }

  internal func makeIterator() -> Iterator {
    return Iterator(lhs: self.lhsValues, rhs: self.rhsValues)
  }
}

/// `[1, 2] -> [(1,1), (1,2), (2,1), (2,2)]`
internal func allPossiblePairings<T>(values: [T]) -> PossiblePairings<T, T> {
  return PossiblePairings(lhs: values, rhs: values)
}

/// `[1, 2], [1, 2] -> [(1,1), (1,2), (2,1), (2,2)]`
internal func allPossiblePairings<T, S>(lhs: [T], rhs: [S]) -> PossiblePairings<T, S> {
  return PossiblePairings(lhs: lhs, rhs: rhs)
}

// MARK: - Powers of 2

internal typealias PowerOf2<T> = (power: Int, value: T)

/// `1, 2, 4, 8, 16, 32, 64, 128, 256, 512, etc…`
internal func allPositivePowersOf2<T: FixedWidthInteger>(
  type: T.Type
) -> [PowerOf2<T>] {
  var result = [PowerOf2<T>]()
  result.reserveCapacity(T.bitWidth)

  var value = T(1)
  var power = 0
  result.append(PowerOf2(power: power, value: value))

  while true {
    let (newValue, overflow) = value.multipliedReportingOverflow(by: 2)
    if overflow {
      return result
    }

    value = newValue
    power += 1
    result.append(PowerOf2(power: power, value: value))
  }
}

/// `-1, -2, -4, -8, -16, -32, -64, -128, -256, -512, etc…`
internal func allNegativePowersOf2<T: FixedWidthInteger>(
  type: T.Type
) -> [PowerOf2<T>] {
  assert(T.isSigned)

  var result = [PowerOf2<T>]()
  result.reserveCapacity(T.bitWidth)

  var value = T(-1)
  var power = 0
  result.append(PowerOf2(power: power, value: value))

  while true {
    let (newValue, overflow) = value.multipliedReportingOverflow(by: 2)
    if overflow {
      return result
    }

    value = newValue
    power += 1
    result.append(PowerOf2(power: power, value: value))
  }
}
