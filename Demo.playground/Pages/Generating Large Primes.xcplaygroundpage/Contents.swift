//: [Previous](@previous)

import Foundation
import BigInt

//: # Generating Large Prime Numbers
//:
//: `BigUInt` has an `isPrime()` method that does a [Miller-Rabin Primality Test][mrpt]. Let's use
//: this to create a function that finds the next prime number after any integer:
//:
//: [mrpt]: https://en.wikipedia.org/wiki/Miller%2dRabin_primality_test


func findNextPrimeAfter(integer: BigUInt) -> BigUInt {
    var candidate = integer
    repeat {
        candidate.increment()
    } while !candidate.isPrime()
    return candidate
}

findNextPrimeAfter(100)
findNextPrimeAfter(1000)
findNextPrimeAfter(10000)
findNextPrimeAfter(100000000000)
findNextPrimeAfter(1 << 64)
findNextPrimeAfter(1 << 128)
findNextPrimeAfter(1 << 256)

//: [Next](@next)
