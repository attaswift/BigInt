import XCTest
@testable import BigIntTests

XCTMain([
   testCase(BigIntTests.allTests),
   testCase(BigUIntTests.allTests),
   testCase(PrimitiveTypeTests.allTests),
   testCase(SipHashableTests.allTests),
])
