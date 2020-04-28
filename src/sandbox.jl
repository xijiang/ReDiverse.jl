function sandbox()
    set = Set(["Hapmap43437-BTA-101873", "ARS-BFGL-NGS-16466"])
    dic = snp_gt_dict("tmp/german.vcf", set)
    println(dic["Hapmap43437-BTA-101873"])
    #=
    java -ea -Xmx3G -jar $bin/beagle.jar \
	     nthreads=$nthreads \
	     ref=ref.vcf.gz \
	     gt=msk.vcf.gz \
	     ne=$ne \
	     out=imp >/dev/null
    =#
end
