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
        fr2ped("$dir/$ver", list, "tmp/plink.ped", "Top")

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
    den = "data/genotypes/step-1.plk"
    isdir(den) || mkdir(den)

    for ver in ["d1", "d2", "d3", "v2", "v3", "v7"]
        title("Dealing with the Dutch data in $dir/$ver")
        list = readdir("$dir/$ver")
        fr2ped("$dir/$ver", list, "tmp/plink.ped", "Top")

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
    autosome_subset(list)
---
Take subset of `bed` in `data/genotypes/step-1.plk/{list}`.
The subset derived consists the shared SNP between `data/maps/target.snp` and `bed`.
"""
function autosome_subset(list)
    cd(work_dir)
    empty_dir("tmp")
    title("Extract autosomal subset")
    item("Create the target set")
    target = begin
        snps = String[]
        p = r"^[1-9][0-9]*$"
        for line in eachline("data/maps/updated/v3.map")
            snp, chr, bp = split(line)
            match(p, chr) === nothing || push!(snps, snp)
        end
        Set(snps)
    end
    done()

    sdir = "data/genotypes/step-1.plk"
    tdir = "data/genotypes/step-2.plk"
    isdir(tdir) || mkdir(tdir)
    for plk in list
        item("Dealing with '$sdir/$plk'")
        open("tmp/sub.snp", "w") do io
            for line in eachline("$sdir/$plk.bim")
                snp = split(line)[2]
                ∈(snp, target) && write(io, snp, '\n')
            end
        end
        bed_snp_subset("$sdir/$plk", "tmp/sub.snp", "$tdir/$plk")
        done()
    end
end

"""
    orgDustbin()
---
Only to store codes I wrote that might be used later.
"""
function recycle_bin()
    message("Codes were posted after return\n" *
            "Check the function codes if they can be reused.")
    return
end
