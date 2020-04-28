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
    #=
    function call_plink_merge(dto, country)
        _ = read(`plink --cow
                        --merge-list tmp/list
                        --make-bed
                        --out $dto/$country`,
                 String)
    end
    =#
    
    fra = "data/plkmax"         # from dir
    dto = "data/3-sets"         # to dir

    print_sst("Prepare directory")
    if isdir(dto)
        rm(dto, recursive = true, force = true)
        mkdir(dto)
    else
        mkdir(dto)
    end
    isdir("tmp") || mkdir("tmp")
    print_done()

    print_sst("Merge Dutch data")
    mlist = ["dutch-10690",
             "dutch-10993",
             "dutch-11483",
             "dutch-777k",
             "dutch-v2",
             "dutch-v3"]
    create_merge_list(fra, mlist)
    plink_merge("tmp/list", "$dto/dutch")
    # call_plink_merge(dto, "dutch")
    print_done()

    print_sst("Merge German data")
    mlist = ["german-v2",
             "german-v3"]
    create_merge_list(fra, mlist)
    plink_merge("tmp/list", "$dto/german")
    # call_plink_merge(dto, "german")
    print_done()

    print_sst("Merge Norge data")
    mlist = ["norge-777k",
             "norge-v1",
             "norge-v2"]
    create_merge_list(fra, mlist)
    plink_merge("tmp/list", "$dto/norge")
    # call_plink_merge(dto, "norge")
    print_done()
end

"""
    check_repeated_snp_list()
---
This function check the SNP in the 3 country sets, who have different SNP names,
but same chromsome and base pair position.
"""
function check_repeated_snp_list()
    println("The repeated SNP list")
    pair = Dict()               # Duplicated SNP and its duplicate
    ssnp = Set()                # set of all duplicated SNP
    open("data/maps/duplicated.snp", "r") do io
        vsnp = String[]         # vector
        for line in eachline(io)
            a, b = split(line)
            push!(vsnp, a)
            push!(vsnp, b)
            pair[a] = b
        end
        ssnp = Set(vsnp)
    end

    println("Compare genotypes")
    sdir = "data/3-sets"
    rm("tmp", recursive=true, force=true)
    mkdir("tmp")
    for country in ["dutch", "german", "norge"]
        print_sst(country)
        plink_2_vcf("$sdir/$country", "tmp/$country")
        dsnp = snp_gt_dict("tmp/$country.vcf", ssnp)
        # then check extracted genotypes
        for (a, b) in pair
            print_item("SNP pair:  $a <-> $b")
            next = false
            if !haskey(dsnp, a)
                print_msg("$country has no SNP $a")
                next = true
            end
            if !haskey(dsnp, b)
                print_msg("$country has no SNP $b")
                next = true
            end
            next && continue
            x = dsnp[a]
            y = dsnp[b]
            tt = length(x)
            ma = mb = cn = 0
            for i in 1:tt
                if x[i] == -1
                    ma += 1
                end
                if y[i] == -1
                    mb += 1
                else
                    if x[i] == y[i]
                        cn += 1
                    end
                end
            end
            println("Total: $tt;  ma: $ma;  mb: $mb;  Same: $cn")
        end
    end
end
