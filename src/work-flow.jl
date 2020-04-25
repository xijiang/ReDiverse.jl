"""
    general_work_flow()
# General guide line
You many follow this general procecure to repeat my analyses.
"""
function general_work_flow()
    # Data preparation
    if false              # Usually it is not necessary to run them from start
        prepare_maps()              # four maps, 50kv{1,2,3}, 777k
        orgGermanGT()               # To convert final reports to plink binaries
        orgDutchGT()
        orgNorgeGT()                # passed: Sat 18 Apr 2020 12:44:28 PM CEST
    end

    # Quality control, all data
    if false
        quality_control("data/plink", "notebooks/png")
    end

    # Create subset for imputation
    if false
        check_maps()
        check_maps_further()
        plink_subset_max()
        ReDiverse.quality_control("data/plkmax", "notebooks/qc2")
    end
end
