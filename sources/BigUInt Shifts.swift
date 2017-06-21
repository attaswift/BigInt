//
//  BigUInt Shifts.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016-2017 Károly Lőrentey.
//

extension BigUInt {

    //MARK: Shift Operators

    /// Shift a big integer to the right by `amount` bits and store the result in place.
    ///
    /// - Complexity: O(count)
    public static func <<=(left: inout BigUInt, right: Int) {
        guard right >= 0 else { left >>= -right; return }
        guard right > 0 else { return }

        let ext = right / Word.bitWidth // External shift amount (new words)
        let up = Word(right % Word.bitWidth) // Internal shift amount (subword shift)
        let down = Word(Word.bitWidth) - up

        if up > 0 {
            var i = 0
            var lowbits: Word = 0
            while i < left.count || lowbits > 0 {
                let Word = left[i]
                left[i] = Word << up | lowbits
                lowbits = Word >> down
                i += 1
            }
        }
        if ext > 0 && left.count > 0 {
            left.words.insert(contentsOf: Array<Word>(repeating: 0, count: ext), at: 0)
        }
    }

    /// Shift a big integer to the left by `amount` bits and return the result.
    ///
    /// - Returns: b * 2^amount
    /// - Complexity: O(count)
    public static func <<(left: BigUInt, right: Int) -> BigUInt {
        guard right >= 0 else { return left >> -right }
        guard right > 0 else { return left }

        let ext = right / Word.bitWidth // External shift amount (new words)
        let up = Word(right % Word.bitWidth) // Internal shift amount (subword shift)
        let down = Word(Word.bitWidth) - up

        var result = BigUInt()
        if up > 0 {
            var i = 0
            var lowbits: Word = 0
            while i < left.count || lowbits > 0 {
                let Word = left[i]
                result[i + ext] = Word << up | lowbits
                lowbits = Word >> down
                i += 1
            }
        }
        else {
            for i in 0 ..< left.count {
                result[i + ext] = left[i]
            }
        }
        return result
    }

    /// Shift a big integer to the right by `amount` bits and store the result in place.
    ///
    /// - Complexity: O(count)
    public static func >>=(left: inout BigUInt, right: Int) {
        guard right >= 0 else { left <<= -right; return }
        guard right > 0 else { return }

        let ext = right / Word.bitWidth // External shift amount (new Words)
        let down = Word(right % Word.bitWidth) // Internal shift amount (subWord shift)
        let up = Word(Word.bitWidth) - down

        if ext >= left.count {
            left = BigUInt()
            return
        }

        if ext > 0 {
            left.words.removeSubrange(0 ..< ext)
        }
        if down > 0 {
            var i = left.count - 1
            var highbits: Word = 0
            while i >= 0 {
                let Word = left[i]
                left[i] = highbits | Word >> down
                highbits = Word << up
                i -= 1
            }
            left.shrink()
        }
    }

    /// Shift a big integer to the right by `amount` bits and return the result.
    ///
    /// - Returns: b / 2^amount
    /// - Complexity: O(count)
    public static func >>(left: BigUInt, right: Int) -> BigUInt {
        guard right >= 0 else { return left << -right }
        guard right > 0 else { return left }

        let ext = right / Word.bitWidth // External shift amount (new Words)
        let down = Word(right % Word.bitWidth) // Internal shift amount (subWord shift)
        let up = Word(Word.bitWidth) - down
        
        if ext >= left.count { return BigUInt() }
        
        var result = BigUInt()
        if down > 0 {
            var highbits: Word = 0
            for i in (ext ..< left.count).reversed() {
                let Word = left[i]
                result[i - ext] = highbits | Word >> down
                highbits = Word << up
            }
        }
        else {
            for i in (ext ..< left.count).reversed() {
                result[i - ext] = left[i]
            }
        }
        return result
    }
    
    public static func &<<=(left: inout BigUInt, right: BigUInt) {
        guard !right.isZero else { return }
        guard right.count == 1, let right = Int(exactly: right[0]) else {
            fatalError("Shift amount too large")
        }
        left <<= right
    }
    public static func &<<(left: BigUInt, right: BigUInt) -> BigUInt {
        guard !right.isZero else { return left }
        guard right.count == 1, let right = Int(exactly: right[0]) else {
            fatalError("Shift amount too large")
        }
        return left << right
    }
    
    public static func &>>=(left: inout BigUInt, right: BigUInt) {
        guard !right.isZero else { return }
        guard right.count == 1, let right = Int(exactly: right[0]) else {
            fatalError("Shift amount too large")
        }
        left >>= right
    }
    
    public static func &>>(left: BigUInt, right: BigUInt) -> BigUInt {
        guard !right.isZero else { return left }
        guard right.count == 1, let right = Int(exactly: right[0]) else {
            fatalError("Shift amount too large")
        }
        return left >> right
    }
}
