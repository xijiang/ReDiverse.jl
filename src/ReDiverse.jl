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
################################################################################

export sandbox_ReDiverse

work_dir = pwd()                # all dirs are relative to work_dir
beagle = "bin/beagle.jar"

include("abg-cmds.jl")
include("commonFunc.jl")
include("prepare-maps.jl")
include("raw-genotype-org.jl")
include("quality-control.jl")
include("makefile.jl")
include("imputation.jl")

include("work-flow.jl")

end # module
