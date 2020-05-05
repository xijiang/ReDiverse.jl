# Note: plink is a global var, and is defined in the main julia file.
# Only warnings and errors are printed on screen
#   - other messages will be stored on disk anyway
#   - Detailed log can be found in the same directory of `out`
# All below commands center around `bfile`

"""
    function make_ped_n_map_to_bed(ped, map, out, species = "cow")
---
Convert
 - `ped`: e.g., plink.ped
 - `map`: e.g., plink.map
Into
 - `out`: out.{bed,bim,fam}
"""
function make_ped_n_map_to_bed(ped::AbstractString,
                               map::AbstractString,
                               out::AbstractString,
                               species::AbstractString = "cow")
    _ = read(`$plink --$species
                     --recode
                     --make-bed
                     --ped $ped
                     --map $map
                     --out $out`,
             String);
end

"""
    extract_bed_subset(src, snp, out, species = "cow")
---
Extract a subset of
 - `src`: src.{bed,bim,fam}
according to
 - `snp`: file name contains a list of SNP names
into:
 - `out`: out.{bed,bim,fam}
"""
function extract_bed_subset(src::AbstractString,
                            snp::AbstractString,
                            out::AbstractString,
                            species::AbstractString = "cow")
    _ = read(`$plink --$species
                     --bfile $src
                     --extract $snp
                     --make-bed
                     --out $out`,
             String)
end

"""
   miss_allele_stats(bfile, out, species = "cow", chr="1-29")
---
Do statistics of missing values in `bfile`, and output them to `out`
"""
function miss_allele_stats(bfile::AbstractString,
                           out::AbstractString,
                           species::AbstractString = "cow",
                           chr::AbstractString = "1-29")
    _ = read(`$plink --$species
                     --bfile $bfile
                     --missing
                     --chr $chr
                     --out $out`,
             String);
end

"""
    allele_maf_stats(bfile, out, species = "cow", chr = "1-29")
---
Do MAF statistics of `bfile`, and output to `out`.
"""
function allele_maf_stats(bfile::AbstractString,
                          out::AbstractString,
                          species::AbstractString = "cow",
                          chr::AbstractString = "1-29")
    _ = read(`$plink --$species
                     --bfile $bfile
                     --chr $chr
                     --nonfounders
                     --freq
                     --out $out`,
             String);
end

"""
    hwe_stats(bfile, out, species = "cow", chr = "1-29")
---
Hardy-Weinberg equillibrium test.
"""
function hwe_stats(bfile::AbstractString,
                   out::AbstractString,
                   species::AbstractString = "cow",
                   chr::AbstractString = "1-29")
    _ = read(`$plink --$species
                     --bfile $bfile
                     --chr $chr
                     --hardy
                     --out $out`,
                 String);
end

"""
    plink_merge(list, out, species = "cow")
---
- `list`: the fine name which contains a bunch of bfiles
"""
function plink_merge(list::AbstractString,
                     out::AbstractString,
                     species::AbstractString = "cow")
    _ = read(`$plink --$species
                     --merge-list $list
                     --make-bed
                     --out $out`,
             String)
end

"""
    plink_2_vcf(src::AbstractString, out::AbstractString, species::AbstractString = "cow")
---
Convert plink bed files to out in vcf format
"""
function plink_2_vcf(src::AbstractString,
                     out::AbstractString,
                     species::AbstractString = "cow")
    _ = read(`$plink --$species
                     --bfile $src
                     --recode vcf-iid
                     --out $out`,
             String)
end

"""
    vcf_2_plink(src::AbstractString, out::AbstractString, species::AbstractString = "cow")
---
Convert a VCF file to plink.{bed,bim,fam}
"""
function vcf_2_plink(src::AbstractString,
                     out::AbstractString,
                     species::AbstractString = "cow")
    _ = read(`$plink --$species
                     --vcf $src
                     --const-fid
                     --out $out`,
             String)
end

"""
    plink_2_map_n_ped(src::AbstractString, out::AbstractString, species::AbstractString = "cow")
---
Recode `plink.{bed,bim,fam}` to `plink.{map,ped}`.
"""
function plink_2_map_n_ped(src::AbstractString,
                           out::AbstractString,
                           species::AbstractString = "cow")
    _ = read(`$plink --$species
		     --bfile $src
		     --recode
		     --out $out`,
             String)
end


"""
    plink_filter_snp(src::AbstractString, geno, maf, hwe, out, species = "cow")
---
- Refer: https://github.com/pcgoddard/Burchardlab_Tutorials/wiki/PLINK:-Quality-Control

Filter `src` in bed format according to geno, maf, and hwe to `target` in bed format. where,
- geno: maximum miss ratio of a SNP loci
- maf: minimu allele frequency
- hwe: minimum p value of hwe statistics
"""
function plink_filter_snp(src::AbstractString,
                          geno::Float64,
                          maf::Float64,
                          hwe::Float64,
                          out::AbstractString,
                          species::AbstractString = "cow")
    _ = read(`$plink --$species
                     --bfile $src
                     --geno $geno
                     --maf $maf
                     --hwe $hwe
                     --make-bed
                     --out $out`,
             String)
end

"""
    plink_filter_id(src, mind, out, species = "cow")
---
Remove ID with missing allele rate over `mind`
"""
function plink_filter_id(src::AbstractString,
                         mind::Float64,
                         out::AbstractString,
                         species::AbstractString = "cow")
    _ = read(`$plink --$species
		     --bfile $src
		     --mind $mind
		     --make-bed
		     --out $out`,
             String)
end
