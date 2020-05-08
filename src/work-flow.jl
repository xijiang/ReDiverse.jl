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
function sandbox(test::Bool = true)
    function release()
        print_desc("Release version")
        print_desc("Warning: This will erase all previous results!!!")
        
        # The workflow
        @time prepare_maps()    # v1-3 d1-3 and d7
        @time update_maps() # only update Dutch and German data to 50k-v3
        @time orgGermanGT() # merge German final reports to plink
        @time orgDutchGT()  # merge Dutch final reports to plink
        @time orgNorgeGT()  # just make soft links
        @time auto_subset() # extract autosomal and SNP in target.snp
        @time update_norge_map() # Norge data formt was in plink
        @time plot_lmiss_n_hwe()
        
        # may run below again for different QC standards
        @time filter_lowQ_snp(maf = 0.02) # Note: to be decided.
        @time plot_imiss()
        @time filter_id(0.1)
        @time merge_into_3_sets()

        # to be tested
        @time beagle_impute()
    end
    
    function debug()
        print_desc("Testing ...")
        dir = "data/genotypes/german/v2"
        list = readdir(dir)
        fr2ped(dir, list, "tmp/plink.ped") # default acquire "AB" results
    end
    
    if test
        debug()
    else
        release()
    end
end
