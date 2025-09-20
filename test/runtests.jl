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

	@test findall(collect("ab"), a) == [1, 3]
	@test findall(collect("b"), a) == [2, 4]
	@test findall(collect("abc"), a) == [3]
	@test findall(collect("a"), a) == [1, 3]
	@test findall(collect("c"), a) == [5]
	@test findall(collect("d"), a) == Int[]

	sub, pos = longest_common_substring(a, collect("zzabcy"))
	@test String(sub) == "abc"
	@test pos == 3  # Julia indices are 1-based

	# empty automaton
	b = SuffixAutomaton()
	@test isempty(b)
	@test !occursin("x", b)
	@test substring_count(b) == 0
	@test findall("x", b) == Int[]

	# single character
	c = SuffixAutomaton()
	append!(c, "a")
	@test occursin("a", c)
	@test !occursin("b", c)
	@test substring_count(c) == 1
	 @test findall(collect("a"), c) == [1]

	# repeated character
	d = SuffixAutomaton()
	append!(d, "aaaa")
	@test occursin("aaa", d)
	 @test findall(collect("aa"), d) == [1, 2, 3]
	@test substring_count(d) == 4  # "a", "aa", "aaa", "aaaa"

	e = SuffixAutomaton{Int}()
	append!(e, [1, 2, 1, 3])

	# membership
	@test occursin([1,2], e)
	@test occursin([2,1], e)
	@test !occursin([2,3], e)

	# occurrences
	@test findall([1], e) == [1, 3]
	@test findall([1,3], e) == [3]

	# distinct substrings
	@test substring_count(e) == 9
end

