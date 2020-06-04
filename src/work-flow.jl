"""
  sandbox(test::Bool = true)
---
This function has two nested functions:
- release()
  - This holds the proved workflow steps
- debug()
  - The steps under test

By default, sandbox will call `debug()`. To run `release()`, call `sandbox(true)`.
"""
function sandbox_ReDiverse(test::Bool = true)
    cd(work_dir)
    isdir("tmp") || mkdir("tmp")
    # make()

    dutch = ["d1", "d2", "d3", "v2", "v3", "v7"]
    german = ["v2", "v3"]
    norge = ["v1", "v2", "v7"]
    list = ["dutch-" .* dutch; "german-" .* german; "norge-" .* norge]
    countries = ["dutch", "german", "norge"]

    if test
        message("Testing ...")
        @time generate_ID_dict()
    else
        title("Organize genotypes")
        message("Release version")
        warning("Warning: This will overwrite all previous results!!!")
        warning("Warning: This will take several hours to finish")
        
        # The workflow
        # -------------------------------------------------
        message("Raw data section, ~11 minutes")
        @time prepare_maps()    # v1-3 d1-3 and d7
        @time update_maps() # only update Dutch and German data to 50k-v3
        @time orgDutchGT()  # merge Dutch final reports to plink
        @time orgGermanGT() # merge German final reports to plink
        @time orgNorgeGT()  # done on 2020-May-19
        @time autosome_subset(list)

        # -------------------------------------------------
        message("Quality control section, <1 min")
        @time plot_lmiss_n_hwe(list)
        @time filter_lowQ_snp(list)
        @time plot_imiss(list, 0.05)
        @time filter_id(list, 0.05)
        # @time find_duplicates() # only need to run once
        @time remove_duplicates(list)

        # -------------------------------------------------
        message("Merge for imputation section, <1 min")
        @time merge_by_country("dutch", dutch)
        @time merge_by_country("german", german)
        @time merge_by_country("norge", norge)
        message("Imputation, ca 1hr")
        @time imputation_with_beagle(countries) # ca 20min (D+G) + 37min (N)
        @time rm_country_specific_snp()

        title("GRM related")
        @time calc_grm()
    end
end
