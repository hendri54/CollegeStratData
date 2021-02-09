# Constants hard wired everywhere

const pkgDir = normpath(@__DIR__, "..");
const dataDir = joinpath(pkgDir, "data");

## -------------  Data types

const Double = Float64
# For no of courses
const ncInt = UInt8
# For time variables
const TimeInt = UInt8
# For indexing types
# const TypeInt = UInt16
# For indexing colleges
const CollInt = UInt8
# For indexing school levels
const SchoolInt = UInt8
# For indexing grid points
# const GridInt = UInt16
# const CaseNameType = Union{Symbol, Vector{Symbol}}




## -------------  Normalizations and Bounds

# Number of data courses per model course
# const dataCoursesPerCourse = 1	


## ------------  Data

# Comment string in CSV files
const commentStr = "#"
    


## --------------  Debugging

const dbgLow = true
const dbgMedium = true
const dbgHigh = true

# # Required Julia version (as a version string)
# const minVersion = "1.4"



# ----------
