# SuffixAutomata
A Julia implementation of *suffix automata* for generic sequences.  

Works with characters, integers, strings, or any other iterable type.  

## Features
- Build a suffix automaton from any sequence (`String`, `Vector{Char}`, `Vector{Int}`, etc.).
- Check substring existence in **O(m)** time (`occursin`).
- Find all occurrences of a pattern (`findall`).
- Count the number of distinct substrings (`substring_count`).
- Compute the longest common substring between two sequences (`longest_common_substring`).

## Usage

```julia
using SuffixAutomata

# build from characters
a = SuffixAutomaton()
append!(a, collect("ababc"))

occursin("ab", a)      # true
findall("ab", a)       # [1, 3]
substring_count(a)     # 12

# build from integers
b = SuffixAutomaton{Int}()
append!(b, [7, 14, 21, 28, 7, 14])

occursin([7, 14], b)   # true
findall([7, 14], b)    # [1, 5]
```

[![Build Status](https://github.com/myersm0/SuffixAutomata.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/myersm0/SuffixAutomata.jl/actions/workflows/CI.yml?query=branch%3Amain)
