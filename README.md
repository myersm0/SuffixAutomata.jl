# SuffixAutomata
A Julia implementation of [suffix automata](https://en.wikipedia.org/wiki/Suffix_automaton) for generic sequences. Works with characters, integers, strings, or any other iterable type.

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
findall([1, 2, 3], a)    # [1:3, 4:6]
occursin(4, a)           # false
lcs([1, 2, 3, 4], a)     # ([1, 2, 3], 1)

push!(a, 4)
occursin(4, a)           # true
lcs([1, 2, 3, 4], a)     # ([1, 2, 3, 4], 1)

length(a)                # 7
a[1:5]                   # [1, 2, 3, 1, 2]
append!(a, a[1:end])     # double the length by appending
length(a)                # 14
```

Alternatively, for the more canonical case of dealing with _character_ data, you may pass in a single string and it will be converted to a `Vector{Char}` for you internally:
```julia
a = SuffixAutomaton("ababc")
typeof(a)                    # SuffixAutomaton{Char}
eltype(a)                    # Char

occursin("ab", a)            # true
findall("ab", a)             # [1:2, 3:4]
lcs("abcdef", a)             # ("abc", 1)

append!(a, "def")
lcs(  "abcdef", a)          # ("abcdef", 1)
lcs( "zabcdef", a)          # ("abcdef", 2)
lcs("zzabcdef", a)          # ("abcdef", 3)
```

Note that we adhere to the `f(needle, haystack)` argument order. For `lcs` (longest common substring), however, there is a gotcha in the fact that the position returned is _the position of the match in the query term_ (the "needle"), perhaps contrary to expectations; but this is the way the algorithm intrinsically works.

[![Build Status](https://github.com/myersm0/SuffixAutomata.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/myersm0/SuffixAutomata.jl/actions/workflows/CI.yml?query=branch%3Amain)
