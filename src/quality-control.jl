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
    platforms = ["dutch-d1", "dutch-d2", "dutch-d3", "dutch-v2", "dutch-v3",
                 "dutch-v7", "german-v2", "german-v3", "norge-v1", "norge-v2",
                 "norge-v7"]
    sdir = "data/genotypes/auto.plk"
    tdir = "notebooks/fig"
    isdir(tdir) || mkdir(tdir)
    mkdir_tmp()
    
    print_sst("Plotting l-missing and Hwe stats")
    for pf in platforms
        print_item("Platform $pf")
        n = "t"                 # dummy, to read N_id. i don't parse it into Int here.
        y = Float64[]
        print_msg("Missing data stats")
        miss_allele_stats("$sdir/$pf", "tmp/$pf")

        open("tmp/$pf.lmiss", "r") do io # plot lmiss
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
        hwe_stats("$sdir/$pf", "tmp/$pf")
        open("tmp/$pf.hwe", "r") do io # plot hwe
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
        h = 0.1                 # the threshold
        p1 = plot(x, y,
                  label = "$pf l-miss",
                  ylabel = "Missing freq., $n ID",
                  xlabel = "Accumulate SNP%",
                  bottom_margin=2mm)
        plot!(p1, [h], seriestype="hline", width=.5, label="Missing frq. = $h")
        v = round(count(x->x<h, y) / nlc * 100, digits = 2)
        plot!(p1, [v], seriestype="vline", width=.5, label="Resv. rate = $v%")

        
        t = -log10.(z)
        h = 0.0001              # the threshold
        p2 = plot(x, t,
                  label = "$pf HWE",
                  ylabel = "-log10 HWE P-value",
                  xlabel = "Accumulate SNP%, $nlc loci")
        plot!(p2, [-log10(h)], seriestype="hline", width=.5, label="P(hwe) = $h")
        v = round(count(x->x>h, z) /nlc *100, digits = 2)
        plot!(p2, [v], seriestype="vline", width=.5, label="Resv. rate = $v%")
        
        plot(p1, p2, size=(800,300), dpi=300)
                  
        savefig("$tdir/$pf-ms-hwe.png")
        print_done()
    end
end
