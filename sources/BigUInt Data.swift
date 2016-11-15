//
//  BigUInt Data.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-04.
//  Copyright © 2016 Károly Lőrentey.
//

import Foundation

extension BigUInt {
    //MARK: NSData Conversion

    /// Initializes an integer from the bits stored inside a piece of `NSData`.
    /// The data is assumed to be in network (big-endian) byte order.
    public init(_ data: Data) {
        // This assumes Digit is binary.
        precondition(Digit.width % 8 == 0)

        self.init()

        let length = data.count
        guard length > 0 else { return }
        let bytesPerDigit = Digit.width / 8
        var index = length / bytesPerDigit
        var c = bytesPerDigit - length % bytesPerDigit
        if c == bytesPerDigit {
            c = 0
            index -= 1
        }
        var digit: Digit = 0
        data.enumerateBytes { p, byteIndex, stop in
            for byte in p {
                digit <<= 8
                digit += Digit(byte)
                c += 1
                if c == bytesPerDigit {
                    self[index] = digit
                    index -= 1
                    c = 0
                    digit = 0
                }
            }
        }
        assert(c == 0 && digit == 0 && index == -1)
    }

    /// Return an `NSData` instance that contains the base-256 representation of this integer, in network (big-endian) byte order.
    public func serialize() -> Data {
        // This assumes Digit is binary.
        precondition(Digit.width % 8 == 0)

        let byteCount = (self.width + 7) / 8

        guard byteCount > 0 else { return Data() }

        var data = Data(count: byteCount)
        data.withUnsafeMutableBytes { (p: UnsafeMutablePointer<UInt8>) -> Void in
            var i = byteCount - 1
            for digit in self {
                var digit = digit
                for _ in 0 ..< Digit.width / 8 {
                    p[i] = UInt8(digit & 0xFF)
                    digit >>= 8
                    if i == 0 {
                        assert(digit == 0)
                        break
                    }
                    i -= 1
                }
            }
        }
        return data
    }
}

