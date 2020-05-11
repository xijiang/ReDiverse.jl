"""
    plot_lmiss_n_hwe(list)
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
function plot_lmiss_n_hwe(list)
    cd(work_dir)
    empty_dir("tmp")
    
    sdir = "data/genotypes/step-2.plk"
    tdir = "notebooks/fig"
    isdir(tdir) || mkdir(tdir)
    
    title("Plotting l-missing and Hwe stats")
    for pf in list
        item("Platform $pf")
        n = "t"                 # dummy, to read N_id. i don't parse it into Int here.
        y = Float64[]
        message("Missing data stats")
        miss_allele_stats("$sdir/$pf", "tmp/$pf")

        open("tmp/$pf.lmiss", "r") do io # plot lmiss
            _ = readline(io)
            for line in eachline(io)
                n, m = [split(line)[i] for i in [4, 5]]
                push!(y, parse(Float64, m))
            end
            sort!(y)
        end

        z = Float64[]
        message("HWE stats")
        hwe_stats("$sdir/$pf", "tmp/$pf")
        open("tmp/$pf.hwe", "r") do io # plot hwe
            _ = readline(io)
            for line in eachline(io)
                push!(z, parse(Float64, split(line)[9]))
            end
            sort!(z, rev = true)
        end

        message("Plot the figures")
        nlc = length(y)
        x = range(0, 100., length = nlc)
        h = 0.1                 # the threshold
        p1 = plot(x, y,
                  label = "$pf l-miss",
                  ylabel = "Missing freq., $n ID",
                  xlabel = "Accumulate SNP%",
                  width = 2,
                  bottom_margin=2mm)
        plot!(p1, [h], seriestype="hline", width=.5, label="Missing frq. = $h")
        v = round(count(x->x<h, y) / nlc * 100, digits = 2)
        plot!(p1, [v], seriestype="vline", width=.5, label="Resv. rate = $v%")

        
        t = -log10.(z)
        h = 0.0001              # the threshold
        p2 = plot(x, t,
                  label = "$pf HWE",
                  ylabel = "-log10 HWE P-value",
                  xlabel = "Accumulate SNP%, $nlc loci",
                  width = 2)
        plot!(p2, [-log10(h)], seriestype="hline", width=.5, label="P(hwe) = $h")
        v = round(count(x->x>h, z) /nlc *100, digits = 2)
        plot!(p2, [v], seriestype="vline", width=.5, label="Resv. rate = $v%")
        
        plot(p1, p2, size=(800,300), dpi=300)
                  
        savefig("$tdir/$pf-ms-hwe.png")
        done()
    end
end

"""
    filter_lowQ_snp(list; geno::Float64=0.1, maf::Float64=0.05, hwe::Float64=0.0001)
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
function filter_lowQ_snp(list;
                         geno::Float64 = 0.1,
                         maf::Float64 = 0.01,
                         hwe::Float64 = 0.0001)
    cd(work_dir)
    title("Remove low quality SNP")
    sdir = "data/genotypes/step-2.plk"
    tdir = "data/genotypes/step-3.plk"
    isdir(tdir) || mkdir(tdir)

    for pf in list
        item("Filtering platform $pf")
        plink_filter_snp("$sdir/$pf", geno, maf, hwe, "$tdir/$pf")
        done()
    end
end

"""
    plot_imiss(list, threshold::Float64 = 0.1)
---
Plot missing data per ID to decide a threshold to filter away low quality ID.
"""
function plot_imiss(list,
                    threshold::Float64 = 0.1)
    title("Plot allele missing per ID")
    sdir = "data/genotypes/step-3.plk"
    tdir = "notebooks/fig"
    isdir(tdir) || mkdir(tdir)
    empty_dir("tmp")

    for pf in list
        item("Dealing with platform $pf")
        miss_allele_stats("$sdir/$pf", "tmp/out")
        y = Float64[]
        open("tmp/out.imiss", "r") do io
            _ = readline(io)
            for line in eachline(io)
                r = parse(Float64, split(line)[6])
                push!(y, r)
            end
        end
        sort!(y)
        tid = length(y)
        nid = count(x->x<threshold, y)
        
        plot(1:tid, y, label=pf, width=2, dpi=300)
        plot!([nid], seriestype="vline", width=.5, label="$tid reduced to $nid")
        plot!([threshold], seriestype="hline", width=.5, label="Threshold = $threshold")
        savefig("$tdir/$pf-imiss.png")
        done()
    end
end

"""
    filter_id(list, mind::Float64 = 0.05)
---
Remove ID with missing alleles over `mind`
"""
function filter_id(list, mind::Float64 = 0.05)
    cd(work_dir)
    title("Remove ID with missing genotypes over $mind")
    sdir = "data/genotypes/step-3.plk"
    tdir = "data/genotypes/step-4.plk"
    isdir(tdir) || mkdir(tdir)
    for pf in list
        item("Dealing with platform $pf")
        plink_filter_id("$sdir/$pf", mind, "$tdir/$pf")
        done()
    end
end

"""
    find_duplicates()
---
Find duplicated SNP in V3 autosomes.
"""
function find_duplicates()
    cd(work_dir)
    empty_dir("tmp")

    title("Find duplicated autosomal SNP")
    file = "data/maps/updated/v3.map"
    open("tmp/auto.map", "w") do io
        for line in read(pipeline(`gawk '{if($2>0 && $2<30) print $0}' $file`,
                                  `sort -nk2 -nk3`), String)
            write(io, line)
        end
    end
    open("data/maps/dup.snp", "w") do io
        for line in read(pipeline(`cat tmp/auto.map`,
                                  `bin/find-dup`), String)
            write(io, line)
        end
    end
end

"""
    remove_duplicates(list)
---
Remove duplicates SNP, i.e., different names, same chromosome and bp, according
to `data/maps/duplicated.snp`.
- Merge genotypes with the non-missing values.
- Use SNP names in the 2nd column
"""
function remove_duplicates(list)
    cd(work_dir)
    empty_dir("tmp")
    sdir = "data/genotypes/step-4.plk"
    tdir = "data/genotypes/step-5.plk"
    isdir(tdir) || mkdir(tdir)
    
    title("Remove duplicated SNP")
    for pf in list
        item("Dealing with platform $pf")
        plink_2_vcf("$sdir/$pf", "tmp/plink")
        open("tmp/filtered.vcf", "w") do io
            for line in read(pipeline(`cat tmp/plink.vcf`, `bin/merge-dup data/maps/dup.snp`))
                write(io, line)
            end
        end
        vcf_2_plink("tmp/filtered.vcf", "$tdir/$pf")
        done()
    end
end
