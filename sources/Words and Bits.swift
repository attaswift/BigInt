//
//  Words and Bits.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2017-08-11.
//  Copyright © 2017 Károly Lőrentey. All rights reserved.
//

extension Array where Element == UInt {
    mutating func twosComplement() {
        var increment = true
        for i in 0 ..< self.count {
            if increment {
                (self[i], increment) = (~self[i]).addingReportingOverflow(1)
            }
            else {
                self[i] = ~self[i]
            }
        }
    }
}

extension BigUInt {
    subscript(bitAt index: Int) -> Bool {
        get {
            precondition(index >= 0)
            let (i, j) = index.quotientAndRemainder(dividingBy: Word.bitWidth)
            return self[i] & (1 << j) != 0
        }
        set {
            precondition(index >= 0)
            let (i, j) = index.quotientAndRemainder(dividingBy: Word.bitWidth)
            if newValue {
                self[i] |= 1 << j
            }
            else {
                self[i] &= ~(1 << j)
            }
        }
    }
}

extension BigUInt {
    public struct Words: RandomAccessCollection {
        private let value: BigUInt

        fileprivate init(_ value: BigUInt) { self.value = value }

        public var startIndex: Int { return 0 }
        public var endIndex: Int { return value.count }

        public subscript(_ index: Int) -> Word {
            return value[index]
        }
    }

    public var words: Words { return Words(self) }
}

extension BigInt {
    public struct Words: RandomAccessCollection {
        public typealias Indices = CountableRange<Int>

        private let value: BigInt
        private let decrementLimit: Int

        fileprivate init(_ value: BigInt) {
            self.value = value
            switch value.sign {
            case .plus:
                self.decrementLimit = 0
            case .minus:
                assert(!value.magnitude.isZero)
                self.decrementLimit = value.magnitude.words.index(where: { $0 != 0 })!
            }
        }

        public var count: Int {
            switch value.sign {
            case .plus:
                if let high = value.magnitude.words.last, high >> (Word.bitWidth - 1) != 0 {
                    return value.magnitude.count + 1
                }
                return value.magnitude.count
            case .minus:
                let high = value.magnitude.words.last!
                if high >> (Word.bitWidth - 1) != 0 {
                    return value.magnitude.count + 1
                }
                return value.magnitude.count
            }
        }

        public var indices: Indices { return 0 ..< count }
        public var startIndex: Int { return 0 }
        public var endIndex: Int { return count }

        public subscript(_ index: Int) -> UInt {
            // Note that indices above `endIndex` are accepted.
            if value.sign == .plus {
                return value.magnitude[index]
            }
            if index <= decrementLimit {
                return ~(value.magnitude[index] &- 1)
            }
            return ~value.magnitude[index]
        }
    }

    public var words: Words {
        return Words(self)
    }
}
