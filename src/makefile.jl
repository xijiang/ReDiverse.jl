"""
    make()
---
This is to make binaries from my C++ files.
It is supposed to run at the startup.
But thic can also be run after new C++ codes were written.
"""
function make()
    isdir("bin") || mkdir("bin")
    #gpp = "g++ -O2 -Wall"
    bins = ["fr2ped",
            "keep-vcf-snp",
            "merge-dup",
            "trans",
            "triallele",
            "vcf-filter-id",
            "vcf-filter-maf",
            "vcf-filter-snp",
            "rm-low-Q-loci",
            ]
    for exe in bins
        print("bin/$exe")
        if (!isfile("bin/$exe")) || (stat("bin/$exe").mtime < stat("src/$exe.cpp").mtime)
            run(`g++ -O2 -Wall -o bin/$exe src/$exe.cpp`)
            print_done()
        else
            print_done("OK")
        end
    end
end
