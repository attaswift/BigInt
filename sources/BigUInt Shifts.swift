//
//  BigUInt Shifts.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016-2017 Károly Lőrentey.
//

extension BigUInt {

    //MARK: Shift Operators
    
    internal func shiftedLeft(by amount: Word) -> BigUInt {
        guard amount > 0 else { return self }
        
        let ext = Int(amount / Word(Word.bitWidth)) // External shift amount (new words)
        let up = Word(amount % Word(Word.bitWidth)) // Internal shift amount (subword shift)
        let down = Word(Word.bitWidth) - up
        
        var result = BigUInt()
        if up > 0 {
            var i = 0
            var lowbits: Word = 0
            while i < self.count || lowbits > 0 {
                let word = self[i]
                result[i + ext] = word << up | lowbits
                lowbits = word >> down
                i += 1
            }
        }
        else {
            for i in 0 ..< self.count {
                result[i + ext] = self[i]
            }
        }
        return result
    }
    
    internal mutating func shiftLeft(by amount: Word) {
        guard amount > 0 else { return }
        
        let ext = Int(amount / Word(Word.bitWidth)) // External shift amount (new words)
        let up = Word(amount % Word(Word.bitWidth)) // Internal shift amount (subword shift)
        let down = Word(Word.bitWidth) - up
        
        if up > 0 {
            var i = 0
            var lowbits: Word = 0
            while i < self.count || lowbits > 0 {
                let word = self[i]
                self[i] = word << up | lowbits
                lowbits = word >> down
                i += 1
            }
        }
        if ext > 0 && self.count > 0 {
            self.words.insert(contentsOf: repeatElement(0 as Word, count: ext), at: 0)
        }
    }
    
    internal func shiftedRight(by amount: Word) -> BigUInt {
        guard amount > 0 else { return self }
        guard amount < self.bitWidth else { return 0 }
        
        let ext = Int(amount / Word(Word.bitWidth)) // External shift amount (new words)
        let down = Word(amount % Word(Word.bitWidth)) // Internal shift amount (subword shift)
        let up = Word(Word.bitWidth) - down
        
        var result = BigUInt()
        if down > 0 {
            var highbits: Word = 0
            for i in (ext ..< self.count).reversed() {
                let Word = self[i]
                result[i - ext] = highbits | Word >> down
                highbits = Word << up
            }
        }
        else {
            for i in (ext ..< self.count).reversed() {
                result[i - ext] = self[i]
            }
        }
        return result
    }
    
    internal mutating func shiftRight(by amount: Word) {
        guard amount > 0 else { return }
        guard amount < self.bitWidth else { self = 0; return }
        
        let ext = Int(amount / Word(Word.bitWidth)) // External shift amount (new words)
        let down = Word(amount % Word(Word.bitWidth)) // Internal shift amount (subword shift)
        let up = Word(Word.bitWidth) - down
        
        if ext > 0 {
            self.words.removeSubrange(0 ..< ext)
        }
        if down > 0 {
            var i = self.count - 1
            var highbits: Word = 0
            while i >= 0 {
                let Word = self[i]
                self[i] = highbits | Word >> down
                highbits = Word << up
                i -= 1
            }
            self.shrink()
        }
    }
    
    /// Returns the result of shifting a value's binary representation the
    /// specified number of digits to the left.
    public static func &<<(left: BigUInt, right: BigUInt) -> BigUInt {
        return left.shiftedLeft(by: Word(right))
    }
    
    /// Calculates the result of shifting a value's binary representation the
    /// specified number of digits to the left, and stores the result in the
    /// left-hand-side variable.
    public static func &<<=(left: inout BigUInt, right: BigUInt) {
        left.shiftLeft(by: Word(right))
    }

    /// Returns the result of shifting a value's binary representation the
    /// specified number of digits to the right.
    public static func &>>(left: BigUInt, right: BigUInt) -> BigUInt {
        guard right.count <= 1 else { return 0 }
        return left.shiftedRight(by: right[0])
    }
    
    /// Calculates the result of shifting a value's binary representation the
    /// specified number of digits to the right, and stores the result in the
    /// left-hand-side variable.
    public static func &>>=(left: inout BigUInt, right: BigUInt) {
        guard right.count <= 1 else { left = 0; return }
        left.shiftRight(by: right[0])
    }
    
    public static func >>=<Other: BinaryInteger>(lhs: inout BigUInt, rhs: Other) {
        if rhs < (0 as Other) {
            lhs <<= (0 - rhs)
        }
        else if rhs >= lhs.bitWidth {
            lhs = 0
        }
        else {
            lhs.shiftRight(by: UInt(rhs))
        }
    }
    
    public static func <<=<Other: BinaryInteger>(lhs: inout BigUInt, rhs: Other) {
        if rhs < (0 as Other) {
            lhs >>= (0 - rhs)
            return
        }
        lhs.shiftLeft(by: Word(exactly: rhs)!)
    }

    public static func >><Other: BinaryInteger>(lhs: BigUInt, rhs: Other) -> BigUInt {
        if rhs < (0 as Other) {
            return lhs << (0 - rhs)
        }
        if rhs > Word.max {
            return 0
        }
        return lhs.shiftedRight(by: UInt(rhs))
    }

    public static func <<<Other: BinaryInteger>(lhs: BigUInt, rhs: Other) -> BigUInt {
        if rhs < (0 as Other) {
            return lhs >> (0 - rhs)
        }
        return lhs.shiftedLeft(by: Word(exactly: rhs)!)
    }
}
