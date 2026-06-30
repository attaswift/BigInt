// This file was written by LiarPrincess for Violet - Python VM written in Swift.
// https://github.com/LiarPrincess/Violet

import Testing
@testable import BigInt

// Well… actually… hash and equatable
@Suite
struct BigIntHashTests {

  private let smis = generateIntValues(countButNotReally: 50)
  private let heaps = generateBigIntValues(countButNotReally: 50)

  // Values that are in both `smis` and `heaps`.
  private var common: [BigInt] {
    var result = [BigInt]()
    let smiSet = Set(self.smis)

    for p in self.heaps {
      let heap = p.create()
      if let int = Int(exactly: heap), smiSet.contains(int) {
        result.append(heap)
      }
    }

    return result
  }

  private let scalars: [UnicodeScalar] = {
    let asciiStart: UInt8 = 0x21 // !
    let asciiEnd: UInt8 = 0x7e // ~
    let result = (asciiStart...asciiEnd).map { UnicodeScalar($0) }
    return result + result // to be sure that it is more than 'self.smis.count'
  }()

  // MARK: - Set

  @Test
  func set_insertAndFind() {
    // Insert all of the values
    var set = Set<BigInt>()
    self.insert(&set, values: self.smis)
    self.insert(&set, values: self.heaps)

    let expectedCount = self.smis.count + self.heaps.count - self.common.count
    #expect(set.count == expectedCount)

    // Check if we can find them
    for value in self.smis {
      let int = self.create(value)
      #expect(set.contains(int), "\(value)")
    }

    for value in self.heaps {
      let int = self.create(value)
      #expect(set.contains(int), "\(int)")
    }
  }

  @Test
  func set_insertAndRemove() {
    // Insert all of the values
    var set = Set<BigInt>()
    self.insert(&set, values: self.smis)
    self.insert(&set, values: self.heaps)

    let allCount = self.smis.count + self.heaps.count - self.common.count
    #expect(set.count == allCount)

    // And now remove them
    for value in self.smis {
      let int = self.create(value)
      let existing = set.remove(int)
      #expect(existing != nil, "Missing: \(value)")
    }

    let withoutSmiCount = self.heaps.count - self.common.count
    #expect(set.count == withoutSmiCount)

    for value in self.heaps {
      let int = self.create(value)
      let wasAlreadyRemoved = self.common.contains(int)

      if !wasAlreadyRemoved {
        let existing = set.remove(int)
        #expect(existing != nil, "Missing: \(int)")
      }
    }

    #expect(set.isEmpty)
  }

  // MARK: - Dict

  @Test
  func dict_insertAndFind() {
    // Insert all of the numbers to dict
    var dict = [BigInt: UnicodeScalar]()
    self.insert(&dict, values: zip(self.smis, self.scalars))
    self.insert(&dict, values: zip(self.heaps, self.scalars), excluding: self.common)

    let expectedCount = self.smis.count + self.heaps.count - self.common.count
    #expect(dict.count == expectedCount)

    // Check if we can find all of the elements
    for (value, char) in zip(self.smis, self.scalars) {
      let int = self.create(value)

      if let result = dict[int] {
        #expect(result == char, "key: \(int)")
      } else {
        Issue.record("missing: \(int)")
      }
    }

    for (value, char) in zip(self.heaps, self.scalars) {
      let int = self.create(value)

      if self.common.contains(int) {
        // It was already checked in 'smi' loop
      } else if let result = dict[int] {
        #expect(result == char, "key: \(int)")
      } else {
        Issue.record("missing: \(int)")
      }
    }
  }

  @Test
  func dict_insertAndRemove() {
    // Insert all of the numbers to dict
    var dict = [BigInt: UnicodeScalar]()
    self.insert(&dict, values: zip(self.smis, self.scalars))
    self.insert(&dict, values: zip(self.heaps, self.scalars), excluding: self.common)

    let expectedCount = self.smis.count + self.heaps.count - self.common.count
    #expect(dict.count == expectedCount)

    // And now remove them
    for value in self.smis {
      let int = self.create(value)
      let existing = dict.removeValue(forKey: int)
      #expect(existing != nil, "Missing: \(value)")
    }

    let withoutSmiCount = self.heaps.count - self.common.count
    #expect(dict.count == withoutSmiCount)

    for value in self.heaps {
      let int = self.create(value)
      let wasAlreadyRemoved = self.common.contains(int)

      if !wasAlreadyRemoved {
        let existing = dict.removeValue(forKey: int)
        #expect(existing != nil, "Missing: \(int)")
      }
    }

    #expect(dict.isEmpty)
  }

  @Test
  func dict_insertReplaceAndFind() {
    // Insert all of the numbers to dict
    var dict = [BigInt: UnicodeScalar]()
    self.insert(&dict, values: zip(self.smis, self.scalars))
    self.insert(&dict, values: zip(self.heaps, self.scalars), excluding: self.common)

    let expectedCount = self.smis.count + self.heaps.count - self.common.count
    #expect(dict.count == expectedCount)

    // Replace the values
    let reversedScalars = self.scalars.reversed()
    self.insert(&dict, values: zip(self.smis, reversedScalars))
    self.insert(&dict, values: zip(self.heaps, reversedScalars), excluding: self.common)

    // Count should have not changed
    #expect(dict.count == expectedCount)

    // Check if we can find all of the elements
    for (value, char) in zip(self.smis, reversedScalars) {
      let int = self.create(value)

      if let result = dict[int] {
        #expect(result == char, "key: \(int)")
      } else {
        Issue.record("missing: \(int)")
      }
    }

    for (value, char) in zip(self.heaps, reversedScalars) {
      let int = self.create(value)

      if self.common.contains(int) {
        // It was already checked in 'smi' loop
      } else if let result = dict[int] {
        #expect(result == char, "key: \(int)")
      } else {
        Issue.record("missing: \(int)")
      }
    }
  }

  // MARK: - Helpers

  private func insert(_ set: inout Set<BigInt>, values: [Int]) {
    for value in values {
      let int = self.create(value)
      set.insert(int)
    }
  }

  private func insert(_ set: inout Set<BigInt>, values: [BigIntPrototype]) {
    for value in values {
      let int = self.create(value)
      set.insert(int)
    }
  }

  private func insert<S: Sequence>(
    _ dict: inout [BigInt: UnicodeScalar],
    values: S
  ) where S.Element == (Int, UnicodeScalar) {
    for (value, char) in values {
      let int = self.create(value)
      dict[int] = char
    }
  }

  private func insert<S: Sequence>(
    _ dict: inout [BigInt: UnicodeScalar],
    values: S,
    excluding: [BigInt]
  ) where S.Element == (BigIntPrototype, UnicodeScalar) {
    for (value, char) in values {
      let int = self.create(value)
      if !excluding.contains(int) {
        dict[int] = char
      }
    }
  }

  private func create(_ value: Int) -> BigInt {
    return BigInt(value)
  }

  private func create(_ p: BigIntPrototype) -> BigInt {
    let heap = p.create()
    return BigInt(heap)
  }
}
