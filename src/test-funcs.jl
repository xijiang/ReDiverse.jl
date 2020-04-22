"""
    are_files_ready(dir::String, stem::Array{String, 1}, suf::String)

---

Function to test if an array of stem, expanded to `dir/stem.suf` exist or not.
When error happend, or the test is not passed, go back and make the missing
files ready.
"""
function are_files_ready(dir::String, stem::Array{String, 1}, suf::String)
    @testset "$suf" begin
        for s in stem
            @test isfile("$dir/$s.$suf")
        end
    end
end

"""
    is_autosome(chr::String)

---

Function to judge if a string is a number 1+, i.e., an autosome.
X, Y, MT and 0 will hence return false.
"""
function is_autosome(chr::String)
    re = r"[1-9]+[0-9]*"        # number started with 0 will be ignored
    return occursin(re, chr)
end
