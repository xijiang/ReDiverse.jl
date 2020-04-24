"""
    check_map_ver()
---
# Description

This function check if some non-autosomal loci on map other than 50k-v3 are on autosomes.
If so, these loci will be updated about their map location.

This is just to recover as many loci as possible to increase imputation results

# Steps
1. Read 50kv3 as dictionary of `dic` = SNP::String -> [chr::Int, bp::Int]
   - I only read the autosomal SNP here
2. Read other maps one by one
3. For each SNP, look up `dic` to see if the latter `chr` is not in 1:29
   - count these SNP
"""
function check_maps()
    maps = ["50kv1",
            "50kv2",
            "50kv3",
            "777k",
            "dutch-ld/10690",
            "dutch-ld/10993",
            "dutch-ld/11483"]
    dir = "data/maps"
    println("Test if all the map files are ready")
    are_files_ready(dir, maps, "map")
    print_msg("If some error happend, you should stop here and make the files ready")

    tmap = Dict()               # The target map, i.e., autosome SNP on 50k-v3
    ref = "50kv3"
    open("$dir/$ref.map", "r") do io
        while !eof(io)
            snp, chr, bp = split(readline(io))
            if is_autosome(String(chr))
                tmap[snp] = [parse(Int, chr), parse(Int, bp)]
            end
        end
    end
    println("Map 50k v3 has ", length(tmap), " autosomal SNP")

    print_desc("Below will count each map that are not 50kv3\n")
    print_desc("1. Total number of SNP\n")
    print_desc("2. number of SNP that are also in 50kv3\n")
    print_desc("3. of 2, number of autosomal SNP\n")
    print_desc("4. of 2, number of non-autosomal SNP\n")
    print_desc("5. of 2, has same chromosome number and bp position\n")
    @printf("%15s%6i.%6i.%6i.%6i.%6i.\n", "Map", 1, 2, 3, 4, 5)
    for mmp in maps
        if mmp == "50kv3"; continue; end
        file = "$dir/$mmp.map"

        a = b = c = d = e = 0
        open(file, "r") do io
            for line in eachline(io)
                a += 1          # total number
                snp, chr, bp = split(line)
                if haskey(tmap, snp)
                    b += 1      # included
                    if is_autosome(String(chr))
                        c += 1  # autosomal
                        x, y = tmap[snp]
                        if parse(Int, chr) == x && parse(Int, bp) == y
                            e += 1 # not changed across map version
                        end
                    else
                        d += 1  # not was even on an autosome
                    end
                end
            end
        end
        @printf("%15s%7i%7i%7i%7i%7i\n", mmp, a, b, c, d, e)
    end
end


"""
    check_maps_further()
---
This function is to summarize the number of final reserved loci on all platforms.
The reason for this is that the Norwegian data has no info from platform 50k-v3.
The can't be imputed from data of other countries.
Hence, the shared number, 49465 autosomal SNP, between v2 and v3 will be the target
imputation number.
SNP on other platforms that are not in these 49465 loci will be discarded.
"""
function check_maps_further()
    dir = "data/maps"
    v3 = get_snp_set("$dir/50kv3.map", true)
    v1 = get_snp_set("$dir/50kv1.map")
    v2 = get_snp_set("$dir/50kv2.map")
    v7 = get_snp_set("$dir/777k.map")
    tgt = intersect(v3, union(v1, v2, v7))
    open("data/maps/target.snp", "w") do io
        for snp in tgt
            write(io, snp, '\n')
        end
    end
    d1 = get_snp_set("$dir/dutch-ld/10690.map")
    d2 = get_snp_set("$dir/dutch-ld/10993.map")
    d3 = get_snp_set("$dir/dutch-ld/11483.map")
    print_desc("Below will print the target number of SNP, and shared numbers of SNP")
    @printf("%9s%9s%9s%9s%9s%9s%9s\n",
            "Target", "50k-V1", "50k-V2", "HD", "PF-10690", "PF-10993", "PF-11483")
    @printf("%9i%9i%9i%9i%9i%9i%9i\n",
            length(tgt),
            length(intersect(tgt, v1)),
            length(intersect(tgt, v2)),
            length(intersect(tgt, v7)),
            length(intersect(tgt, d1)),
            length(intersect(tgt, d2)),
            length(intersect(tgt, d3)))
end

"""
    plink_subset_max()
---
This is to
1. take the genotype subset from each plink file, according data/maps/target.snp
2. update the map according 50kv3.map

So that the data are ready for QC and imputation. The results from this procedure
are subject to another quality control. Hence, the number of SNP obtained here are
the upper limit. I will have a function `plink_subset_final`, to produce results
for imputation. This is very long and ugly function
"""
function plink_subset_max()
    mdir = "data/maps"          # the old maps
    pdir = "data/plink"         # where the collected genotypes are
    tdir = "data/plkmax" # holds plink files filtered and map updated.
    isdir(tdir) || mkdir(tdir)
    rm("tmp", recursive=true, force=true) # make the 
    mkdir("tmp")

    ##################################################
    print_sst("Create a target map dictionary")
    mtgt = create_map_dict("data/maps/target.snp", "data/maps/50kv3.map")
    println("Done")

    ##################################################
    print_sst("Dealing with Dutch data")
    pre = "dutch-"
    pair = Dict([("10690", "dutch-ld/10690"),
                 ("10993", "dutch-ld/10690"),
                 ("11483", "dutch-ld/11483"),
                 ("v2",    "50kv2"),
                 ("v3",    "50kv3"),
                 ("777k",  "777k")])
    for (g, m) in pair
        update_bed("$pdir/$pre$g", "$mdir/$m.map", mtgt)
    end
    println("Done")

    ##################################################
    print_sst("Dealing with German data")
    pre = "german-"
    pair = Dict([("v2", "50kv2"),
                 ("v3", "50kv3")])
    for (g, m) in pair
        update_bed("$pdir/$pre$g", "$mdir/$m.map", mtgt)
    end
    println("Done")

    ##################################################
    print_sst("Dealing with Norge data")
    pre = "norge-"
    pair = Dict([("v1",   "50kv1"),
                 ("v2",   "50kv2"),
                 ("777k", "777k")])
    for (g, m) in pair
        update_bed("$pdir/$pre$g", "$mdir/$m.map", mtgt)
    end
    println("Done")
end
