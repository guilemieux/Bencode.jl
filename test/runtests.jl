using Test
using Bencode

@testset "bencode tests" begin
    @testset "bencode should return a Vector{UInt8}" begin
        @test typeof(bencode(Vector{UInt8}([0x00, 0x01]))) == Vector{UInt8}
        @test typeof(bencode("")) == Vector{UInt8}
        @test typeof(bencode(0)) == Vector{UInt8}
        @test typeof(bencode([])) == Vector{UInt8}
        @test typeof(bencode(Dict())) == Vector{UInt8}
    end

    @testset "bencode with Vector{UInt8} input" begin
        @test bencode(Vector{UInt8}([0x00, 0x01])) == 
                Vector{UInt8}([0x32, 0x3a, 0x00, 0x01])
        @test bencode(Vector{UInt8}([])) == Vector{UInt8}([0x30, 0x3a])
    end

    @testset "bencode with String input" begin
        @test String(bencode("test")) == "4:test"
        @test String(bencode("")) == "0:"
        @test String(bencode("0123456789")) == "10:0123456789"
        @test String(bencode(":test:")) == "6::test:"
        @test String(bencode("α😈")) == "6:α😈"  # α is 2 bytes and 😈 is 4 bytes
    end

    @testset "bencode with Integer input" begin
        @test String(bencode(1)) == "i1e"
        @test String(bencode(123456)) == "i123456e"
        @test String(bencode(0)) == "i0e"
        @test String(bencode(-1234)) == "i-1234e"
    end

    @testset "bencode with List input" begin
        @test String(bencode(["hello", 1, "two"])) == "l5:helloi1e3:twoe"
        @test String(bencode(1:3)) == "li1ei2ei3ee"
        @test String(bencode([])) == "le"
    end

    @testset "bencode with Dict input" begin
        @test String(bencode(Dict())) == "de"
        @test String(bencode(Dict("A" => 1, "B" => "two"))) == "d1:Ai1e1:B3:twoe"
        @test String(bencode(Dict("B" => "two", "A" => 1))) == "d1:Ai1e1:B3:twoe"
        @test String(bencode(Dict(
            "string" => "Hello World",
            "integer" => 12345,
            "dict" => Dict(
                "key" => "value"
            ),
            "list" => [1, 2, "string", 3, Dict()]
        ))) == "d4:dictd3:key5:valuee7:integeri12345e4:listli1ei2e6:stringi3edee6:string11:Hello Worlde"
    end
end

@testset "bdecode tests" begin
    @testset "bdecode integer" begin
        @test bdecode("i0e") == 0
        @test bdecode("i-10e") == -10
        @test bdecode("i-0e") == 0
        @test bdecode("i1234e") == 1234
    end

    @testset "bdecode string" begin
        @test bdecode("4:spam") == Vector{UInt8}("spam")
        @test bdecode("6:α😈") == Vector{UInt8}("α😈")
        @test bdecode("10:0123456789") == Vector{UInt8}("0123456789")
        @test bdecode("6::test:") == Vector{UInt8}(":test:")
    end

    @testset "bdecode list" begin
        @test bdecode("l5:helloi1e3:twoe") == [Vector{UInt8}("hello"), 1, Vector{UInt8}("two")]
    end
end
