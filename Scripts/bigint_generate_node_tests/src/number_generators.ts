// ===========
// === Smi ===
// ===========

export const smiMax = 2147483647n;
export const smiMin = -2147483648n;

/**
 * We will return `2 * countButNotReally + 3` values (don't ask).
 */
export function generateSmiNumbers(countButNotReally: number): bigint[] {
  const result: bigint[] = [];

  result.push(0n);
  result.push(1n);
  result.push(-1n);

  const count = BigInt(countButNotReally);
  const step = smiMax / count;

  for (let i = BigInt(0); i < countButNotReally; i++) {
    const s = i * step;

    const fromMax = smiMax - s;
    result.push(fromMax);

    const fromMin = smiMin + s;
    result.push(fromMin);
  }

  return result;
}

// ============
// === Heap ===
// ============

export const wordMax = 18446744073709551615n;
export const wordMin = 0n;

/**
 * We will return `2 * countButNotReally + 5` values (don't ask).
 */
export function generateHeapNumbers(countButNotReally: number): bigint[] {
  const result: bigint[] = [];

  result.push(0n);
  result.push(1n);
  result.push(-1n);
  result.push(wordMax);
  result.push(-wordMax);

  let word = 2n; // Start from '2' and go up
  const maxWordCount = 3;

  for (let i = 0; i < countButNotReally; i++) {
    const min1WordBecauseWeAlreadyAddedZero = 1
    const wordCount = (i % maxWordCount) + min1WordBecauseWeAlreadyAddedZero;

    let value = 1n;
    for (let j = 0; j < wordCount; j++) {
      value = value * wordMax + word;
      word += 1n;
    }

    result.push(value);
    result.push(-value);
  }

  return result;
}
