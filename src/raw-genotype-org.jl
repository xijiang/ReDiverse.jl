"""
    orgGermanGT()

This is to manipulate the German genotype data, which were received on Apr. 04, 2020.
The data consist four platfomrs:
1. LD:  12 ID, ignored
2. MD:   5 ID, ignored
3. V2:  70 ID, takes 73+ seconds to finish, will find a better way later.
4. V3: 733 ID, took 765s !!! too bad

# ToDo:
* A faster C++ version/improved Julia version, I/O adoped here is too slow
* Errror check need to be included
"""
function orgGermanGT()
    println("Ignoring data in data/genotypes/german/ld\n")
    println("Ignoring data in data/genotypes/german/md\n")

    platform = ["v2/", "v3/"]
    ofile = ["v2", "v3"]
    lmap = ["50kv2.map",  "50kv3.map"]
    
    dir = "data/genotypes/german/"
    mdr = "data/maps/"
    den = "data/genotypes/plink/german-"

    for i in 1:length(platform)
        gdr = dir * platform[i] # genotype directory
        prx = den * ofile[i]    # prifix of the plink files
        ref = mdr * lmap[i]     # map reference
        @time merge_to_plink_bed(gdr, ref, prx)
    end
end

#=
"""
    orgDutchGT()

This is to manipulae the Dutch data, which were received much earlier.
I am doing them with `Julia` procedure.

# Simple description
1. platform 10690, 1994 ID
2. platform 10993,  102 ID
3. platform 11483,  109 ID
4. platform    v2,  343 ID
5. platform    v3,   44 ID
"""
function orgDutchGT()
    # Note I define to add a '/', so that I don't have to use join([a, b], '/')
    platform = ["10690/", "10993/", "11483/", "50kv3/", "54609/"]
    ofile = ["10690", "10993", "11483", "v3", "v2"]
    dir = "data/genotypes/dutch/"
    den = "data/genotypes/ped/dutch-"
    
    for i in 1:5
        wdir = dir * platform[i]
        ped = den * ofile[i] * ".ped"
        @time merge_to_plink_bed(wdir, ped)
    end
end
=#
