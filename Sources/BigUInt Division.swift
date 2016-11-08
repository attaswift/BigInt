//
//  BigUInt Division.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-03.
//  Copyright © 2016 Károly Lőrentey.
//

extension BigUInt {
    //MARK: Division

    /// Divide this integer by the digit `y`, leaving the quotient in its place and returning the remainder.
    ///
    /// - Requires: y > 0
    /// - Complexity: O(count)
    public mutating func divide(byDigit y: Digit) -> Digit {
        precondition(y > 0)
        if y == 1 { return 0 }
        lift()

        var remainder: Digit = 0
        for i in (0..<count).reversed() {
            let u = self[i]
            let q = Digit.fullDivide((remainder, u), y)
            self[i] = q.div
            remainder = q.mod
        }
        return remainder
    }

    /// Divide this integer by the digit `y` and return the resulting quotient and remainder.
    ///
    /// - Requires: y > 0
    /// - Returns: (quotient, remainder) where quotient = floor(x/y), remainder = x - quotient * y
    /// - Complexity: O(x.count)
    public func divided(byDigit y: Digit) -> (quotient: BigUInt, remainder: Digit) {
        var div = self
        let mod = div.divide(byDigit: y)
        return (div, mod)
    }

    /// Divide this integer by `y` and return the resulting quotient and remainder.
    ///
    /// - Requires: `y > 0`
    /// - Returns: `(quotient, remainder)` where `quotient = floor(self/y)`, `remainder = self - quotient * y`
    /// - Complexity: O(count^2)
    public func divided(by y: BigUInt) -> (quotient: BigUInt, remainder: BigUInt) {
        // This is a Swift adaptation of "divmnu" from Hacker's Delight, which is in
        // turn a C adaptation of Knuth's Algorithm D (TAOCP vol 2, 4.3.1).

        precondition(y.count > 0)

        // First, let's take care of the easy cases.

        if self.count < y.count {
            return (0, self)
        }
        if y.count == 1 {
            // The single-digit case reduces to a simpler loop.
            let (div, mod) = divided(byDigit: y[0])
            return (div, BigUInt(mod))
        }

        // In the hard cases, we will simply perform the long division algorithm we
        // learned in school. It works by successively calculating the single-digit quotient of 
        // the top y.count + 1 digits of x divided by y, replacing the top of x with the remainder, 
        // and repeating the process one digit lower.
        //
        // The tricky part is that the algorithm needs to be able to do n+1/n digit divisions,
        // but we only have a primitive for dividing two digits by a single
        // digit. (Remember that this step is also tricky when we do it on paper!)
        //
        // The solution is that the long division can be approximated by a single fullDivide
        // using just the most significant digits. We can then use multiplications and
        // subtractions to refine the approximation until we get the correct quotient digit.
        //
        // We could do this by doing a simple 2/1 fullDivide, but Knuth goes one step further,
        // and implements a 3/2 division. This results in an exact approximation in the
        // vast majority of cases, eliminating an extra subtraction over big integers.
        //
        // Here is the code for the 3/2 division:

        /// Return the quotient of the 3/2-digit division `x/y` as a single `Digit`.
        ///
        /// - Requires: (x.0, x.1) <= y && y.0.high != 0
        /// - Returns: The exact value when it fits in a single `Digit`, otherwise `Digit.max`.
        func approximateQuotient(x: (Digit, Digit, Digit), y: (Digit, Digit)) -> Digit {
            // Start with q = (x.0, x.1) / y.0, (or Digit.max on overflow)
            var q: Digit
            var r: Digit
            if x.0 == y.0 {
                q = Digit.max
                let (s, o) = Digit.addWithOverflow(x.0, x.1)
                if o { return q }
                r = s
            }
            else {
                let (d, m) = Digit.fullDivide((x.0, x.1), y.0)
                q = d
                r = m
            }
            // Now refine q by considering x.2 and y.1.
            // Note that since y is normalized, q * y - x is between 0 and 2.
            let (ph, pl) = Digit.fullMultiply(q, y.1)
            if ph < r || (ph == r && pl <= x.2) { return q }

            let (r1, ro) = Digit.addWithOverflow(r, y.0)
            if ro { return q - 1 }

            let (pl1, so) = Digit.subtractWithOverflow(pl, y.1)
            let ph1 = (so ? ph - 1 : ph)

            if ph1 < r1 || (ph1 == r1 && pl1 <= x.2) { return q - 1 }
            return q - 2
        }

        // The function above requires that the divisor's most significant digit is larger than
        // Digit.max / 2. This ensures that the approximation has tiny error bounds,
        // which is what makes this entire approach viable.
        // To satisfy this requirement, we can simply normalize the division by multiplying
        // both the divisor and the dividend by the same (small) factor.
        let z = y.leadingZeroes
        let divisor = y << z
        var remainder = self << z // We'll calculate the remainder in the normalized dividend.
        var quotient = BigUInt()
        assert(divisor.count == y.count && divisor.last!.high > 0)

        // We're ready to start the long division!
        let dc = divisor.count
        let d1 = divisor[dc - 1]
        let d0 = divisor[dc - 2]
        for j in (dc ... remainder.count).reversed() {
            // Approximate dividing the top dc+1 digits of `remainder` using the topmost 3/2 digits.
            let r2 = remainder[j]
            let r1 = remainder[j - 1]
            let r0 = remainder[j - 2]
            let q = approximateQuotient(x: (r2, r1, r0), y: (d1, d0))

            // Multiply the entire divisor with `q` and subtract the result from remainder.
            // Normalization ensures the 3/2 quotient will either be exact for the full division, or
            // it may overshoot by at most 1, in which case the product will be greater
            // than the remainder.
            let product = divisor.multiplied(byDigit: q)
            if product <= remainder[j - dc ... j] {
                remainder.subtract(product, atPosition: j - dc)
                quotient[j - dc] = q
            }
            else {
                // This case is extremely rare -- it has a probability of 1/2^(Digit.width - 1).
                remainder.subtract(product - divisor, atPosition: j - dc)
                quotient[j - dc] = q - 1
            }
        }
        // The remainder's normalization needs to be undone, but otherwise we're done.
        return (quotient, remainder >> z)
    }

