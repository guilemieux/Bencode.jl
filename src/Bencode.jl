module Bencode

export bencode, bdecode

function bencode(b::Vector{UInt8})::Vector{UInt8}
    blen = length(b)
    blenbytestring = Vector{UInt8}(string(blen))
    vcat(blenbytestring, UInt8(':'), b)
end

function bencode(s::AbstractString)::Vector{UInt8}
    bencode(Vector{UInt8}(s))
end

function bencode(n::Integer)::Vector{UInt8}
    Vector{UInt8}("i" * string(n) * "e")
end

function bencode(l::AbstractVector)::Vector{UInt8}
    if isempty(l)
        Vector{UInt8}("le")
    else
        listcontent = mapreduce(bencode, vcat, l)
        vcat(UInt8('l'), listcontent, UInt8('e'))
    end
end

function bencode(d::Dict)::Vector{UInt8}
    if isempty(d)
        return Vector{UInt8}("de")
    else
        ks = collect(keys(d))
        keyisless = (a, b) -> isless(string(a), string(b))
        sortedkeys = sort(ks, lt=keyisless)
        encodekeyvalue(key) = vcat(bencode(key), bencode(d[key]))
        dictcontent = mapreduce(encodekeyvalue, vcat, sortedkeys)
        vcat(UInt8('d'), dictcontent, UInt8('e'))
    end
end

function bdecode(s::AbstractString)
    bdecode(Vector{UInt8}(s))
end


function bdecode(data::AbstractVector{UInt8}; retnbytesread::Bool=false)
    val, nread = nothing, nothing
    val, nread = if isdigit(Char(data[1]))
        bdecodebytes(data)
    elseif Char(data[1]) == 'i'
        bdecodeint(data)
    elseif Char(data[1]) == 'l'
        bdecodelist(data)
    end
    retnbytesread ? (val, nread) : val
end

function bdecodeint(data::AbstractVector{UInt8})::Tuple{Int, Int}
    indexofend = findfirst(isequal(UInt8('e')), data)
    n = parse(Int, String(data[2:indexofend - 1]))
    n, indexofend
end

function bdecodebytes(data::AbstractVector{UInt8})::Tuple{Vector{UInt8}, Int}
    colonindex = findfirst(isequal(UInt8(':')), data)
    strlen = parse(Int, String(copy(data[1:colonindex - 1])))
    str = data[colonindex + 1:colonindex + strlen]
    str, colonindex + strlen
end

function bdecodelist(data::AbstractVector{UInt8})::Tuple{Vector, Int}
    list = []
    totalread = 1
    data = data[2:end]
    while Char(data[1]) != 'e'
        element, nread = bdecode(data; retnbytesread=true)
        push!(list, element)
        totalread += nread
        data =  data[nread + 1:end]
    end
    list, totalread + 1
end

end # module
