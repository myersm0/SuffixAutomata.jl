module SuffixAutomata

export SuffixAutomaton, lcs, substring_count, get_all_substrings

mutable struct State{T}
	transitions::Dict{T, State{T}}
	suffix_link::Union{State{T}, Nothing}
	length::Int
	is_terminal::Bool
	first_occurrence::Int
end

State{T}(length::Int = 0, first_pos::Int = 0) where {T} =
	State{T}(Dict{T, State{T}}(), nothing, length, false, first_pos)

mutable struct SuffixAutomaton{T}
	root::State{T}
	last::State{T}
	states::Vector{State{T}}
	data::Vector{T}
end

"""
    SuffixAutomaton{T}()

Create an empty suffix automaton for elements of type `T`.
"""
function SuffixAutomaton{T}() where {T}
	root = State{T}(0, 0)
	return SuffixAutomaton{T}(root, root, [root], T[])
end

"""
    SuffixAutomaton()

Create an empty suffix automaton for character data.
"""
SuffixAutomaton() = SuffixAutomaton{Char}()

"""
    SuffixAutomaton(data::AbstractVector{T}) where T

Create a suffix automaton from a vector of elements.
"""
function SuffixAutomaton(data::AbstractVector{T}) where {T}
	sa = SuffixAutomaton{T}()
	append!(sa, data)
	return sa
end

"""
    SuffixAutomaton(str::AbstractString)

Create a character-based suffix automaton from a string.
"""
function SuffixAutomaton(str::AbstractString)
	sa = SuffixAutomaton{Char}()
	append!(sa, str)
	return sa
end

function clone_state(state::State{T}, new_length::Int) where {T}
	new_state = State{T}(new_length, state.first_occurrence)
	new_state.transitions = copy(state.transitions)
	new_state.suffix_link = state.suffix_link
	new_state.is_terminal = state.is_terminal
	return new_state
end

"""
    push!(automaton::SuffixAutomaton{T}, symbol::T)

Add a single symbol to a suffix automaton, updating its structure.
"""
function Base.push!(automaton::SuffixAutomaton{T}, symbol::T) where {T}
	position = length(automaton.data)
	push!(automaton.data, symbol)
	new_state = State{T}(automaton.last.length + 1, position)
	push!(automaton.states, new_state)
	current = automaton.last
	# add transitions to the new state from all states on the suffix path
	while !isnothing(current) && !haskey(current.transitions, symbol)
		current.transitions[symbol] = new_state
		current = current.suffix_link
	end
	if isnothing(current)
		# we've reached the root via suffix links
		new_state.suffix_link = automaton.root
	else
		next_state = current.transitions[symbol]
		if current.length + 1 == next_state.length
			# the transition is solid (goes to the right place)
			new_state.suffix_link = next_state
		else
			# we need to split the state
			clone = clone_state(next_state, current.length + 1)
			push!(automaton.states, clone)
			next_state.suffix_link = clone
			new_state.suffix_link = clone
			while !isnothing(current) && current.transitions[symbol] === next_state
				current.transitions[symbol] = clone
				current = current.suffix_link
			end
		end
	end
	automaton.last = new_state
	return automaton
end

"""
    append!(automaton::SuffixAutomaton, sequence)

Add a sequence of symbols to a suffix automaton.
"""
function Base.append!(automaton::SuffixAutomaton, sequence)
	for symbol in sequence
		push!(automaton, symbol)
	end
	return automaton
end

"""
    append!(automaton::SuffixAutomaton{Char}, str::AbstractString)

Add the characters of a string to a character-based suffix automaton.
"""
function Base.append!(automaton::SuffixAutomaton{Char}, str::AbstractString)
	for char in str
		push!(automaton, char)
	end
	return automaton
end

function mark_terminals!(automaton::SuffixAutomaton)
	current = automaton.last
	while !isnothing(current)
		current.is_terminal = true
		current = current.suffix_link
	end
end

function find_state(automaton::SuffixAutomaton, pattern)
	current = automaton.root
	for symbol in pattern
		if haskey(current.transitions, symbol)
			current = current.transitions[symbol]
		else
			return nothing
		end
	end
	return current
end

"""
    occursin(pattern, automaton::SuffixAutomaton{T}) where T

Check if a pattern occurs as in the automaton's data.
"""
function Base.occursin(pattern, automaton::SuffixAutomaton)
	return !isnothing(find_state(automaton, pattern))
end

function Base.occursin(pattern::AbstractString, automaton::SuffixAutomaton{Char})
	return !isnothing(find_state(automaton, collect(pattern)))
end

function Base.in(pattern, automaton::SuffixAutomaton)
	return occursin(pattern, automaton)
end

"""
    findall(pattern, automaton::SuffixAutomaton{T}) where T

Find all occurrences of a pattern in the automaton's text.

Returns a (possibly empty) `Vector{UnitRange{Int}}`.
"""
function Base.findall(pattern, automaton::SuffixAutomaton{T}) where {T}
	isempty(pattern) && return UnitRange{Int}[]
	state = find_state(automaton, pattern)
	isnothing(state) && return UnitRange{Int}[]
	patlen = length(pattern)
	positions = UnitRange{Int}[]
	for i in 1:(length(automaton.data) - patlen + 1)
		if automaton.data[i:i+patlen-1] == pattern
			push!(positions, i:i+patlen-1)
		end
	end
	return positions
end

