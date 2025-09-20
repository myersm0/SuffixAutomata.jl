
module SuffixAutomata

export SuffixAutomaton, longest_common_substring, substring_count, get_all_substrings

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
	text::Vector{T}
end

function SuffixAutomaton{T}() where {T}
	root = State{T}(0, 0)
	return SuffixAutomaton{T}(root, root, [root], T[])
end

SuffixAutomaton() = SuffixAutomaton{Char}()

function clone_state(state::State{T}, new_length::Int) where {T}
	new_state = State{T}(new_length, state.first_occurrence)
	new_state.transitions = copy(state.transitions)
	new_state.suffix_link = state.suffix_link
	new_state.is_terminal = state.is_terminal
	return new_state
end

function Base.push!(automaton::SuffixAutomaton{T}, symbol::T) where {T}
	position = length(automaton.text)
	push!(automaton.text, symbol)
	
	new_state = State{T}(automaton.last.length + 1, position)
	push!(automaton.states, new_state)
	
	current = automaton.last
	
	# add transitions to the new state from all states on the suffix path
	while current !== nothing && !haskey(current.transitions, symbol)
		current.transitions[symbol] = new_state
		current = current.suffix_link
	end
	
	if current === nothing
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
			
			while current !== nothing && current.transitions[symbol] === next_state
				current.transitions[symbol] = clone
				current = current.suffix_link
			end
		end
	end
	
	automaton.last = new_state
	return automaton
end

function Base.append!(automaton::SuffixAutomaton{T}, sequence) where {T}
	for symbol in sequence
		push!(automaton, symbol)
	end
	return automaton
end

function mark_terminals!(automaton::SuffixAutomaton{T}) where {T}
	current = automaton.last
	while current !== nothing
		current.is_terminal = true
		current = current.suffix_link
	end
end

function find_state(automaton::SuffixAutomaton{T}, pattern) where {T}
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

function Base.occursin(pattern, automaton::SuffixAutomaton{T}) where {T}
	return find_state(automaton, pattern) !== nothing
end

function Base.in(pattern, automaton::SuffixAutomaton{T}) where {T}
	return occursin(pattern, automaton)
end

function Base.findall(pattern, automaton::SuffixAutomaton{T}) where {T}
	isempty(pattern) && return collect(1:length(automaton.text)+1)
	state = find_state(automaton, pattern)
	state === nothing && return Int[]
	positions = Int[]
	pattern_length = length(pattern)
	text_length = length(automaton.text)
	for i in 1:(text_length - pattern_length + 1)
		match = true
		for j in 1:pattern_length
			if automaton.text[i + j - 1] != pattern[j]
				match = false
				break
			end
		end
		if match
			push!(positions, i)
		end
	end
	return positions
end


function longest_common_substring(
		automaton1::SuffixAutomaton{T}, sequence2
	) where {T}
	current = automaton1.root
	length = 0
	best_length = 0
	best_position = 0
	
	for (i, symbol) in enumerate(sequence2)
		while current !== automaton1.root && !haskey(current.transitions, symbol)
			current = current.suffix_link
			length = current === nothing ? 0 : current.length
		end
		
		if haskey(current.transitions, symbol)
			current = current.transitions[symbol]
			length += 1
		else
			current = automaton1.root
			length = 0
		end
		
		if length > best_length
			best_length = length
			best_position = i - length + 1
		end
	end
	
	if best_length > 0
		return sequence2[best_position:best_position + best_length - 1], best_position
	else
		return nothing, 0
	end
end

function Base.length(automaton::SuffixAutomaton)
	return length(automaton.text)
end

function Base.size(automaton::SuffixAutomaton)
	return length(automaton.states)
end

function Base.isempty(automaton::SuffixAutomaton)
	return isempty(automaton.text)
end

function Base.eltype(::Type{SuffixAutomaton{T}}) where {T}
	return T
end

function Base.eltype(::SuffixAutomaton{T}) where {T}
	return T
end

function substring_count(automaton::SuffixAutomaton{T}) where {T}
	count = 0
	for state in automaton.states
		if state !== automaton.root
			parent_length = state.suffix_link === nothing ? 0 : state.suffix_link.length
			count += state.length - parent_length
		end
	end
	return count
end

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

function Base.iterate(automaton::SuffixAutomaton{T}) where {T}
	if isempty(automaton.text)
		return nothing
	end
	return automaton.text[1], 2
end

function Base.iterate(automaton::SuffixAutomaton{T}, state::Int) where {T}
	if state > length(automaton.text)
		return nothing
	end
	return automaton.text[state], state + 1
end

function Base.show(io::IO, automaton::SuffixAutomaton{T}) where {T}
	print(io, "SuffixAutomaton{", T, "}(length=", length(automaton), ", states=", size(automaton), ")")
end

function Base.show(io::IO, ::MIME"text/plain", automaton::SuffixAutomaton{T}) where {T}
	println(io, "SuffixAutomaton{", T, "}")
	println(io, "  sequence length: ", length(automaton))
	println(io, "  states: ", size(automaton))
	println(io, "  unique substrings: ", substring_count(automaton))
	length(automaton) > 0 || return
	if length(automaton) <= 50
		print(io, "  content: ")
		if T == Char
			print(io, "\"", String(automaton.text), "\"")
		else
			print(io, automaton.text)
		end
	else
		print(io, "  content: [", length(automaton), " elements]")
	end
end


end


