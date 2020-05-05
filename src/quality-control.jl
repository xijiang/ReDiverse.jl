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

"""
    filter_lowQ_snp(; geno::Float64=0.1, maf::Float64=0.05, hwe::Float64=0.0001)
---
Remove low quality SNP in each platform by country.

SNP of 
- missing ratio > 0.1
- MAF < 0.01
- P-value of HWE statistics <0.0001

are removed.

Note this is a keyword argument example. Call example:

`filter_lowQ_snp(maf = 0.02`
"""
function filter_lowQ_snp(; geno::Float64 = 0.1,
                         maf::Float64 = 0.01,
                         hwe::Float64 = 0.0001)
    print_sst("Remove low quality SNP")
    sdir = "data/genotypes/auto.plk"
    tdir = "data/genotypes/flt-snp.plk"
    isdir(tdir) || mkdir(tdir)
    platforms = ["dutch-d1", "dutch-d2", "dutch-d3", "dutch-v2", "dutch-v3",
                 "dutch-v7", "german-v2", "german-v3", "norge-v1", "norge-v2",
                 "norge-v7"]
    for pf in platforms
        print_item("Filtering platform $pf")
        plink_filter_snp("$sdir/$pf", geno, maf, hwe, "$tdir/$pf")
    end
    
    dd1 = get_bim_snp_set(tdir * "/" * platforms[1] * ".bim")
    dd2 = get_bim_snp_set(tdir * "/" * platforms[2] * ".bim")
    dd3 = get_bim_snp_set(tdir * "/" * platforms[3] * ".bim")
    dv2 = get_bim_snp_set(tdir * "/" * platforms[4] * ".bim")
    dv3 = get_bim_snp_set(tdir * "/" * platforms[5] * ".bim")
    dv7 = get_bim_snp_set(tdir * "/" * platforms[6] * ".bim")
    gv2 = get_bim_snp_set(tdir * "/" * platforms[7] * ".bim")
    gv3 = get_bim_snp_set(tdir * "/" * platforms[8] * ".bim")
    nv1 = get_bim_snp_set(tdir * "/" * platforms[9] * ".bim")
    nv2 = get_bim_snp_set(tdir * "/" * platforms[10]* ".bim")
    nv7 = get_bim_snp_set(tdir * "/" * platforms[11]* ".bim")
    ud = union(dd1, dd2, dd3, dv2, dv3, dv7)
    ug = union(gv2, gv3)
    un = union(nv1, nv2, nv7)
    super = intersect(ud, ug, un)
    print_item("Statistics")
    print("| $maf | ")
    stats = [length(intersect(dd1, super)), 
             length(intersect(dd2, super)),
             length(intersect(dd3, super)),
             length(intersect(dv2, super)),
             length(intersect(dv3, super)),
             length(intersect(dv7, super)),
             length(intersect(gv2, super)),
             length(intersect(gv3, super)),
             length(intersect(nv1, super)),
             length(intersect(nv2, super)),
             length(intersect(nv7, super)),
             length(super)]
    print(join(stats, " | "), " |\n")
    open("data/maps/super.snp", "w") do io
        for snp in super
            write(io, "$snp\n")
        end
    end
end

"""
    plot_imiss(threshold::Float64 = 0.1)
---
Plot missing data per ID to decide a threshold to filter away low quality ID.
"""
function plot_imiss(threshold::Float64 = 0.1)
    print_sst("Plot allele missing per ID")
    platforms = ["dutch-d1", "dutch-d2", "dutch-d3", "dutch-v2", "dutch-v3",
                 "dutch-v7", "german-v2", "german-v3", "norge-v1", "norge-v2",
                 "norge-v7"]
    sdir = "data/genotypes/unified.plk"
    tdir = "notebooks/fig"
    mkdir_tmp()

    for pf in platforms
        print_item("Dealing with platform $pf")
        miss_allele_stats("$sdir/$pf", "tmp/out")
        y = Float64[]
        open("tmp/out.imiss", "r") do io
            _ = readline(io)
            while !eof(io)
                line = readline(io)
                r = parse(Float64, split(line)[6])
                push!(y, r)
            end
        end
        sort!(y)
        tid = length(y)
        nid = count(x->x<threshold, y)
        
        plot(1:tid, y, label=pf, dpi=300)
        plot!([nid], seriestype="vline", label="$tid reduced to $nid")
        savefig("$tdir/$pf-imiss.png")
    end
end

"""
    filter_id(mind::Float64 = 0.05)
---
Remove ID with missing alleles over `mind`
"""
function filter_id(mind::Float64 = 0.05)
    print_sst("Remove ID with missing genotypes over $mind")
    platforms = ["dutch-d1", "dutch-d2", "dutch-d3", "dutch-v2", "dutch-v3",
                 "dutch-v7", "german-v2", "german-v3", "norge-v1", "norge-v2",
                 "norge-v7"]
    sdir = "data/genotypes/unified.plk"
    tdir = "data/genotypes/flt-id.plk"
    isdir(tdir) || mkdir(tdir)
    for pf in platforms
        print_item("Dealing with platform $pf")
        plink_filter_id("$sdir/$pf", mind, "$tdir/$pf")
    end
end

