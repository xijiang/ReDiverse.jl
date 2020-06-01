"""
    platform_check_with_freq()
---
- Calculate frequencies
- Calculate correlation matrix of the 11 platforms
"""
function platform_check_with_freq()
    platforms = ["dutch-d1",
                 "dutch-d2",
                 "dutch-d3",
                 "dutch-v2",
                 "dutch-v3",
                 "dutch-v7",
                 "german-v2",
                 "german-v3",
                 "norge-v1",
                 "norge-v2",
                 "norge-v7"]
    title("Correlation between 11 platforms")
    # do_all_shared_alleles_have_the_same_alternatives(platforms)

    subtitle("Using raw data")
    # raw_frq(platforms)

    subtitle("Using imputed data")
    imp_frq(platforms)
end

"""
    function imp_frq(platforms)
---
Split country data on ID of different platforms.  Then calculate new frequencies,
and new correlation like with their raw genotypes.
"""

function imp_frq(platforms)
    raw = joinpath(work_dir, "data/genotypes/step-5.plk")
    fra = joinpath(work_dir, "data/genotypes/step-8.plk")
    til = joinpath(work_dir, "notebooks/frq")
    tmp = joinpath(work_dir, "tmp")
    empty_dir(tmp)
    countries = ["dutch", "german", "norge"]

    item("Merge 3-country data")
    open(joinpath(tmp, "country.lst"), "w") do io
        for country in countries
            write(io, "$fra/$country\n")
        end
    end
    merge_beds(joinpath(tmp, "country.lst"),
               joinpath(tmp, "all")
               )
    done()
    
    item("Extract all ID from imputed and QC-ed country data")
    ID = begin
        fam = CSV.read(joinpath(tmp, "all.fam"), header = [:a, :id, :b, :c, :d, :c])
        Set(fam.id)
    end
    done()
    
    item("Platform specific frequencies")
    for pf in platforms
        id = begin
            fam = CSV.read(joinpath(raw, "$pf.fam"), header = [:a, :id, :b, :c, :d, :c])
            Set(fam.id)
        end
        open(joinpath(tmp, "keep.id"), "w") do io
            for i in id
                write(io, "0 $i\n")
            end
        end
        plink_keep_id(joinpath(tmp, "all"),
                      joinpath(tmp, "keep.id"),
                      joinpath(tmp, "sub"))
        allele_maf_stats(joinpath(tmp, "sub"),
                         joinpath(tmp, pf))
    end
    done()

    item("Correlation of frequencies")
    freq = begin
        DF = Any[]
        for pf in platforms
            df = CSV.read(joinpath(tmp, "$pf.frq"), delim = ' ', ignorerepeated = true)
            push!(DF, select(df, :SNP, :MAF))
        end
        innerjoin(DF..., on = :SNP, makeunique = true)
    end
    corrs = DataFrame(cor(Matrix(select(freq, r"MAF"))))
    names = ["SNP", "dd1", "dd2", "dd3", "dv2", "dv3", "dv7", "gv2", "gv3", "nv1", "nv2", "nv7"]
    rename!(freq, names)
    CSV.write(joinpath(til, "imp-frq.csv"), freq)
    rename!(corrs, names[2:end])
    CSV.write(joinpath(til, "imp-cor.csv"), corrs)
    done()
end

"""
    raw_frq(fra, platforms, out)
---
Calculate platform specific allele frequencies.  Then compare them on shared loci.
Calculate before and after imputation.
"""
function raw_frq(platforms)
    item("Platform specific allele frequencies")
    cd(work_dir)
    fra = joinpath(work_dir, "data/genotypes/step-5.plk")
    tmp = joinpath(work_dir, "tmp")
    empty_dir(tmp)
    for pf in platforms
        allele_maf_stats(joinpath(fra, pf), joinpath(tmp, pf))
    end
    done()

    item("Calculate correlation matrix of the 11 platforms")
    til = joinpath(work_dir, "notebooks/frq")
    isdir(til) || mkdir(til)
    
    shrfreq = begin
        DF = Any[]
        for pf in platforms
            df = CSV.read(joinpath(tmp, "$pf.frq"), delim = ' ', ignorerepeated = true)
            push!(DF, select(df, :SNP, r"MAF"))
        end
        innerjoin(DF..., on = :SNP, makeunique = true)
    end                         # frequencies of shared SNP
    pfcor = DataFrame(cor(Matrix(select(shrfreq, r"MAF"))))
    
    names = ["SNP", "dd1", "dd2", "dd3", "dv2", "dv3", "dv7", "gv2", "gv3", "nv1", "nv2", "nv7"]
    rename!(shrfreq, names)
    CSV.write(joinpath(til, "raw-frq.csv"), shrfreq)
    
    rename!(pfcor, names[2:end])
    CSV.write(joinpath(til, "raw-cor.csv"), pfcor)
    done()
end

"""
    do_all_shared_alleles_have_the_same_alternatives(platforms)
---
This function was originally to swap alleles, as order of the alternatives
affects the genotype coding.  But `plink` calculates MAF.  So, swapping the
alternative alleles won't affect the MAF.  The swapping was not successful in
the first place.  I took the apportunity to check if all platforms are using
`Top` results.
"""
function do_all_shared_alleles_have_the_same_alternatives(platforms)
    subtitle("Using raw shared SNP")
    item("Check if they are all of Top results")
    fra = joinpath(work_dir, "data/genotypes/step-5.plk")
    
    names = ["CHR", "SNP", "Gap", "BP", "A", "B"]
    message("Shared loci and their alternative alleles")
    snpmap = begin
        df = Any[]
        for pf in platforms
            dd = CSV.read(joinpath(fra, "$pf.bim"), header = names)
            select!(dd, [:SNP, :A, :B])
            push!(df, dd)
        end
        innerjoin(df..., on = :SNP, makeunique = true)
    end
    # To write the SNP for genotype subset.
    # CSV.write(joinpath(tmp, "keep.snp"),
    #           select(snpmap, :SNP),
    #           writeheader = false)
    # 
    # bed_snp_subset(joinpath(fra, platforms[1]),
    #                joinpath(tmp, "keep.snp"),
    #                joinpath(tmp, platforms[1])
    #                )
    
    message("The rest platforms, need some swapping")
    ref = Matrix(select(snpmap, [:A, :B]))
    i = 1
    for pf in platforms[2:end]  # Not successful
        tst = Matrix(select(snpmap, ["A_$i", "B_$i"]))
        i += 1
        same = true
        for k in 1:size(ref)[1]
            if ref[k, 1] == tst[k, 1]
                if ref[k, 2] ≠ tst[k, 2]
                    same = false
                end
            else
                if ref[k, 1] ≠ tst[k, 2] || ref[k, 2] ≠ tst[k, 1]
                    same = false
                end
            end
        end
        if !same
            printly("Platform ", platforms[i], " is different.")
        end
    end
    done()
end
