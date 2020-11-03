module Bencode

export bencode

function bencode(s::AbstractString)
    b = Vector{UInt8}(s)
    blen = length(b)
    blenbytestring = Vector{UInt8}(string(blen))
    vcat(blenbytestring, UInt8(':'), b)
end

bencode(n::Integer) = Vector{UInt8}("i" * string(n) * "e")

function bencode(l::AbstractVector)
    if isempty(l)
        Vector{UInt8}("le")
    else
        listcontent = mapreduce(bencode, vcat, l)
        vcat(UInt8('l'), listcontent, UInt8('e'))
    end
end

bencode(d::Dict) = Vector{UInt8}(string(d))

end # module
