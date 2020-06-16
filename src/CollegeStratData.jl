module CollegeStratData

using ArgCheck, DocStringExtensions
using CSV, DataFrames
using CommonLH, EconometricsLH, FilesLH

# DataSettings
export DataSettings, make_data_settings, test_data_settings
export n_school, n_gpa, n_2year, n_colleges, n_parental, hsgpa_ub, parental_ub, hsgpa_masses, parental_masses, mass_gpa_yp, can_graduate, is_two_year, two_year_colleges, four_year_colleges, no_grad_idx, grad_idx, mean_by_gpa

# Helpers
export regressor_name, const_regressor, const_regressor_name, regressor_string, regressor_strings, gpa_regressors, parental_regressors, quality_regressors, school_regressors

# Data Files
export copy_raw_data_files, data_file, read_regression_file

# Moments
export load_moment, n_entrants
export exper_profile, wage_regr_intercepts, workstart_earnings, wage_regr_grads

export cdf_gpa_by_qual


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
# include("show_deviations.jl")
# include("show_data.jl")
include("helpers.jl")


"""
	$(SIGNATURES)

Mapping of data moment names to functions that load them.
The user can then simply call `load_moment` to load any moment.
"""
moment_map() = Dict([
    :corrGpaYp => corr_gpa_yp,
    :coursesTried_qtM => courses_tried_qual_year,
    :cumLoans_qtM => cum_loans_qual_year,
    :fracEnroll_qV => frac_enroll_by_qual,
    :fracEnter_gV => frac_enter_by_gpa,
    :fracEnter_pV => frac_enter_by_parental,
    :fracEnter_gpM => load_entry_gpa_yp,
    # Fraction in each quality among [gpa, yp] entrants
    :fracEnter_gpqM => load_qual_entry_gpa_yp_all,
    :fracGrad => grad_rate,
    :fracGrad_gV => grad_rate_by_gpa,
    :fracGrad_qV => grad_rate_by_quality,
    :fracGrad_qpM => frac_grad_qual_parental,
    :fracGrad_qgM => grad_rate_qual_gpa,
    :fracQual_qpM => frac_qual_by_parental,
    :fracQual_qgM => frac_qual_by_gpa,
    :gpaMean_qV => afqt_mean_by_quality,
    :mass_gpM => mass_by_gpa_yp,
    :massEntry_qgM => mass_entry_qual_gpa,
    :studyTime => mean_study_time,
    :studyTime_qV => mean_study_times_by_qual,
    :studyTime_qgM => study_time_qual_gpa,
    :timeToDrop_gV => time_to_drop_by_gpa,
    :timeToDrop_qV => time_to_drop_by_quality,
    :timeToDrop_qgM => time_to_drop_qual_gpa,
    :timeToGrad_gV => time_to_grad_by_gpa,
    :timeToGrad_qV => time_to_grad_by_quality,
    :timeToGrad_qpM => time_to_grad_qual_parental,
    :tuition_qV => college_tuition,
    :workTime_gV => work_hours_by_gpa,
    :workTime_qV => work_hours_by_qual,
    :workTime_pV => work_hours_by_parental,
    # Regressions
    :transferRegr => transfer_regr,
    :tuitionRegr => tuition_regr,
    :wageRegrIntercepts => wage_regr_intercepts,
    :wageRegrGrads => wage_regr_grads
]);

"""
	$(SIGNATURES)

Load a data moment by name.
"""
function load_moment(ds :: DataSettings, mName :: Symbol)
    mm = moment_map();
    return mm[mName](ds)
end


end # module
