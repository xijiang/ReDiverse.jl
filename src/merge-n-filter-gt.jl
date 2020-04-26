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
    function call_plink_merge(dto, country)
        _ = read(`plink --cow
                        --merge-list tmp/list
                        --make-bed
                        --out $dto/$country`,
                 String)
    end
    
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
    call_plink_merge(dto, "dutch")
    print_done()

    print_sst("Merge German data")
    mlist = ["german-v2",
             "german-v3"]
    create_merge_list(fra, mlist)
    call_plink_merge(dto, "german")
    print_done()

    print_sst("Merge Norge data")
    mlist = ["norge-777k",
             "norge-v1",
             "norge-v2"]
    create_merge_list(fra, mlist)
    call_plink_merge(dto, "norge")
    print_done()
end

"""
    check_repeated_snp_list()
---
This function check the SNP in the 3 country sets, who have different SNP names,
but same chromsome and base pair position.
"""
function check_repeated_snp_list()
    print_sst("The repeated SNP list")
    dsnp = Dict()               # dictionary
    ssnp = Set()                # set of all SNP
    open("data/maps/duplicated.snp", "r") do io
        vsnp = String[]         # vector
        for line in eachline(io)
            a, b = split(line)
            push!(vsnp, a)
            push!(vsnp, b)
            dsnp[a] = b
        end
        ssnp = Set(vsnp)
    end

    #=
    print_sst("Check manifest")
    mnft = Dict()
    open("data/maps/illumina/BovineSNP50_v3_A2.csv") do io
        for _ in 1:8            # skip header
            _ = readline(io)
        end
        for _ in 1:53218        # I know the number of SNP
            x = split(readline(io), ',')
            if x[2] in ssnp
                mnft[x[2]] = uppercase(x[17])
            end
        end
    end
    for (a, b) in dsnp
        x = mnft[a]
        y = mnft[b]
        if x ≠ y
            z = reverse_complement(y)
            if x ≠ z
                println(a, '\t' , b)
            end
        end
    end
    =#

    print_sst("Compare genotypes")
    sdir = "data/3-sets"
    rmdir("tmp", recursive=true, force=true)
    mkdir("tmp")
    for country in ["dutch", "german", "norge"]
        _ = read(`bin/plink --cow
                            --bfile $sdir/$country
                            --recode vcf-iid
                            --out tmp/$country`,
                 String)
        dgtp = Dict()
        open("tmp/$country.vcf", "r") do io
            line = "######"
            while line[2] == '#'
                line = readline(io)
            end
            while !eof(io)
                x = split(readline(io))
                if x[3] in ssnp
                    dgtp[x[3]] = x[10:]
                end
            end
        end
        # then check extracted genotypes
        for (a, b) in dsnp
            #println(a, '\t', b)
            #for i in length(dgtp[a])
            #for x in dgtp[a]
        end
    end
    
end
