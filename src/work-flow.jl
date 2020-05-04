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
        @time update_norge_map() # 
    end
    
    function debug()
        print_desc("Testing ...")
    end
    
    if test
        debug()
    else
        release()
    end
end
