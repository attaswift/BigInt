// This file was written by LiarPrincess for Violet - Python VM written in Swift.
// https://github.com/LiarPrincess/Violet

import Testing
@testable import BigInt

// swiftlint:disable file_length

private typealias Smi = Int32
private typealias Word = BigInt.Word

@Suite
struct BigIntCOWTests {

  // This can't be '1' because 'n *= 1 -> n' (which is one of our test cases)
  private let smiValue = BigInt(2)
  private let heapValue = BigInt(Word.max)
  private let shiftCount = 3

  // MARK: - Plus

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  @Test
  func plus_doesNotModifyOriginal() {
    // +smi
    var value = BigInt(Smi.max)
    _ = +value
    #expect(value == BigInt(Smi.max))

    // +heap
    value = BigInt(Word.max)
    _ = +value
    #expect(value == BigInt(Word.max))
  }

  // MARK: - Minus

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  @Test
  func minus_doesNotModifyOriginal() {
    // -smi
    var value = BigInt(Smi.max)
    _ = -value
    #expect(value == BigInt(Smi.max))

    // -heap
    value = BigInt(Word.max)
    _ = -value
    #expect(value == BigInt(Word.max))
  }

  // MARK: - Invert

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  @Test
  func invert_doesNotModifyOriginal() {
    // ~smi
    var value = BigInt(Smi.max)
    _ = ~value
    #expect(value == BigInt(Smi.max))

    // ~heap
    value = BigInt(Word.max)
    _ = ~value
    #expect(value == BigInt(Word.max))
  }

