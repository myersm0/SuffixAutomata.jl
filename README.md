# SuffixAutomata
A Julia implementation of *suffix automata* for generic sequences. Works with characters, integers, strings, or any other iterable type.

Some use cases for [numbers](https://github.com/myersm0/SuffixAutomata.jl/blob/main/examples/numbers.jl) and for [text data](https://github.com/myersm0/SuffixAutomata.jl/blob/main/examples/shakespeare.jl) are demonstrated in the `examples` folder.

## Features
- Build a suffix automaton from any sequence (`String`, `Vector{Char}`, `Vector{Int}`, etc.).
- Check substring existence in **O(m)** time (`occursin`).
- Find all occurrences of a pattern (`findall`).
- Count the number of distinct substrings (`substring_count`).
- Compute the longest common substring between two sequences (`lcs`).

## Usage

```julia
using SuffixAutomata

# build from characters
a = SuffixAutomaton()
append!(a, collect("ababc"))

occursin("ab", a)      # true
findall("ab", a)       # [1, 3]
lcs("abcdefg", a)      # ("abc", 1)

# build from integers
a = SuffixAutomaton{Int}()
append!(a, [1, 2, 3, 1, 2, 3])

occursin([1, 2, 3], a)   # true
findall([1, 2, 3], a)    # [1, 4]
occursin(4, a)           # false
lcs(a, [1, 2, 3, 4])     # ([1, 2, 3], 1)

push!(a, 4)
occursin(4, a)           # true
lcs(a, [1, 2, 3, 4])     # ([1, 2, 3, 4], 1)
```

[![Build Status](https://github.com/myersm0/SuffixAutomata.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/myersm0/SuffixAutomata.jl/actions/workflows/CI.yml?query=branch%3Amain)
