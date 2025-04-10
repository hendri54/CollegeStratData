module CollegeStratData

using ArgCheck, DocStringExtensions
using CSV, DataFrames, DelimitedFiles
using CommonLH, EconometricsLH, FilesLH
using BaseMM, DataCollegeStrat;

# DataSettings
export DataSettings, make_data_settings, test_data_settings
export n_gpa, n_2year, n_parental, hsgpa_ub, parental_ub, hsgpa_masses, parental_masses, mass_gpa_yp, can_graduate, is_two_year, two_year_colleges, four_year_colleges, no_grad_idx, grad_idx, mean_by_gpa

# Helpers
export regressor_name, regressor_string, regressor_strings, gpa_regressors, parental_regressors, quality_regressors, school_regressors;

# Data Files
export data_file, missing_file_list, read_regression_file, raw_file
export file_name_differences, compare_dirs

# Moments
export load_moment, n_entrants
export exper_profile, wage_regr_intercepts, workstart_earnings, wage_regr_grads
export get_regr_coef, get_intercept, has_intercept;

export cdf_gpa_by_qual


include("constants.jl")

# Types
include("types.jl")
include("wage_regressions.jl")
include("datasettings.jl")
include("excel_files.jl");

# Data handling routines. Must come first.
include("raw_data_files.jl");
include("each_raw_file.jl");
include("data_files.jl")
include("delim_xy_file.jl")
include("delim_single_col.jl");
include("regression_files.jl");

# Individual data moments
include("scalar_moments.jl")
include("worker_moments.jl");
include("by_year.jl");
include("by_gpa.jl")
include("by_gpa_yp.jl")
include("by_gpa_yp_qual.jl")
include("by_quality.jl")
include("by_quality_parental.jl")
include("by_quality_gpa.jl")
include("by_parental.jl")
include("by_grad_year.jl");
include("regression_moments.jl");
include("wage_fixed_effects.jl");

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
    :collEarn_qpM => coll_earn_qual_parental,
    :collEarn_qV => coll_earn_by_qual,
    :collEarn_pV => coll_earn_by_parental,
    :coursesTried_otM => courses_tried_grad_year,
    :coursesTried_qtM => courses_tried_qual_year,
    :cumLoans_qptM => cum_loans_qual_yp_year,
    :cumLoans_qtM => cum_loans_qual_year,
    :cumLoans90_qtM => cum_loans90_qual_year,
    :cumLoans90_tV => cum_loans90_year,
    :cumFracDropYr2_qgM => cum_frac_drop_yr2_qual_gpa,
    :fracDrop4y_tV => frac_drop_4y_by_year,
    :fracDrop_qtM => frac_drop_qual_year,
    :fracDrop_gtM => frac_drop_gpa_year,
    :fracEnroll_qV => frac_enroll_by_qual,
    :fracEnrollUncond_qV => frac_enroll_uncond_by_qual,
    :fracEnter_gV => frac_enter_by_gpa,
    :fracEnter_pV => frac_enter_by_parental,
    :fracEnter_gpM => load_entry_gpa_yp,
    :fracEnter => frac_enter,
    :fracGrad => frac_gradc,
    :fracGrad_gV => frac_gradc_by_gpa,
    :fracGrad_qV => frac_gradc_by_quality,
    :fracGrad_pV => frac_gradc_by_parental,
    :fracGrad_qpM => frac_gradc_qual_parental,
    :fracGrad_qgM => frac_gradc_qual_gpa,
    :fracLocal_qV => frac_local_by_quality,
    # Fraction in each quality among [gpa, yp] HS grads (conditional on entry)
    :fracQual_qgpM => (ds -> load_qual_entry_gpa_yp(ds; conditionalOnEntry = true)),
    :fracQual_qpM => frac_qual_by_parental,
    :fracQual_qgM => frac_qual_by_gpa,
    :fracGpa_gqM => frac_gpa_by_qual,
    :gpaMean_qV => afqt_mean_by_quality,
    :mass_gpM => mass_by_gpa_yp,
    :massEntry_qgM => mass_entry_qual_gpa,
    :massEntry_qpM => mass_entry_qual_parental,
    :massGrad_qgM => mass_grad_qual_gpa,
    :massGrad_qpM => mass_grad_qual_parental,
    # :statusByYear => status_by_year,  # File does not work without transfer students
    :studyTime => study_time,
    :studyTime_qV => study_time_qual,
    :studyTime_qgM => study_time_qual_gpa,
    :timeToDrop4y_gV => time_to_drop_4y_by_gpa,
    :timeToDrop4y_qV => time_to_drop_4y_by_quality,
    :timeToDrop4y_qgM => time_to_drop_4y_qual_gpa,
    :timeToGrad4y_gV => time_to_grad_4y_by_gpa,
    :timeToGrad4y_qV => time_to_grad_4y_by_quality,
    :timeToGrad4y_qpM => time_to_grad_4y_qual_parental,
    :timeToGrad4y_qgM => time_to_grad_4y_qual_gpa,
    :transfers_qgM => (ds -> transfers_xy(ds, [:qual, :gpa])),
    :transfers_qpM => (ds -> transfers_xy(ds, [:qual, :parental])),
    :tuition_qgM => (ds -> net_price_xy(ds, [:qual, :gpa])),
    :tuition_qpM => (ds -> net_price_xy(ds, [:qual, :parental])),
    :tuition_qV => college_tuition,
    :wageFe_sgM => (ds -> wage_fixed_effects(ds, ClassHsGpa())),
    :wageFe_sqM => (ds -> wage_fixed_effects(ds, ClassQuality())),
    :wageFe_sV => (ds -> wage_fixed_effects(ds, ClassAll())),
    :workTime_gV => work_hours_by_gpa,
    :workTime_qV => work_hours_by_qual,
    :workTime_pV => work_hours_by_parental,
    # Regressions
    :transferRegr => transfer_regr,
    :transferRegrQpInteractions => transfer_regr_w_qp_interactions,
    :tuitionRegr => tuition_regr,
    :tuitionRegrQpInteractions => tuition_regr_w_qp_interactions,
    :wageRegrIntercepts => wage_regr_intercepts,
    :wageRegrGrads => wage_regr_grads
    ]);

"""
	$(SIGNATURES)

Load a data moment by name.

For regression moments, this returns a `RegressionTable`. For other moments, it returns means, std errors of means, and cell counts.
"""
function load_moment(ds :: DataSettings, mName :: Symbol)
    mm = moment_map();
    if !haskey(mm, mName)
        error("Moment $mName does not exist");
    end
    return mm[mName](ds)
end


end # module
