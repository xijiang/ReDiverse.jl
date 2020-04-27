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
                     --recode
                     --out $out`,
             String)
end

"""
   miss_allele_stats(bfile, out, species = "cow")
---
Do statistics of missing values in `bfile`, and output them to `out`
"""
function miss_allele_stats(bfile::AbstractString,
                           out::AbstractString,
                           species::AbstractString = "cow")
    _ = read(`$plink --$species
                     --bfile $bfile
                     --missing
                     --out $out`,
             String);
end

"""
    allele_maf_stats(bfile, out, species = "cow")
---
Do MAF statistics of `bfile`, and output to `out`.
"""
function allele_maf_stats(bfile::AbstractString,
                          out::AbstractString,
                          species::AbstractString = "cow")
    _ = read(`$plink --$species
                     --bfile $bfile
                     --nonfounders
                     --freq
                     --out $out`,
             String);
end

"""
    hwe_stats(bfile, out, species = "cow")
---
"""
function hwe_stats(bfile::AbstractString,
                   out::AbstractString,
                   species::AbstractString = "cow")
    _ = read(`$plink --$species
                     --bfile $bfile
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
    _ = read(`$plink --species
                     --merge-list $list
                     --make-bed
                     --out $out`,
             String)
end
