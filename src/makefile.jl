"""
    make()
---
This is to make binaries from my C++ files.
It is supposed to run at the startup.
But thic can also be run after new C++ codes were written.
"""
function make()
    title("C++ binaries")
    isdir("bin") || mkdir("bin")
    bins = ["find-dup",
            "merge-dup"]
    for bin in bins
        if (!isfile("bin/$bin")) || (stat("bin/$bin").mtime < stat("src/$bin.cpp").mtime)
            print("g++ -O2 -Wall -o bin/$bin src/$bin.cpp")
            run(`g++ -O2 -Wall -o bin/$bin src/$bin.cpp`)
            done()
        else
            print("bin/$bin")
            done("OK")
        end
    end
end
