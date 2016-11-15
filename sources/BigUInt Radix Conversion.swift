//
//  BigUInt Radix Conversion.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016 Károly Lőrentey.
//

extension BigUInt: CustomStringConvertible {

    //MARK: Radix Conversion

    /// Calculates the number of numerals in a given radix that fit inside a single `Digit`.
    ///
    /// - Returns: (chars, power) where `chars` is highest that satisfy `radix^chars <= 2^Digit.width`. `power` is zero
    ///   if radix is a power of two; otherwise `power == radix^chars`.
    fileprivate static func charsPerDigit(forRadix radix: Int) -> (chars: Int, power: Digit) {
        var power: Digit = 1
        var overflow = false
        var count = 0
        while !overflow {
            let (p, o) = Digit.multiplyWithOverflow(power, Digit(radix))
            overflow = o
            if !o || p == 0 {
                count += 1
                power = p
            }
        }
        return (count, power)
    }

    /// Initialize a big integer from an ASCII representation in a given radix. Numerals above `9` are represented by
    /// letters from the English alphabet.
    ///
    /// - Requires: `radix > 1 && radix < 36`
    /// - Parameter `text`: A string consisting of characters corresponding to numerals in the given radix. (0-9, a-z, A-Z)
    /// - Parameter `radix`: The base of the number system to use, or 10 if unspecified.
    /// - Returns: The integer represented by `text`, or nil if `text` contains a character that does not represent a numeral in `radix`.
    public init?(_ text: String, radix: Int = 10) {
        precondition(radix > 1)
        let (charsPerDigit, power) = BigUInt.charsPerDigit(forRadix: radix)

        var digits: [Digit] = []
        var piece: String = ""
        var count = 0
        for c in text.characters.reversed() {
            piece.insert(c, at: piece.startIndex)
            count += 1
            if count == charsPerDigit {
                guard let d = Digit(piece, radix: radix) else { return nil }
                digits.append(d)
                piece = ""
                count = 0
            }
        }
        if !piece.isEmpty {
            guard let d = Digit(piece, radix: radix) else { return nil }
            digits.append(d)
        }

        if power == 0 {
            self.init(digits)
        }
        else {
            self.init()
            for d in digits.reversed() {
                self.multiply(byDigit: power)
                self.addDigit(d)
            }
        }
    }

    /// Return the decimal representation of this integer.
    public var description: String {
        return String(self, radix: 10)
    }
}

extension String {
    /// Initialize a new string with the base-10 representation of an unsigned big integer.
    ///
    /// - Complexity: O(v.count^2)
    public init(_ v: BigUInt) { self.init(v, radix: 10, uppercase: false) }

    /// Initialize a new string representing an unsigned big integer in the given radix (base).
    ///
    /// Numerals greater than 9 are represented as letters from the English alphabet,
    /// starting with `a` if `uppercase` is false or `A` otherwise.
    ///
    /// - Requires: radix > 1 && radix <= 36
    /// - Complexity: O(count) when radix is a power of two; otherwise O(count^2).
    public init(_ v: BigUInt, radix: Int, uppercase: Bool = false) {
        precondition(radix > 1)
        let (charsPerDigit, power) = BigUInt.charsPerDigit(forRadix: radix)

        guard !v.isEmpty else { self = "0"; return }

        var parts: [String]
        if power == 0 {
            parts = v.map { String($0, radix: radix, uppercase: uppercase) }
        }
        else {
            parts = []
            var rest = v
            while !rest.isZero {
                let mod = rest.divide(byDigit: power)
                parts.append(String(mod, radix: radix, uppercase: uppercase))
            }
        }
        assert(!parts.isEmpty)

        self = ""
        var first = true
        for part in parts.reversed() {
            let zeroes = charsPerDigit - part.characters.count
            assert(zeroes >= 0)
            if !first && zeroes > 0 {
                // Insert leading zeroes for mid-digits
                self += String(repeating: "0", count: zeroes)
            }
            first = false
            self += part
        }
    }
}

extension BigUInt: CustomPlaygroundQuickLookable {
    /// Return the playground quick look representation of this integer.
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        let text = String(self)
        return PlaygroundQuickLook.text(text + " (\(self.width) bits)")
    }
}
