"""
    calc_grm()
---
This will calculate a cross-country (breed) **`G`**-matrix using Mario's `calc_grm`,
which is now in `~/.local/bin`.
"""
function calc_grm()
    title("Calculate cross-country G-matrix")
    cd(work_dir)
    fra = joinpath(work_dir, "data/genotypes/step-8.plk")
    tmp = joinpath(work_dir, "tmp")
    bin = joinpath(work_dir, "bin")
    grm = joinpath(work_dir, "data/genotypes/grm")
    isdir(grm) || mkdir(grm)
    empty_dir(tmp)
    
    item("Convert country.bed to raw data")
    for country in ["dutch", "german", "norge"]
        plink_012(joinpath(fra, country), joinpath(tmp, country))
    end
    
    item("Merge raw data for `calc_grm`")
    cd(tmp)
    _ = run(pipeline(`$bin/merge4grm dutch.raw german.raw norge.raw`,
                     "genotypes.txt"))
    
    item("Create a parameter file for `calc_grm`")
    open("calc_grm.inp", "w") do io
        nlc = 0
        open(joinpath(tmp, "genotypes.txt"), "r") do gt
            line = readline(gt)
            nlc = length(split(line)) - 1
        end                     # it's 44037 anyway
        write(io, "$nlc\n")
        write(io, "genotypes.txt\n")
        write(io, "genotypes\n")
        write(io, "3 country.idx\n")
        write(io, "vanraden\n")
        write(io, "giv 0.00\n")
        write(io, "G ASReml\n")
        write(io, "print_giv=asc\n")
        write(io, "print_geno=no genotypes.dat\n")
        write(io, "12\n")       # number of threads
    end
    _ = run(`calc_grm`)
    _ = read(run(pipeline("G.grm", `gawk '{if($1==$2) print $3}'`, "diag.txt")), String)

    cd(tmp)
    isdir("$grm/all") || mkdir("$grm/all")
    for file in ["breed_profiles.txt",
                 "calc_grm.inp",
                 "calculated_all_freq.dat",
                 "calculated_all_freq_per_br_profile.dat",
                 "country.idx",
                 "diag.txt",
                 "G_asreml.giv",
                 "genomic_inbr_coef.dat",
                 "genotypes.txt",
                 "G.grm",
                 "high_grm_coefs.log",
                 "ID.dic",
                 "ID_vs_row_number_G.txt",
                 "present_breed_not_gen.dat",
                 "WARNING_ERROR_calc_grm.log"]
        mv(file, "$grm/all/$file", force=true)
    end
    cd(work_dir)
end

"""
    calc_grm_by_country()
---
Calculate **`G`** by country.  Also QQ-plot diagonals.  This must be run after `calc_grm`
to have the data ready.
"""
function calc_grm_by_country()
    title("Examine GRM by country")
    grm = joinpath(work_dir, "data/genotypes/grm")
    tmp = joinpath(work_dir, "tmp")
    bin = joinpath(work_dir, "bin")
    til = joinpath(work_dir, "data/genotypes/grm")

    cd(tmp)
    for country in ["dutch", "german", "norge"]
        item("G of $country")
        _ = run(pipeline(`$bin/merge4grm $country.raw`,
                         "genotypes.txt"))
        open("calc_grm.inp", "w") do io
            nlc = 0
            open(joinpath(tmp, "genotypes.txt"), "r") do gt
                line = readline(gt)
                nlc = length(split(line)) - 1
            end                     # it's 44037 anyway
            write(io, "$nlc\n")
            write(io, "genotypes.txt\n")
            write(io, "genotypes\n")
            write(io, "1\n")
            write(io, "vanraden\n")
            write(io, "giv 0.00\n")
            write(io, "G ASReml\n")
            write(io, "print_giv=asc\n")
            write(io, "print_geno=no genotypes.dat\n")
            write(io, "12\n")       # number of threads
        end
        _ = run(`calc_grm`)
        _ = read(run(pipeline("G.grm", `gawk '{if($1==$2) print $3}'`, "diag.txt")), String)

        isdir("$til/$country") || mkdir("$til/$country")
        for file in ["calc_grm.inp",
                     "calculated_all_freq.dat",
                     "country.idx",
                     "diag.txt",
                     "G_asreml.giv",
                     "genomic_inbr_coef.dat",
                     "genotypes.txt",
                     "G.grm",
                     "high_grm_coefs.log",
                     "ID.dic",
                     "ID_vs_row_number_G.txt",
                     "WARNING_ERROR_calc_grm.log"]
            isfile(file) && mv(file, "$grm/$country/$file", force=true)
        end
    end
    cd(work_dir)
end

"""
    plot_grm_diag()
---
Sort and plot diagonals of `GRM`.
"""
function plot_grm_diag()
    title("QQ-Plot GRM diagonals")
    fra = joinpath(work_dir, "data/genotypes/grm")
    pp = Any[]
    for country in ["all", "dutch", "german", "norge"]
        item("Figure of $country")
        dd = Float64[]
        for line in eachline(joinpath(fra, "$country/diag.txt"))
            push!(dd, parse(Float64, line))
        end
        p = plot(sort(dd), label = country, dpi=300)
        push!(pp, p)
    end
    plot(pp[1], pp[2], pp[3], pp[4], layout=4)
    savefig("notebooks/fig/diag.png")
end

