using Test, ReDiverse

########################################
println("Compile the C++ codes")
cd("../src")
run(`make`)
run(`make mv`)

########################################
println("Test tools and data")

@testset "Tools" begin
    @test isfile("../bin/beagle.jar") || "beagle.jar not ready in ../bin"
    @test isfile("../bin/plink") || Error("Plink not ready in ../bin")
end

@testset "Genotypes" begin
    @test length(readdir("../data/genotypes/german/ld/")) == 11
    @test length(readdir("../data/genotypes/german/md/")) == 4
    @test length(readdir("../data/genotypes/german/v2/")) == 69
    @test length(readdir("../data/genotypes/german/v3/")) == 732
    @test length(readdir("../data/genotypes/dutch/10690/")) == 1994
    @test length(readdir("../data/genotypes/dutch/10993/")) == 102
    @test length(readdir("../data/genotypes/dutch/11483/")) == 109
    @test length(readdir("../data/genotypes/dutch/50kv3/")) == 44
    @test length(readdir("../data/genotypes/dutch/54609/")) == 343
    @test length(readdir("../data/genotypes/dutch/777k/")) == 10
    @test length(readdir("../data/genotypes/norge/")) == 9
end

@testset "Maps" begin
    for i in ["BovineSNP50_v3_A2.csv",
              "cow.50k.v1.tsv",
              "cow.50k.v2.tsv",
              "dutch.snp",
              "hd-mnft.csv"]
        @test isfile("../data/maps/illumina/" * i)
    end
end
