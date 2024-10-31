//
//  Floating Point Conversion.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2017-08-11.
//  Copyright © 2016-2017 Károly Lőrentey.
//

#if canImport(Foundation)
import Foundation
#endif

extension BigUInt {
    public init?<T: BinaryFloatingPoint>(exactly source: T) {
        guard source.isFinite else { return nil }
        guard !source.isZero else { self = 0; return }
        guard source.sign == .plus else { return nil }
        let value = source.rounded(.towardZero)
        guard value == source else { return nil }
        assert(value.floatingPointClass == .positiveNormal)
        assert(value.exponent >= 0)
        let significand = value.significandBitPattern
        self = (BigUInt(1) << value.exponent) + BigUInt(significand) >> (T.significandBitCount - Int(value.exponent))
    }

    public init<T: BinaryFloatingPoint>(_ source: T) {
        self.init(exactly: source.rounded(.towardZero))!
    }

    #if canImport(Foundation)
    public init?(exactly source: Decimal) {
        guard source.isFinite else { return nil }
        guard !source.isZero else { self = 0; return }
        guard source.sign == .plus else { return nil }
        assert(source.floatingPointClass == .positiveNormal)
        guard source.exponent >= 0 else { return nil }
        let intMaxD = Decimal(UInt.max)
        let intMaxB = BigUInt(UInt.max)
        var start = BigUInt()
        var value = source
        while value >= intMaxD {
            start += intMaxB
            value -= intMaxD
        }
        start += BigUInt((value as NSNumber).uintValue)
        self = start
    }

    public init?(truncating source: Decimal) {
        guard source.isFinite else { return nil }
        guard !source.isZero else { self = 0; return }
        guard source.sign == .plus else { return nil }
        assert(source.floatingPointClass == .positiveNormal)
        let intMaxD = Decimal(UInt.max)
        let intMaxB = BigUInt(UInt.max)
        var start = BigUInt()
        var value = source
        while value >= intMaxD {
            start += intMaxB
            value -= intMaxD
        }
        start += BigUInt((value as NSNumber).uintValue)
        self = start
    }
    #endif
}

extension BigInt {
    public init?<T: BinaryFloatingPoint>(exactly source: T) {
        guard let magnitude = BigUInt(exactly: source.magnitude) else { return nil }
        let sign = BigInt.Sign(source.sign)
        self.init(sign: sign, magnitude: magnitude)
    }

    public init<T: BinaryFloatingPoint>(_ source: T) {
        self.init(exactly: source.rounded(.towardZero))!
    }

    #if canImport(Foundation)
    public init?(exactly source: Decimal) {
        guard let magnitude = BigUInt(exactly: source.magnitude) else { return nil }
        let sign = BigInt.Sign(source.sign)
        self.init(sign: sign, magnitude: magnitude)
    }

    public init?(truncating source: Decimal) {
        guard let magnitude = BigUInt(truncating: source.magnitude) else { return nil }
        let sign = BigInt.Sign(source.sign)
        self.init(sign: sign, magnitude: magnitude)
    }
    #endif
}

extension BinaryFloatingPoint where RawExponent: FixedWidthInteger, RawSignificand: FixedWidthInteger {
    public init(_ value: BigInt) {
        guard !value.isZero else { self = 0; return }
        let v = value.magnitude
        let bitWidth = v.bitWidth
        var exponent = bitWidth - 1
        let shift = bitWidth - Self.significandBitCount - 1
        var significand = value.magnitude >> (shift - 1)
        if significand[0] & 3 == 3 { // Handle rounding
            significand >>= 1
            significand += 1
            if significand.trailingZeroBitCount >= Self.significandBitCount {
                exponent += 1
            }
        }
        else {
            significand >>= 1
        }
        let bias = 1 << (Self.exponentBitCount - 1) - 1
        guard exponent <= bias else { self = Self.infinity; return }
        significand &= 1 << Self.significandBitCount - 1
        self = Self.init(sign: value.sign == .plus ? .plus : .minus,
                         exponentBitPattern: RawExponent(bias + exponent),
                         significandBitPattern: RawSignificand(significand))
    }

    public init(_ value: BigUInt) {
        self.init(BigInt(sign: .plus, magnitude: value))
    }
}

extension BigInt.Sign {
    public init(_ sign: FloatingPointSign) {
        switch sign {
        case .plus:
            self = .plus
        case .minus:
            self = .minus
        }
    }
}
