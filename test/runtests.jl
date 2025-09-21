using Test
using SuffixAutomata
using Pkg.Artifacts

@testset "SuffixAutomata.jl" begin
	a = SuffixAutomaton{Char}()
	append!(a, "ababc")
	@test a == SuffixAutomaton("ababc") == SuffixAutomaton(collect("ababc"))

	@test occursin("ab", a)
	@test occursin("bc", a)
	@test !occursin("ac", a)
	@test occursin("a", a)
	@test occursin("c", a)
	@test !occursin("d", a)

	@test substring_count(a) == 12

	@test findall("ab", a) == [1:2, 3:4]
	@test findall("b", a) == [2:2, 4:4]
	@test findall("abc", a) == [3:5]
	@test findall("a", a) == [1:1, 3:3]
	@test findall("c", a) == [5:5]
	@test findall("d", a) == UnitRange{Int}[]

	sub, pos = lcs("zzabcy", a)
	@test String(sub) == "abc"
	@test pos == 3

	# empty automaton
	a = SuffixAutomaton()
	@test isempty(a)
	@test !occursin("x", a)
	@test substring_count(a) == 0
	@test findall("x", a) == UnitRange{Int}[]

	# single character
	a = SuffixAutomaton()
	append!(a, "a")
	@test occursin("a", a)
	@test !occursin("b", a)
	@test substring_count(a) == 1
	@test findall(collect("a"), a) == [1:1]

	# repeated character
	a = SuffixAutomaton()
	append!(a, "aaaa")
	@test occursin("aaa", a)
	@test occursin(collect("aaa"), a)
	@test findall("aa", a) == findall(collect("aa"), a) == [1:2, 2:3, 3:4]
	@test substring_count(a) == 4  # "a", "aa", "aaa", "aaaa"

	a = SuffixAutomaton{Int}()
	append!(a, [1, 2, 1, 3])
	@test a == SuffixAutomaton(a.data)

	# membership
	@test occursin([1,2], a)
	@test occursin([2,1], a)
	@test !occursin([2,3], a)

	# occurrences
	@test findall([1], a) == [1:1, 3:3]
	@test findall([1,3], a) == [3:4]

	# distinct substrings
	@test substring_count(a) == 9
end

rootpath = artifact"pg_texts"
filename = joinpath(rootpath, "pg11.txt") # Alice in Wonderland
text = join(readlines(filename)[54:3403], '\n')
@testset "Alice in Wonderland" begin
	a = SuffixAutomaton(text)
	@test occursin("Alice", a)
	for letter in collect("abcdefghijklmnopqrstuvwxyz")
		@test !occursin("Alice$letter", a)
	end
	words = unique(split(text, r"[^a-z0-9']+"i))
	for word in words
		@test occursin(word, a)
	end
	@test lcs("Alice", a) == lcs("Alicexyz", a) == ("Alice", 1)
	@test lcs("xyzAlice", a) == lcs("xyzAlicexyz", a) == ("Alice", 4)
	@test lcs("αβ̧γ", a) == ("", 0)
	@test lcs(collect("αβ̧γ"), a) == (Char[], 0)
	@test length(findall("Alice", a)) == 397
end
	







