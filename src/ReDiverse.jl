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
using Plots, LaTeXStrings, Test, Printf
plink  = "bin/plink"
beagle = "bin/beagle.jar"

export sandbox

include("commonFunc.jl")
include("prepare-tools.jl")
include("prepare-maps.jl")
include("raw-genotype-org.jl")
include("quality-control.jl")
include("extract-loci.jl")
include("merge-n-filter-gt.jl")
include("plink-cmd.jl")
include("print-styles.jl")
include("test-funcs.jl")

include("work-flow.jl")
include("sandbox.jl")           # has the only exported funciton
end # module
