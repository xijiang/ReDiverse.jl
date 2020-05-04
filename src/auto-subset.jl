"""
    auto_subset()
---
Take subset of bed in `data/genotypes/ori.plk/*`.
The subset consists the shared SNP between `data/maps/target.snp` and `bed`.
"""
function auto_subset()
    print_sst("Create the target set")
    tsnp = Set()
    snps = String[]
    for snp in eachline("data/maps/target.snp")
        push!(snps, snp)
    end
    tsnp = Set(snps)
    print_done()

    plks = ["dutch-d1", "dutch-d2", "dutch-d3", "dutch-v2", "dutch-v3",
            "dutch-v7", "german-v2", "german-v3", "norge-v1", "norge-v2",
            "norge-v7"]
    sdir = "data/genotypes/ori.plk"
    tdir = "data/genotypes/auto.plk"
    isdir(tdir) || mkdir(tdir)
    isdir("tmp") || mkdir("tmp")

    print_sst("Creating autosomal subset")
    for plk in plks
        print_item("Dealing with $sdir/$plk")
        open("tmp/sub.snp", "w") do io
            for line in eachline("$sdir/$plk.bim")
                snp = split(line)[2]
                if snp in tsnp
                    write(io, snp, '\n')
                end
            end
        end
        extract_bed_subset("$sdir/$plk", "tmp/sub.snp", "$tdir/$plk")
        print_done()
    end
end

"""
    update_norge_map()
---
Norwegian data came in plink format.
Previously, a subset was extracted with its original map.
This is to update the map according to v3.
"""
function update_norge_map()
    print_sst("Update maps in Norwegian data")
    norge = ["norge-v1", "norge-v2", "norge-v7"]
    sdir = "data/genotypes/auto.plk"
    
    print_item("Prepare files")
    for file in readdir("tmp")
        rm("tmp/$file", force=true)
    end
    for file in readdir(sdir)
        SubString(file, 1:5) == "norge" && mv("$sdir/$file", "tmp/$file", force=true)
    end
    print_done()

    print_item("Read dictionary")
    dic = ref_map_dict("data/maps/updated/v3.map")
    print_done()
    
    for pf in norge
        print_item("Dealing with $pf")
        plink_2_map_n_ped("tmp/$pf", "tmp/plink")
        open("tmp/new.map", "w") do io
            for line in eachline("tmp/plink.map")
                chr, snp, lnk, bp = split(line)
                write(io, dic[snp][1], '\t', snp, '\t', lnk, '\t', dic[snp][2], '\n')
            end
        end
        make_ped_n_map_to_bed("tmp/plink.ped", "tmp/new.map", "$sdir/$pf")
        print_done()
    end
end