"""
    calc_grm_w_ped()
---
Previously the elements in Dutch and Norwegian block are weird.  This funciton tries to bend the results
toward the **A** matrix, to see if the problem is alieved or not.
"""
function calc_grm_w_ped()
    title("Calculate GRM with pedigree")
    item("Prepare directories")
    countries = ["dutch", "german", "norge"]
    cd(work_dir)
    fra = joinpath(work_dir, "data/genotypes/step-8.plk")
    tmp = joinpath(work_dir, "tmp")
    bin = joinpath(work_dir, "bin")
    grm = joinpath(work_dir, "data/genotypes/grm")
    ped = joinpath(work_dir, "data/pedigree")
    isdir(grm) || mkdir(grm)
    empty_dir(tmp)
    done()

    item("Create unified pedigree")
    run(pipeline(joinpath(ped, "dg.ped"),
                 `$bin/pedsort UUUUUUUUUUUUUUUUUUU`,
                 joinpath(tmp, "dg.ped")))
    run(pipeline(joinpath(ped, "norge.ped"),
                 `$bin/pedsort 0`,
                 joinpath(tmp, "norge.ped")))
    argv = joinpath.(tmp, ["dg.ped", "norge.ped"])
    run(pipeline(`$bin/merge-ped $argv`, joinpath(tmp,"one.ped")))
    done()

    item("Convert country.bed to raw data")
    for country in countries
        plink_012(joinpath(fra, country), joinpath(tmp, country))
    end
    done()

    item("Merge raw data for `calc_grm`")
    argv = joinpath.(tmp, ["dutch.raw", "german.raw", "norge.raw", "country.idx"])
    _ = run(pipeline(joinpath(tmp, "one.ped"), `$bin/merge4grm $argv`, joinpath(tmp, "genotypes.txt")))
    done()
    
    item("Create a parameter file for `calc_grm`")
    nlc = begin
        open(joinpath(tmp, "genotypes.txt"), "r") do gt
            line = readline(gt)
            length(split(line)) - 1
        end
    end
    open(joinpath(tmp, "three.ped"), "w") do ped
        for line in eachline(joinpath(tmp, "one.ped"))
            id, pa, ma = split(line)[1:3]
            write(ped, "$id $pa $ma\n")
        end
    end

    inp = ["$nlc", "genotypes.txt three.ped", "genotypes", "1", "vanraden",
           "giv 0.00", "G ASReml", "print_giv=asc", "print_geno=no genotypes.dat",
           "12", "!checkparents", ""]
    write(joinpath(tmp, "calc_grm.inp"), join(inp, '\n'))
    done()

    item("Run `calc_grm`")
    cd(tmp)
    _ = run(`calc_grm`)
    cd(work_dir)
end

"""
This function create an ID (string) dictionary to (integer).
- Unknown ID are coded as 0
- Known ID start from 1
- ID in sire, dam columns and not in ID column are coded first
- Country were also recorded as 1, 2, 3 for dutch, german and norge, respectively.
"""
function generate_ID_dict()
    title("generate a ID dictionary of all ID in 3 countries")
    dic = open(joinpath(work_dir, "data/pedigree/ID.dict"), "w")
    ped = open(joinpath(work_dir, "data/pedigree/union.ped"), "w")
    idx = open(joinpath(work_dir, "data/pedigree/country.idx"), "w")
    ref = Dict()
    iid = 0
    
    write(dic, "UUUUUUUUUUUUUUUUUUU 0 0\n") # an unknown parent
    write(dic, "0 0 0\n")                   # another unknown parent
    push!(ref, "UUUUUUUUUUUUUUUUUUU" => 0)
    push!(ref, "0" => 0)
    breed = Dict("dutch" => " 1 0 0\n", "german" => " 0 1 0\n", "norge" => " 0 0 1\n")

    for country in ["dutch", "german", "norge"]
        id, pa, ma = begin
            a = String[]
            b = String[]
            c = String[]
            fra = joinpath(work_dir, "data/pedigree/$country.ped")
            for line in eachline(fra)
                x, y, z = (split(line)[i] for i in [1, 2, 3])
                push!(a, x)
                push!(b, y)
                push!(c, z)
            end
            Set(a), delete!(Set(b), "UUUUUUUUUUUUUUUUUUU"), delete!(Set(c), "UUUUUUUUUUUUUUUUUUU")
        end

        println("N id pa ma in $country: ", length(id), ' ', length(pa), ' ', length(ma))
        for i in setdiff(union(pa, ma), id)
            iid += 1
            write(dic, "$i $iid $country\n")
            push!(ref, i => iid)
            write(ped, iid, " 0 0\n")
            write(idx, iid, breed[country])
        end
        for line in eachline(joinpath(work_dir, "data/pedigree/$country.ped"))
            x, y, z = (split(line)[i] for i in [1, 2, 3])
            iid += 1
            push!(ref, x => iid)
            write(dic, "$x $iid $country\n")
            write(ped, iid, ' ', ref[y], ' ', ref[z], '\n')
            write(idx, iid, breed[country])
        end
    end

    close(ped, ped, idx)
    done()
end

function test_ID()
    title("Test ID")
    #til = joinpath
end
#= Discarded codes
    allid = begin
        id = String[]
        for x in eachline(joinpath(work_dir, "data/pedigree/ids"))
            push!(id, x)
        end
        Set(id)
    end
    for country in ["dutch", "german", "norge"]
        cid = begin
            id = String[]
            for line in eachline(joinpath(work_dir, "data/genotypes/step-8.plk/$country.fam"))
                push!(id, split(line)[2])
            end
            Set(id)
        end
        did = setdiff(cid, allid)
        if length(did) > 0
            println(country, " has ", length(did), " ID not in the pedigree")
            write(joinpath(work_dir, "tmp/$country.diff"), join(did, '\n'), '\n')
        end
    end
=#
