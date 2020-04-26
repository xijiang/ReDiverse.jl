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

"""
    quality_control(sdir::String, dpng::String)
---
# Description
## Arguments
- `sdir`: the source dir, i.e., where the plink files are
- `dpng`: the result plots, in png format, will be put into this dir
- I will user `tmp` dir to hold mid-results.

## This driver will test
1. Allele missing statistics
2. Hardy-Weinberg test
3. Mendelian error test
4. Frequency test
5. Plot of the results

# Example
## Quality control of the plink files in `data/plink`
- `ReDiverse.quality_control("data/plink", "notebooks/png")`

## QC `data/plkmax`
- `ReDiverse.quality_control("data/plkmax", "notebooks/qc2")`
"""
function quality_control(sdir::String, dpng::String)
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
    # src = "data/plink"
    # tgt = "data/qc"
    print_sst("Test if all the bed files in $sdir are ready")
    are_files_ready(sdir, batches, "bed")

    print_sst("Make folder, tmp/ and $dpng ready")
    isdir(dpng) || mkdir(dpng)
    isdir("tmp") && rm("tmp", recursive=true, force=true)
    mkdir("tmp")
    println("The plink logs can be found in data/qc")
    println("Only warnings and errors are shown in Julia REPL")
    print_done()

    #curTime = Dates.format(Dates.now(), "yyyy-mm-dd--HH:MM:SS")
    for batch in batches
        print_sst("Dealing with data batch: $batch")
        
        println("Histogram missing data")
        _ = read(`bin/plink
                      --cow
                      --bfile $sdir/$batch
                      --missing
                      --out tmp/$batch`,
                 String);
        plot_miss(batch, dpng)
        
        println("Histogram MAF")
        _ = read(`bin/plink
                      --cow
                      --bfile $sdir/$batch
                      --nonfounders
                      --freq
                      --out tmp/$batch`,
                 String);
        plot_freq(batch, dpng)

        println("HWE test")
        _ = read(`bin/plink
                      --cow
                      --bfile $sdir/$batch
                      --hardy
                      --out tmp/$batch`,
                 String);
    end
end
