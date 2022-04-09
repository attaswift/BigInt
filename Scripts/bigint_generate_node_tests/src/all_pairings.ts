export interface BigIntPair {
  lhs: bigint;
  rhs: bigint;
}

export function allPossiblePairings(lhsValues: bigint[], rhsValues: bigint[]): BigIntPair[] {
  const result: BigIntPair[] = [];

  for (const lhs of lhsValues) {
    for (const rhs of rhsValues) {
      result.push({ lhs, rhs });
    }
  }

  return result;
}
