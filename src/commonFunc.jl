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
    gt = ""::String
    valid = Set(['A', 'C', 'G', 'T'])
    
    open(file, "r") do io
        line = "pattern"
        for i in 1:5
            line = readline(io)
        end
        n_loci = parse(Int, split(line)[3])
        allele = fill('0', n_loci * 2)
        
        while line[1:3] ≠ "SNP" # the header may have 10 or 11 lines
            line = readline(io)
        end

        for i in 1:n_loci
            line = readline(io)
            id, a, b = [split(line)[k] for k in [2, 3, 4]]
            if a[1] in valid
                allele[i*2 - 1] = a[1]
            end
            if b[1] in valid
                allele[i*2] = b[1]
            end
        end
        gt = join(allele)
    end
    
    return id, gt
end

########################################
"""
    create_plink_ped(dir::String)

---

Given the `dir` name, this procecore merge all files in this directory into
`tmp/plink.ped`.  Make **sure** that the only final report files are in this
directory

# Plink ped format:
1. Family ID
2. Individual ID
3. Paternal ID
4. Maternal ID
5. Sex (1=male; 2=female; other=unknown)
6. Phenotype
7. Then (allele-1 allele-2) x number of loci
8. `*0, or zero` is for missing
"""
function create_plink_ped(dir::String)
    println("\nMerging genotypes in $dir to tmp/plink.ped")
    open("tmp/plink.ped", "w") do ped
        cnt = 0
        println("In directory $dir: ")
        for f in readdir(dir)
            ID, genotype = read_a_final_report(dir * f)
            cnt += 1
            print("\r    Dealing with file $f,  number ", cnt)
            write(ped, "dummy ", ID, " 0 0 0 -9 ")
            write(ped, join(split(genotype, ""), " "), '\n')
        end
    end
    println("\nMerged genotypes written to tmp/plink.ped\n")
end

########################################
"""
    ref_map_dict(fmap::String)

---

This create a dictionary of SNP -> [chr, bp] and return it

# Notes
1. chromosome
2. SNP-name
3. linkage distance, can be 0
4. base pari position
"""
function ref_map_dict(fmap)     # fmap: the physical map
    println("Creating a SNP dictionary with $fmap")
    snpdic = Dict()
    open(fmap, "r") do io
        while !eof(io)
            snp, chr, bp = split(readline(io))
            snpdic[snp] = [chr, bp]
        end
    end

    return snpdic
end

################################################################################
"""
    create_plink_map(dir::String, tmap::Dict)

---

Given a `infile` in final report and a SNP map dictionary, `tmap`, which is a super set of SNP
in the final report, this subroutine write the plink map to `oofile`.
"""
function create_plink_map(dir::String, tmap::Dict)
    println("Create tmp/plink.map with the fist file in $dir")

    open("tmp/plink.map", "w") do foo
        line = "duummy"
        open(dir*readdir(dir)[1], "r") do io
            while line[1:6] != "[Data]"
                line = readline(io)
            end
            _ = readline(io)
            while !eof(io)
                snp = split(readline(io))[1]
                chr, bp = tmap[snp]
                write(foo, chr, ' ', snp, " 0 ", bp, '\n')
            end
        end
    end
end

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

    create_plink_ped(dir)

    snpdic = ref_map_dict(ref)

    create_plink_map(dir, snpdic) # read the first file to create tmp/plink.map

    println()

    _ = read(`bin/plink --cow --recode --make-bed --ped tmp/plink.ped --map tmp/plink.map --out $name`, String);

    println()                   # to show time used more clearly
end

"""
    get_snp_set(file::String)
---
Read the SNP names in the map file, and return the SNP set.
"""
function get_snp_set(file::String, autosome_only::Bool = false)
    SNP = String[]
    open(file, "r") do io
        for line in eachline(io)
            snp, chr = [split(line)[i] for i in 1:2]
            if autosome_only
                is_autosome(String(chr)) && push!(SNP, String(snp))
            else
                push!(SNP, String(snp))
            end
        end
    end
    return Set(SNP)
end

################################################################################
# Print message functions
"""
    print_header(msg::String)
---
Given a message, this function print 4 lines
1. an empty line
2. repeat = 80 times
3. the message
4. emphsis of the letters
"""
function print_header(msg::String)
    println()
    println(repeat('=', 80))
    println(msg)
    println(repeat('^', length(msg)))
end

"""
    print_sst(msg::String)
---
If there are several parts in a function, this function print a title of bold
light blue.
"""
function print_sst(msg::String)
    println()
    printstyled(msg, '\n', bold=true, color=:light_blue)
    printstyled(repeat('=', length(msg)), '\n', color=:light_blue)
end

"""
    print_msg(msg::String)

---

This function print the msg as soft warning, i.e., the text color is of :light_magenta
"""
function print_msg(msg::String)
    println()
    printstyled(msg; color = :light_magenta)
    println("\n")
end

"""
    print_desc(msg::String)

---
This is to print some descriptions of results that are going to be showed below the
description.
This function print the message, a newline, and in color :yellow.
"""
function print_desc(msg::String)
    printstyled(msg, '\n'; color=:yellow)
end
