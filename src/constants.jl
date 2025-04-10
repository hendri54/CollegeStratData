# Constants hard wired everywhere

const pkgDir = normpath(@__DIR__, "..");
const dataDir = joinpath(pkgDir, "data");

n_groups(ds, ::ClassAll) = 1; 
n_groups(ds, ::ClassHsGpa) = n_gpa(ds);
n_groups(ds, :: ClassQuality) = n_colleges(ds);
n_groups(ds, ::ClassParental) = n_parental(ds);
n_groups(ds, ::ClassSchooling) = n_school(ds);

# Groupings for file names
const grpQuality = :qual;
const grpGpa = :afqt;
const grpParental = :yp;

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


## -----------  Raw regression files

# Name of intercept regressor in raw data files.
const RegrInter = :cons;
const RegrQualVar = :last_type;
const RegrGpaVar = :afqt;
const RegrParentalVar = :inc_quartile;


## ------------  Other raw data files

const AllColHeaderGpa = "afqt_quartileALL";
const AllRowHeader = "All";

## ------------  Data labels

# Comment string in CSV files
const commentStr = "#"
    
# School levels, used in files and file names.
const SchoolHSG = :HSG;
const SchoolSC = :SC;
const SchoolCG = :CG;
const EdLevels = [SchoolHSG, SchoolSC, SchoolCG];


# ----------
