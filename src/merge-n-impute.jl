"""
    merge_into_3_sets()
---
some documents here.
"""
function merge_into_3_sets()
    # two nested functions which will be used 3 times.
    function create_merge_list(fra, mlist)
        open("tmp/list", "w") do io
            for l in mlist
                write(io, "$fra/$l\n")
            end
        end
    end

    print_sst("Merge files in data/genotypes/flt-id.plk into 3 country sets")
    fra = "data/genotypes/flt-id.plk" # from dir
    dto = "data/genotypes/plink"      # to dir
    isdir(dto) || mkdir(dto)
    mkdir_tmp()

    print_item("Merge Dutch data")
    mlist = ["dutch-d1", "dutch-d2", "dutch-d3", "dutch-v2", "dutch-v3", "dutch-v7"]
    create_merge_list(fra, mlist)
    plink_merge("tmp/list", "tmp/dutch")
    print_done()

    print_item("Merge German data")
    mlist = ["german-v2", "german-v3"]
    create_merge_list(fra, mlist)
    plink_merge("tmp/list", "tmp/german")
    print_done()

    print_item("Merge Norge data")
    mlist = ["norge-v7", "norge-v1", "norge-v2"]
    create_merge_list(fra, mlist)
    plink_merge("tmp/list", "tmp/norge")
    print_done()

    print_item("Remove duplicates SNP")
    print_msg("I simply remove the duplicates here, since they passed all QC already")
    for country in ["dutch", "german", "norge"]
        _ = read(`$plink --cow
			 --bfile tmp/$country
			 --list-duplicate-vars
			 --out tmp/$country`,
                 String)
        _ = read(`$plink --cow
		         --bfile tmp/$country
		         --exclude tmp/$country.dupvar
		         --make-bed
		         --out tmp/x-$country`,
                 String)
    end

    print_item("Create a shared SNP list")
    sd = get_bim_snp_set("tmp/x-dutch.bim")
    sg = get_bim_snp_set("tmp/x-german.bim")
    sn = get_bim_snp_set("tmp/x-norge.bim")
    open("tmp/shared.snp", "w") do io
        for snp in intersect(sd, sg, sn)
            write(io, snp, '\n')
        end
    end

    print_item("Remove country specific SNP")
    for country in ["dutch", "german", "norge"]
        extract_bed_subset("tmp/x-$country", "tmp/shared.snp", "$dto/$country")
    end
end

"""
    beagle_impute()
---
Convert the plink files to VCF and then impute the missing with `beagle`
"""
function beagle_impute()
    countries = ["dutch", "german", "norge"]
    fra = "data/genotypes/plink"
    dto = "data/genotypes/imp.vcf"
    isdir(dto) || mkdir(dto)
    mkdir_tmp()
    print_sst("Impute data in $fra to $dto")
    for country in countries
        print_item(country)
        plink_2_vcf("$fra/$country", "tmp/$country")
        _ = read(`java -jar $beagle
                        gt=tmp/$country.vcf
                        ne=100
                        out=$dto/$country`,
                 String)
    end
end
