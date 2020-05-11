# plink related commands
plink             = "$work_dir/bin/plink"
ped_n_map_to_bed  = ABG.ped_n_map_to_bed
bed_snp_subset    = ABG.bed_snp_subset
miss_allele_stats = ABG.miss_allele_stats
allele_maf_stats  = ABG.allele_maf_stats
hwe_stats         = ABG.hwe_stats
merge_beds        = ABG.merge_beds
plink_2_vcf       = ABG.plink_2_vcf
vcf_2_plink       = ABG.vcf_2_plink
bed_2_map_n_ped   = ABG.bed_2_map_n_ped
plink_filter_snp  = ABG.plink_filter_snp
plink_filter_id   = ABG.plink_filter_id
fr2ped            = ABG.fr2ped

# styled printing
title   = ABG.title
message = ABG.message
warning = ABG.warning
item    = ABG.item
done    = ABG.done

# miscs
# empty_dir = ABG.empty_dir
function empty_dir(dir::AbstractString = "tmp")
    isdir(dir) || return
    for f in readdir(dir)
        rm(joinpath(dir, f), force=true, recursive=true)
    end
end
