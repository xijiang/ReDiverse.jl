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
    cd(work_dir)
    empty_dir("tmp")
    warning("Ignoring data in data/genotypes/german/ld")
    warning("Ignoring data in data/genotypes/german/md")

    dir = "data/genotypes/german"
    mdr = "data/maps/updated"
    den = "data/genotypes/step-1.plk"
    isdir(den) || mkdir(den)

    for ver in ["v2", "v3"]
        title("Dealing with the German data in $dir/$ver")
        list = readdir("$dir/$ver")
        fr2ped("$dir/$ver", list, "tmp/plink.ped") # default acquire "AB" results

        item("Creating a SNP dictionary with $mdr/$ver.map")
        dic = ref_map_dict("$mdr/$ver.map")
        done()

        item("Merge 'tmp/plink.ped' and 'tmp/plink.map' to '$den/german-$ver'")
        sample = list[1]
        create_plink_map("$dir/$ver/$sample", dic, "tmp/plink.map") 
        ped_n_map_to_bed("tmp/plink.ped", "tmp/plink.map", "$den/german-$ver")
        done()
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
    cd(work_dir)
    empty_dir("tmp")
    
    dir = "data/genotypes/dutch"
    mdr = "data/maps/updated"
    den = "data/genotypes/step-1.plk/dutch"
    isdir(den) || mkdir(den)

    for ver in ["d1", "d2", "d3", "v2", "v3", "v7"]
        title("Dealing with the Dutch data in $dir/$ver")
        list = readdir("$dir/$ver")
        fr2ped("$dir/$ver", list, "tmp/plink.ped")

        item("Creating a SNP dictionary with $mdr/$ver.map")
        dic = ref_map_dict("$mdr/$ver.map")
        done()

        item("Merge 'tmp/plink.ped' and 'tmp/plink.map' to '$den/dutch-$ver'")
        sample = list[1]
        create_plink_map("$dir/$ver/$sample", dic, "tmp/plink.map")
        ped_n_map_to_bed("tmp/plink.ped", "tmp/plink.map", "$den/dutch-$ver")
        done()
    end
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
    title("About Norwegian data")
    message("Waiting data in final report from Arne")
	#    src = ["illumina54k_v1.bed",
	#           "illumina54k_v1.bim",
	#           "illumina54k_v1.fam",
	#           "illumina777k.bed",
	#           "illumina777k.bim",
	#           "illumina777k.fam"]
	#    den = ["norge-v1.bed",
	#           "norge-v1.bim",
	#           "norge-v1.fam",
	#           "norge-v7.bed",
	#           "norge-v7.bim",
	#           "norge-v7.fam"]
	#    
	#    print_sst("Make soft links of Norwegian genotypes to genotypes/ori.plk")
	#    dir = pwd()
	#    cd("data/genotypes/ori.plk")
	#    for i in 1:length(src)
	#        a, b = [src den][i, :]
	#        isfile(b) && rm(b)
	#        symlink("../norge/$a", b)
	#    end
	#    cd(dir)
	#
	#    mkdir_tmp()
	#    plink_2_vcf("data/genotypes/norge/illumina54k_v2", "tmp/plink")
	#    vcf_2_plink("tmp/plink.vcf", "data/genotypes/ori.plk/norge-v2")
end
