################################################################################
"""
    prepare_maps()
---
# Job descriptions
This is to prepare various maps:
1. [x] Illumina cow 50k v1
2. [x] Illumina cow 50k v2
3. [x] Illumina cow 50k v3
4. [x] Illumina cow 777k
5. [x] Three dutch map
   - 10690
   - 10993
   - 11483

This is suppose to run once for all. It also garantee the maps created meet the
requirements of downstream analysis, e.g., to merge with plink.ped.

# Note
The Illumina platfomr 50k v1-3 has more SNP than those in the final reports.
A subset should be made for that.

# Plink map file
1. chromosome (1-29, X, Y or 0 if unplaced)
2. rs# or snp identifier
3. Genetic distance (morgans)
4. Base-pair position (bp units)
"""
function prepare_maps()
    cd(work_dir)
    tdir = "data/maps/origin"
    isdir(tdir) || mkdir(tdir)

    title("Prepare 7 maps for downstream analsis")
    item("Extract Name, Chr, Mapinfo columns from the Illumina 777k mnft")
    open("$tdir/v7.map", "w") do v7
        open("data/maps/illumina/hd-mnft.csv", "r") do io
            nsnp = 0
            for line in eachline(io) # read total number of SNP
                if occursin("Loci Count", line)
                    nsnp = parse(Int, split(line, ',')[2])
                    break
                end
            end
            for line in eachline(io) # skip header
                occursin("IlmnID", line) && break
            end
            for _ in 1:nsnp
                line = readline(io)
                name, chr, bp = [split(line, ',')[k] for k in [2, 10, 11]]
                write(v7, join([name, chr, bp], '\t'), '\n')
            end
        end
    end
    done()

    item("Extract Name, Chr, Mapinfo columns from the Illumina 54k v1")
    open("$tdir/v1.map", "w") do v1
        open("data/maps/illumina/cow.50k.v1.tsv", "r") do io
            _ = readline(io)
            for line in eachline(io)
                name, chr, bp = [split(line, '\t')[k] for k in [14, 12, 13]]
                write(v1, join([name, chr, bp], '\t'), '\n')
            end
        end
    end
    done()
    
    item("Extract Name, Chr, Mapinfo columns from the Illumina 50k v2")
    open("$tdir/v2.map", "w") do v2
        open("data/maps/illumina/cow.50k.v2.tsv", "r") do io
            _ = readline(io)
            for line in eachline(io)
                name, chr, bp = [split(line, '\t')[k] for k in [14, 12, 13]]
                write(v2, join([name, chr, bp], '\t'), '\n')
            end
        end
    end
    done()
    
    item("Extract Name, Chr, Mapinfo columns from the Illumina 50k v3")
    open("$tdir/v3.map", "w") do v3
        open("data/maps/illumina/BovineSNP50_v3_A2.csv", "r") do io
            nsnp = 0
            for line in eachline(io) # read total number of SNP
                if occursin("Loci Count", line)
                    nsnp = parse(Int, split(line, ',')[2])
                    break
                end
            end
            for line in eachline(io) # skip header
                occursin("IlmnID", line) && break
            end
            for _ in 1:nsnp
                line = readline(io)
                name, chr, bp = [split(line, ',')[k] for k in [2, 10, 11]]
                write(v3, join([name, chr, bp], '\t'), '\n')
            end
        end
    end
    done()

    item("Make soft links of 3 Dutch maps")
    dir = pwd()
    cd(tdir)
    for file in ["d1", "d2", "d3"]
        isfile("$file.map") && rm("$file.map")
    end
    symlink("../dutch-ld/10690.map", "d1.map")
    symlink("../dutch-ld/10993.map", "d2.map")
    symlink("../dutch-ld/11483.map", "d3.map")
    cd(work_dir)
end

"""
    update_maps()
---
This function read `v3.map` in `data/maps/origin` as dictionary. Then update the rest with this dictionary.
"""
function update_maps()
    cd(work_dir)
    sdir = "data/maps/origin"
    tdir = "data/maps/updated"
    isdir(tdir) || mkdir(tdir)

    title("Update d1-3, v1, v2, and v7 with v3.map")
    item("v3.map")
    dic = Dict()
    for line in eachline("$sdir/v3.map")
        snp, chr, bp = split(line)
        dic[snp] = [chr, bp]
    end
    cp("$sdir/v3.map", "$tdir/v3.map", force=true)

    for ver in ["d1", "d2", "d3", "v1", "v2", "v7"]
        item("$ver.map")
        target = open("$tdir/$ver.map", "w")
        for line in eachline("$sdir/$ver.map")
            snp, chr, bp = split(line)
            if haskey(dic, snp)
                write(target, snp, ' ', dic[snp][1], ' ', dic[snp][2], '\n')
            else
                write(target, line, '\n')
            end
        end
        done()
    end
end
