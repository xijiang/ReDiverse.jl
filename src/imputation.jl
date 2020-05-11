"""
    merge_by_country(country, platform_list)
---
Merge the platforms by country.
"""
function merge_by_country(country::AbstractString, list)
    cd(work_dir)
    empty_dir("tmp")
    fra = "data/genotypes/step-5.plk"
    dto = "data/genotypes/step-6.plk"
    isdir(dto) || mkdir(dto)

    item("Merge $country data")
    open("tmp/merge.lst", "w") do io
        for l in list
            write(io, "$fra/$country-$l\n")
        end
    end

    merge_beds("tmp/merge.lst", "$dto/$country")
    done()
end

"""
    imputation_with_beagle(countries)
---
1. Convert `bed` to `vcf`
2. Impute with `beagle.jar`
3. Convert back them to `bed`
"""
function imputation_with_beagle(countries)
    fra = "data/genotypes/step-6.plk"
    dto = "data/genotypes/step-7.plk"
    cd(work_dir)
    isdir(dto) || mkdir(dto)
    empty_dir("tmp")

    title("Impute with beagle.jar")
    for country in countries
        item("Impute $country data")
        plink_2_vcf("$fra/$country", "tmp/miss")
        _ = read(`java -jar $beagle
                        gt=tmp/miss.vcf
                        ne=100
                        out=tmp/imp`,
                 String)
        vcf_2_plink("tmp/imp.vcf.gz", "$dto/$country")
        done()
    end
end
