##################################################
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
    open("tmp/plink.map", "w") do foo
        line = "duummy"
        file = readdir(dir)[1]
        open("$dir/$file", "r") do io
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

"""
    mkdir_tmp(dir::AbstractString = "tmp")
---
- If not exists, make it. 
- If exists, clean all files and folders in it.
"""
function mkdir_tmp(dir::AbstractString = "tmp")
    isdir(dir) && rm(dir, force=true, recursive=true)
    mkdir(dir)
end

"""
Create SNP Set from a bim file
"""
function get_bim_snp_set(bim::AbstractString)
    ssnp = Set()
    vsnp = String[]
    for line in eachline(bim)
        push!(vsnp, split(line)[2])
    end
    ssnp = Set(vsnp)
    return ssnp
end

#=
Not going to use any more

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
=#
