#!/usr/bin/env python3
"""Example candidate metric: number of AST nodes in a Python file.

This is the `def-operationalize-behavior-and-size` "size" proxy from the
deterministic-metric-design skill: size measured on the parse tree, so it is
invariant to comments and whitespace (unlike LOC).

Adapter contract: take exactly one path argument, print ONE number to stdout.
"""
import ast
import sys


def ast_node_count(path: str) -> int:
    source = open(path, encoding="utf-8").read()
    return sum(1 for _ in ast.walk(ast.parse(source)))


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("usage: metric_ast_nodes.py <path>", file=sys.stderr)
        sys.exit(1)
    try:
        print(ast_node_count(sys.argv[1]))
    except SyntaxError:
        # Unparseable input → 0 is a defined, in-range value (see prop-prove-boundedness).
        print(0)
