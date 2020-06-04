"""
    make()
---
This is to make binaries from my C++ files.
It is supposed to run at the startup.
But thic can also be run after new C++ codes were written.
"""
function make()
    title("C++ binaries")
    cd(work_dir)
    isdir("bin") || mkdir("bin")
    cpp = "cpp"
    bins = ["find-dup",
            "merge-dup",
            "split-h",
            "split-v",
            "merge4grm",
            "pedsort",
            "merge-ped"]
    for bin in bins
        if (!isfile("bin/$bin")) || (stat("bin/$bin").mtime < stat("$cpp/$bin.cpp").mtime)
            print("g++ -O2 -Wall -o bin/$bin $cpp/$bin.cpp")
            run(`g++ -O2 -Wall -o bin/$bin $cpp/$bin.cpp`)
            done()
        else
            print("bin/$bin")
            done("OK")
        end
    end
end