    /// Divide `x` by `y` and return the quotient.
    ///
    /// - Note: Use `divided(by:)` if you also need the remainder.
    public static func /(x: BigUInt, y: BigUInt) -> BigUInt {
        return x.divided(by: y).quotient
    }

    /// Divide `x` by `y` and return the remainder.
    ///
    /// - Note: Use `divided(by:)` if you also need the remainder.
    public static func %(x: BigUInt, y: BigUInt) -> BigUInt {
        return x.divided(by: y).remainder
    }

    /// Divide `x` by `y` and store the quotient in `x`.
    ///
    /// - Note: Use `divided(by:)` if you also need the remainder.
    public static func /=(x: inout BigUInt, y: BigUInt) {
        x = x.divided(by: y).quotient
    }

    /// Divide `x` by `y` and store the remainder in `x`.
    ///
    /// - Note: Use `divided(by:)` if you also need the remainder.
    public static func %=(x: inout BigUInt, y: BigUInt) {
        x = x.divided(by: y).remainder
    }

    /// Divide `lhs` by `rhs`, returning the quotient. This function never results in an overflow.
    public static func divideWithOverflow(_ lhs: BigUInt, _ rhs: BigUInt) -> (BigUInt, overflow: Bool) {
        return (lhs / rhs, false)
    }

    /// Divide `lhs` by `rhs`, returning the remainder. This function never results in an overflow.
    public static func remainderWithOverflow(_ lhs: BigUInt, _ rhs: BigUInt) -> (BigUInt, overflow: Bool) {
        return (lhs % rhs, false)
    }
}
