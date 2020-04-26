# This was done on: Sat 18 Apr 2020 12:44:28 PM CEST
# by Xijiang Yu

"""
    orgGermanGT()
---
This is to manipulate the German genotype data, which were received on Apr. 04, 2020.
The data consist four platfomrs:
1. LD:  12 ID, ignored
2. MD:   5 ID, ignored, these are actually of platform v3, with a lot missings
3. V2:  70 ID, takes 73+ seconds to finish, will find a better way later.
4. V3: 733 ID, took 765s !!! too bad

# ToDo:
* A faster C++ version/improved Julia version, I/O adoped here is too slow
* Errror check need to be included
"""
function orgGermanGT()
    println("Ignoring data in data/genotypes/german/ld\n")
    println("Ignoring data in data/genotypes/german/md\n")

    dir = "data/genotypes/german/"
    mdr = "data/maps/"
    den = "data/plink/german-"

    println("Dealing with the data with platform 50k v2")
    @time merge_to_plink_bed(dir*"v2/", mdr*"50kv2.map", den*"v2")

    println("Dealing with the data with platform 50k v3")
    @time merge_to_plink_bed(dir*"v3/", mdr*"50kv3.map", den*"v3")
end

"""
    orgDutchGT()
---
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
    dir = "data/genotypes/dutch/"
    mdr = "data/maps/"
    den = "data/plink/dutch-"

    println("Dutch data, platform 50kv2")
    @time merge_to_plink_bed(dir*"54609/", mdr*"50kv2.map", den*"v2")

    println("Dutch data, platform 50kv3")
    @time merge_to_plink_bed(dir*"50kv3/", mdr*"50kv3.map", den*"v3")

    println("Dutch data, platform 777k")
    @time merge_to_plink_bed(dir*"777k/", mdr*"777k.map", den*"777k")

    mdr = "data/maps/dutch-ld/"
    println("Datch data, platform 10690")
    @time merge_to_plink_bed(dir*"10690/", mdr*"10690.map", den*"10690")

    println("Datch data, platform 10993")
    @time merge_to_plink_bed(dir*"10993/", mdr*"10993.map", den*"10993")

    println("Datch data, platform 11483")
    @time merge_to_plink_bed(dir*"11483/", mdr*"11483.map", den*"11483")
end


"""
    orgNorgeGT()
---
This is to mange Norwegian genotype data. Since the data were already in plink format, I just make
some soft links to `data/plink`
"""
function orgNorgeGT()
    cdir = pwd()

    src = ["illumina54k_v1.bed",
           "illumina54k_v1.bim",
           "illumina54k_v1.fam",
           "illumina54k_v2.bed",
           "illumina54k_v2.bim",
           "illumina54k_v2.fam",
           "illumina777k.bed",
           "illumina777k.bim",
           "illumina777k.fam"]
    den = ["norge-v1.bed",
           "norge-v1.bim",
           "norge-v1.fam",
           "norge-v2.bed",
           "norge-v2.bim",
           "norge-v2.fam",
           "norge-777k.bed",
           "norge-777k.bim",
           "norge-777k.fam"]
    
    for i in 1:length(src)
        a, b = [src den][i, :]
        run(`ln -s $cdir/data/genotypes/norge/$a data/plink/$b`)
    end
end
