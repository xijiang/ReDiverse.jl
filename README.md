# ReDiverse.jl
There are two ways to use these codes. 

1. One is to install `ReDiverse` as a `Julia` package.
2. The other way is to clone a local copy, e.g.,

```bash
git clone https://github.com/xijiang/ReDiverse.jl ReDiverse
```

I will refer `path-to/ReDiverse` in 2, or the working directory in 1 as the `work` directory later.

## Data organization
In `work`, the `data` directory structure is as below:
- data/
  - maps
    - **dutch-ld**: 3 dutch LD maps
    - **illumina**: v1,2,3 and 7 manifests
  - genotypes
    - dutch
      - **d1**: platform 10690. stores all the final reports with this platform. similar below
      - **d2**: 10993
      - **d3**: 11483
      - **v2**: 54609
      - **v3**: 53218
      - **v7**: 777962
    - german
      - v2, v3
    - norge
      - v1, v2, v7
      
## Anaysis

### Package requirement
- Test, Printf, Plots, LaTeXStrings

### Usage of the codes
- After clone or add to packages, you may run `test` in package environment.
- File `work-flow.jl` has all the blocks for this projects.  It also has the only exported function `sandbox()`.
  - call `sandbox()`, or `sandbox(true)` to run functions in debug block.
  - call `sandbox(false)` to run all tested functions in release block.

## Reports
Reports can be found in `notebooks`.

## Tools outside this package
Program `plink` and `beagle.jar` should be ready in `work/bin/`.
