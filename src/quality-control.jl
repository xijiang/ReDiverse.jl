"""
    plot_miss(batch::String)

---
To plot the histograms of missing alleles. Two figures side by side are to be plotted:
1. the imiss data, which are per ID
2. the lmiss data, which are per locus

The plink missing stat files should be in data/qc.
"""
function plot_miss(batch::String)
    dir = "notebooks/png"
    isdir(dir) || mkdir(dir)
    imiss, lmiss = "data/qc/$batch.imiss", "data/qc/$batch.lmiss"

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
    plot_freq(batch::String)

---

The plink frequency files should be in data/qc.
"""
function plot_freq(batch::String)
    freq = "data/qc/$batch.frq"
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

    dir = "notebooks/png"
    isdir(dir) || mkdir(dir)
    Plots.histogram(y,
                    size = (400, 300),
                    dpi = 300,
                    xlabel = "MAF",
                    ylabel = "Number of loci ovserved on the freq.",
                    label = "$batch: MAF histogram")
    Plots.savefig("$dir/$batch-maf.png")
end

"""
    quality_control()

---

This driver will test
1. Allele missing statistics
2. Hardy-Weinberg test
3. Mendelian error test
4. Frequency test
5. Plot of the results
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
    src = "data/plink"
    tgt = "data/qc"
    println("Test if all the bed files are ready")
    are_files_ready(src, batches, "bed")
    isdir(tgt) || mkdir(tgt)

    println("The plink logs can be found in data/qc")
    println("Only warnings and errors are shown in Julia REPL")
    #curTime = Dates.format(Dates.now(), "yyyy-mm-dd--HH:MM:SS")
    for batch in batches
        print_header("Dealing with data batch: $batch")
        
        # Histogram missing data
        _ = read(`bin/plink
                      --cow
                      --bfile $src/$batch
                      --missing
                      --out $tgt/$batch`,
                 String);
        plot_miss(batch)
        
        # Histogram MAF
        println(repeat('-', 60))
        _ = read(`bin/plink
                      --cow
                      --bfile $src/$batch
                      --nonfounders
                      --freq
                      --out $tgt/$batch`,
                 String);
        plot_freq(batch)

        # HWE
        println(repeat('-', 60))
        _ = read(`bin/plink
                      --cow
                      --bfile $src/$batch
                      --hardy
                      --out $tgt/$batch`,
                 String);
    end
end
