function sandbox()
    sdir = "data/genotypes/final-vcf"
    countries = ["dutch", "german", "norge"]
    duplicates = "data/maps/duplicated.snp"
    for c in countries
        run(pipeline(`cat $sdir/$c.vcf`,
                     `bin/merge-dup $duplicates`, stdout="tmp/$c.vcf"))
    end
end
