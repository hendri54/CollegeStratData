module CollegeStratData

using ArgCheck, DocStringExtensions, Parameters
using CSV, DataFrames
using CommonLH, EconometricsLH, FilesLH

# DataSettings
export DataSettings, default_data_settings, make_data_settings
export n_school, n_gpa, n_2year, n_colleges, n_parental, hsgpa_ub, parental_ub, hsgpa_masses, parental_masses, mass_gpa_yp, is_two_year, two_year_colleges, no_grad_idx, grad_idx, mean_by_gpa

# Helpers
export regressor_name

# export MomentTable, make_moment_table, get_moment, has_moment
# Data Files
export copy_raw_data_files, data_file, read_regression_file

# Scalar moments
export load_moment


include("constants.jl")
include("types.jl")
include("datasettings.jl")

# Data handling routines. Must come first.
include("raw_data_files.jl")
include("data_files.jl")
include("delim_xy_file.jl")
include("delim_single_col.jl")

# Individual data moments
include("scalar_moments.jl")
# include("worker_moments.jl")
include("by_gpa.jl")
include("by_gpa_yp.jl")
include("by_gpa_yp_qual.jl")
include("by_quality.jl")
# include("by_quality_parental.jl")
# include("by_quality_gpa.jl")
# include("by_parental.jl")
# include("regression_moments.jl")

# Processing all moments (must come last)
# include("show_deviations.jl")
# include("all_moments.jl")
# include("show_data.jl")
include("helpers.jl")


"""
	$(SIGNATURES)

Mapping of data moment names to functions that load them.
The user can then simply call `load_moment` to load any moment.
"""
moment_map() = Dict([
    :corrGpaYp => corr_gpa_yp,
    :fracEnter_gV => frac_enter_by_gpa,
    :fracEnter_gpM => load_entry_gpa_yp,
    :fracGrad => grad_rate,
    :fracGrad_gV => grad_rate_by_gpa,
    :mass_gpM => mass_by_gpa_yp,
    :timeToDrop_gV => time_to_drop_by_gpa,
    :timeToGrad_gV => time_to_grad_by_gpa,
    :workTime_gV => work_hours_by_gpa,
]);

"""
	$(SIGNATURES)

Load a data moment by name.
"""
function load_moment(ds :: DataSettings, mName :: Symbol)
    mm = moment_map();
    return mm[mName](ds)
end


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

end # module
