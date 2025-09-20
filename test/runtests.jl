using SuffixAutomata
using Test

using Test
using SuffixAutomata

@testset "SuffixAutomata.jl" begin
	
	@testset "Construction" begin
		sa = SuffixAutomaton()
		@test eltype(sa) == Char
		@test isempty(sa)
		@test length(sa) == 0
		@test size(sa) == 1  # root state
		sa_int = SuffixAutomaton{Int}()
		@test eltype(sa_int) == Int
		@test isempty(sa_int)
		sa_str = SuffixAutomaton{String}()
		@test eltype(sa_str) == String
	end
	
	@testset "push! and append!" begin
		sa = SuffixAutomaton{Char}()
		push!(sa, 'a')
		@test length(sa) == 1
		@test !isempty(sa)
		push!(sa, 'b')
		push!(sa, 'c')
		@test length(sa) == 3
		sa2 = SuffixAutomaton{Char}()
		append!(sa2, "abc")
		@test length(sa2) == 3
		@test collect(sa2) == ['a', 'b', 'c']
		sa3 = SuffixAutomaton{Int}()
		push!(sa3, 1) |> sa -> push!(sa, 2)
		@test length(sa3) == 2
	end
	
	@testset "occursin" begin
		sa = SuffixAutomaton{Char}()
		append!(sa, "abcab")
		@test occursin("ab", sa)
		@test occursin("abc", sa)
		@test occursin("cab", sa)
		@test occursin("b", sa)
		@test occursin("abcab", sa)
		@test "ab" in sa
		@test "bc" in sa
		@test !occursin("abd", sa)
		@test !occursin("ac", sa)
		@test !occursin("abcabc", sa)
		@test occursin("", sa)
		@test occursin("a", sa)
		@test occursin("c", sa)
		@test !occursin("d", sa)
	end
	
	@testset "findall" begin
		sa = SuffixAutomaton{Char}()
		append!(sa, "abababab")
		positions = findall("ab", sa)
		@test positions == [1, 3, 5, 7]
		positions = findall("aba", sa)
		@test positions == [1, 3, 5]
		positions = findall("bab", sa)
		@test positions == [2, 4, 6]
		positions = findall("abababab", sa)
		@test positions == [1]
		positions = findall("bb", sa)
		@test isempty(positions)
		sa_empty = SuffixAutomaton{Char}()
		@test isempty(findall("a", sa_empty))
	end
	
	@testset "Integer sequences" begin
		sa = SuffixAutomaton{Int}()
		append!(sa, [1, 2, 3, 1, 2, 3, 4])
		@test occursin([1, 2], sa)
		@test occursin([2, 3], sa)
		@test occursin([1, 2, 3], sa)
		@test occursin([3, 4], sa)
		@test !occursin([1, 3], sa)
		positions = findall([1, 2, 3], sa)
		@test positions == [1, 4]
		positions = findall([3], sa)
		@test positions == [3, 6]
	end
	
	@testset "Longest common substring" begin
		sa1 = SuffixAutomaton{Char}()
		append!(sa1, "abcdefg")
		# exact match
		lcs, pos = longest_common_substring(sa1, "cde")
		@test lcs == "cde"
		@test pos == 1
		# partial match
		lcs, pos = longest_common_substring(sa1, "xyzcdexyz")
		@test lcs == "cde"
		@test pos == 4
		# multiple possible matches (returns first longest)
		lcs, pos = longest_common_substring(sa1, "abcxyzdefg")
		@test length(lcs) == 4  # either "abc" or "defg"
		# no match
		lcs, pos = longest_common_substring(sa1, "xyz")
		@test lcs === nothing
		@test pos == 0
		# with integer sequences
		sa_int = SuffixAutomaton{Int}()
		append!(sa_int, [1, 2, 3, 4, 5])
		lcs, pos = longest_common_substring(sa_int, [9, 2, 3, 4, 9])
		@test lcs == [2, 3, 4]
		@test pos == 2
	end
	
	@testset "Substring counting" begin
		sa = SuffixAutomaton{Char}()
		@test substring_count(sa) == 0
		push!(sa, 'a')
		@test substring_count(sa) == 1  # "a"
		push!(sa, 'b')
		@test substring_count(sa) == 3  # "a", "b", "ab"
		push!(sa, 'a')
		@test substring_count(sa) == 5  # "a", "b", "ab", "ba", "aba"
		# test with repeating pattern
		sa2 = SuffixAutomaton{Char}()
		append!(sa2, "aaa")
		@test substring_count(sa2) == 3  # "a", "aa", "aaa"
	end
	
	@testset "Get all substrings" begin
		sa = SuffixAutomaton{Char}()
		append!(sa, "aba")
		substrings = get_all_substrings(sa)
		substring_strs = Set(String.(substrings))
		expected = Set(["a", "b", "ab", "ba", "aba"])
		@test substring_strs == expected
		sa_int = SuffixAutomaton{Int}()
		append!(sa_int, [1, 2, 1])
		substrings = get_all_substrings(sa_int)
		substring_set = Set(substrings)
		expected_int = Set([[1], [2], [1, 2], [2, 1], [1, 2, 1]])
		@test substring_set == expected_int
	end
	
	@testset "Iterator interface" begin
		sa = SuffixAutomaton{Char}()
		append!(sa, "hello")
		@test collect(sa) == ['h', 'e', 'l', 'l', 'o']
		chars = Char[]
		for c in sa
			push!(chars, c)
		end
		@test chars == ['h', 'e', 'l', 'l', 'o']
		sa_int = SuffixAutomaton{Int}()
		append!(sa_int, [1, 2, 3])
		@test collect(sa_int) == [1, 2, 3]
		sa_empty = SuffixAutomaton{Char}()
		@test collect(sa_empty) == []
	end
	
	@testset "Complex patterns" begin
		# repeating patterns
		sa = SuffixAutomaton{Char}()
		append!(sa, "mississippi")
		@test occursin("iss", sa)
		@test length(findall("iss", sa)) == 2
		@test length(findall("i", sa)) == 4
		@test length(findall("ss", sa)) == 2
		@test length(findall("si", sa)) == 2
		# overlapping patterns
		sa2 = SuffixAutomaton{Char}()
		append!(sa2, "aaaa")
		@test length(findall("aa", sa2)) == 3  # positions 1, 2, 3
		# test with custom type
		struct Note
			pitch::Int
			duration::Float64
		end
		Base.:(==)(a::Note, b::Note) = a.pitch == b.pitch && a.duration == b.duration
		Base.hash(n::Note, h::UInt) = hash((n.pitch, n.duration), h)
		sa_notes = SuffixAutomaton{Note}()
		notes = [Note(60, 0.5), Note(62, 0.5), Note(64, 1.0)]
		append!(sa_notes, notes)
		@test occursin([Note(60, 0.5), Note(62, 0.5)], sa_notes)
		@test !occursin([Note(60, 1.0)], sa_notes)
	end
	
	@testset "Edge cases" begin
		# empty patterns
		sa = SuffixAutomaton{Char}()
		append!(sa, "test")
		@test occursin([], sa)
		@test occursin("", sa)
		# single element
		sa_single = SuffixAutomaton{Int}()
		push!(sa_single, 42)
		@test occursin([42], sa_single)
		@test !occursin([43], sa_single)
		@test findall([42], sa_single) == [1]
		# very long pattern not in automaton
		sa_long = SuffixAutomaton{Char}()
		append!(sa_long, "short")
		@test !occursin("this is a very long string", sa_long)
		# pattern longer than automaton
		@test !occursin("shorter", sa_long)
	end
	
	@testset "Display" begin
		sa = SuffixAutomaton{Char}()
		io = IOBuffer()
		show(io, sa)
		@test occursin("SuffixAutomaton{Char}", String(take!(io)))
		append!(sa, "test")
		io = IOBuffer()
		show(io, MIME("text/plain"), sa)
		output = String(take!(io))
		@test occursin("sequence length: 4", output)
		@test occursin("unique substrings:", output)
		@test occursin("content:", output)
		sa_long = SuffixAutomaton{Int}()
		append!(sa_long, 1:100)
		io = IOBuffer()
		show(io, MIME("text/plain"), sa_long)
		output = String(take!(io))
		@test occursin("[100 elements]", output)
	end
	
end
