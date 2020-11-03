module Bencode

export bencode

bencode(s::AbstractString) = string(length(s)) * ":" * s
bencode(n::Integer) = "i" * string(n) * "e"
bencode(l::AbstractVector) = "l" * join(map(bencode, l)) * "e"

end # module
