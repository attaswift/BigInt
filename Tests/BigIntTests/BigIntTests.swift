//
//  BigIntTests.swift
//  BigIntTests
//
//  Created by Károly Lőrentey on 2015-12-26.
//  Copyright © 2016-2017 Károly Lőrentey.
//
import Testing
@testable import BigInt
import Foundation

@Suite struct BigIntTests {
    typealias Word = BigInt.Word

    @Test func signs() {
        #expect(BigInt.isSigned)

        #expect(BigInt().signum() == 0)
        #expect(BigInt(-2).signum() == -1)
        #expect(BigInt(-1).signum() == -1)
        #expect(BigInt(0).signum() == 0)
        #expect(BigInt(1).signum() == 1)
        #expect(BigInt(2).signum() == 1)

        #expect(BigInt(words: [0, Word.max]).signum() == -1)
        #expect(BigInt(words: [0, 1]).signum() == 1)
    }

    @Test func init_() {
        #expect(BigInt().sign == .plus)
        #expect(BigInt().magnitude == 0)

        #expect(BigInt(Int64.min).sign == .minus)
        #expect(BigInt(Int64.min).magnitude - 1 == BigInt(Int64.max).magnitude)

        let zero = BigInt(0)
        #expect(zero.magnitude.isZero)
        #expect(zero.sign == .plus)

        let minusOne = BigInt(-1)
        #expect(minusOne.magnitude == 1)
        #expect(minusOne.sign == .minus)

        let b: BigInt = 42
        #expect(b.magnitude == 42)
        #expect(b.sign == .plus)

        #expect(BigInt(UInt64.max).magnitude == BigUInt(UInt64.max))

        let b2: BigInt = "+300"
        #expect(b2.magnitude == 300)
        #expect(b2.sign == .plus)

        let b3: BigInt = "-300"
        #expect(b3.magnitude == 300)
        #expect(b3.sign == .minus)

        // We have to call BigInt.init here because we don't want Literal initialization via coercion (SE-0213)
        #expect(BigInt.init("Not a number") == nil)
        #expect(BigInt(unicodeScalarLiteral: UnicodeScalar(52)) == BigInt(4))
        #expect(BigInt(extendedGraphemeClusterLiteral: "4") == BigInt(4))

        #expect(BigInt(words: []) == 0)
        #expect(BigInt(words: [1, 1]) == BigInt(1) << Word.bitWidth + 1)
        #expect(BigInt(words: [1, 2]) == BigInt(2) << Word.bitWidth + 1)
        #expect(BigInt(words: [0, Word.max]) == -(BigInt(1) << Word.bitWidth))
        #expect(BigInt(words: [1, Word.max]) == -BigInt(Word.max))
        #expect(BigInt(words: [1, Word.max, Word.max]) == -BigInt(Word.max))
        
        #expect(BigInt(exactly: 1) == BigInt(1))
        #expect(BigInt(exactly: -1) == BigInt(-1))
    }

    @Test func init_FloatingPoint() {
        #expect(BigInt(42.0) == 42)
        #expect(BigInt(-42.0) == -42)
        #expect(BigInt(42.5) == 42)
        #expect(BigInt(-42.5) == -42)
        #expect(BigInt(exactly: 42.0) == 42)
        #expect(BigInt(exactly: -42.0) == -42)
        #expect(BigInt(exactly: 42.5) == nil)
        #expect(BigInt(exactly: -42.5) == nil)
        #expect(BigInt(exactly: Double.leastNormalMagnitude) == nil)
        #expect(BigInt(exactly: Double.leastNonzeroMagnitude) == nil)
        #expect(BigInt(exactly: Double.infinity) == nil)
        #expect(BigInt(exactly: Double.nan) == nil)
        #expect(BigInt(exactly: Double.signalingNaN) == nil)
        #expect(BigInt(clamping: -42) == -42)
        #expect(BigInt(clamping: 42) == 42)
        #expect(BigInt(truncatingIfNeeded: -42) == -42)
        #expect(BigInt(truncatingIfNeeded: 42) == 42)
    }

