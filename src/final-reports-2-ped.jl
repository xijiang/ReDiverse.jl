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
    fr2ped(dir, list, ped, allele)
---
# Description
Given a `list` of final report files, this function merge them into one file
`ped`.  Valid DNA strand designation can be any one in ["`Top`", "`AB`",
"`Forward`", "`Design`", "`Plus`"].

The function will analyse the first file in the list to see what designations
are available.  It throw an error if the specified `opt` is not available.

Finally, this function will plot GC-score in `tmp/gc-score.png`.  Hence package
`Plots` should be loaded before calling this function.  Dir `tmp` will be
created if not exists.

# Example
```
dir = "path-to-final-reports"
list = readdir(dir)
fr2ped(dir, list, "path-to/plink.ped", allele="AB")
```
"""
function fr2ped(dir::AbstractString,
                list,
                ped::AbstractString,
                allele::AbstractString = "AB")
    print_item("Analyse fields")
    nlc = x = y = 0
    open(joinpath(dir, list[1]), "r") do io
        # skip header
        for line in eachline(io)
            occursin("[Data]", line) && break
            occursin("Num SNPs", line) && ( nlc = parse(Int, split(line, '\t')[2]) )
        end

        # find allele columns
        header = split(readline(io), '\t')
        fields = split(readline(io)) # first record
        n = 0
        for f in fields
            n += 1
            println(n, '\t', header[n], '\t', f)
            if occursin("Allele1", header[n]) && split(header[n], ' ')[3] == allele
                x, y = n, n+1
            end
        end
        n = 1
        for _ in eachline(io)
            n += 1
        end
        n == nlc || error("Number of SNP available, $n is different from $nlc stated in the header")
    end
    x > 0 || error("Allele $allele designation not found in these final reports")
    print_msg("Genotypes in $allele format are in column $x and $y.\n" *
              "A total of $nlc loci found in this report")

    print_item("Merge the reports in '$dir' to '$ped'")
    function isvalid(c::Char)
        valid = Set(['A', 'C', 'G', 'T', 'B'])
        return (c in valid)
    end
    cnt = 0
    open(ped, "w") do io
        for report in list
            cnt += 1
            id = ""::String
            gt = fill('0', nlc*2)
            ilc = 0
            print("\r Dealing with $report, number $cnt")
            open(joinpath(dir, report), "r") do rp
                for line in eachline(rp) # skip header
                    occursin("SNP Name", line) && break
                end
                for line in eachline(rp)
                    ilc += 1
                    id, a, b = [split(line)[i] for i in [2, x, y]]
                    isvalid(a[1]) && (gt[ilc*2-1] = a[1])
                    isvalid(b[1]) && (gt[ilc * 2] = b[1])
                end
            end
            write(io, "dummy $id 0 0 0 -9 ", join(gt, ' '), '\n')
        end
    end
    print_done()
end
