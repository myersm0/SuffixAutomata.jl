using Test
using SuffixAutomata

@testset "SuffixAutomata.jl" begin
	a = SuffixAutomaton{Char}()
	append!(a, "ababc")

	@test occursin("ab", a)
	@test occursin("bc", a)
	@test !occursin("ac", a)
	@test occursin("a", a)
	@test occursin("c", a)
	@test !occursin("d", a)

	@test substring_count(a) == 12

	@test findall("ab", a) == [1, 3]
	@test findall("b", a) == [2, 4]
	@test findall("abc", a) == [3]
	@test findall("a", a) == [1, 3]
	@test findall("c", a) == [5]
	@test findall("d", a) == Int[]

	sub, pos = lcs(a, "zzabcy")
	@test String(sub) == "abc"
	@test pos == 3  # Julia indices are 1-based

	# empty automaton
	a = SuffixAutomaton()
	@test isempty(a)
	@test !occursin("x", a)
	@test substring_count(a) == 0
	@test findall("x", a) == Int[]

	# single character
	a = SuffixAutomaton()
	append!(a, "a")
	@test occursin("a", a)
	@test !occursin("b", a)
	@test substring_count(a) == 1
	@test findall(collect("a"), a) == [1]

	# repeated character
	a = SuffixAutomaton()
	append!(a, "aaaa")
	@test occursin("aaa", a)
	@test occursin(collect("aaa"), a)
	@test findall("aa", a) == findall(collect("aa"), a) == [1, 2, 3]
	@test substring_count(a) == 4  # "a", "aa", "aaa", "aaaa"

	a = SuffixAutomaton{Int}()
	append!(a, [1, 2, 1, 3])

	# membership
	@test occursin([1,2], a)
	@test occursin([2,1], a)
	@test !occursin([2,3], a)

	# occurrences
	@test findall([1], a) == [1, 3]
	@test findall([1,3], a) == [3]

	# distinct substrings
	@test substring_count(a) == 9
end