  // MARK: - Add

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  @Test
  func add_toCopy_doesNotModifyOriginal() {
    // smi + smi
    var value = BigInt(Smi.max)
    var copy = value
    _ = copy + self.smiValue
    #expect(value == BigInt(Smi.max))

    // smi + heap
    value = BigInt(Smi.max)
    copy = value
    _ = copy + self.heapValue
    #expect(value == BigInt(Smi.max))

    // heap + smi
    value = BigInt(Word.max)
    copy = value
    _ = copy + self.smiValue
    #expect(value == BigInt(Word.max))

    // heap + heap
    value = BigInt(Word.max)
    copy = value
    _ = copy + self.heapValue
    #expect(value == BigInt(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  @Test
  func add_toInout_doesNotModifyOriginal() {
    // smi + smi
    var value = BigInt(Smi.max)
    self.addSmi(toInout: &value)
    #expect(value == BigInt(Smi.max))

    // smi + heap
    value = BigInt(Smi.max)
    self.addHeap(toInout: &value)
    #expect(value == BigInt(Smi.max))

    // heap + smi
    value = BigInt(Word.max)
    self.addSmi(toInout: &value)
    #expect(value == BigInt(Word.max))

    // heap + heap
    value = BigInt(Word.max)
    self.addHeap(toInout: &value)
    #expect(value == BigInt(Word.max))
  }

  private func addSmi(toInout value: inout BigInt) {
    _ = value + self.smiValue
  }

  private func addHeap(toInout value: inout BigInt) {
    _ = value + self.heapValue
  }

  @Test
  func addEqual_toCopy_doesNotModifyOriginal() {
    // smi + smi
    var value = BigInt(Smi.max)
    var copy = value
    copy += self.smiValue
    #expect(value == BigInt(Smi.max))

    // smi + heap
    value = BigInt(Smi.max)
    copy = value
    copy += self.heapValue
    #expect(value == BigInt(Smi.max))

    // heap + smi
    value = BigInt(Word.max)
    copy = value
    copy += self.smiValue
    #expect(value == BigInt(Word.max))

    // heap + heap
    value = BigInt(Word.max)
    copy = value
    copy += self.heapValue
    #expect(value == BigInt(Word.max))
  }

  @Test
  func addEqual_toInout_doesModifyOriginal() {
    // smi + smi
    var value = BigInt(Smi.max)
    self.addEqualSmi(toInout: &value)
    #expect(value != BigInt(Smi.max))

    // smi + heap
    value = BigInt(Smi.max)
    self.addEqualHeap(toInout: &value)
    #expect(value != BigInt(Smi.max))

    // heap + smi
    value = BigInt(Word.max)
    self.addEqualSmi(toInout: &value)
    #expect(value != BigInt(Word.max))

    // heap + heap
    value = BigInt(Word.max)
    self.addEqualHeap(toInout: &value)
    #expect(value != BigInt(Word.max))
  }

  private func addEqualSmi(toInout value: inout BigInt) {
    value += self.smiValue
  }

  private func addEqualHeap(toInout value: inout BigInt) {
    value += self.heapValue
  }

  // MARK: - Sub

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  @Test
  func sub_toCopy_doesNotModifyOriginal() {
    // smi - smi
    var value = BigInt(Smi.max)
    var copy = value
    _ = copy - self.smiValue
    #expect(value == BigInt(Smi.max))

    // smi - heap
    value = BigInt(Smi.max)
    copy = value
    _ = copy - self.heapValue
    #expect(value == BigInt(Smi.max))

    // heap - smi
    value = BigInt(Word.max)
    copy = value
    _ = copy - self.smiValue
    #expect(value == BigInt(Word.max))

    // heap - heap
    value = BigInt(Word.max)
    copy = value
    _ = copy - self.heapValue
    #expect(value == BigInt(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  @Test
  func sub_toInout_doesNotModifyOriginal() {
    // smi - smi
    var value = BigInt(Smi.max)
    self.subSmi(toInout: &value)
    #expect(value == BigInt(Smi.max))

    // smi - heap
    value = BigInt(Smi.max)
    self.subHeap(toInout: &value)
    #expect(value == BigInt(Smi.max))

    // heap - smi
    value = BigInt(Word.max)
    self.subSmi(toInout: &value)
    #expect(value == BigInt(Word.max))

    // heap - heap
    value = BigInt(Word.max)
    self.subHeap(toInout: &value)
    #expect(value == BigInt(Word.max))
  }

  private func subSmi(toInout value: inout BigInt) {
    _ = value - self.smiValue
  }

  private func subHeap(toInout value: inout BigInt) {
    _ = value - self.heapValue
  }

  @Test
  func subEqual_toCopy_doesNotModifyOriginal() {
    // smi - smi
    var value = BigInt(Smi.max)
    var copy = value
    copy -= self.smiValue
    #expect(value == BigInt(Smi.max))

    // smi - heap
    value = BigInt(Smi.max)
    copy = value
    copy -= self.heapValue
    #expect(value == BigInt(Smi.max))

    // heap - smi
    value = BigInt(Word.max)
    copy = value
    copy -= self.smiValue
    #expect(value == BigInt(Word.max))

    // heap - heap
    value = BigInt(Word.max)
    copy = value
    copy -= self.heapValue
    #expect(value == BigInt(Word.max))
  }

  @Test
  func subEqual_toInout_doesModifyOriginal() {
    // smi - smi
    var value = BigInt(Smi.max)
    self.subEqualSmi(toInout: &value)
    #expect(value != BigInt(Smi.max))

    // smi - heap
    value = BigInt(Smi.max)
    self.subEqualHeap(toInout: &value)
    #expect(value != BigInt(Smi.max))

    // heap - smi
    value = BigInt(Word.max)
    self.subEqualSmi(toInout: &value)
    #expect(value != BigInt(Word.max))

    // heap - heap
    value = BigInt(Word.max)
    self.subEqualHeap(toInout: &value)
    #expect(value != BigInt(Word.max))
  }

  private func subEqualSmi(toInout value: inout BigInt) {
    value -= self.smiValue
  }

  private func subEqualHeap(toInout value: inout BigInt) {
    value -= self.heapValue
  }

  // MARK: - Mul

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  @Test
  func mul_toCopy_doesNotModifyOriginal() {
    // smi * smi
    var value = BigInt(Smi.max)
    var copy = value
    _ = copy * self.smiValue
    #expect(value == BigInt(Smi.max))

    // smi * heap
    value = BigInt(Smi.max)
    copy = value
    _ = copy * self.heapValue
    #expect(value == BigInt(Smi.max))

    // heap * smi
    value = BigInt(Word.max)
    copy = value
    _ = copy * self.smiValue
    #expect(value == BigInt(Word.max))

    // heap * heap
    value = BigInt(Word.max)
    copy = value
    _ = copy * self.heapValue
    #expect(value == BigInt(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  @Test
  func mul_toInout_doesNotModifyOriginal() {
    // smi * smi
    var value = BigInt(Smi.max)
    self.mulSmi(toInout: &value)
    #expect(value == BigInt(Smi.max))

    // smi * heap
    value = BigInt(Smi.max)
    self.mulHeap(toInout: &value)
    #expect(value == BigInt(Smi.max))

    // heap * smi
    value = BigInt(Word.max)
    self.mulSmi(toInout: &value)
    #expect(value == BigInt(Word.max))

    // heap * heap
    value = BigInt(Word.max)
    self.mulHeap(toInout: &value)
    #expect(value == BigInt(Word.max))
  }

  private func mulSmi(toInout value: inout BigInt) {
    _ = value * self.smiValue
  }

  private func mulHeap(toInout value: inout BigInt) {
    _ = value * self.heapValue
  }

  @Test
  func mulEqual_toCopy_doesNotModifyOriginal() {
    // smi * smi
    var value = BigInt(Smi.max)
    var copy = value
    copy *= self.smiValue
    #expect(value == BigInt(Smi.max))

    // smi * heap
    value = BigInt(Smi.max)
    copy = value
    copy *= self.heapValue
    #expect(value == BigInt(Smi.max))

    // heap * smi
    value = BigInt(Word.max)
    copy = value
    copy *= self.smiValue
    #expect(value == BigInt(Word.max))

    // heap * heap
    value = BigInt(Word.max)
    copy = value
    copy *= self.heapValue
    #expect(value == BigInt(Word.max))
  }

  @Test
  func mulEqual_toInout_doesModifyOriginal() {
    // smi * smi
    var value = BigInt(Smi.max)
    self.mulEqualSmi(toInout: &value)
    #expect(value != BigInt(Smi.max))

    // smi * heap
    value = BigInt(Smi.max)
    self.mulEqualHeap(toInout: &value)
    #expect(value != BigInt(Smi.max))

    // heap * smi
    value = BigInt(Word.max)
    self.mulEqualSmi(toInout: &value)
    #expect(value != BigInt(Word.max))

    // heap * heap
    value = BigInt(Word.max)
    self.mulEqualHeap(toInout: &value)
    #expect(value != BigInt(Word.max))
  }

  private func mulEqualSmi(toInout value: inout BigInt) {
    value *= self.smiValue
  }

  private func mulEqualHeap(toInout value: inout BigInt) {
    value *= self.heapValue
  }

  // MARK: - Div

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  @Test
  func div_toCopy_doesNotModifyOriginal() {
    // smi / smi
    var value = BigInt(Smi.max)
    var copy = value
    _ = copy / self.smiValue
    #expect(value == BigInt(Smi.max))

    // smi / heap
    value = BigInt(Smi.max)
    copy = value
    _ = copy / self.heapValue
    #expect(value == BigInt(Smi.max))

    // heap / smi
    value = BigInt(Word.max)
    copy = value
    _ = copy / self.smiValue
    #expect(value == BigInt(Word.max))

    // heap / heap
    value = BigInt(Word.max)
    copy = value
    _ = copy / self.heapValue
    #expect(value == BigInt(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  @Test
  func div_toInout_doesNotModifyOriginal() {
    // smi / smi
    var value = BigInt(Smi.max)
    self.divSmi(toInout: &value)
    #expect(value == BigInt(Smi.max))

    // smi / heap
    value = BigInt(Smi.max)
    self.divHeap(toInout: &value)
    #expect(value == BigInt(Smi.max))

    // heap / smi
    value = BigInt(Word.max)
    self.divSmi(toInout: &value)
    #expect(value == BigInt(Word.max))

    // heap / heap
    value = BigInt(Word.max)
    self.divHeap(toInout: &value)
    #expect(value == BigInt(Word.max))
  }

  private func divSmi(toInout value: inout BigInt) {
    _ = value / self.smiValue
  }

  private func divHeap(toInout value: inout BigInt) {
    _ = value / self.heapValue
  }

  @Test
  func divEqual_toCopy_doesNotModifyOriginal() {
    // smi / smi
    var value = BigInt(Smi.max)
    var copy = value
    copy /= self.smiValue
    #expect(value == BigInt(Smi.max))

    // smi / heap
    value = BigInt(Smi.max)
    copy = value
    copy /= self.heapValue
    #expect(value == BigInt(Smi.max))

    // heap / smi
    value = BigInt(Word.max)
    copy = value
    copy /= self.smiValue
    #expect(value == BigInt(Word.max))

    // heap / heap
    value = BigInt(Word.max)
    copy = value
    copy /= self.heapValue
    #expect(value == BigInt(Word.max))
  }

  @Test
  func divEqual_toInout_doesModifyOriginal() {
    // smi / smi
    var value = BigInt(Smi.max)
    self.divEqualSmi(toInout: &value)
    #expect(value != BigInt(Smi.max))

    // smi / heap
    value = BigInt(Smi.max)
    self.divEqualHeap(toInout: &value)
    #expect(value != BigInt(Smi.max))

    // heap / smi
    value = BigInt(Word.max)
    self.divEqualSmi(toInout: &value)
    #expect(value != BigInt(Word.max))

    // heap / heap
    value = BigInt(Word.max)
    self.divEqualHeap(toInout: &value)
    #expect(value != BigInt(Word.max))
  }

  private func divEqualSmi(toInout value: inout BigInt) {
    value /= self.smiValue
  }

  private func divEqualHeap(toInout value: inout BigInt) {
    value /= self.heapValue
  }

  // MARK: - Mod

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  @Test
  func mod_toCopy_doesNotModifyOriginal() {
    // smi % smi
    var value = BigInt(Smi.max)
    var copy = value
    _ = copy % self.smiValue
    #expect(value == BigInt(Smi.max))

    // smi % heap
    value = BigInt(Smi.max)
    copy = value
    _ = copy % self.heapValue
    #expect(value == BigInt(Smi.max))

    // heap % smi
    value = BigInt(Word.max)
    copy = value
    _ = copy % self.smiValue
    #expect(value == BigInt(Word.max))

    // heap % heap
    value = BigInt(Word.max)
    copy = value
    _ = copy % self.heapValue
    #expect(value == BigInt(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  @Test
  func mod_toInout_doesNotModifyOriginal() {
    // smi % smi
    var value = BigInt(Smi.max)
    self.modSmi(toInout: &value)
    #expect(value == BigInt(Smi.max))

    // smi % heap
    value = BigInt(Smi.max)
    self.modHeap(toInout: &value)
    #expect(value == BigInt(Smi.max))

    // heap % smi
    value = BigInt(Word.max)
    self.modSmi(toInout: &value)
    #expect(value == BigInt(Word.max))

    // heap % heap
    value = BigInt(Word.max)
    self.modHeap(toInout: &value)
    #expect(value == BigInt(Word.max))
  }

  private func modSmi(toInout value: inout BigInt) {
    _ = value % self.smiValue
  }

  private func modHeap(toInout value: inout BigInt) {
    _ = value % self.heapValue
  }

  @Test
  func modEqual_toCopy_doesNotModifyOriginal() {
    // smi % smi
    var value = BigInt(Smi.max)
    var copy = value
    copy %= self.smiValue
    #expect(value == BigInt(Smi.max))

    // smi % heap
    value = BigInt(Smi.max)
    copy = value
    copy %= self.heapValue
    #expect(value == BigInt(Smi.max))

    // heap % smi
    value = BigInt(Word.max)
    copy = value
    copy %= self.smiValue
    #expect(value == BigInt(Word.max))

    // heap % heap
    value = BigInt(Word.max)
    copy = value
    copy %= self.heapValue
    #expect(value == BigInt(Word.max))
  }

  @Test
  func modEqual_toInout_doesModifyOriginal() {
    // smi % smi
    var value = BigInt(Smi.max)
    self.modEqualSmi(toInout: &value)
    #expect(value != BigInt(Smi.max))

    // smi % heap
    // 'heap' is always greater than 'smi', so modulo is actually equal to 'smi'
//    value = BigInt(Smi.max)
//    self.modEqualHeap(toInout: &value)
//    XCTAssertNotEqual(value, BigInt(Smi.max))

    // heap % smi
    value = BigInt(Word.max)
    self.modEqualSmi(toInout: &value)
    #expect(value != BigInt(Word.max))

    // heap % heap
    value = BigInt(Word.max)
    self.modEqualHeap(toInout: &value)
    #expect(value != BigInt(Word.max))
  }

  private func modEqualSmi(toInout value: inout BigInt) {
    value %= self.smiValue
  }

  private func modEqualHeap(toInout value: inout BigInt) {
    value %= self.heapValue
  }

  // MARK: - Shift left

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  @Test
  func shiftLeft_copy_doesNotModifyOriginal() {
    // smi << int
    var value = BigInt(Smi.max)
    var copy = value
    _ = copy << self.shiftCount
    #expect(value == BigInt(Smi.max))

    // heap << int
    value = BigInt(Word.max)
    copy = value
    _ = copy << self.shiftCount
    #expect(value == BigInt(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  @Test
  func shiftLeft_inout_doesNotModifyOriginal() {
    // smi << int
    var value = BigInt(Smi.max)
    self.shiftLeft(value: &value)
    #expect(value == BigInt(Smi.max))

    // heap << int
    value = BigInt(Word.max)
    self.shiftLeft(value: &value)
    #expect(value == BigInt(Word.max))
  }

  private func shiftLeft(value: inout BigInt) {
    _ = value << self.shiftCount
  }

  @Test
  func shiftLeftEqual_copy_doesNotModifyOriginal() {
    // smi << int
    var value = BigInt(Smi.max)
    var copy = value
    copy <<= self.shiftCount
    #expect(value == BigInt(Smi.max))

    // heap << int
    value = BigInt(Word.max)
    copy = value
    copy <<= self.shiftCount
    #expect(value == BigInt(Word.max))
  }

  @Test
  func shiftLeftEqual_inout_doesModifyOriginal() {
    // smi << int
    var value = BigInt(Smi.max)
    self.shiftLeftEqual(value: &value)
    #expect(value != BigInt(Smi.max))

    // heap << int
    value = BigInt(Word.max)
    self.shiftLeftEqual(value: &value)
    #expect(value != BigInt(Word.max))
  }

  private func shiftLeftEqual(value: inout BigInt) {
    value <<= self.shiftCount
  }

  // MARK: - Shift right

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  @Test
  func shiftRight_copy_doesNotModifyOriginal() {
    // smi >> int
    var value = BigInt(Smi.max)
    var copy = value
    _ = copy >> self.shiftCount
    #expect(value == BigInt(Smi.max))

    // heap >> int
    value = BigInt(Word.max)
    copy = value
    _ = copy >> self.shiftCount
    #expect(value == BigInt(Word.max))
  }

  /// This test actually DOES make sense, because, even though 'BigInt' is immutable,
  /// the heap that is points to is not.
  @Test
  func shiftRight_inout_doesNotModifyOriginal() {
    // smi >> int
    var value = BigInt(Smi.max)
    self.shiftRight(value: &value)
    #expect(value == BigInt(Smi.max))

    // heap >> int
    value = BigInt(Word.max)
    self.shiftRight(value: &value)
    #expect(value == BigInt(Word.max))
  }

  private func shiftRight(value: inout BigInt) {
    _ = value >> self.shiftCount
  }

  @Test
  func shiftRightEqual_copy_doesNotModifyOriginal() {
    // smi >> int
    var value = BigInt(Smi.max)
    var copy = value
    copy >>= self.shiftCount
    #expect(value == BigInt(Smi.max))

    // heap >> int
    value = BigInt(Word.max)
    copy = value
    copy >>= self.shiftCount
    #expect(value == BigInt(Word.max))
  }

  @Test
  func shiftRightEqual_inout_doesModifyOriginal() {
    // smi >> int
    var value = BigInt(Smi.max)
    self.shiftRightEqual(value: &value)
    #expect(value != BigInt(Smi.max))

    // heap >> int
    value = BigInt(Word.max)
    self.shiftRightEqual(value: &value)
    #expect(value != BigInt(Word.max))
  }

  private func shiftRightEqual(value: inout BigInt) {
    value >>= self.shiftCount
  }
}
