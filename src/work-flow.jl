"""
    general_work_flow()
# General guide line
You many follow this general procecure to repeat my analyses.
"""
function general_work_flow()
    function print_procedure(proc)
        for p in proc
            println(p)
        end
    end
    print_msg("'from' and 'to' below need to be specified. See work-flow.jl")
    print_sst("Data preparation")
    proc = ["prepare_maps()", "orgGermanGT()", "orgDutchGT()", "orgNorgeGT()"]
    print_procedure(proc)
    if false              # Usually it is not necessary to run them from start
        prepare_maps()              # four maps, 50kv{1,2,3}, 777k
        orgGermanGT()               # To convert final reports to plink binaries
        orgDutchGT()
        orgNorgeGT()                # passed: Sat 18 Apr 2020 12:44:28 PM CEST
    end

    print_sst("Quality control, all data")
    print_procedure(["quality_control(from, to)"])
    if false
        quality_control("data/plink", "notebooks/png")
    end
    #=
    print_sst("Create subset for imputation")
    proc = ["check_maps()", "check_maps_furthre()", "plink_subset_max()", "quality_control(from, to)", "merge_into_3_sets()"]
    print_procedure(proc)
    if false
        check_maps()
        check_maps_further()
        plink_subset_max()
        quality_control("data/plkmax", "notebooks/qc2")
        merge_into_3_sets()
    end
    =#
end
