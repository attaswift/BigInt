# What is this?

This script will use [Node.js](https://nodejs.org/en/) to generate tests for our `BigInt`.

Those tests should replace `/Tests/BigIntTests/Violet - Node`.

Example test:

```Swift
  func test_add_smi_smi() {
    // This whole test has ~500 lines, this is just an extract:
    self.addTest(lhs: "0", rhs: "0", expecting: "0")
    self.addTest(lhs: "0", rhs: "1", expecting: "1")
    self.addTest(lhs: "0", rhs: "-1", expecting: "-1")
    self.addTest(lhs: "0", rhs: "2147483647", expecting: "2147483647")
    self.addTest(lhs: "1", rhs: "0", expecting: "1")
    self.addTest(lhs: "1", rhs: "1", expecting: "2")
    self.addTest(lhs: "1", rhs: "-1", expecting: "0")
    self.addTest(lhs: "1", rhs: "2147483647", expecting: "2147483648")
    self.addTest(lhs: "-1", rhs: "0", expecting: "-1")
    self.addTest(lhs: "-1", rhs: "1", expecting: "0")
    self.addTest(lhs: "-1", rhs: "-1", expecting: "-2")
    self.addTest(lhs: "-1", rhs: "-1073741828", expecting: "-1073741829")
    self.addTest(lhs: "2147483647", rhs: "0", expecting: "2147483647")
    self.addTest(lhs: "2147483647", rhs: "1", expecting: "2147483648")
    self.addTest(lhs: "2147483647", rhs: "-1", expecting: "2147483646")
    self.addTest(lhs: "2147483647", rhs: "2147483647", expecting: "4294967294")
  }
```

# How to run?

Requires [Node.js](https://nodejs.org/en/).

Run the following commands from the repository root:
```
cd ./Scripts/bigint_generate_node_tests
npm i
./main.sh
```

This will generate `out.swift` file with the result.
