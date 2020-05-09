##################################################
"""
    ref_map_dict(fmap::String)
---
This create a dictionary of SNP -> [chr, bp] and return it

## Notes
The 3 columns in `fmap`:

1. chromosome
2. SNP-name
3. base pair position
"""
function ref_map_dict(fmap)     # fmap: the physical map
    snpdic = Dict()
    for line in eachline(fmap)
        snp, chr, bp = split(line)
        snpdic[snp] = [chr, bp]
    end

    return snpdic
end

################################################################################
"""
    create_plink_map(sample::String, dic::Dict, to::String)
---
Given a `sample` in final report format and a SNP -> [chr, bp] dictionary, `dic`,
which is a super set of SNP in the final report, this subroutine write a plink
map to `to`.
"""
function create_plink_map(sample::String, dic::Dict, to::String)
    open(to, "w") do foo
        open(sample, "r") do sp
            for line in eachline(sp)
                occursin("SNP Name", line) && break
            end
            for line in eachline(sp)
                snp = split(line)[1]
                chr, bp = dic[snp]
                write(foo, chr, ' ', snp, " 0 ", bp, '\n')
            end
        end
    end
end

##################################################
"""
    clean_all(; force=false)
---
Remove all intermediate data results.  Take care to call this function
"""
function clean_all(; force::Bool = false)
    list = ["data/maps/origin",
            "data/maps/updated",
            "data/genotypes/step-1.plk"]
    if force
        for l in list
            item("Removing '$l'")
            rm(l, force=true, recursive=true)
            done()
        end
    else
        title("Remove all intermediate results")
        message("Are you sure to remove all intermediate results?\n" *
                "If so, call `clean_all(force = true)\n" *
                "And these directories will be removed:")
        for l in list
            println("- $l")
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
