#=
"""
    plot_miss(batch::String, dir::String)
---
To plot the histograms of missing alleles. Two figures side by side are to be plotted:
1. the imiss data, which are per ID
2. the lmiss data, which are per locus

The plink missing stat files should be in `tmp/`.
The png files will be put in `dir/`.
"""
function plot_miss(batch::String, dir::String)
    isdir(dir) || mkdir(dir)
    imiss, lmiss = "tmp/$batch.imiss", "tmp/$batch.lmiss"

    y_i = Float64[]
    open(imiss, "r") do io
        _ = readline(io)
        while !eof(io)
            fmiss = parse(Float64, split(readline(io))[6])
            push!(y_i, fmiss)
        end
    end
    nid = length(y_i)
    p1 = Plots.histogram(y_i,
                         xlabel = "Loci missing frequencies per ID (n=$nid)",
                         ylabel = "Number of ID of x_frequency range",
                         label = batch*": plink imiss histogram" 
                         )

    y_l = Float64[]
    open(lmiss, "r") do io
        _ = readline(io)
        while !eof(io)
            lmiss = parse(Float64, split(readline(io))[5])
            push!(y_l, lmiss)
        end
    end
    nlc = length(y_l)
    p2 = Plots.histogram(y_l,
                         xlabel = "Loci missing frequencies per locus",
                         ylabel = "Number of loci of x_frequency range",
                         label = batch*": plink lmiss histogram")
    Plots.plot(p1, p2, size=(800, 300), dpi=300)

    Plots.savefig("$dir/$batch.png")
end

"""
    plot_freq(batch::String, dir::String)
---
The plink frequency files should be in `tmp`.
The result png files will bein in `dir`.
"""
function plot_freq(batch::String, dir::String)
    freq = "tmp/$batch.frq"
    y = Float64[]
    open(freq, "r") do io
        _ = readline(io)
        while !eof(io)
            f = split(readline(io))[5]
            if f == "NA"
                f = "0"
            end
            push!(y, parse(Float64, f))
        end
    end

    isdir(dir) || mkdir(dir)
    Plots.histogram(y,
                    size = (400, 300),
                    dpi = 300,
                    xlabel = "MAF",
                    ylabel = "Number of loci ovserved on the freq.",
                    label = "$batch: MAF histogram")
    Plots.savefig("$dir/$batch-maf.png")
end
=#
"""
    plot_lmiss_n_hwe()
---
Plot the loci missing results to determine thresholds to elimate SNP.
Note:
- I found it is better to plot accumulate distribution of allele missing rate.
  - Hence I totally rewrote the function
- This must be done after plink stats missing.
- Removing low quality SNP seems should be the first step
  - as there are many SNP, e.g., thousands.
- Low quality ID can be done after this procedure.
"""
function plot_lmiss_n_hwe()
    batches = ["dutch-10690",
               "dutch-10993",
               "dutch-11483",
               "dutch-777k",
               "dutch-v2",
               "dutch-v3",
               "german-v2",
               "german-v3",
               "norge-777k",
               "norge-v1",
               "norge-v2"]
    sdir = "data/plkmax"
    tdir = "notebooks/fig"
    isdir(tdir) || mkdir(tdir)
    isdir("tmp") && rm("tmp", recursive=true, force=true)
    mkdir("tmp")
    
    print_sst("Plotting l-missing and Hwe data")
    for b in batches
        print_item("Platform $b")
        n = "t"                 # dummy, to read N_id. i don't parse it into Int here.
        y = Float64[]
        print_msg("Missing data stats")
        miss_allele_stats("$sdir/$b", "tmp/$b")

        open("tmp/$b.lmiss", "r") do io # plot lmiss
            _ = readline(io)
            while !eof(io)
                line = readline(io)
                n, m = [split(line)[i] for i in [4, 5]]
                push!(y, parse(Float64, m))
            end
            sort!(y)
        end

        z = Float64[]
        print_msg("HWE stats")
        hwe_stats("$sdir/$b", "tmp/$b")
        open("tmp/$b.hwe", "r") do io # plot hwe
            _ = readline(io)
            while !eof(io)
                line = readline(io)
                push!(z, parse(Float64, split(line)[9]))
            end
            sort!(z, rev = true)
        end

        print_msg("Plot the figures")
        nlc = length(y)
        x = range(0, 100., length = nlc)
        p1 = plot(x, y,
                  label = "$b l-miss",
                  ylabel = "Missing freq., $n ID",
                  xlabel = "Accumulate SNP%")
        t = -log10.(z)
        p2 = plot(x, t,
                  label = "$b HWE",
                  ylabel = "-log10 HWE P-value",
                  xlabel = "Accumulate SNP%, $nlc loci")
        plot(p1, p2, size=(800,300), dpi=300)
                  
        savefig("$tdir/$b-ms-hwe.png")
        print_done()
    end
end

"""
    quality_control()
---
# Description
## Arguments
- `sdir`: the source dir, i.e., where the plink files are
- I will user `tmp` dir to hold mid-results.

## This driver will test
1. Allele missing statistics
2. Hardy-Weinberg test
3. Frequency test

# Example
## Quality control of the plink files in `data/plink`
- `ReDiverse.quality_control("data/plink")`
"""
function quality_control()
    batches = ["dutch-10690",
               "dutch-10993",
               "dutch-11483",
               "dutch-777k",
               "dutch-v2",
               "dutch-v3",
               "german-v2",
               "german-v3",
               "norge-777k",
               "norge-v1",
               "norge-v2"]
    sdir = "data/plink"
    print_sst("Test if all the bed files in $sdir are ready")
    are_files_ready(sdir, batches, "bed")

    print_sst("Make folder tmp ready")
    isdir("tmp") && rm("tmp", recursive=true, force=true)
    mkdir("tmp")
    println("The plink logs can be found in data/qc")
    println("Only warnings and errors are shown in Julia REPL")
    print_done()

    #curTime = Dates.format(Dates.now(), "yyyy-mm-dd--HH:MM:SS")
    for batch in batches
        print_sst("Dealing with data batch: $batch")
        
        print_item("Missing data stats")
        miss_allele_stats("$sdir/$batch", "tmp/$batch")
        
        print_item("MAF stats")
        allele_maf_stats("$sdir/$batch", "tmp/$batch")

        println("HWE stats")
        hwe_stats("$sdir/$batch", "tmp/$batch")
    end
end
