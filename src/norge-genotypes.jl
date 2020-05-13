"""
    split_h(file, ref.map, out)
---
Split the one final report `file` that consist more than one ID in one column.
Then use my other procedures to merge them to plink `out`.
"""
function split_h(file::AbstractString,
                  dic,
                  out::AbstractString)
    cd(work_dir)
    empty_dir("tmp")
    cd("tmp")
    _ = read(pipeline(`cat $work_dir/$file`,
                      `$work_dir/bin/split-h`),
             String)
    cd(work_dir)
    list = readdir("tmp")       # the newly created files
    fr2ped("tmp", list, "tmp/plink.ped", "Top")
    sample = list[1]
    create_plink_map("tmp/$sample", dic, "tmp/plink.map")
    ped_n_map_to_bed("tmp/plink.ped", "tmp/plink.map", out);
end

"""
    split_v(file, ref.map, out)
---
Split the one final report `file` that consist more than one ID in one row.
Then use my other procedures to merge them to plink `out`.
"""
function split_v(file::AbstractString,
                 dic,
                 out::AbstractString)
    cd(work_dir)
    empty_dir("tmp")
    cd("tmp")
    _ = read(pipeline(`cat $work_dir/$file`,
                      `$work_dir/bin/split-v`),
             String)
    cd(work_dir)
    list = readdir("tmp")
    fr2ped("tmp", list, "tmp/plink.ped", "Top")
    sample = list[1]
    create_plink_map("tmp/$sample", dic, "tmp/plink.map")
    ped_n_map_to_bed("tmp/plink.ped", "tmp/plink.map", out)
end

"""
    orgNorgeGT()
---
This is to mange Norwegian genotype data. Since the data were already in plink format, I just make
some soft links to `data/plink`

## Notes:
- Platform V2 needs special treatment
- It was converted to VCF format, and then converted to bed format again
  - to circumvent some HWE problem
- Need to find ou the reason later.

## Steps:

1. Merged final reports to plink.ped, using Top fields. Chromosome and bp info updated with 𝑣3
2. Removed non-autosomal SNP. Only loci on chr 1-29 left, according to 𝑣−3
3. Filtered loci of geno<0.9, maf<0.01, 𝑃hwe<10−4
4. Filtered ID with mind<0.95.
5. Removed dupicated loci.
6. Merged all platforms into 3 country sets.
7. Imputed results.
8. Remove country specific loci, and ready for 𝐆-matrix.
"""
function orgNorgeGT()
    title("About Norwegian data")

    item("Platform v1")
    cd(work_dir)
    fra = "data/genotypes/norge/v1"
    # remember to remove some ID
    # dic = ref_map_dict("data/maps/updated/v1.map")
    # split_h("$fra/FinalReport_54kV1_apr2009_ed1.txt", dic, "tmp/a")
    # split_h("$fra/FinalReport_54kV1_ed1.txt", dic, "tmp/a")

    item("Platform v2")
    cd(work_dir)
    fra = "data/genotypes/norge/v2"
    dic = ref_map_dict("data/maps/updated/v2.map")
    # split_v("$fra/151119_Geno_uttak3634_fillin3528_week47.txt", dic, "tmp/a")
    # split_h("$fra/151126_Geno_uttak_3664_fillin_3528_FinalReport_Standard.txt", dic, "tmp/a")
    # split_h("$fra/151210_Geno_uttak3692_fillin_3528_4samples3634_FinalReport_Geno-GS.txt", dic, "tmp/a")
    # split_h("$fra/151216_Geno_uttak3713_fillin_3528_3715_week51_FinalReport_Geno_GS.txt", dic, "tmp/a")
    # split_h("$fra/160115_Geno_3738_fillin_FinalReport_TN_Geno_GS.txt", dic, "tmp/a")
    # split_h("$fra/160127_Geno_uttak3771_fillin3715_week04_FinalReport_Geno_GS.txt", dic, "tmp/a")
    # split_h("$fra/160211_Geno_uttak3793_fillin3715_FinalReport_Geno_GS.txt", dic, "tmp/a")
    # split_h("$fra/160225_Geno_uttak_3817_pl1-2_fillin_3715_3809_FinalReport_Geno_GS.txt", dic, "tmp/a")
    # split_h("$fra/160310_Geno_uttak3848_fillin3809_week10_72samples_FinalReport_Geno_GS.txt", dic, "tmp/a")
    # split_h("$fra/160310_Geno_uttak3848_fillin3809_week10_raw_23samples_chip80_FinalReport_Geno_GS.txt", dic, "tmp/a")
    # for i in 1:5
    #     split_v("$fra/FinalReport_54kV2_collection2.txt.$i", dic, "tmp/a")
    # end
    # for i in 1:56
    #     split_v("$fra/FinalReport_54kV2_collection_ed1.txt.$i", dic, "tmp/a")
    # end
    # split_h("$fra/FinalReport_54kV2_ed1.txt", dic, "tmp/a")
    # split_h("$fra/FinalReport_54kV2_feb2011_ed1.txt", dic, "tmp/a")
    # split_h("$fra/FinalReport_54kV2_genoskan.txt", dic, "tmp/a")
    # split_v("$fra/FinalReport_54kV2_nov2011_ed1.txt", dic, "tmp/a")
end
#=
     1  170126_Geno_uttak_4352_777K_autoclustered_FinalReport.txt
     2  171025_HG_BovineHD_plate1-5_FinalReport_GenoGS.txt
     3  171107_Geno_BovineHD_uttak4818_FinalReport_matrix.txt
     4  180317_Geno777_uttak5097_96samples_Geno-cluster_FinalReport.txt
     5  181119_Geno777_uttak5526_96samples_FinalReport_Geno-cluster.txt
     6  FinalReport_777k_apr2015.txt
     7  FinalReport_777k_jan2015.txt
     8  FinalReport_777k_jun2015.txt
     9  FinalReport_777k.txt
Also check the 0.9291 problem. It must be a problem from split-v.cpp.
=#
