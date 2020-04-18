function sandbox()
    dir = "data/genotypes/dutch/"
    den = "data/plink/dutch-"
    mdr = "data/maps/dutch-ld/"

    println("Datch data, platform 11483")
    @time merge_to_plink_bed(dir*"11483/", mdr*"11483.map", den*"11483")
end
