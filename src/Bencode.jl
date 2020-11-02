module Bencode

export bencode

bencode(s::AbstractString) = string(length(s)) * ":" * s
bencode(n::Integer) = "i" * string(n) * "e"

end # module
