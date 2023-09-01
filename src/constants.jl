# Constants hard wired everywhere
# export ClassHsGpa, ClassQuality, ClassAll;

const pkgDir = normpath(@__DIR__, "..");
const dataDir = joinpath(pkgDir, "data");

# use from BaseMM once imported there +++++
# abstract type AbstractClassification end;

# struct ClassAll <: AbstractClassification end;
n_groups(ds, ::ClassAll) = 1; 

# struct ClassHsGpa <: AbstractClassification end;
n_groups(ds, ::ClassHsGpa) = n_gpa(ds);

# struct ClassQuality <: AbstractClassification end;
n_groups(ds, :: ClassQuality) = n_colleges(ds);


abstract type AbstractMoment end;

struct MtMean <: AbstractMoment end;
sub_dir(::MtMean) = "Means";
# Prefix, wage regression fixed effect files only
wage_fe_prefix(::MtMean) = "mean";

struct MtStd <: AbstractMoment end;
sub_dir(::MtStd) = "StandardDeviations";
wage_fe_prefix(::MtStd) = "SD";

struct MtCount <: AbstractMoment end;
sub_dir(::MtCount) = "Counts";
wage_fe_prefix(::MtCount) = "N";

struct MtRegression <: AbstractMoment end;
sub_dir(::MtRegression) = "Regressions";


abstract type AbstractSelfOrTranscript end;
struct Transcript <: AbstractSelfOrTranscript end;
sub_dir(::Transcript) = "Transcripts";
struct SelfReport <: AbstractSelfOrTranscript end;
sub_dir(::SelfReport) = "SelfReport";

abstract type AbstractGroup end;
struct GrpFinance <: AbstractGroup end;
sub_dir(::GrpFinance) = "Financing";
struct GrpFreshmen <: AbstractGroup end;
sub_dir(::GrpFreshmen) = "Fresh_Char";
struct GrpHsGrads <: AbstractGroup end;
sub_dir(::GrpHsGrads) = "HS_Char";
struct GrpProgress <: AbstractGroup end;
sub_dir(::GrpProgress) = "Progress";
struct GrpNone <: AbstractGroup end;
sub_dir(::GrpNone) = "";


# Name of intercept regressor in raw data files.
const RegrInter = :cons;


## ------------  Data labels

# Comment string in CSV files
const commentStr = "#"
    
# School levels, used in files and file names.
const SchoolHSG = :HSG;
const SchoolSC = :SC;
const SchoolCG = :CG;
const EdLevels = [SchoolHSG, SchoolSC, SchoolCG];


# ----------
