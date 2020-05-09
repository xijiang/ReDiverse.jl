"""
    pkg ReDiverse
---

# General description
A package to organize and analysis ReDiverse data. Below are the `ToDo`s

# Urgent
- `Start imputation asap`

# General roadmap
1. Genotype collection, and convert to `plink` format.
2. [x] Genotype data clean
3. [x] Determine of SNP chip platforms, and final SNP set.
4. Imputation
5. GBLUP
6. Cross-validation strategy

"""
module ReDiverse
using Plots, Plots.Measures, LaTeXStrings, Test, Printf, ABG
using ABG: title, item, warning, message, done, fr2ped, empty_dir
################################################################################

beagle = "bin/beagle.jar"
work_dir = pwd()                # all dirs are relative to work_dir
isdir("tmp") || mkdir("tmp")

export sandbox_ReDiverse

include("commonFunc.jl")
include("prepare-maps.jl")
include("raw-genotype-org.jl")

include("auto-subset.jl")
include("quality-control.jl")
include("merge-n-impute.jl")

include("merge-n-filter-gt.jl")
include("clean-before-impute.jl")
#include("plink-cmd.jl")
include("makefile.jl")
include("test-funcs.jl")
include("prepare-tools.jl")

include("work-flow.jl")         # provides sandbox()
end # module
