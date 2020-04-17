function sandbox()
    dir = "data/genotypes/dutch/"
    mdr = "data/maps/"
    den = "data/plink/dutch-"

    println("Dutch data, platform 50kv2")
    @time merge_to_plink_bed(dir*"54609/", mdr*"50kv2.map", "tmp/v2")
end
