//: [Previous](@previous)

import Foundation
import BigInt

//: ## Let's calculate the first thousand digits of π

//: A fun application of BigInts is generating the digits of π.
//: Let's implement [Jeremy Gibbon's spigot algorithm][spigot] as an infinite `GeneratorType`. 
//: This is a quite slow algorithm, but it makes up for it with its grooviness factor.
//:
//: [spigot]: http://www.cs.ox.ac.uk/jeremy.gibbons/publications/spigot.pdf

func digitsOfPi() -> AnyGenerator<Int> {
    var q: BigUInt = 1
    var r: BigUInt = 180
    var t: BigUInt = 60
    var i: UInt64 = 2 // Works until digit #826_566_842
    return anyGenerator {
        let u: UInt64 = 3 * (3 * i + 1) * (3 * i + 2)
        let y = (q.multiplyByDigit(27 * i - 12) + 5 * r) / (5 * t)
        (q, r, t) = (
            10 * q.multiplyByDigit(i * (2 * i - 1)),
            10 * (q.multiplyByDigit(5 * i - 2) + r - y * t).multiplyByDigit(u),
            t.multiplyByDigit(u))
        i += 1
        return Int(y[0])
    }
}

//: Well, that was surprisingly easy. Does it work? You bet:

var digits = "π ≈ "
var count = 0
for digit in digitsOfPi() {
    assert(digit < 10)
    digit
    digits += String(digit)
    count += 1
    if count == 1 { digits += "." }
    if count == 1000 { break }
}

digits
//: [Next](@next)
