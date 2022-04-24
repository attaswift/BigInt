import { allPossiblePairings, BigIntPair } from './all_pairings';
import { generateSmiNumbers, generateHeapNumbers } from './number_generators';

const smiNumbers = generateSmiNumbers(10);
const heapNumbers = generateHeapNumbers(10);

const smiSmiPairs = allPossiblePairings(smiNumbers, smiNumbers);
const smiHeapPairs = allPossiblePairings(smiNumbers, heapNumbers);
const heapSmiPairs = allPossiblePairings(heapNumbers, smiNumbers);
const heapHeapPairs = allPossiblePairings(heapNumbers, heapNumbers);

// ========================
// === Unary operations ===
// ========================

export type UnaryOperation = (value: bigint) => bigint;

export function printUnaryOperationTests(name: string, op: UnaryOperation) {
  const nameLower = name.toLowerCase();
  const testFn = `self.${nameLower}Test`;

  console.log(`  // MARK: - ${name}`);
  console.log();

  printUnaryOperationTest(`${nameLower}_smi`, testFn, smiNumbers, op);
  printUnaryOperationTest(`${nameLower}_heap`, testFn, heapNumbers, op);
}

function printUnaryOperationTest(
  name: string,
  testFn: string,
  values: bigint[],
  op: UnaryOperation
) {
  console.log(`  func test_${name}() {`);
  for (const value of values) {
    const expected = op(value);
    console.log(`    ${testFn}(value: "${value}", expecting: "${expected}")`);
  }

  console.log('  }');
  console.log();
}

// =========================
// === Binary operations ===
// =========================

export type BinaryOperation = (lhs: bigint, rhs: bigint) => bigint;

export function printBinaryOperationTests(name: string, op: BinaryOperation) {
  const nameLower = name.toLowerCase();
  const testFn = `self.${nameLower}Test`;

  console.log(`  // MARK: - ${name}`);
  console.log();

  printBinaryOperationTest(`${nameLower}_smi_smi`, testFn, smiSmiPairs, op);
  printBinaryOperationTest(`${nameLower}_smi_heap`, testFn, smiHeapPairs, op);
  printBinaryOperationTest(`${nameLower}_heap_smi`, testFn, heapSmiPairs, op);
  printBinaryOperationTest(`${nameLower}_heap_heap`, testFn, heapHeapPairs, op);
}

function printBinaryOperationTest(
  name: string,
  testFn: string,
  values: BigIntPair[],
  op: BinaryOperation
) {
  const isDiv = name.startsWith('div') || name.startsWith('mod');

  console.log(`  func test_${name}() {`);
  for (const { lhs, rhs } of values) {
    if (isDiv && rhs == 0n) {
      continue; // Well.. hello there!
    }

    const expected = op(lhs, rhs);
    console.log(`    ${testFn}(lhs: "${lhs}", rhs: "${rhs}", expecting: "${expected}")`);
  }
  console.log('  }');
  console.log();
}

// ===============
// === Div mod ===
// ===============

export function printDivModTests() {
  const name = 'DivMod';
  const nameLower = 'divMod';
  const testFn = `self.${nameLower}Test`;

  console.log(`  // MARK: - ${name}`);
  console.log();

  printDivModTest(`${nameLower}_smi_smi`, testFn, smiSmiPairs);
  printDivModTest(`${nameLower}_smi_heap`, testFn, smiHeapPairs);
  printDivModTest(`${nameLower}_heap_smi`, testFn, heapSmiPairs);
  printDivModTest(`${nameLower}_heap_heap`, testFn, heapHeapPairs);
}

function printDivModTest(
  name: string,
  testFn: string,
  values: BigIntPair[]
) {
  const isDiv = true;

  console.log(`  func test_${name}() {`);
  for (const { lhs, rhs } of values) {
    if (isDiv && rhs == 0n) {
      continue; // Well.. hello there!
    }

    const div = lhs / rhs;
    const mod = lhs % rhs;
    console.log(`    ${testFn}(lhs: "${lhs}", rhs: "${rhs}", div: "${div}", mod: "${mod}")`);
  }
  console.log('  }');
  console.log();
}

// =============
// === Power ===
// =============

export function printPowerTests() {
  const name = 'Power';
  const nameLower = 'power';
  const testFn = `self.${nameLower}Test`;

  console.log(`  // MARK: - ${name}`);
  console.log();

  printPowerTest(`${nameLower}_smi`, testFn, smiNumbers);
  printPowerTest(`${nameLower}_heap`, testFn, heapNumbers);
}

const exponents = [0n, 1n, 2n, 3n, 5n, 10n];

function printPowerTest(
  name: string,
  testFn: string,
  values: bigint[]
) {
  const isDiv = true;

  console.log(`  func test_${name}() {`);
  for (const value of values) {
    for (const exponent of exponents) {
      const result = value ** exponent;
      console.log(`    ${testFn}(base: "${value}", exponent: ${exponent}, expecting: "${result}")`);
    }
  }
  console.log('  }');
  console.log();
}

// ==============
// === Shifts ===
// ==============

export type ShiftOperation = (value: bigint, count: bigint) => bigint;

export function printShiftOperationTests(name: string, op: ShiftOperation) {
  const nameLower = name.toLowerCase();
  const testFn = `self.shift${name}Test`;

  const lessThanWord = 5n;
  const word = 64n;
  const moreThanWord = 64n + 64n - 7n;

  console.log(`  // MARK: - Shift ${nameLower}`);
  console.log();

  printShiftTest(`shift${name}_smi_lessThanWord`, testFn, smiNumbers, lessThanWord, op);
  printShiftTest(`shift${name}_smi_word`, testFn, smiNumbers, word, op);
  printShiftTest(`shift${name}_smi_moreThanWord`, testFn, smiNumbers, moreThanWord, op);

  printShiftTest(`shift${name}_heap_lessThanWord`, testFn, heapNumbers, lessThanWord, op);
  printShiftTest(`shift${name}_heap_word`, testFn, heapNumbers, word, op);
  printShiftTest(`shift${name}_heap_moreThanWord`, testFn, heapNumbers, moreThanWord, op);
}

function printShiftTest(
  name: string,
  testFn: string,
  values: bigint[],
  count: bigint,
  op: ShiftOperation
) {
  console.log(`  func test_${name}() {`);

  for (const value of values) {
    const expected = op(value, count);
    console.log(`    ${testFn}(value: "${value}", count: ${count}, expecting: "${expected}")`);
  }

  console.log('  }');
  console.log();
}
