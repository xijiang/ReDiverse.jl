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
QQ-plot of `GRM` diagonals.
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

                