    @Test func init_Decimal() throws {
        #expect(BigInt(exactly: Decimal(0)) == 0)
        #expect(BigInt(exactly: Decimal(Double.nan)) == nil)
        #expect(BigInt(exactly: Decimal(10)) == 10)
        #expect(BigInt(exactly: Decimal(1000)) == 1000)
        #expect(BigInt(exactly: Decimal(1000.1)) == nil)
        #expect(BigInt(exactly: Decimal(1000.9)) == nil)
        #expect(BigInt(exactly: Decimal(1001.5)) == nil)
        #expect(BigInt(exactly: Decimal(UInt.max) + 5) == "18446744073709551620")
        #expect(BigInt(exactly: (Decimal(UInt.max) + 5.5)) == nil)
        #expect(BigInt(exactly: Decimal.greatestFiniteMagnitude) == "3402823669209384634633746074317682114550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        #expect(BigInt(truncating: Decimal(0)) == 0)
        #expect(BigInt(truncating: Decimal(Double.nan)) == nil)
        #expect(BigInt(truncating: Decimal(10)) == 10)
        #expect(BigInt(truncating: Decimal(1000)) == 1000)
        #expect(BigInt(truncating: Decimal(1000.1)) == 1000)
        #expect(BigInt(truncating: Decimal(1000.9)) == 1000)
        #expect(BigInt(truncating: Decimal(1001.5)) == 1001)
        #expect(BigInt(truncating: Decimal(UInt.max) + 5) == "18446744073709551620")
        #expect(BigInt(truncating: (Decimal(UInt.max) + 5.5)) == "18446744073709551620")

        #expect(BigInt(exactly: -Decimal(10)) == -10)
        #expect(BigInt(exactly: -Decimal(1000)) == -1000)
        #expect(BigInt(exactly: -Decimal(1000.1)) == nil)
        #expect(BigInt(exactly: -Decimal(1000.9)) == nil)
        #expect(BigInt(exactly: -Decimal(1001.5)) == nil)
        #expect(BigInt(exactly: -(Decimal(UInt.max) + 5)) == "-18446744073709551620")
        #expect(BigInt(exactly: -(Decimal(UInt.max) + 5.5)) == nil)
        #expect(BigInt(exactly: Decimal.leastFiniteMagnitude) == "-3402823669209384634633746074317682114550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
        #expect(BigInt(truncating: -Decimal(10)) == -10)
        #expect(BigInt(truncating: -Decimal(1000)) == -1000)
        #expect(BigInt(truncating: -Decimal(1000.1)) == -1000)
        #expect(BigInt(truncating: -Decimal(1000.9)) == -1000)
        #expect(BigInt(truncating: -Decimal(1001.5)) == -1001)
        #expect(BigInt(truncating: -(Decimal(UInt.max) + 5)) == "-18446744073709551620")
        #expect(BigInt(truncating: -(Decimal(UInt.max) + 5.5)) == "-18446744073709551620")
    }

