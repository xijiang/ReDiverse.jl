"""
    make()
---
This is to make binaries from my C++ files.
It is supposed to run at the startup.
But thic can also be run after new C++ codes were written.
"""
function make()
    title("C++ binaries")
    isdir(rdBin) || mkdir(rdBin)
    bins = ["find-dup",
            "merge-dup",
            "split-h",
            "split-v",
            "raw2gt",
            "pedsort",
            "merge-ped"]
    width = 60
    for bin in bins
        exe = joinpath(rdBin, bin)
        cpp = joinpath(rdCpp, "$bin.cpp")
        if !isfile(exe) || stat(exe).mtime < stat(cpp).mtime
            msg = "g++ -O2 -Wall $bin.cpp -o $bin"
            print(lpad(msg, width))
            run(`g++ -O2 -Wall -o $exe $cpp`)
            done()
        else
            print(lpad(bin, width))
            done("OK")
        end
    end
end
