using Test
using Bencode

@test bencode(1) == "i1e"
@test bencode(123456) == "i123456e"
@test bencode(0) == "i0e"
@test bencode(-1234) == "i-1234e"

@test bencode("hello") == "5:hello"
@test bencode("") == "0:"

@test bencode(["hello", 1, "two"]) == "l5:helloi1e3:twoe"
@test bencode(1:3) == "li1ei2ei3ee"
@test bencode([]) == "le"
@test bencode(Vector{UInt8}("hello")) == ""