    @Test func init_Buffer() {
        func test(_ b: BigInt, _ d: Array<UInt8>) {
            d.withUnsafeBytes { buffer in
                let initialized = BigInt(buffer)
                #expect(initialized == b)
            }
        }
        
        // Positive integers
        test(BigInt(), [])
        test(BigInt(1), [0x00, 0x01])
        test(BigInt(2), [0x00, 0x02])
        test(BigInt(0x0102030405060708), [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
        test(BigInt(0x01) << 64 + BigInt(0x0203040506070809), [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09])
        
        // Negative integers
        test(BigInt(), [])
        test(BigInt(-1), [0x01, 0x01])
        test(BigInt(-2), [0x01, 0x02])
        test(BigInt(0x0102030405060708) * BigInt(-1), [0x01, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
        test((BigInt(0x01) << 64 + BigInt(0x0203040506070809)) * BigInt(-1), [0x01, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09])
    }

    @Test func conversionToFloatingPoint() {
        func test<F: BinaryFloatingPoint>(_ a: BigInt, _ b: F)
        where F.RawExponent: FixedWidthInteger, F.RawSignificand: FixedWidthInteger {
                let f = F(a)
                #expect(f == b)
        }

        for i in -100 ..< 100 {
            test(BigInt(i), Double(i))
        }
        test(BigInt(0x5A5A5A), 0x5A5A5A as Double)
        test(BigInt(1) << 64, 0x1p64 as Double)
        test(BigInt(0x5A5A5A) << 64, 0x5A5A5Ap64 as Double)
        test(BigInt(1) << 1023, 0x1p1023 as Double)
        test(BigInt(10) << 1020, 0xAp1020 as Double)
        test(BigInt(1) << 1024, Double.infinity)
        test(BigInt(words: convertWords([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xFFFFFFFFFFFFF800, 0])),
             Double.greatestFiniteMagnitude)

        for i in -100 ..< 100 {
            test(BigInt(i), Float(i))
        }
        test(BigInt(0x5A5A5A), 0x5A5A5A as Float)
        test(BigInt(1) << 64, 0x1p64 as Float)
        test(BigInt(0x5A5A5A) << 64, 0x5A5A5Ap64 as Float)
        test(BigInt(1) << 1023, 0x1p1023 as Float)
        test(BigInt(10) << 1020, 0xAp1020 as Float)
        test(BigInt(1) << 1024, Float.infinity)
        test(BigInt(words: convertWords([0, 0xFFFFFF0000000000, 0])),
             Float.greatestFiniteMagnitude)

        #expect(Decimal(BigInt(0)) == 0)
        #expect(Decimal(BigInt(20)) == 20)
        #expect(Decimal(BigInt(123456789)) == 123456789)
        #expect(Decimal(BigInt(exactly: Decimal.greatestFiniteMagnitude)!) == .greatestFiniteMagnitude)
        #expect(Decimal(BigInt(exactly: Decimal.greatestFiniteMagnitude)! * 2) == .greatestFiniteMagnitude)
        #expect(Decimal(-BigInt(0)) == 0)
        #expect(Decimal(-BigInt(20)) == -20)
        #expect(Decimal(-BigInt(123456789)) == -123456789)
        #expect(Decimal(-BigInt(exactly: Decimal.greatestFiniteMagnitude)!) == -.greatestFiniteMagnitude)
        #expect(Decimal(-BigInt(exactly: Decimal.greatestFiniteMagnitude)! * 2) == -.greatestFiniteMagnitude)

    }

    @Test func twosComplement() {
        func check(_ a: [Word], _ b: [Word]) {
            var a2 = a
            a2.twosComplement()
            #expect(a2 == b)
            var b2 = b
            b2.twosComplement()
            #expect(b2 == a)
        }
        check([1], [Word.max])
        check([Word.max], [1])
        check([1, 1], [Word.max, Word.max - 1])
        check([(1 as Word) << (Word.bitWidth - 1)], [(1 as Word) << (Word.bitWidth - 1)])
        check([0], [0])
        check([0, 0, 1], [0, 0, Word.max])
        check([0, 0, 1, 0, 1], [0, 0, Word.max, Word.max, Word.max - 1])
        check([0, 0, 1, 1], [0, 0, Word.max, Word.max - 1])
        check([0, 0, 1, 0, 0, 0], [0, 0, Word.max, Word.max, Word.max, Word.max])
    }

    @Test func sign() {
        #expect(BigInt(-1).sign == .minus)
        #expect(BigInt(0).sign == .plus)
        #expect(BigInt(1).sign == .plus)
    }

    @Test func bitWidth() {
        #expect(BigInt(0).bitWidth == 0)
        #expect(BigInt(1).bitWidth == 2)
        #expect(BigInt(-1).bitWidth == 2)
        #expect((BigInt(1) << 64).bitWidth == Word.bitWidth + 2)
        #expect(BigInt(Word.max).bitWidth == Word.bitWidth + 1)
        #expect(BigInt(Word.max >> 1).bitWidth == Word.bitWidth)
    }

    @Test func trailingZeroBitCount() {
        #expect(BigInt(0).trailingZeroBitCount == 0)
        #expect(BigInt(1).trailingZeroBitCount == 0)
        #expect(BigInt(-1).trailingZeroBitCount == 0)
        #expect(BigInt(2).trailingZeroBitCount == 1)
        #expect(BigInt(Word.max).trailingZeroBitCount == 0)
        #expect(BigInt(-2).trailingZeroBitCount == 1)
        #expect(-BigInt(Word.max).trailingZeroBitCount == 0)
        #expect((BigInt(1) << 100).trailingZeroBitCount == 100)
        #expect(((-BigInt(1)) << 100).trailingZeroBitCount == 100)
    }

    @Test func words() {
        #expect(Array(BigInt(0).words) == [])
        #expect(Array(BigInt(1).words) == [1])
        #expect(Array(BigInt(-1).words) == [Word.max])

        let highBit = (1 as Word) << (Word.bitWidth - 1)
        #expect(Array(BigInt(highBit).words) == [highBit, 0])
        #expect(Array((-BigInt(highBit)).words) == [highBit, Word.max])

        #expect(Array(BigInt(sign: .plus, magnitude: BigUInt(words: [Word.max])).words) == [Word.max, 0])
        #expect(Array(BigInt(sign: .minus, magnitude: BigUInt(words: [Word.max])).words) == [1, Word.max])

        #expect(Array((BigInt(1) << Word.bitWidth).words) == [0, 1])
        #expect(Array((-(BigInt(1) << Word.bitWidth)).words) == [0, Word.max])

        #expect(Array((BigInt(42) << Word.bitWidth).words) == [0, 42])
        #expect(Array((-(BigInt(42) << Word.bitWidth)).words) == [0, Word.max - 41])

        let huge = BigUInt(words: [0, 1, 2, 3, 4])
        #expect(Array(BigInt(sign: .plus, magnitude: huge).words) == [0, 1, 2, 3, 4])
        #expect(Array(BigInt(sign: .minus, magnitude: huge).words) == [0, Word.max, ~2, ~3, ~4] as [Word])


        #expect(BigInt(1).words[100] == 0)
        #expect(BigInt(-1).words[100] == Word.max)

        #expect(BigInt(words: [0, 1, 2, 3, 4]).words.indices == 0 ..< 5)
    }

    @Test func complement() {
        #expect(~BigInt(-3) == BigInt(2))
        #expect(~BigInt(-2) == BigInt(1))
        #expect(~BigInt(-1) == BigInt(0))
        #expect(~BigInt(0) == BigInt(-1))
        #expect(~BigInt(1) == BigInt(-2))
        #expect(~BigInt(2) == BigInt(-3))

        #expect(~BigInt(words: [1, 2, 3, 4]) == BigInt(words: [Word.max - 1, Word.max - 2, Word.max - 3, Word.max - 4]))
        #expect(~BigInt(words: [Word.max - 1, Word.max - 2, Word.max - 3, Word.max - 4]) == BigInt(words: [1, 2, 3, 4]))
    }

    @Test func binaryAnd() {
        #expect(BigInt(1) & BigInt(2) == 0)
        #expect(BigInt(-1) & BigInt(2) == 2)
        #expect(BigInt(-1) & BigInt(words: [1, 2, 3, 4]) == BigInt(words: [1, 2, 3, 4]))
        #expect(BigInt(-1) & -BigInt(words: [1, 2, 3, 4]) == -BigInt(words: [1, 2, 3, 4]))
        #expect(BigInt(Word.max) & BigInt(words: [1, 2, 3, 4]) == BigInt(1))
        #expect(BigInt(Word.max) & BigInt(words: [Word.max, 1, 2]) == BigInt(Word.max))
        #expect(BigInt(Word.max) & BigInt(words: [Word.max, Word.max - 1]) == BigInt(Word.max))
    }

    @Test func binaryOr() {
        #expect(BigInt(1) | BigInt(2) == 3)
        #expect(BigInt(-1) | BigInt(2) == -1)
        #expect(BigInt(-1) | BigInt(words: [1, 2, 3, 4]) == -1)
        #expect(BigInt(-1) | -BigInt(words: [1, 2, 3, 4]) == -1)
        #expect(BigInt(Word.max) | BigInt(words: [1, 2, 3, 4]) == BigInt(words: [Word.max, 2, 3, 4]))
        #expect(BigInt(Word.max) | BigInt(words: [1, 2, 3, Word.max]) == BigInt(words: [Word.max, 2, 3, Word.max]))
        #expect(BigInt(Word.max) | BigInt(words: [Word.max - 1, Word.max - 1]) == BigInt(words: [Word.max, Word.max - 1]))
    }

    @Test func binaryXor() {
        #expect(BigInt(1) ^ BigInt(2) == 3)
        #expect(BigInt(-1) ^ BigInt(2) == -3)
        #expect(BigInt(1) ^ BigInt(-2) == -1)
        #expect(BigInt(-1) ^ BigInt(-2) == 1)
        #expect(BigInt(-1) ^ BigInt(words: [1, 2, 3, 4]) == BigInt(words: [~1, ~2, ~3, ~4] as [Word]))
        #expect(BigInt(-1) ^ -BigInt(words: [1, 2, 3, 4]) == BigInt(words: [0, 2, 3, 4]))
        #expect(BigInt(Word.max) ^ BigInt(words: [1, 2, 3, 4]) == BigInt(words: [~1, 2, 3, 4] as [Word]))
        #expect(BigInt(Word.max) ^ BigInt(words: [1, 2, 3, Word.max]) == BigInt(words: [~1, 2, 3, Word.max] as [Word]))
        #expect(BigInt(Word.max) ^ BigInt(words: [Word.max - 1, Word.max - 1]) == BigInt(words: [1, Word.max - 1]))
    }

    @Test func conversionToString() {
        let b = BigInt(-256)
        #expect(b.description == "-256")
        #expect(String(b, radix: 16, uppercase: true) == "-100")
        let pql = b.playgroundDescription as? String
        if pql == "-256 (9 bits)" {}
        else {
            Issue.record("Unexpected Playground Quick Look: \(pql ?? "nil")")
        }
    }

    @Test func comparable() {
        #expect(BigInt(1) == BigInt(1))
        #expect(BigInt(1) != BigInt(-1))

        #expect(BigInt(1) < BigInt(42))
        #expect(!(BigInt(1) < BigInt(-42)))
        #expect(BigInt(-1) < BigInt(42))
        #expect(BigInt(-42) < BigInt(-1))
    }

    @Test func hashable() {
        #expect(BigInt(1).hashValue == BigInt(1).hashValue)
        #expect(BigInt(1).hashValue != BigInt(2).hashValue)
        #expect(BigInt(42).hashValue != BigInt(-42).hashValue)
        #expect(BigInt(1).hashValue != BigInt(-1).hashValue)
    }

    @Test func strideable() {
        #expect(BigInt(1).advanced(by: 100) == 101)
        #expect(BigInt(Word.max).advanced(by: 1 as BigInt.Stride) == BigInt(1) << Word.bitWidth)

        #expect(BigInt(Word.max).distance(to: BigInt(words: [0, 1])) == BigInt(1))
        #expect(BigInt(words: [0, 1]).distance(to: BigInt(Word.max)) == BigInt(-1))
        #expect(BigInt(0).distance(to: BigInt(words: [0, 1])) == BigInt(words: [0, 1]))
    }

    func compare(_ a: Int, _ b: Int, r: Int, op: (BigInt, BigInt) -> BigInt) {
        #expect(op(BigInt(a), BigInt(b)) == BigInt(r))
    }

    @Test func addition() {
        compare(0, 0, r: 0, op: +)
        compare(1, 2, r: 3, op: +)
        compare(1, -2, r: -1, op: +)
        compare(-1, 2, r: 1, op: +)
        compare(-1, -2, r: -3, op: +)
        compare(2, -1, r: 1, op: +)
    }

    @Test func negation() {
        #expect(-BigInt(0) == BigInt(0))
        #expect(-BigInt(1) == BigInt(-1))
        #expect(-BigInt(-1) == BigInt(1))
    }

    @Test func subtraction() {
        compare(0, 0, r: 0, op: -)
        compare(2, 1, r: 1, op: -)
        compare(2, -1, r: 3, op: -)
        compare(-2, 1, r: -3, op: -)
        compare(-2, -1, r: -1, op: -)
    }

    @Test func multiplication() {
        compare(0, 0, r: 0, op: *)
        compare(0, 1, r: 0, op: *)
        compare(1, 0, r: 0, op: *)
        compare(0, -1, r: 0, op: *)
        compare(-1, 0, r: 0, op: *)
        compare(2, 3, r: 6, op: *)
        compare(2, -3, r: -6, op: *)
        compare(-2, 3, r: -6, op: *)
        compare(-2, -3, r: 6, op: *)
    }

    @Test func quotientAndRemainder() {
        func compare(_ a: BigInt, _ b: BigInt, r: (BigInt, BigInt)) {
            let actual = a.quotientAndRemainder(dividingBy: b)
            #expect(actual.quotient == r.0, "quotient")
            #expect(actual.remainder == r.1, "remainder")
        }

        compare(0, 1, r: (0, 0))
        compare(0, -1, r: (0, 0))
        compare(7, 4, r: (1, 3))
        compare(7, -4, r: (-1, 3))
        compare(-7, 4, r: (-1, -3))
        compare(-7, -4, r: (1, -3))
    }

    @Test func division() {
        compare(0, 1, r: 0, op: /)
        compare(0, -1, r: 0, op: /)
        compare(7, 4, r: 1, op: /)
        compare(7, -4, r: -1, op: /)
        compare(-7, 4, r: -1, op: /)
        compare(-7, -4, r: 1, op: /)
    }

    @Test func remainder() {
        compare(0, 1, r: 0, op: %)
        compare(0, -1, r: 0, op: %)
        compare(7, 4, r: 3, op: %)
        compare(7, -4, r: 3, op: %)
        compare(-7, 4, r: -3, op: %)
        compare(-7, -4, r:-3, op: %)
    }

    @Test func modulo() {
        #expect(BigInt(22).modulus(5) == 2)
        #expect(BigInt(-22).modulus(5) == 3)
        #expect(BigInt(22).modulus(-5) == 2)
        #expect(BigInt(-22).modulus(-5) == 3)
    }

    @Test func strideableRequirements() {
        #expect(5 == BigInt(3).advanced(by: 2))
        #expect(2 == BigInt(3).distance(to: 5))
    }

    @Test func absoluteValuableRequirements() {
        #expect(BigInt(5) == abs(5 as BigInt))
        #expect(BigInt(0) == abs(0 as BigInt))
        #expect(BigInt(5) == abs(-5 as BigInt))
    }

    @Test func integerArithmeticRequirements() {
        #expect(3 as Int64 == Int64(3 as BigInt))
        #expect(-3 as Int64 == Int64(-3 as BigInt))
    }

    @Test func assignmentOperators() {
        var a = BigInt(1)
        a += 13
        #expect(a == 14)

        a -= 7
        #expect(a == 7)

        a *= 3
        #expect(a == 21)

        a /= 2
        #expect(a == 10)

        a %= 7
        #expect(a == 3)
    }

    @Test func exponentiation() {
        #expect(BigInt(0).power(0) == 1)
        #expect(BigInt(0).power(1) == 0)
        #expect(BigInt(0).power(2) == 0)

        #expect(BigInt(1).power(-2) == 1)
        #expect(BigInt(1).power(-1) == 1)
        #expect(BigInt(1).power(0) == 1)
        #expect(BigInt(1).power(1) == 1)
        #expect(BigInt(1).power(2) == 1)

        #expect(BigInt(2).power(-4) == 0)
        #expect(BigInt(2).power(-3) == 0)
        #expect(BigInt(2).power(-2) == 0)
        #expect(BigInt(2).power(-1) == 0)
        #expect(BigInt(2).power(0) == 1)
        #expect(BigInt(2).power(1) == 2)
        #expect(BigInt(2).power(2) == 4)
        #expect(BigInt(2).power(3) == 8)
        #expect(BigInt(2).power(4) == 16)

        #expect(BigInt(-1).power(-4) == 1)
        #expect(BigInt(-1).power(-3) == -1)
        #expect(BigInt(-1).power(-2) == 1)
        #expect(BigInt(-1).power(-1) == -1)
        #expect(BigInt(-1).power(0) == 1)
        #expect(BigInt(-1).power(1) == -1)
        #expect(BigInt(-1).power(2) == 1)
        #expect(BigInt(-1).power(3) == -1)
        #expect(BigInt(-1).power(4) == 1)

        #expect(BigInt(-2).power(-4) == 0)
        #expect(BigInt(-2).power(-3) == 0)
        #expect(BigInt(-2).power(-2) == 0)
        #expect(BigInt(-2).power(-1) == 0)
        #expect(BigInt(-2).power(0) == 1)
        #expect(BigInt(-2).power(1) == -2)
        #expect(BigInt(-2).power(2) == 4)
        #expect(BigInt(-2).power(3) == -8)
        #expect(BigInt(-2).power(4) == 16)
    }

    @Test func modularExponentiation() {
        for i in -5 ... 5 {
            for j in -5 ... 5 {
                for m in [-7, -5, -3, -2, -1, 1, 2, 3, 5, 7] {
                    guard i != 0 || j >= 0 else { continue }
                    #expect(BigInt(i).power(BigInt(j), modulus: BigInt(m)) == BigInt(i).power(j).modulus(BigInt(m)), "\(i), \(j), \(m)")
                }
            }
        }
    }

    @Test func squareRoot() {
        #expect(BigInt(0).squareRoot() == 0)
        #expect(BigInt(1).squareRoot() == 1)
        #expect(BigInt(2).squareRoot() == 1)
        #expect(BigInt(3).squareRoot() == 1)
        #expect(BigInt(4).squareRoot() == 2)
        #expect(BigInt(5).squareRoot() == 2)
        #expect(BigInt(9).squareRoot() == 3)
    }

    @Test func gCD() {
        #expect(BigInt(12).greatestCommonDivisor(with: 15) == 3)
        #expect(BigInt(-12).greatestCommonDivisor(with: 15) == 3)
        #expect(BigInt(12).greatestCommonDivisor(with: -15) == 3)
        #expect(BigInt(-12).greatestCommonDivisor(with: -15) == 3)
    }

    @Test func inverse() {
        for base in -100 ... 100 {
            for modulus in [2, 3, 4, 5] {
                let base = BigInt(base)
                let modulus = BigInt(modulus)
                if let inverse = base.inverse(modulus) {
                    #expect((base * inverse).modulus(modulus) == 1, "\(base), \(modulus), \(inverse)")
                }
                else {
                    #expect(BigInt(base).greatestCommonDivisor(with: modulus) != BigInt(1), "\(base), \(modulus)")
                }
            }
        }
    }

    @Test func primes() {
        #expect(!BigInt(-7).isPrime())
        #expect(BigInt(103).isPrime())

        #expect(!BigInt(-3_215_031_751).isStrongProbablePrime(7))
        #expect(BigInt(3_215_031_751).isStrongProbablePrime(7))
        #expect(!BigInt(3_215_031_751).isPrime())
    }

    @Test func shifts() {
        #expect(BigInt(1) << Word.bitWidth == BigInt(words: [0, 1]))
        #expect(BigInt(-1) << Word.bitWidth == BigInt(words: [0, Word.max]))
        #expect(BigInt(words: [0, 1]) << -Word.bitWidth == BigInt(1))

        #expect(BigInt(words: [0, 1]) >> Word.bitWidth == BigInt(1))
        #expect(BigInt(-1) >> Word.bitWidth == BigInt(-1))
        #expect(BigInt(1) >> Word.bitWidth == BigInt(0))
        #expect(BigInt(words: [0, Word.max]) >> Word.bitWidth == BigInt(-1))
        #expect(BigInt(1) >> -Word.bitWidth == BigInt(words: [0, 1]))

        #expect(BigInt(1) &<< BigInt(Word.bitWidth) == BigInt(words: [0, 1]))
        #expect(BigInt(words: [0, 1]) &>> BigInt(Word.bitWidth) == BigInt(1))
    }

    @Test func shiftAssignments() {

        var a: BigInt = 1
        a <<= Word.bitWidth
        #expect(a == BigInt(words: [0, 1]))

        a = -1
        a <<= Word.bitWidth
        #expect(a == BigInt(words: [0, Word.max]))

        a = BigInt(words: [0, 1])
        a <<= -Word.bitWidth
        #expect(a == 1)

        a = BigInt(words: [0, 1])
        a >>= Word.bitWidth
        #expect(a == 1)

        a = -1
        a >>= Word.bitWidth
        #expect(a == -1)

        a = 1
        a >>= Word.bitWidth
        #expect(a == 0)

        a = BigInt(words: [0, Word.max])
        a >>= Word.bitWidth
        #expect(a == BigInt(-1))

        a = 1
        a >>= -Word.bitWidth
        #expect(a == BigInt(words: [0, 1]))

        a = 1
        a &<<= BigInt(Word.bitWidth)
        #expect(a == BigInt(words: [0, 1]))

        a = BigInt(words: [0, 1])
        a &>>= BigInt(Word.bitWidth)
        #expect(a == BigInt(1))

    }

    @Test func codable() {
        func test(_ a: BigInt) {
            do {
                let json = try JSONEncoder().encode(a)
                print(String(data: json, encoding: .utf8)!)
                let b = try JSONDecoder().decode(BigInt.self, from: json)
                #expect(a == b)
            }
            catch let error {
                Issue.record("Error thrown: \(error.localizedDescription)")
            }
        }
        test(0)
        test(1)
        test(-1)
        test(0x0102030405060708)
        test(-0x0102030405060708)
        test(BigInt(1) << 64)
        test(-BigInt(1) << 64)
        test(BigInt(words: [1, 2, 3, 4, 5, 6, 7]))
        test(-BigInt(words: [1, 2, 3, 4, 5, 6, 7]))

        do {
            _ = try JSONDecoder().decode(BigUInt.self, from: "[\"*\", 1]".data(using: .utf8)!)
            Issue.record("Expected a decoding error")
        } catch {
            guard let error = error as? DecodingError else { Issue.record("Expected a decoding error"); return }
            guard case .dataCorrupted(let context) = error else { Issue.record("Expected a dataCorrupted error"); return }
            #expect(context.debugDescription == "Invalid big integer sign")
        }
    }

    @Test func decodableString() {
        func test(_ a: BigInt, _ v: String? = nil) {
            do {
                let json = try JSONEncoder().encode(v ?? a.description)
                let b = try JSONDecoder().decode(BigInt.self, from: json)
                #expect(a == b)
            } catch let error {
                Issue.record("Error thrown: \(error.localizedDescription)")
            }
        }

        test(1, "1")
        test(1, "+1")
        test(-1, "-1")
        test(0, "+0")
        test(0, "-0")
        test(15, "0xf")
        test(15, "0Xf")
        test(15, "0x0f")
        test(BigInt(1) << 64)
        test(-BigInt(1) << 64)
    } 

    @Test func decodableStringError() {
        func test(_ v: String, _ m: String) {
            do {
                _ = try JSONDecoder().decode(BigInt.self, from: try! JSONEncoder().encode(v))
                Issue.record("Expected a decoding error")
            } catch {
                guard let error = error as? DecodingError else { Issue.record("Expected a decoding error"); return }
                guard case .dataCorrupted(let context) = error else { Issue.record("Expected a dataCorrupted error"); return }
                #expect(m == context.debugDescription)
            }
        }

        test("124q", "Invalid decimal BigInt string")
        test("-124q", "Invalid decimal BigInt string")
        test("0xXYZ", "Invalid hexadecimal BigInt string")
    }

    
    @Test func conversionToData() {
        func test(_ b: BigInt, _ d: Array<UInt8>) {
            let expected = Data(d)
            let actual = b.serialize()
            #expect(actual == expected)
            #expect(BigInt(actual) == b)
        }
        
        // Positive integers
        test(BigInt(), [])
        test(BigInt(1), [0x00, 0x01])
        test(BigInt(2), [0x00, 0x02])
        test(BigInt(0x0102030405060708), [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
        test(BigInt(0x01) << 64 + BigInt(0x0203040506070809), [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 09])
        
        // Negative integers
        test(BigInt(), [])
        test(BigInt(-1), [0x01, 0x01])
        test(BigInt(-2), [0x01, 0x02])
        test(BigInt(0x0102030405060708) * BigInt(-1), [0x01, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
        test((BigInt(0x01) << 64 + BigInt(0x0203040506070809)) * BigInt(-1), [0x01, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 09])

    }

}
