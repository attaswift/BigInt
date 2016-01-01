import Foundation

//: The `BigInt` module provides a `BigInt` type that implements an [https://en.wikipedia.org/wiki/Arbitrary-precision_arithmetic](integer type of arbitrary width).
//: These work much like `Int`s, but they don't have a preset maximum value---so they will never overflow.
//: The only practical limit to their capacity is the amount of memory & address space that your computer has, and the
//: amount of time you're willing to spend waiting for results---when their operands are truly huge,
//: big integer operations can take a long time to execute.
//: (`BigInt` represents integers in base 2^64, storing digits in an `Array<UInt64>`, so the theoretical
//: maximum value it can store is (2^64)^`Int.max` - 1.)

import BigInt

//: `BigInt` has several interesting initializers, but for now, the simplest way to create big integers is to use integer
//: or string literals. The latter is useful when you want to create a number that's larger than `UIntMax.max`:

let a: BigInt = 123
let b: BigInt = 12345678
let c: BigInt = 1234567890123456
let d: BigInt = "12345678901234567890123456789012345678901234567890123456789012345678"

//: To work with `BigInt`s, you can use the same arithmetic operators as with everyday `Int` values:

a + b
b - a
-b
a * b
a * b * c
a * b * c * d

d / c
d % c
d / (c * c)
d / (c * c * c)
d / (c * c * c * c)

//: The canonical way to demo big integers is with the factorial function. Here is a fancy definition for it:

func fact(n: Int) -> BigInt {
    return (1...n).lazy.map { BigInt($0) }.reduce(BigInt(1), combine: *)
}

let f1 = fact(1)
let f2 = fact(2)
let f3 = fact(3)
let f4 = fact(4)
let f10 = fact(10)
let f100 = fact(100)
let f1000 = fact(1000)

//: That last value seems quite large. Just how many decimal digits is it? Let's convert it to a `String` to find out.

let decimal = String(f1000)
let digitCount = decimal.characters.count

//: Wow. 2500 digits is peanuts for `BigInt`, but Xcode's playground tech isn't designed to perform well with much more loop iterations, so let's stay at this level for now.

let ff2 = f1000 * f1000
String(ff2).characters.count

let ff4 = ff2 * ff2
String(ff4).characters.count

let ff8 = ff4 * ff4
String(ff8).characters.count

//: That last operation multiplied two 10000-digit numbers; you may have noticed it took a couple of seconds to compute that value. Converting such huge values to decimal isn't particularly cheap, either.


