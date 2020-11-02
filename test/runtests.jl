using Test
using Bencode

@test bdecode(1) == "i1e"
@test bdecode(123456) == "i123456e"
@test bdecode(0) == "i0e"
@test bdecode(-1234) == "i-1234e"
