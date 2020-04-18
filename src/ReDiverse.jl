"""
    pkg ReDiverse
---

# General description
A package to organize and analysis ReDiverse data. Below are the `ToDo`s

# Urgent
- `Some Dutch maps`
- `Convert Dutch genotypes of several platforms` with above maps
- `Considering unify maps`
- `Do quality check`
- `Start imputation asap`
# General roadmap
1. Genotype collection, and convert to `plink` format.
2. [x] Genotype data clean
3. Determine of SNP chip platforms, and final SNP set.
4. Imputation
5. GBLUP
6. Cross-validation strategy
"""
module ReDiverse
export sandbox

include("commonFunc.jl")
include("prepare-tools.jl")
include("prepare-maps.jl")
include("raw-genotype-org.jl")

include("work-flow.jl")

include("sandbox.jl")           # the only exported funciton
end # module
