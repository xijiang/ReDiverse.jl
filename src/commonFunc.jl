################################################################################
"""
    read_3c_map_file(file::String)
---
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
---
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

    make_ped_n_map_to_bed("tmp/plink.ped", "tmp/plink.map", name)
    #=
    _ = read(`bin/plink --cow
                        --recode
                        --make-bed
                        --ped tmp/plink.ped
                        --map tmp/plink.map
                        --out $name`,
             String);
    =#                          # Just in case

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

"""
    create_map_dict(fsnp::String, fmap::String)
---
Given:
- fsnp: the file name of a list of SNP
- fmap: 3-column (snp chr bp) map file name

This function return a dictionary of {(snp::String, [chr::String, bp::String])}
"""
function create_map_dict(fsnp::String, fmap::String)
    ssnp = Set()
    open(fsnp, "r") do io
        vsnp = String[]
        for snp in eachline(io)
            push!(vsnp, snp)
        end
        ssnp = Set(vsnp)        # will be gone after this block
    end

    mdic = Dict()
    open(fmap, "r") do io
        for line in eachline(io)
            snp, chr, bp = [split(line)[i] for i in 1:3]
            if snp in ssnp
                mdic[String(snp)] = [String(chr), String(bp)]
            end
        end
    end
    return mdic
end

"""
    update_bed(sbed::String, mmap::String, ref::Dict)
---
# Description
Given:
1. sbed: the source plink file name, without {.bed,.bim...}
2. mmap: its snp map file (in my format (snp, chr, bp))
3. ref:  the super set of SNP, and map

This function:
1. extract subset `stem` according to `ref`
2. update the map
3. put the final results into `data/plkmax`
"""
function update_bed(sbed::String, mmap::String, ref::Dict)
    open("tmp/tmp.snp", "w") do foo
        open(mmap, "r") do io
            for line in eachline(io)
                snp = split(line)[1]
                if haskey(ref, snp)
                    write(foo, snp, '\n')
                end
            end
        end
    end                         # this is ugly, but safer

    println("Created SNP final list and its map")
    extract_bed_subset(sbed, "tmp/tmp.snp", "tmp/tmp")
    #=
    _ = read(`bin/plink --cow
                        --bfile $sbed
                        --extract tmp/tmp.snp
                        --recode
                        --out tmp/tmp`,
             String)
    =#
    println("Update the map according to Illumina 50k v3")
    open("tmp/new.map", "w") do foo
        open("tmp/tmp.map", "r") do io
            for line in eachline(io)
                ochr, snp, obp = [split(line)[i] for i in [1, 2, 4]]
                if haskey(ref, snp)
                    nchr, nbp = ref[snp]
                    write(foo, nchr, '\t', snp, "\t0\t", nbp, '\n')
                end
            end
        end
    end
    
    tdir="data/plkmax"          # the target dir
    tbed=basename(sbed)
    make_ped_n_map_to_bed("tmp/tmp.ped", "tmp/new.map", "$tdir/$tbed")
    #=
    _ = read(`bin/plink --cow
                        --map tmp/new.map
                        --ped tmp/tmp.ped
                        --make-bed
                        --out $tdir/$tbed`,
             String)
    =#
end

"""
    snp_gt_dict(vcf::AbstractString, snp::Set)
---
Given the `vcf` file name and a `snp` name set, this function create a dic
of Dict{AbstractString, Vector{Int}}.
"""
function snp_gt_dict(vcf::AbstractString, snp::Set)
    function myparse(tstr::AbstractString)
        t = -1
        if tstr[1] ≠ '.'
            t  = parse(Int, tstr[1])
            t += parse(Int, tstr[3])
        end
        return t
    end
    
    dic = Dict()
    open(vcf, "r") do io
        # skip header
        line = "##"
        while(line[2] == '#')
            line = readline(io)
        end
        while !eof(io)
            line = split(readline(io))
            if line[3] in snp
                gt = Vector{Int}
                gt = map(x->myparse(x), line[10:length(line)])
                dic[line[3]] = gt
            end
        end
    end
    return dic
end

#=
"""
    reverse_complement(seq::String)
---
Return the reverse and complement of sequence `seq`. It is supposed `seq` are all of upper case.
The dictionary is: "ACGT[]/NY" -> "TGCA][/NY". Otherwise, the character is not translated.
"""
function reverse_complement(seq::AbstractString)
    comp = Dict()
    str = "ACGT[]/NYRKSWMTGCA][/NYRKSWM"
    n = Int(length(str)/2)
    for i in 1:n
        comp[str[i]] = str[i+n]
    end
    return reverse(map(x -> comp[x], seq))
end
=#
