"""
    cvt_2_plk_n_rm_id()
---
Convert Norwegian final reports to plink format. Also remove ID who were genotyped more than once.
The ID duplicates who were
- of low density genotype
- genotyped earlier

were removed in above precedure order.
"""
function cvt_2_plk_n_rm_id()
    title("Norwegian raw data")
    #############################
    
    tmp = joinpath(work_dir, "tmp")
    fra = joinpath(work_dir, "data/genotypes/norge")
    til = joinpath(work_dir, "data/genotypes/step-0.plk") # convert to plink and rm ID first
    isdir(til) || mkdir(til)
    empty_dir(til)


    dat = joinpath(fra, "2020-05-11") # where are the 86 files
    ver = "ver"                       # v7, v2, v1, v0

    dic = Dict()

    open(joinpath(fra, "file.desc"), "r") do desc
        _ = readline(desc)      # I defined a header to remember contents.
        for line in eachline(desc)
            nn, vv, _, ff = split(line) # number, version, date, file-name
            subtitle(ff)
            #-------------
            
            nc = 0                       # number of columns in ff
            
            if vv ≠ ver                  # Read map dictionary
                ver = vv
                empty!(dic)
                item("Read map $ver")
                dic = ref_map_dict(joinpath(work_dir, "data/maps/updated", "$vv.map"))
            end

            item("Create a GenofileId to GenoId shortlist dictionary")
            sdc = joinpath(til, "$nn.dic")
            open(sdc, "w") do io # output shortlist.
                for line in eachline(joinpath(fra, "idmap_rediverse"))
                    f, x, y = [split(line)[i] for i in [2, 3, 4]]
                    if f == ff
                        write(io, "$x\t$y\n")
                    end
                end
            end
            
            open(joinpath(fra, "2020-05-11", ff), "r") do io
                for _ in 1:20   # to get into the body
                    line = readline(io)
                end
                nc = length(split(line))
            end                 # determin whether to split v or h.
            
            empty_dir(tmp)
            file = joinpath(dat, ff)
            cd(tmp)
            if nc >10           # split vertically
                item("Split file $ff vertically")
                _ = read(pipeline(`cat $file`,
                                  `$work_dir/bin/split-v $sdc`),
                         String)
            else                # split horizonly
                item("Split file $ff horizonly")
                _ = read(pipeline(`cat $file`,
                                  `$work_dir/bin/split-h $sdc`),
                         String)
            end
            cd(work_dir)
            list = readdir(tmp)         # the newly created files
            fr2ped(tmp, list, joinpath(tmp, "plink.ped"), "Top")
            sample = list[1]
            create_plink_map(joinpath(tmp, sample), dic, joinpath(tmp, "plink.map"))
            ped_n_map_to_bed(joinpath(tmp, "plink.ped"), joinpath(tmp, "plink.map"), joinpath(til, nn));
        end
    end
end

"""
    merge_raw_norge_gt()
---
Merge the data converted by `cvt_2_plk_n_rm_id` into v0, 1, 2, 7 four files.
"""
function merge_raw_norge_gt()
    title("Merge Norwegian data")
    fra = joinpath(work_dir, "data/genotypes/step-0.plk")
    mid = joinpath(work_dir, "tmp")
    til = joinpath(work_dir, "data/genotypes/step-1.plk")
    isdir(til) || mkdir(til)

    v7 = "0".*[string(i) for i in 1:9]
    v2 = [string(i) for i in 10:84]
    v1 = ["85"]
    v0 = ["86"]
    tt = ["v7", "v2", "v1"]
    it = 1
    
    ID = Set()                  # ID already dealed
    for vv in [v7, v2, v1]      # v0 was removed as they were all genotyped again later.
        target = tt[it]
        subtitle("Dealing with platform $target")
        empty_dir(mid)
        for s in vv
            open(joinpath(mid, "list"), "w") do list
                for line in eachline(joinpath(fra, "$s.fam"))
                    id = split(line)[2]
                    if id ∉ ID
                        push!(ID, id)
                        write(list, "dummy $id\n")
                    end
                end
            end                 # created keep ID list
            plink_keep_id(joinpath(fra, s),
                          joinpath(mid, "list"),
                          joinpath(mid, s)
                          )
        end
        open(joinpath(mid, "merge.lst"), "w") do list
            for s in vv
                write(list, joinpath(mid, s), '\n')
            end
        end
        merge_beds(joinpath(mid, "merge.lst"),
                   joinpath(til, "norge-$target")
                   )
        it += 1
    end
end

"""
    orgNorgeGT()
---
Organize raw Norwegian data into step-1.plk.  Namely v0, v1, v2, v7.
"""
function orgNorgeGT()
    # Step-0: convert final report to plink, and translate GenofileId to GenoId.
    @time cvt_2_plk_n_rm_id()
    # Step-1: merge to v7, 2, 1, 0 four files, remove dup ID plink by plink
    # ID in v0 were all genotyped again later, so not included.
    @time merge_raw_norge_gt()
end
