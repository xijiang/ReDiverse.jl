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
1. chromosome (1-22, X, Y or 0 if unplaced)
2. rs# or snp identifier
3. Genetic distance (morgans)
4. Base-pair position (bp units)
"""
function prepare_maps()
    tdir = "data/maps/origin"
    isdir(tdir) || mkdir(tdir)
    
    print_sst("Extract Name, Chr, Mapinfo columns from the Illumina 777k mnft")
    ifile, ofile = ["data/maps/illumina/hd-mnft.csv", "$tdir/v7.map"]
    buffer = readlines(ifile)
    nsnp = parse(Int, split(buffer[6], ',')[2])
    open(ofile, "w") do io      # this will overwrite the file anyway
        for i in 9:(8 + nsnp)
            line = buffer[i]
            name, chr, bp = [split(line, ',')[k] for k in [2, 10, 11]]
            write(io, join([name, chr, bp], '\t'))
            write(io, '\n')
        end
    end
    println("777k data written to $ofile\n")

    print_sst("Extract Name, Chr, Mapinfo columns from the Illumina 50k v1")
    ifile, ofile = ["data/maps/illumina/cow.50k.v1.tsv", "$tdir/v1.map"]
    buffer = readlines(ifile)
    open(ofile, "w") do io
        for i in 2:length(buffer)
            line = buffer[i]
            name, chr, bp = [split(line, '\t')[k] for k in [14, 12, 13]]
            write(io, join([name, chr, bp], '\t'))
            write(io, '\n')
        end
    end
    println("50k v1 data written to $ofile\n")
    
    print_sst("Extract Name, Chr, Mapinfo columns from the Illumina 50k v2")
    ifile, ofile = ["data/maps/illumina/cow.50k.v2.tsv", "$tdir/v2.map"]
    buffer = readlines(ifile)
    open(ofile, "w") do io
        for i in 2:length(buffer)
            line = buffer[i]
            name, chr, bp = [split(line, '\t')[k] for k in [14, 12, 13]]
            write(io, join([name, chr, bp], '\t'))
            write(io, '\n')
        end
    end
    println("50k v2 data written to $ofile\n")
    
    print_sst("Extract Name, Chr, Mapinfo columns from the Illumina 50k v3")
    ifile, ofile = ["data/maps/illumina/BovineSNP50_v3_A2.csv", "$tdir/v3.map"]
    buffer = readlines(ifile)
    nsnp = parse(Int, split(buffer[6], ',')[2])
    open(ofile, "w") do io
        for i in 9:(8 + nsnp)
            line = buffer[i]
            name, chr, bp = [split(line, ',')[k] for k in [2, 10, 11]]
            write(io, join([name, chr, bp], '\t'))
            write(io, '\n')
        end
    end
    println("50k v3 data written to $ofile\n")

    print_sst("Make soft links of 3 Dutch maps")
    dir = pwd()
    cd(tdir)
    symlink("../dutch-ld/10690.map", "d1.map")
    symlink("../dutch-ld/10993.map", "d2.map")
    symlink("../dutch-ld/11483.map", "d3.map")
    cd(dir)
end

"""
    update_maps()
---
This function read `v3.map` in `data/maps/origin` as dictionary. Then update the rest with this dictionary.
"""
function update_maps()
    sdir = "data/maps/origin"
    tdir = "data/maps/updated"
    isdir(tdir) || mkdir(tdir)

    print_sst("v3.map")
    dic = Dict()
    for line in eachline("$sdir/v3.map")
        snp, chr, bp = split(line)
        dic[snp] = [chr, bp]
    end
    cp("$sdir/v3.map", "$tdir/v3.map", force=true)

    for ver in ["d1", "d2", "d3", "v1", "v2", "v7"]
        print_sst("$ver.map")
        target = open("$tdir/$ver.map", "w")
        for line in eachline("$sdir/$ver.map")
            snp, chr, bp = split(line)
            if haskey(dic, snp)
                write(target, snp, ' ', dic[snp][1], ' ', dic[snp][2], '\n')
            else
                write(target, line, '\n')
            end
        end
    end
end
