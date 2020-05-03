"""
    clean_before_impute()
---
This function works on files in `data/genotypes/final-vcf.
These 3 files were merged by country, with a common set `v3` intersect (union `v1`, `v2`, `hd`).
Then remove 
1. one set of 27 duplicates pairs.
   - merge genotype if the other is missing
2. low quality loci
   - if reference number is lower than 20%(?). i.e., no way to impute
3. low MAF loci
   - currently 0.01 (exclusive)
4. low quality ID
5. non-shared loci among countries.
"""
function clean_before_impute()
    isdir("tmp") && rm("tmp", recursive=true, force=true)
    mkdir("tmp")
    
    println()
end
