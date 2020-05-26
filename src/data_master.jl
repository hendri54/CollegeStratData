"""
    Data

Construct data targets for calibration.
Read data from CSV files. Make them into named `Deviations` (using `ModelParams`).

Everything is converted into model units.

Each deviation shows up in several places:
1. `MomentTable` defines locations of data files
2. each deviation has a function that constructs it (e.g. `entry_by_gpa_yp`)
3. each deviation that is used in any of the model versions is listed in `make_deviation`

Adding a deviation
1. Locate the moments in a green table in the excel files
2. Locate the corresponding `dat` file
3. Add an entry in 'MomentTable'
4. Write a function that reads the `dat` file and converts it into a `Deviation`

"""

export DataMoment, DataSettings
export MomentTable, make_moment_table, get_moment, has_moment
export copy_raw_data_files


# Data handling routines. Must come first.
include("data_files.jl")
include("delim_xy_file.jl")
include("delim_single_col.jl")

# Individual data moments
include("scalar_moments.jl")
include("worker_moments.jl")
include("by_gpa.jl")
include("by_gpa_yp.jl")
include("by_gpa_yp_qual.jl")
include("by_quality.jl")
include("by_quality_parental.jl")
include("by_quality_gpa.jl")
include("by_parental.jl")
include("regression_moments.jl")

# Processing all moments (must come last)
include("show_deviations.jl")
include("all_moments.jl")
include("show_data.jl")
include("helpers.jl")




## --------------  Moment stubs


## Borrowing limits
#=
From 
    Wei, Christina Chang, and Lutz Berkner. 2008. “Trends in Undergraduate Borrowing II: Federal Student Loans in 1995-96, 1999-2000, and 2003-04. Postsecondary Education Descriptive Analysis Report. NCES 2008-179.” National Center for Education Statistics. Table 1.
Using data for dependent students (73% in 1999/2000) (many independent students are older). 
=#
function borrow_limits(ds :: DataSettings; modelUnits :: Bool = true)
    overallMax = 23000.0;
    annualMax = vcat([2625.0, 3500.0], fill(5500.0, 4));
    borrowLimitV = min.(overallMax, cumsum(annualMax));
    if modelUnits
        borrowLimitV = dollars_data_to_model(borrowLimitV, :perYear);
    end
    return borrowLimitV
end

# ---------------