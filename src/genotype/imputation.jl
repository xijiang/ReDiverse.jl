function update_german_id()
    item("Update German ID")
    dic = Dict()
    for line in eachline(joinpath(work_dir, "data/pedigree/german.ref"))
        a, b = split(line)
        dic[a] = b
    end
    til = joinpath(work_dir, "data/genotypes/step-6.plk/german.fam")
    fra = joinpath(work_dir, "tmp/tt")
    mv(til, fra, force=true)
    open(til, "w") do io
        for line in eachline(fra)
            a, b, c, d, e, f = split(line)
            write(io, "$a ", dic[b], " $c $d $e $f\n")
        end
    end
end

"""
    merge_by_country(country, platform_list)
---
Merge the platforms by country.
"""
function merge_by_country(country::AbstractString, list)
    cd(work_dir)
    tmp = joinpath(work_dir, "tmp")
    empty_dir(tmp)
    fra = "data/genotypes/step-5.plk"
    dto = "data/genotypes/step-6.plk"
    ref = joinpath(work_dir, "data/maps/ref.allele")
    lst = joinpath(tmp, "merge.lst")
    isdir(dto) || mkdir(dto)

    item("Merge $country data")
    open("tmp/merge.lst", "w") do io
        for l in list
            write(io, "$fra/$country-$l\n")
        end
    end

    _ = read(`plink --cow
                    --merge-list "tmp/merge.lst"
                    --reference-allele $ref
                    --make-bed
                    --out $dto/$country`,
             String)
    #merge_beds("tmp/merge.lst", "$dto/$country")
    done()
end

"""
    imputation_with_beagle(countries)
---
1. Convert `bed` to `vcf`
2. Impute with `beagle.jar`
3. Convert back them to `bed`
"""
function imputation_with_beagle()
    cd(work_dir)
    fra = joinpath(work_dir, "data/genotypes/step-6.plk")
    dto = joinpath(work_dir, "data/genotypes/step-7.plk")
    tmp = joinpath(work_dir, "tmp")
    ref = joinpath(work_dir, "data/maps/ref.allele")
    isdir(dto) || mkdir(dto)
    empty_dir(tmp)
    countries = ["dutch", "german", "norge", "two"]

    title("Impute with beagle.jar")
    for country in countries
        item("Impute $country data")
        plink_2_vcf("$fra/$country", "tmp/miss")
        _ = read(`java -jar $beagle
                        gt=tmp/miss.vcf
                        ne=100
                        out=tmp/imp`,
                 String)
        _ = read(`plink --cow
			--vcf $tmp/imp.vcf.gz
                        --reference-allele $ref
			--const-fid
                        --make-bed
			--out $dto/$country`,
                 String)
        done()
    end
end

"""
    merge_dg()
---
Merge Dutch and German data together for imputation, as they are connected.
"""
function merge_dg()
    cd(work_dir)
    fra = joinpath(work_dir, "data/genotypes/step-6.plk")
    tmp = joinpath(work_dir, "tmp")
    ref = joinpath(work_dir, "data/maps/ref.allele")
    empty_dir(tmp)

    title("Merge dutch and german data")
    lst = joinpath(tmp, "list")
    write(lst,
          joinpath(fra, "dutch"), '\n',
          joinpath(fra, "german"), '\n')
    out = joinpath(fra, "two")
    _ = read(`plink --cow
                    --merge-list $lst
                    --reference-allele $ref
                    --make-bed
                    --out $out`,
             String)
    done()
end

"""
    rm_country_specific_snp()
---
The final step for `G` calculation. After imputation, remove country specific SNP
to calculate cross-country `G` matrix.
"""
function rm_country_specific_snp()
    tmp = joinpath(work_dir, "tmp")
    fra = joinpath(work_dir, "data/genotypes/step-7.plk")
    til = joinpath(work_dir, "data/genotypes/step-8.plk")
    ref = joinpath(work_dir, "data/maps/ref.allele")
    isdir(til) || mkdir(til)
    lst = joinpath(tmp, "snp.list")
    empty_dir(tmp)

    function snp_set(bim)
        snp = AbstractString[]
        for line in eachline(bim)
            push!(snp, split(line)[2])
        end
        return Set(snp)
    end
    
    title("Remove country specific SNP")
    item("Create shared SNP list")
    sd = snp_set(joinpath(fra, "dutch.bim"))
    sg = snp_set(joinpath(fra, "german.bim"))
    sn = snp_set(joinpath(fra, "norge.bim"))
    ss = intersect(sd, sg, sn)

    open(lst, "w") do io
        for snp in ss
            write(io, snp, '\n')
        end
    end
    for country in ["dutch", "german", "norge", "two"]
        # bed_snp_subset(joinpath(fra, country),
        #                lst,
        #                joinpath(til, country)
        #                )
        src = joinpath(fra, country)
        out = joinpath(til, country)
        _ = read(`plink --cow
                        --bfile $src
                        --extract $lst
                        --reference-allele $ref
                        --make-bed
                        --out $out`,
                 String)
    end
end
