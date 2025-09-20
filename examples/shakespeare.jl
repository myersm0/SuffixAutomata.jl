
using SuffixAutomata
using Pkg.Artifacts

rootpath = artifact"pg_texts"
filename = joinpath(rootpath, "pg100.txt") # Alice in Wonderland

# Load complete works of Shakespeare
text = read(filename, String)

# Build suffix automaton from entire text - O(n) construction
a = SuffixAutomaton(lowercase(text))

# Count of every unique substring in Shakespeare:
substring_count(a) # this actually overflows, though
# todo: fix overflow

# ===== Demo 1: Fast pattern search across entire corpus =======================
# Find all occurrences of a phrase
positions = findall("to be, or not to be", a)
length(positions)  # how many times this exact phrase appears

# Check existence of phrases - O(m) time
occursin("wherefore art thou", a)                         # true
occursin("the quality of mercy", a)                       # true
occursin("eye of newt", a)                                # true (from Macbeth)
occursin("this phrase does not occur in shakespeare", a)  # false

# Even with millions of characters, pattern search remains O(m)
# and pattern existence check is just following at most m transitions
long_quote = "all the world’s a stage"
@time occursin(long_quote, a)  # near-instant even in huge text


# ===== Demo 2: Finding longest common passages between parts ==================
# Compare first half with second half to find repeated passages
midpoint = length(a) ÷ 2
first_half = a[1:midpoint]
second_half = a[midpoint+1:end]

sa_first = SuffixAutomaton(first_half)
repeated_passage, position = lcs(sa_first, second_half)
# finds longest passage that appears in both halves
length(repeated_passage)  # length of longest repeated passage
join(repeated_passage)


# ===== Demo 3: Quick concordance building =====================================
# Find context around a word efficiently
target = "affection"
positions = findall(target, a)

# Get context windows around each occurrence
window_size = 20
contexts = String[]
for pos in positions[1:10]
	start_pos = max(1, pos - window_size)
	end_pos = min(length(a), pos + length(target) + window_size)
	context = a[start_pos:end_pos]
	push!(contexts, String(context))
end

contexts



