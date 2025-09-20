
using SuffixAutomata
using BenchmarkTools
using Pkg.Artifacts

rootpath = artifact"pg_texts"
filename = joinpath(rootpath, "pg11.txt") # Alice in Wonderland
text = join(readlines(filename)[54:3403], ' ')

const SUITE = BenchmarkGroup()

a = SuffixAutomaton(text)

string_dict = Dict(
	"short early" => "Alice",
	"short mid" => "Queen",
	"long early" => "Alice was beginning to get very tired",
	"long mid" => "Do you play croquet with the Queen to-day",
	"null" => "this phrase doesn't occur in the text"
)

SUITE["construction"] = @benchmarkable SuffixAutomaton($text)

for (k, v) in string_dict
	SUITE["lcs $k"] = @benchmarkable lcs($a, $v)
	SUITE["occursin: $k"] = @benchmarkable occursin($v, $a)
	SUITE["findall: $k"] = @benchmarkable findall($v, $a)
end







