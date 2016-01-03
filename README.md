# BigInt

This repository provides [integer types of arbitrary width][wiki] implemented
in pure Swift. The representation is in base 2^64, using `Array<UInt64>`.
                                                                  
[wiki]: https://en.wikipedia.org/wiki/Arbitrary-precision_arithmetic

This module is handy when you need an integer type that's wider than `UIntMax`, but 
you don't want to add [The GNU Multiple Precision Arithmetic Library][GMP] 
as a dependency.

[GMP]: https://gmplib.org

Two big integer types are included: `BigUInt` and `BigInt`, the latter being the signed variant.
Both of these are Swift structs with copy-on-write value semantics, and they can be used much 
like any other integer type.

The library provides implementations for some of the most frequently useful functions on 
big integers, including

- All functionality from `Comparable` and `Hashable`
- The full set of arithmetic operators: `+`, `-`, `*`, `/`, `%`, `+=`, `-=`, `*=`, `/=`, `%=`
  - Addition and subtraction have variants that allow for shifting the digits of the second 
    operand on the fly.
  - Unsigned subtraction will trap when the result would be negative. (There are variants 
    that return an overflow flag.)
  - Multiplication uses brute force for numbers up to 1024 digits, then switches to Karatsuba's recursive method. 
    (This limit is configurable, see `BigUInt.directMultiplicationLimit`.) 
    A fused multiply-add method is also available.
  - Division uses Knuth's Algorithm D, with its 3/2 digits wide quotient approximation. 
    It will trap when the divisor is zero. `BigUInt.divmod` returns the quotient and
    remainder at once; this is faster than calculating them separately.
- Bitwise operators: `~`, `|`, `&`, `^`, `|=`, `&=`, `^=`, plus the following read-only properties:
  - `width`: the minimum number of bits required to store the integer,
  - `trailingZeroes`: the number of trailing zero bits in the binary representation,
  - `leadingZeroes`: the number of leading zero bits (when the last digit isn't full),
- Shift operators: `>>`, `<<`, `>>=`, `<<=`
  - Left shifts need to allocate memory to extend the digit array, so it's probably not a good idea
   to left shift a `BigUInt` by 2^50 bits.
- Radix conversion between `String`s and big integers up to base 36 (using repeated divisions).
  - Big integers use this to implement `StringLiteralConvertible` (in base 10).
- `sqrt(n)`: The square root of an integer (using Newton's method)
- `BigUInt.gcd(n, m)`: The greatest common divisor of two integers (Stein's algorithm)
- `BigUInt.powmod(base, exponent, modulus)`: Modular exponentiation (right-to-left binary method):

The implementations are intended to be reasonably efficient, but they are unlikely to be
competitive with GMP at all, even when I happened to implement an algorithm with same asymptotic
behavior as GMP. (I haven't performed a comparison benchmark, though.)

The library has 100% unit test coverage.

I haven't found (64,64)->128 multiplication or (128,64)->64 division operations in Swift, so 
the module has implementations for those in terms of the standard single-width `*` and `/` 
operators. (I suspect there are LLVM intrinsics for double-width arithmetics that are probably
accessible somehow, though.) This sounds slow, but 64-bit digits are still considerably faster
than 32-bit, even though the latter can use direct 64-bit arithmetic to implement these primitives.

`BigInt` consists of a `BigUInt` absolute value and a sign bit, both of which are accessible as public read-write properties. 

`BigUInt` is a `MutableCollectionType` of its 64-bit digits, with the least significant digit at 
index 0. As a convenience, `BigUInt` allows you to subscript it with indexes at or above its `count`.
The subscript operator returns 0 for out-of-bound `get`s and automatically extends the array on 
out-of-bound `set`s. This makes memory management simpler.


## Why is there no generic `BigInt<Digit>` type?

The types provided by `BigInt` are not parametric---this is very much intentional, as 
Swift 2.2.1 generics cost us dearly at runtime in this use case. In every approach I tried,
making arbitrary-precision arithmetic operations work with a generic `Digit` type parameter 
resulted in code that was literally *ten times slower*.

This is an area that I plan to investigate more, as it would be useful to have generic
implementations for arbitrary-width arithmetic operations. (Polynomial division and decimal bases
are two examples.) The library already implements double-digit multiplication and division as 
extension methods on a protocol with an associated type requirement; this has not measurably affected
performance. Unfortunately, the same is not true for `BigUInt`'s methods.

Of course, as a last resort, we could just duplicate the code to create a separate
generic variant that was slower but more flexible.

## Obligatory demonstration with a factorial function

```Swift
import BigInt

func factorial(n: Int) -> BigInt {
    guard n > 1 else { return 1 }
    var result: BigInt = 1    
	for i in 2...n {
        result *= Digit(i)
    }
    return result
}

print(factorial(10))
362880

print(factorial(100))
93326215443944152681699238856266700490715968264381621468592963895217599993229915
6089414639761565182862536979208272237582511852109168640000000000000000000000

print(factorial(1000))
40238726007709377354370243392300398571937486421071463254379991042993851239862902
05920442084869694048004799886101971960586316668729948085589013238296699445909974
24504087073759918823627727188732519779505950995276120874975462497043601418278094
64649629105639388743788648733711918104582578364784997701247663288983595573543251
31853239584630755574091142624174743493475534286465766116677973966688202912073791
43853719588249808126867838374559731746136085379534524221586593201928090878297308
43139284440328123155861103697680135730421616874760967587134831202547858932076716
91324484262361314125087802080002616831510273418279777047846358681701643650241536
91398281264810213092761244896359928705114964975419909342221566832572080821333186
11681155361583654698404670897560290095053761647584772842188967964624494516076535
34081989013854424879849599533191017233555566021394503997362807501378376153071277
61926849034352625200015888535147331611702103968175921510907788019393178114194545
25722386554146106289218796022383897147608850627686296714667469756291123408243920
81601537808898939645182632436716167621791689097799119037540312746222899880051954
44414282012187361745992642956581746628302955570299024324153181617210465832036786
90611726015878352075151628422554026517048330422614397428693306169089796848259012
54583271682264580665267699586526822728070757813918581788896522081643483448259932
66043367660176999612831860788386150279465955131156552036093988180612138558600301
43569452722420634463179746059468257310379008402443243846565724501440282188525247
09351906209290231364932734975655139587205596542287497740114133469627154228458623
77387538230483865688976461927383814900140767310446640259899490222221765904339901
88601856652648506179970235619389701786004081188972991831102117122984590164192106
88843871218556461249607987229085192968193723886426148396573822911231250241866493
53143970137428531926649875337218940694281434118520158014123344828015051399694290
15348307764456909907315243327828826986460278986432113908350621709500259738986355
42771967428222487575867657523442202075736305694988250879689281627538488633969099
59826280956121450994871701244516461260379029309120889086942028510640182154399457
15680594187274899809425474217358240106367740459574178516082923013535808184009699
63725242305608559037006242712434169090041536901059339838357779394109700277534720
00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000
```