using Test
using Bencode

# Shorthand for frequently used methods
v(s) = Vector{UInt8}(s)
s(v) = String(copy(v))

@testset "bencode tests" begin
    @testset "bencode should return a Vector{UInt8}" begin
        @test typeof(bencode(Vector{UInt8}([0x00, 0x01]))) == Vector{UInt8}
        @test typeof(bencode("")) == Vector{UInt8}
        @test typeof(bencode(0)) == Vector{UInt8}
        @test typeof(bencode([])) == Vector{UInt8}
        @test typeof(bencode(Dict())) == Vector{UInt8}
    end

    @testset "bencode with Vector{UInt8} input" begin
        @test bencode(v([0x00, 0x01])) == v([0x32, 0x3a, 0x00, 0x01])
        @test bencode(v([])) == v([0x30, 0x3a])
    end

    @testset "bencode with String input" begin
        @test bencode("test") == v("4:test")
        @test bencode("") == v("0:")
        @test bencode("0123456789") == v("10:0123456789")
        @test bencode(":test:") == v("6::test:")
        @test bencode("α😈") == v("6:α😈")  # α is 2 bytes and 😈 is 4 bytes
    end

    @testset "bencode with Integer input" begin
        @test bencode(1) == v("i1e")
        @test bencode(123456) == v("i123456e")
        @test bencode(0) == v("i0e")
        @test bencode(-1234) == v("i-1234e")
    end

    @testset "bencode with List input" begin
        @test bencode(["hello", 1, "two"]) == v("l5:helloi1e3:twoe")
        @test bencode(1:3) == v("li1ei2ei3ee")
        @test bencode([]) == v("le")
    end

    @testset "bencode with Dict input" begin
        @test bencode(Dict()) == v("de")
        @test bencode(Dict("A" => 1, "B" => "two")) == v("d1:Ai1e1:B3:twoe")
        @test bencode(Dict("B" => "two", "A" => 1)) == v("d1:Ai1e1:B3:twoe")
        @test bencode(Dict(
            "string" => "Hello World",
            "integer" => 12345,
            "dict" => Dict(
                "key" => "value"
            ),
            "list" => [1, 2, "string", 3, Dict()]
        )) == v("d4:dictd3:key5:valuee7:integeri12345e4:listli1ei2e6:stringi3edee6:string11:Hello Worlde")
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
        @test bdecode("4:spam") == v("spam")
        @test bdecode("6:α😈") == v("α😈")
        @test bdecode("10:0123456789") == v("0123456789")
        @test bdecode("6::test:") == v(":test:")
    end

    @testset "bdecode list" begin
        @test bdecode("l5:helloi1e3:twoe") == [v("hello"), 1, v("two")]
        @test bdecode("le") == []
        @test bdecode("li4e1:2e"; bytestostr=true) == [4, "2"]
        @test bdecode("l4:spam4:eggse"; bytestostr=true, retnbytesread=true) == (["spam", "eggs"], 14)
    end
end