"""
    findall(pattern, automaton::SuffixAutomaton{T}) where T

Find all occurrences of a single element `T` in a `SuffixAutomaton{T}`.

Returns a (possibly empty) `Vector{Int}`.
"""
function Base.findall(element::T, automaton::SuffixAutomaton{T}) where {T}
	return findall([element], automaton) .|> first  # convert ranges to integers
end

function Base.findall(pattern::AbstractString, automaton::SuffixAutomaton{Char})
	return findall(collect(pattern), automaton)
end

"""
    lcs(sequence, automaton::SuffixAutomaton{T}) where T

Find the longest common substring between a sequence and the automaton's text.

Returns a tuple of `(substring, position)` where `substring` is the longest 
common substring and `position` is its 1-based starting position in the input sequence
"""
function lcs(sequence, automaton::SuffixAutomaton{T}) where T
	current = automaton.root
	length = 0
	best_length = 0
	best_position = 0
	
	for (i, symbol) in enumerate(sequence)
		while current !== automaton.root && !haskey(current.transitions, symbol)
			current = current.suffix_link
			length = isnothing(current) ? 0 : current.length
		end
		
		if haskey(current.transitions, symbol)
			current = current.transitions[symbol]
			length += 1
		else
			current = automaton.root
			length = 0
		end
		
		if length > best_length
			best_length = length
			best_position = i - length + 1
		end
	end
	
	best_length > 0 || return T[], 0
	return sequence[best_position:best_position + best_length - 1], best_position
end

function lcs(sequence::AbstractString, automaton::SuffixAutomaton{Char})
	result, pos = lcs(collect(sequence), automaton)
	isnothing(result) && return nothing, 0
	return String(result), pos
end

"""
    length(automaton::SuffixAutomaton)

Get the length of the sequence used to build the automaton.
"""
function Base.length(automaton::SuffixAutomaton)
	return length(automaton.data)
end

"""
    size(automaton::SuffixAutomaton)

Get the number of states in the automaton.
"""
function Base.size(automaton::SuffixAutomaton)
	return length(automaton.states)
end

"""
    isempty(automaton::SuffixAutomaton)

Check if the automaton is empty (contains no data).
"""
function Base.isempty(automaton::SuffixAutomaton)
	return isempty(automaton.data)
end

function Base.eltype(::Type{SuffixAutomaton{T}}) where {T}
	return T
end

function Base.eltype(::SuffixAutomaton{T}) where {T}
	return T
end

"""
    getindex(automaton::SuffixAutomaton, i)

Access elements of the underlying sequence by index.
"""
function Base.getindex(automaton::SuffixAutomaton, args...) end

function Base.getindex(automaton::SuffixAutomaton, i::Integer)
	return automaton.data[i]
end

function Base.getindex(automaton::SuffixAutomaton, r::AbstractRange)
	return automaton.data[r]
end

function Base.firstindex(automaton::SuffixAutomaton)
	return 1
end

function Base.lastindex(automaton::SuffixAutomaton)
	return length(automaton.data)
end

function Base.isequal(a::SuffixAutomaton, b::SuffixAutomaton)
	a.data == b.data
end

function Base.:(==)(a::SuffixAutomaton, b::SuffixAutomaton)
	isequal(a, b)
end

"""
    substring_count(automaton::SuffixAutomaton)

Count the number of distinct substrings in the automaton.
"""
function substring_count(automaton::SuffixAutomaton)
	count = 0
	for state in automaton.states
		if state !== automaton.root
			parent_length = isnothing(state.suffix_link) ? 0 : state.suffix_link.length
			count += state.length - parent_length
		end
	end
	return count
end

"""
    get_all_substrings(automaton::SuffixAutomaton)

Get all distinct substrings recognized by the automaton.

Warning: for large texts, this can return a very large number of substrings (up to O(n²)).
"""
function get_all_substrings(automaton::SuffixAutomaton{T}) where {T}
	substrings = Vector{Vector{T}}()
	function dfs(state::State{T}, path::Vector{T})
		if state !== automaton.root && length(path) > 0
			push!(substrings, copy(path))
		end
		for (symbol, next_state) in state.transitions
			push!(path, symbol)
			dfs(next_state, path)
			pop!(path)
		end
	end
	dfs(automaton.root, T[])
	return substrings
end

function Base.iterate(automaton::SuffixAutomaton)
	isempty(automaton.data) && return nothing
	return automaton.data[1], 2
end

function Base.iterate(automaton::SuffixAutomaton, state::Integer)
	state > length(automaton.data) && return nothing
	return automaton.data[state], state + 1
end

function Base.show(io::IO, automaton::SuffixAutomaton)
	len = length(automaton)
	siz = size(automaton)
	print(io, "SuffixAutomaton{$T}(length=$len, states=$siz")
end

function Base.show(
		io::IO, ::MIME"text/plain", automaton::SuffixAutomaton{T}
	) where {T}
	println(io, "SuffixAutomaton{$T}")
	println(io, "  sequence length: $(length(automaton))")
	println(io, "  states: $(size(automaton))")
	println(io, "  unique substrings: $(substring_count(automaton))")
	length(automaton) > 0 || return
	if length(automaton) <= 50
		print(io, "  content: ")
		if T == Char
			print(io, "\"", String(automaton.data), "\"")
		else
			print(io, automaton.data)
		end
	else
		print(io, "  content: [$(length(automaton)) elements]")
	end
end

end
