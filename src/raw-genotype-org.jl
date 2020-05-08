################################################################################
"""
    merge_to_plink_ped(dir::String, ref::String, name::String)
---
# Introduction
This is a simple covertion program from Illumina final report to plink bed.
I simply put the pa, ma ID and sex as `0`.
No phenotype is provided, hence `-9` for the phenotype column.
I put a default family name as `dummy`.

# Arguments
- dir: where holds the final report files (and only)
- ref: the reference physical map file name
- name: results will be put to data/plink/name.*

# C++ codes
I also wrote a C++ program, fr2ped.cpp, which uses only a tiny fraction of time
used by this Julia program.

# Note
If all alleles are missing on one locus, `plink` will report a triallele warning.
"""
function merge_to_plink_bed(dir::String, ref::String, name::String)
    isdir("tmp") || mkdir("tmp")

    print_item("Merge files in $dir to tmp/plink.ped")
    create_plink_ped(dir)
    print_done()

    print_item("Creating a SNP dictionary with $ref")
    snpdic = ref_map_dict(ref)
    print_done()

    print_item("Create tmp/plink.map with the fist file in $dir")
    create_plink_map(dir, snpdic) # read the first file to create tmp/plink.map
    print_done()

    print_item("Merge ped and map to $name.bed")
    make_ped_n_map_to_bed("tmp/plink.ped", "tmp/plink.map", name)
    print_done()
end

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
    print_msg("Ignoring data in data/genotypes/german/ld")
    print_msg("Ignoring data in data/genotypes/german/md")

    dir = "data/genotypes/german"
    mdr = "data/maps/updated"
    den = "data/genotypes/ori.plk"
    isdir(den) || mkdir(den)
    den *= "/german"

    for ver in ["v2", "v3"]
        print_sst("Dealing with the German data in $dir/$ver")
        list = readdir("$dir/ver")
        fr2ped(dir, list, "tmp/plink.ped") # default acquire "AB" results

        print_item("Creating a SNP dictionary with $ref")
        snpdic = ref_map_dict(ref)
        print_done()
        merge_to_plink_bed("$dir/$ver", "$mdr/$ver.map", "$den-$ver")
    end
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
6. platform  777k,   10 ID
"""
function orgDutchGT()
    dir = "data/genotypes/dutch"
    mdr = "data/maps/updated"
    den = "data/genotypes/ori.plk/dutch"

    print_sst("Dutch data, platform 50kv2")
    @time merge_to_plink_bed("$dir/54609", "$mdr/v2.map", "$den-v2")

    print_sst("Dutch data, platform 50kv3")
    @time merge_to_plink_bed("$dir/50kv3", "$mdr/v3.map", "$den-v3")

    print_sst("Dutch data, platform 777k")
    @time merge_to_plink_bed("$dir/777k", "$mdr/v7.map", "$den-v7")

    print_sst("Datch data, platform 10690")
    @time merge_to_plink_bed("$dir/10690", "$mdr/d1.map", "$den-d1")

    print_sst("Datch data, platform 10993")
    @time merge_to_plink_bed("$dir/10993", "$mdr/d2.map", "$den-d2")

    print_sst("Datch data, platform 11483")
    @time merge_to_plink_bed("$dir/11483", "$mdr/d3.map", "$den-d3")
end


"""
    orgNorgeGT()
---
This is to mange Norwegian genotype data. Since the data were already in plink format, I just make
some soft links to `data/plink`

## Notes:
- Platform V2 needs special treatment
- It was converted to VCF format, and then converted to bed format again
  - to circumvent some HWE problem
- Need to find ou the reason later.
"""
function orgNorgeGT()
    src = ["illumina54k_v1.bed",
           "illumina54k_v1.bim",
           "illumina54k_v1.fam",
           "illumina777k.bed",
           "illumina777k.bim",
           "illumina777k.fam"]
    den = ["norge-v1.bed",
           "norge-v1.bim",
           "norge-v1.fam",
           "norge-v7.bed",
           "norge-v7.bim",
           "norge-v7.fam"]
    
    print_sst("Make soft links of Norwegian genotypes to genotypes/ori.plk")
    dir = pwd()
    cd("data/genotypes/ori.plk")
    for i in 1:length(src)
        a, b = [src den][i, :]
        isfile(b) && rm(b)
        symlink("../norge/$a", b)
    end
    cd(dir)

    mkdir_tmp()
    plink_2_vcf("data/genotypes/norge/illumina54k_v2", "tmp/plink")
    vcf_2_plink("tmp/plink.vcf", "data/genotypes/ori.plk/norge-v2")
end
