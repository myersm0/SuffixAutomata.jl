
using SuffixAutomata

# ===== Demo 1: Finding patterns in mathematical sequences =====================
# Build automaton from Fibonacci sequence modulo 10
fib = Int[]
a, b = 0, 1
for i in 1:120
	push!(fib, a)
	a, b = b, (a + b) % 10
end

a = SuffixAutomaton(fib)

# The Fibonacci sequence mod 10 repeats every 60 numbers (Pisano period)
# Find the repeating pattern
pattern = fib[1:60]
occurrences = findall(pattern, a)  # [1, 61] - pattern repeats at position 61

# Find all occurrences of the pattern [1, 1] (consecutive 1s)
double_ones = findall([1, 1], a)  # finds all positions with consecutive 1s

# Check if certain patterns exist - O(m) time complexity
occursin([7, 7], a)  # true - pattern exists
occursin([7, 7, 7], a)  # false - three consecutive 7s don't exist


# ===== Demo 2: Analyzing prime gaps ===========================================
# Build automaton from gaps between consecutive primes
function primes_up_to(n)
	sieve = trues(n)
	sieve[1] = false
	for i in 2:isqrt(n)
		if sieve[i]
			for j in i^2:i:n
				sieve[j] = false
			end
		end
	end
	return findall(sieve)
end

primes = primes_up_to(1000)
gaps = diff(primes)  # gaps between consecutive primes

a = SuffixAutomaton(gaps)

# Twin primes have gap 2
twin_prime_positions = findall([2], a)  # all twin prime locations
length(twin_prime_positions)  # count of twin primes up to 1000

# Cousin primes have gap 4
cousin_prime_positions = findall([4], a)

# Find prime quadruplets pattern: gaps of [2, 4] or [4, 2]
findall([2, 4], a)  # prime quadruplets like (5,7,11,13)
findall([4, 2], a)  # prime quadruplets like (7,11,13,17)

# Find the longest repeated gap pattern
test_gaps = diff(primes_up_to(5000))
sa_test = SuffixAutomaton(test_gaps[1:500])
repeated_pattern, pos = lcs(sa_test, test_gaps[501:end])
# finds longest gap pattern that appears in both halves


# ===== Demo 3: Pattern mining in sequences ====================================
# Generate a sequence with intentional patterns
sequence = Int[]
for i in 1:10
	append!(sequence, [1, 2, 3])  # pattern A
	append!(sequence, [4, 5])     # pattern B
	if i % 3 == 0
		append!(sequence, [1, 2, 3])  # extra pattern A every 3rd iteration
	end
end

a = SuffixAutomaton(sequence)

# Count unique subsequences - reveals sequence complexity
substring_count(a)  # number of distinct subsequences

# Find most frequent patterns efficiently
pattern_a_count = length(findall([1, 2, 3], a))
pattern_b_count = length(findall([4, 5], a))

# Detect if sequence contains specific complex pattern
complex_pattern = [1, 2, 3, 4, 5, 1, 2, 3]
occursin(complex_pattern, a)  # O(m) check

# Find all patterns of length 3
all_subs = get_all_substrings(a)
length_3_patterns = unique(filter(x -> length(x) == 3, all_subs))


# ===== Demo 4: Real-time pattern detection (simulating streaming data) ========
a = SuffixAutomaton{Int}()

# Simulate incoming data stream
data_stream = [1, 2, 1, 2, 3, 1, 2, 1, 2, 3, 4, 1, 2]
alert_pattern = [1, 2, 3, 4]  # pattern we're watching for

for (i, value) in enumerate(data_stream)
	push!(a, value)
	# Check if alert pattern just appeared
	if length(a) >= length(alert_pattern)
		if occursin(alert_pattern, a)
			position = i - length(alert_pattern) + 1  # position where pattern started
			# Pattern detected at position!
			break
		end
	end
end

# After processing stream, analyze patterns
all_positions_of_12 = findall([1, 2], a)  # all occurrences of [1,2]
substring_count(a)  # complexity of received data



