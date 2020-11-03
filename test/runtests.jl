using Test
using Bencode

@testset "bencode tests" begin
    @testset "bencode should return a Vector{UInt8}" begin
        @test typeof(bencode("")) == Vector{UInt8}
        @test typeof(bencode(0)) == Vector{UInt8}
        @test typeof(bencode([])) == Vector{UInt8}
        @test typeof(bencode(Dict())) == Vector{UInt8}
    end

    @testset "bencode with Integer input" begin
        @test String(bencode(1)) == "i1e"
        @test String(bencode(123456)) == "i123456e"
        @test String(bencode(0)) == "i0e"
        @test String(bencode(-1234)) == "i-1234e"
    end

    @testset "bencode with String input" begin
        @test String(bencode("test")) == "4:test"
        @test String(bencode("")) == "0:"
        @test String(bencode("0123456789")) == "10:0123456789"
        @test String(bencode(":test:")) == "6::test:"
        @test String(bencode("α😈")) == "6:α😈"  # α is 2 bytes and 😈 is 4 bytes
    end

    @testset "bencode with List input" begin
        @test String(bencode(["hello", 1, "two"])) == "l5:helloi1e3:twoe"
        @test String(bencode(1:3)) == "li1ei2ei3ee"
        @test String(bencode([])) == "le"
    end
end
