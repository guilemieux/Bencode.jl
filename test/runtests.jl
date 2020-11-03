using Test
using Bencode

@test bencode(1) == "i1e"
@test bencode(123456) == "i123456e"
@test bencode(0) == "i0e"
@test bencode(-1234) == "i-1234e"
