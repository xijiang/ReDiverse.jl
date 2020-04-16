################################################################################
"""
    read_3c_map_file(file::String)
This is to read a 3-column map files, to use with merge_final_report_2_plink_fam(lmap, ID)
funciton, to create a plink fam file. The file must has the first 3 column as:
1. SNP name
2. chromosome name
3. base pair position

It return a Dict() of [snp::String] -> [chr::String, bp::String]

# Example
    ```juliarepl
    julia> read_3c_map_file(file)
    ```
"""
function read_3c_map_file(file::String)
    tmap = Dict()
    snp = chr = bp = ""::String
    open(file, "r") do io
        while !eof(io)
            snp, chr, bp = split(readline(io))[1:3]
            tmap[snp] = [chr, bp]
        end
    end
    return tmap
end

################################################################################
"""
    read_a_final_report()

Given a file name of genotypes in Illumina final report format, this funciton
only reads ID name, and genotypes into a string.

# Example
    ```juliarepl
    julia> read_final_report("data/genotypes/german/ld/276000122071617_LD.txt")
    ID genotypes
    ```
"""
function read_a_final_report(file::String)
    id = ""::String
    genotypes = ""::String
    
    open(file, "r") do io
        line = "pattern"
        while line[1:6] ≠ "[Data]"
            line = readline(io)
        end
        _ = readline(io)        # skip header line below '[Data]'

        while !eof(io)
            line = strip(readline(io))
            if length(line) > 10 # 0 is enough to avoid an empty line
                id, a, b = [split(line)[i] for i in [2, 3, 4]]
                genotypes *= a
                genotypes *= b
            end
        end
    end
    
    return id, genotypes
end

################################################################################
"""
    create_map_for_a_final_report_group(infile::String, tmap::Dict, oofile::String)
---
Given a `infile` in final report and a SNP map dictionary, `tmap`, which is a super set of SNP
in the final report, this subroutine write the plink map to `oofile`.
"""
function create_map_for_a_final_report_group(infile::String, tmap::Dict, oofile::string)
    open(oofile, "w") do oo
        line = "duummy"
        open(file, "r") do ii
            while line[1:6] != "[Data]"
                line = readline(ii)
            end
            _ = readline(ii)
            while !eof(ii)
                snp = split(readline(ii))[1]
                chr, bp = tmap[snp]
                write(oo, chr, ' ', snp, " 0 ", bp, '\n')
            end
        end
    end
end

################################################################################
"""
    merge_to_plink_ped(ID::String, genotype::String)

---

# Introduction
This is a simple covertion program from Illumina final report to plink bed.
I simply put the pa, ma ID and sex as `0`.
No phenotype is provided, hence `-9` for the phenotype column.
I put a default family name as `dummy`.

# Notes
## Plink map:
1. chromosome
2. snp-name
3. linkage distance, can be 0
4. base pari position

## Plink ped:
1. Family ID
2. Individual ID
3. Paternal ID
4. Maternal ID
5. Sex (1=male; 2=female; other=unknown)
6. Phenotype
7. Then (allele-1 allele-2) x number of loci
8. `*0, or zero` is for missing

## C++ codes
I also wrote a C++ program, which uses only a tiny fraction of Julia program.
"""
function merge_to_plink_bed(dir::String, ref::String, prefix::String)
    println("\nDealing with $dir")
    isdir("tmp") || mkdir("tmp")

    open("tmp/tmp.ped", "w") do ped
        cnt = 0
        for f in readdir(dir)
            ID, genotype = read_a_final_report(dir * f)
            cnt += 1
            print("\rDealing with ID $dir$f,  number ", cnt)
            write(ped, join(["famDum", ID, "\t0\t0\t0\t-9"], '\t'))
            
            for allele in genotype
                write(ped, '\t', allele)
            end
            write(ped, '\n')
        end
    end
    println("\nMerged data written to tmp.ped")

    println("\nRead the reference physical map")
    psnp = Dict()
    open(ref, "r") do io
        while !eof(io)
            snp, chr, bp = split(readline(io))
            psnp[snp] = [chr, bp]
        end
    end
    
    println("Create a map from referernce in the order of the final report")
    foo = open("tmp/tmp.map", "w")
    open(dir*readdir(dir)[1], "r") do io
        line = "duuuummy"
        while line[1:6] ≠ "[Data]"
            line = readline(io)
        end
        _ = readline(io)
        while !eof(io)
            line = strip(readline(io))
            snp = split(line)[1]
            chr, bp = psnp[snp]
            write(foo, join([chr, snp, 0, bp], '\t'), '\n')
        end
    end
    close(foo)
end
