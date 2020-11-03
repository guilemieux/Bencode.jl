# Bencode.jl
Bencode encoder and decoder for Julia

## Installation
`Bencode.jl` can be installed from the Julia REPL using the following command:

```julia
julia> ]
pkg> add https://github.com/guilemieux/Bencode.jl
```

## Usage

```julia
using Bencode
```

### Encoding

```julia
data = Dict(
    "string" => "Hello World",
    "integer" => 12345,
    "dict" => Dict(
        "key" => "value"
    ),
    "list" => [1, 2, "string", 3, Dict()]
)

result = bencode(data)
```

#### Output

```julia
# TODO
```