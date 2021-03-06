module Bencode

export bencode, bdecode

function bencode(b::Vector{UInt8})::Vector{UInt8}
    blen = length(b)
    blenbytestring = Vector{UInt8}(string(blen))
    [blenbytestring; UInt8(':'); b]
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
        [UInt8('l'); listcontent; UInt8('e')]
    end
end

function bencode(d::Dict)::Vector{UInt8}
    if isempty(d)
        return Vector{UInt8}("de")
    else
        ks = collect(keys(d))
        keyisless = (a, b) -> isless(string(a), string(b))
        sortedkeys = sort(ks, lt=keyisless)
        encodekeyvalue(key) = [bencode(key); bencode(d[key])]
        dictcontent = mapreduce(encodekeyvalue, vcat, sortedkeys)
        [UInt8('d'); dictcontent; UInt8('e')]
    end
end

function bdecode(s::AbstractString; bytestostr::Bool=true, retnbytesread::Bool=false)
    bdecode(Vector{UInt8}(s); bytestostr=bytestostr, retnbytesread=retnbytesread)
end


function bdecode(data::AbstractVector{UInt8}; bytestostr::Bool=true, retnbytesread::Bool=false)
    val, nread = if isdigit(Char(data[1]))
        bytestostr ? bdecodestr(data) : bdecodebytes(data)
    elseif Char(data[1]) == 'i'
        bdecodeint(data)
    elseif Char(data[1]) == 'l'
        bdecodelist(data, bytestostr)
    elseif Char(data[1]) == 'd'
        bdecodedict(data, bytestostr)
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

function bdecodestr(data::AbstractVector{UInt8})::Tuple{String, Int}
    b, nread = bdecodebytes(data)
    String(copy(b)), nread
end

function bdecodelist(data::AbstractVector{UInt8}, bytestostr::Bool)::Tuple{Vector, Int}
    list = []
    totalread = 1
    data = data[2:end]
    while Char(data[1]) != 'e'
        element, nread = bdecode(data; bytestostr=bytestostr, retnbytesread=true)
        push!(list, element)
        totalread += nread
        data =  data[nread + 1:end]
    end
    list, totalread + 1
end

function bdecodedict(data::AbstractVector{UInt8}, bytestostr::Bool)::Tuple{Dict, Int}
    dict = Dict()
    totalread = 1
    data = data[2:end]
    while Char(data[1]) != 'e'
        key, nreadkey = bdecode(data;
                bytestostr=true, retnbytesread=true) # bytes are not allowed in keys
        data = data[nreadkey + 1:end]
        val, nreadval = bdecode(data; bytestostr=bytestostr, retnbytesread=true)
        dict[key] = val
        data = data[nreadval + 1:end]
        totalread += nreadkey + nreadval
    end
    dict, totalread + 1
end

end # module
