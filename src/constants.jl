# Constants hard wired everywhere

const pkgDir = normpath(@__DIR__, "..");
const dataDir = joinpath(pkgDir, "data");

## -------------  Data types

# const Double = Float64
# # For no of courses
# const ncInt = UInt8
# # For time variables
# const TimeInt = UInt8
# # For indexing types
# # const TypeInt = UInt16
# # For indexing colleges
# const CollInt = UInt8
# # For indexing school levels
# const SchoolInt = UInt8
# For indexing grid points
# const GridInt = UInt16
# const CaseNameType = Union{Symbol, Vector{Symbol}}

abstract type AbstractMoment end;
struct MtMean <: AbstractMoment end;
sub_dir(::MtMean) = "Means";
struct MtStd <: AbstractMoment end;
sub_dir(::MtStd) = "StandardDeviations";
struct MtCount <: AbstractMoment end;
sub_dir(::MtCount) = "Counts";
struct MtRegression <: AbstractMoment end;
sub_dir(::MtRegression) = "Regressions";

abstract type AbstractSelfOrTranscript end;
struct Transcript <: AbstractSelfOrTranscript end;
sub_dir(::Transcript) = "Transcripts";
struct SelfReport <: AbstractSelfOrTranscript end;
sub_dir(::SelfReport) = "SelfReport";

# # Sub-dirs for data files
# dMomentType = Dict([
#     MtMean() => "Means",  
#     MtCount() => "Counts", 
#     MtStd() => "StandardDeviations", 
# 	MtRegression() => "Regressions"]);


# const MtMean = :mean;
# const MtStd = :std;
# const MtCount = :count;

# Name of intercept regressor in raw data files.
const RegrInter = :cons;

## -------------  Normalizations and Bounds

# Number of data courses per model course
# const dataCoursesPerCourse = 1	


## ------------  Data

# Comment string in CSV files
const commentStr = "#"
    
# School levels, used in files and file names.
const SchoolHSG = :HSG;
const SchoolSC = :SC;
const SchoolCG = :CG;

## --------------  Debugging

# const dbgLow = true
# const dbgMedium = true
# const dbgHigh = true

# # Required Julia version (as a version string)
# const minVersion = "1.4"



# ----------
