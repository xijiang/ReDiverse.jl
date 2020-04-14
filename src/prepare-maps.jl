################################################################################
"""
    prepare_maps()

---

# ToDo
This is to prepare various maps:
1. [x] Illumina cow 50k v1
2. [x] Illumina cow 50k v2
3. [x] Illumina cow 50k v3
4. [x] Illumina cow 777k
5. A dutch map

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
    println("Extract Name, Chr, Mapinfo columns from the Illumina 777k mnft")
    ifile, ofile = ["data/maps/illumina/hd-mnft.csv", "data/maps/777k.map"]
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

    println("Extract Name, Chr, Mapinfo columns from the Illumina 50k v1")
    ifile, ofile = ["data/maps/illumina/cow.50k.v1.tsv", "data/maps/50kv1.map"]
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
    
    println("Extract Name, Chr, Mapinfo columns from the Illumina 50k v2")
    ifile, ofile = ["data/maps/illumina/cow.50k.v2.tsv", "data/maps/50kv2.map"]
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
    
    println("Extract Name, Chr, Mapinfo columns from the Illumina 50k v3")
    ifile, ofile = ["data/maps/illumina/BovineSNP50_v3_A2.csv", "data/maps/50kv3.map"]
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
end
