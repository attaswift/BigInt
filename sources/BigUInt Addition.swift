//
//  BigUInt Addition.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016-2017 Károly Lőrentey.
//

extension BigUInt {
    //MARK: Addition
    
    /// Add `word` to this integer in place.
    /// `word` is shifted `shift` words to the left before being added.
    ///
    /// - Complexity: O(max(count, shift))
    internal mutating func addWord(_ word: Word, shiftedBy shift: Int = 0) {
        precondition(shift >= 0)
        var carry: Word = word
        var i = startIndex + shift
        while carry > 0 {
            let (d, c) = self[i].addingReportingOverflow(carry)
            self[i] = d
            carry = (c == .overflow ? 1 : 0)
            i += 1
        }
    }

    /// Add the digit `d` to this integer and return the result.
    /// `d` is shifted `shift` words to the left before being added.
    ///
    /// - Complexity: O(max(count, shift))
    internal func addingWord(_ word: Word, shiftedBy shift: Int = 0) -> BigUInt {
        var r = self
        r.addWord(word, shiftedBy: shift)
        return r
    }

    /// Add `b` to this integer in place.
    /// `b` is shifted `shift` words to the left before being added.
    ///
    /// - Complexity: O(max(count, b.count + shift))
    internal mutating func add(_ b: BigUInt, shiftedBy shift: Int = 0) {
        precondition(shift >= 0)
        var carry = false
        var bi = 0
        while bi < b.count || carry {
            let ai = shift + bi
            let (d, c) = self[ai].addingReportingOverflow(b[bi])
            if carry {
                let (d2, c2) = d.addingReportingOverflow(1)
                self[ai] = d2
                carry = c == .overflow || c2 == .overflow
            }
            else {
                self[ai] = d
                carry = c == .overflow
            }
            bi += 1
        }
    }

    /// Add `b` to this integer and return the result.
    /// `b` is shifted `shift` words to the left before being added.
    ///
    /// - Complexity: O(max(count, b.count + shift))
    internal func adding(_ b: BigUInt, shiftedBy shift: Int = 0) -> BigUInt {
        var r = self
        r.add(b, shiftedBy: shift)
        return r
    }

    /// Increment this integer by one. If `shift` is non-zero, it selects
    /// the word that is to be incremented.
    ///
    /// - Complexity: O(count + shift)
    internal mutating func increment(atPosition shift: Int = 0) {
        self.addWord(1, shiftedBy: shift)
    }

    /// Add `a` and `b` together and return the result.
    ///
    /// - Complexity: O(max(a.count, b.count))
    public static func +(a: BigUInt, b: BigUInt) -> BigUInt {
        return a.adding(b)
    }

    /// Add `a` and `b` together, and store the sum in `a`.
    ///
    /// - Complexity: O(max(a.count, b.count))
    public static func +=(a: inout BigUInt, b: BigUInt) {
        a.add(b, shiftedBy: 0)
    }
}
