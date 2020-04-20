"""
    pkg ReDiverse
---

# General description
A package to organize and analysis ReDiverse data. Below are the `ToDo`s

# Urgent
- `Convert Dutch genotypes of several platforms` with above maps
- `Considering unify maps`
- `Do quality check`
- `Start imputation asap`
## Done
- [x] Some Dutch maps

# General roadmap
1. Genotype collection, and convert to `plink` format.
2. [x] Genotype data clean
3. Determine of SNP chip platforms, and final SNP set.
4. Imputation
5. GBLUP
6. Cross-validation strategy

"""
module ReDiverse

using Plots, LaTeXStrings, GR
# using GR; GR.inline("pdf") or GR.inline("png")
# To avoid Error/Warning messages like:
# connect: Connection refused
# GKS: can't connect to GKS socket application
# 
# GKS: Open failed in routine OPEN_WS
# GKS: GKS not in proper state. GKS must be either in the state WSOP or WSAC in routine ACTIVATE_WS
# GKS: character ignored due to unicode error
# GKS: character ignored due to unicode error
# ......
# See: https://github.com/jheinen/GR.jl/issues/172
GR.inline("png")
#Plots.scalefontsizes(1)

export sandbox

include("commonFunc.jl")
include("prepare-tools.jl")
include("prepare-maps.jl")
include("raw-genotype-org.jl")
include("quality-control.jl")
include("work-flow.jl")
include("sandbox.jl")           # has the only exported funciton
end # module
