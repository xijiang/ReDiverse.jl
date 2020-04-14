function myDebug()
    println("Ignoring data in data/genotypes/german/ld\n")
    println("Ignoring data in data/genotypes/german/md\n")

    platform = ["v2/", "v3/"]
    ofile = ["v2", "v3"]
    lmap = ["50kv2.map",  "50kv3.map"]
    
    dir = "data/genotypes/german/"
    mdr = "data/maps/"
    den = "data/genotypes/plink/german-"

    i = 2
    gdr = dir * platform[i] # genotype directory
    prx = den * ofile[i]    # prifix of the plink files
    ref = mdr * lmap[i]     # map reference
    @time merge_to_plink_bed(gdr, ref, prx)
end
