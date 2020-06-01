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
4. [x] Imputation → multi-breed GRM
5. GBLUP
6. Cross-validation strategy

"""
module ReDiverse
using Plots, Plots.Measures, LaTeXStrings, Test, Printf, DataFrames, CSV
using Statistics, LinearAlgebra
################################################################################

export sandbox_ReDiverse

work_dir = pwd()                # all dirs are relative to work_dir
beagle = "bin/beagle.jar"

include("commonFunc.jl")
include("genotype/prepare-maps.jl")
include("genotype/raw-genotype-org.jl")
include("genotype/norsk-genotypes.jl")
include("genotype/quality-control.jl")
include("imputation.jl")
include("calc-grm.jl")
include("check-grm.jl")
include("utils/abg-cmds.jl")
include("utils/makefile.jl")

include("work-flow.jl")

end # module
