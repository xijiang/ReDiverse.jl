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
   - [x] GRM validation
5. GBLUP
6. Cross-validation strategy

"""
module ReDiverse
using Test
# , Printf, DataFrames, CSV
# using Statistics, LinearAlgebra
################################################################################

export sandbox_ReDiverse

work_dir = pwd()                # all data and results are relative to work_dir
rdDir = begin                   # package directory
    t = splitdir(pathof(ReDiverse))[1]
    l = findlast('/', t) - 1
    t[1:l]
end
rdBin = joinpath(rdDir, "bin")
rdCpp = joinpath(rdDir, "src/cpp")

beagle = joinpath(rdBin, "beagle.jar")
plink = joinpath(rdBin, "plink")

#include("work-flow.jl")
#
## raw genotype orgnization
#include("genotype/prepare-maps.jl")
#include("genotype/raw-genotype-org.jl")
#include("genotype/norsk-genotypes.jl")
#include("genotype/quality-control.jl")
#include("genotype/imputation.jl")
#
## about the genomic relationship matrix
#include("grm/calc-grm.jl")
#include("grm/check-grm.jl")
#
## some utilities
#include("utils/makefile.jl")
#include("utils/commonFunc.jl")

#include("utils/abg-cmds.jl")
end # module
