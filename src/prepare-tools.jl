"""
    Below are instructions to download the (latest) versions of
    - plink
    - beagle.jar

    run `python3 src/get-beagle-url.py` to observe the latest beagle url.
    Download the version in `bin`, and make a soft link `beagle.jar` to
    this file.


    For plink do:
        git clone https://github.com/chrchang/plink-ng
        sudo dnf install perl-Digest-SHA   # if necessary

    then change the line:
        BLASFLAGS64     ?= -llapack -lf77blas -latlas
    in plink-ng/1.9/Makefile to:
        BLASFLAGS64     ?= -llapack -lf77blas

    run:
        ./plink_first_compile
    in plink-ng/1.9

    finally link plink 1.9 to bin/
"""
function updateTools()
    println("Please type at the REPL prompt:")
    println("  ?ReDiverse.updateTools")
    println("To see how to prepare `plink` and `beagle.jar` to date")
end
