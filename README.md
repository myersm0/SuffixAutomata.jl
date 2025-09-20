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
You will normally construct a `SuffixAutomaton{T}` from a `Vector{T}` where T is any iterable type:
```julia
using SuffixAutomata

a = SuffixAutomaton([1, 2, 3, 1, 2, 3])

occursin([1, 2, 3], a)   # true
findall([1, 2, 3], a)    # [1, 4]
occursin(4, a)           # false
lcs(a, [1, 2, 3, 4])     # ([1, 2, 3], 1)

push!(a, 4)
occursin(4, a)           # true
lcs(a, [1, 2, 3, 4])     # ([1, 2, 3, 4], 1)

length(a)                # 7
a[1:5]                   # [1, 2, 3, 1, 2]
append!(a, a[1:end])     # double the length by appending
length(a)                # 14
```

Alternatively you may pass in a single string and it will be broken up for you into a vector of `Char`:
```julia
a = SuffixAutomaton("ababc")
typeof(a)                    # SuffixAutomaton{Char}

occursin("ab", a)            # true
findall("ab", a)             # [1, 3]
lcs(a, "abcdefg")            # ("abc", 3)
```

[![Build Status](https://github.com/myersm0/SuffixAutomata.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/myersm0/SuffixAutomata.jl/actions/workflows/CI.yml?query=branch%3Amain)
