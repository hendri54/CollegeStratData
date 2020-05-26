"""
    $(SIGNATURES)

Make deviation vector by parsing vector of deviation functions.
Each function returns a `ModelParams.AbstractDeviation`.

Only stores deviations actually used by the model. This is determined by `calTargetV` (from `Case`). Its keys match entries in `MomentTable`.

Requires that all raw data files have been copied to local dir.
When deviation function is Nothing: error.
"""
function make_deviation_vector(ds :: DataSettings, calTargetV :: TargetMoments)
    dv = ModelParams.DevVector();

    mTable = make_moment_table();
    for dm in mTable
        mStat = dev_name(dm);
        if is_used(calTargetV, mStat)
            if has_moment(mTable, mStat)
                # dm = get_moment(mTable, mStat);
                @assert !isnothing(dm.devFct)  "devFct required if used in calibration."
                # Make the `Deviation` object
                dev = dm.devFct(ds);
                @assert isa(dev, AbstractDeviation)  "Not a Deviation: $dev"
                ModelParams.append!(dv, dev);
            else
                error("calTarget not found: $mStat")
            end
        end
    end
    return dv :: DevVector
end



## ------------  Map named moments to model statistics

moments_to_stats() = Dict([
    # Aggregates
    :meanStudyTime => (:meanStudyTime, :none),
    :corrGpaYp => (:corrGpaYp, :none),
    :fracGrad => (:fracGrad, :none),
    :ltyMean_sV => (:ltyMean_sV, :none),
    # By ability
    :fracEnter_aV => (:fracEnter_gV, :abilS),
    :fracGrad_aV => (:fracGrad_gV, :abilS),
    # By ability / parental
    :fracEnter_apM => (:fracEnter_xyM, :abilYpS),
    :fracGrad_apM => (:fracGrad_xyM, :abilYpS),
    :transfer_apM => (:transfer_xyM, :abilYpS),
    :tuition_apM => (:tuition_xyM, :abilYpS),
    # By quality / parental
    :fracGrad_qpM => (:fracGrad_xyM, :qualYpS),
    :timeToGrad_qpM => (:timeToGrad_xyM, :qualYpS),
    # By gpa / parental / quality
    :fracEnter_gpqM => (:fracEnter_xyqM, :gpaYpQualS)
    ]);

function model_stat(statName :: Symbol)
    ms = moments_to_stats();
    if haskey(ms, statName)
        return ModelStatistic(ms[statName]...);
    else
        # Fallback
        return ModelStatistic(statName);
    end
end


## -----------  Common code

function frac_enter_dev(target :: Symbol, m :: Vector{F1}, group :: Symbol) where F1 <: AbstractFloat

    dev = Deviation{Double}(name = target, dataV = m, modelV = m,
        scalarWt = 1.5 / length(m),
        shortStr = String(target),
        longStr = "Entry rates by " * make_label(group), 
        showPath = file_name("fracEnter", group, ".dat"))
    return dev
end

function frac_grad_dev(target :: Symbol, m :: Vector{F1}, group :: Symbol) where F1 <: AbstractFloat

    dev = Deviation{Double}(name = target, dataV = m, modelV = m,
        scalarWt = 3.0 / length(m),
        shortStr = String(target),
        longStr = "Graduation rate by " * make_label(group), 
        showPath = file_name("fracGrad", group, ".dat"));
    return dev
end

function time_to_drop_dev(target :: Symbol, m :: Vector{F1}, group :: Symbol) where F1 <: AbstractFloat

    dev = Deviation{Double}(name = target, dataV = m, modelV = m,
        scalarWt = 1.0 / length(m),
        shortStr = String(target),
        longStr = "Time to dropout by " * make_label(group), 
        showPath = file_name("timeToDrop", group, ".dat"));
    return dev
end

function time_to_grad_dev(target :: Symbol, m :: Vector{F1}, group :: Symbol) where F1 <: AbstractFloat

    dev = Deviation{Double}(name = target, dataV = m, modelV = m,
        scalarWt = 1.0 / length(m),
        shortStr = String(target),
        longStr = "Time to graduate by " * make_label(group), 
        showPath = file_name("timeToGrad", group, ".dat"));
    return dev
end

function work_hours_dev(target :: Symbol, m :: Vector{F1}, group :: Symbol) where F1 <: AbstractFloat

    dev = Deviation{Double}(name = target, dataV = m, modelV = m,
        wtV = 1.0 ./ m,  scalarWt = 8.0 / length(m),
        shortStr = String(target),
        longStr = "Work hours by " * make_label(group), 
        showPath = file_name("workHours", group, ".dat"))
    return dev
end


## ---------------  Define all moments


# -----  Aggregates
# Scalar, therefore no show function or raw data file

# Mean study time; all students
function dm_mean_study_time()
    target = :meanStudyTime;
    return DataMoment(target,  model_stat(target),  string(target),  nothing, 
        dev_mean_study_time, nothing);
end

function dm_corr_gpa_yp()
    target = :corrGpaYp;
    return DataMoment(target, model_stat(target),  
        "corrGpaYp", nothing, corr_gpa_yp, nothing)
end

function dm_grad_rate()
    target = :fracGrad;
    return DataMoment(target,  model_stat(target),  string(target),
        nothing,  grad_rate,  nothing);   
end


## ------------  By schooling

function dm_pen_lty_school()
    target = :penLtySchool;
    return DataMoment(target,  model_stat(:ltyMean_sV),  string(target),
        nothing,  pen_lty_school, nothing);
end

function dm_pen_h_gains()
    target = :penHGains;
    return DataMoment(target,  ModelStatistic(:hGainWorkStart_sV),  string(target),
        nothing,  pen_h_gains, nothing);
end


# -------  By quality

# Net college price, year 1. Not actually a target, but constructed as one (could be a target later)
function dm_net_price_by_quality()
    return DataMoment(:netPriceQual,  ModelStatistic(:netPrice_gV, :qualS),
        file_name("netPrice", :quality, ".dat"),  nothing,
        net_college_price, show_dev_by_quality);
end

# Hours worked, year 1
function dm_work_hours_by_qual()
    return DataMoment(:workTime_qV,  ModelStatistic(:workTime_gV, :qualS),
        file_name("workHours", :quality, ".dat"),  nothing,  
        work_hours_by_quality, show_dev_by_quality)
end

# Mean AFQT percentile by college quality group
# Freshmen
function dm_afqt_mean_by_quality()
    return DataMoment(:gpaMean_qV,  ModelStatistic(:gpaMean_gV, :qualS),
        file_name("afqtMean", :quality, ".dat"),  nothing,
        afqt_mean_by_quality, show_dev_by_quality);
end

function dm_grad_rate_by_quality()
    return DataMoment(:fracGrad_qV,  ModelStatistic(:fracGrad_gV, :qualS),
        file_name("fracGrad", :quality, ".dat"),  nothing,
        grad_rate_by_quality,  show_dev_by_quality);
end

function dm_time_to_drop_by_qual() 
    return DataMoment(:timeToDrop_qV,  ModelStatistic(:timeToDrop_gV, :qualS),
        file_name("timeToDrop", :quality, ".dat"),  nothing,
        time_to_drop_by_quality,  show_dev_by_quality);
end

function dm_time_to_grad_by_qual() 
    return DataMoment(:timeToGrad_qV,  ModelStatistic(:timeToGrad_gV, :qualS),
        file_name("timeToGrad", :quality, ".dat"),  nothing,
        time_to_grad_by_quality,  show_dev_by_quality);
end


# ----------  By quality / parental

# Conditional on enrollment: fraction in each quality given parental
dm_frac_qual_by_parental() =
    DataMoment(:fracQual_qpM,
        ModelStatistic(:fracEntrants_x_yM, :qualYpS),
        "frac_qual_by_parental.dat", nothing,
        frac_qual_by_parental, plot_quality_yp);
    
dm_frac_grad_qual_parental() =
    DataMoment(:fracGrad_qpM,  model_stat(:fracGrad_qpM),
        file_name("fracGrad", [:quality, :parental], ".dat"), nothing,
        frac_grad_qual_parental, plot_quality_yp);

dm_time_to_grad_qual_parental() =
    DataMoment(:timeToGrad_qpM,  model_stat(:timeToGrad_qpM),
        file_name("timeToGrad", [:quality, :parental], ".dat"),  nothing,
        time_to_grad_qual_parental, plot_quality_yp);

    
# -----------  By quality / grad status

function dm_pen_earn_qual_grad()
    target = :earnWorkStart_qgM;
    return DataMoment(target, ModelStatistic(target, :qualGradS),
        "pen_earn_qual_grad.dat",  nothing,  
        pen_earn_qual_grad,  nothing)
end


# --------------  By quality / gpa

fn_qual_gpa(baseName) = file_name(baseName, [:quality, :gpa], ".dat");

function dm_time_to_drop_qual_gpa()
    target = :timeToDrop_qgM;
    return DataMoment(target, ModelStatistic(:timeToDrop_xyM, :qualGpaS),  
        fn_qual_gpa("timeToDrop"),  nothing, 
        time_to_drop_qual_gpa, plot_quality_gpa)
end

# Study time. No raw data file. Different source.
function dm_study_time_qual_gpa()
    target = :studyTime_qgM;
    return DataMoment(target, ModelStatistic(:studyTime_xyM, :qualGpaS),  
        fn_qual_gpa("studyTime"),  nothing,  study_time_qual_gpa, plot_quality_gpa);
end

function dm_grad_rate_qual_gpa()
    target = :fracGrad_qgM;
    return DataMoment(target, ModelStatistic(:fracGrad_xyM, :qualGpaS),  
        fn_qual_gpa("fracGrad"),  nothing,
        grad_rate_qual_gpa,  plot_quality_gpa);
end

function dm_mass_entry_qual_gpa()
    target = :massEntry_qgM;
    # In stats by [qual, gpa], mass_xyM sums to 1 and is for entrants only.
    return DataMoment(target, ModelStatistic(:mass_xyM, :qualGpaS),  
        fn_qual_gpa("massEntry"),  nothing,
        mass_entry_qual_gpa,  plot_quality_gpa);
end

# function dm_grad_rate_gpa_yp()
#     return DataMoment("fracGradGpaYp.dat",  
#         RawDataFile(:selfReport, :progress, :mean, "grad_rate.dat"),  
#         grad_rate_by_gpa_yp, plot_gpa_yp);
# end

# --------  By gpa

fn_gpa(baseName) = file_name(baseName, :gpa, ".dat");

function dm_time_to_drop_by_gpa()
    return DataMoment(:timeToDrop_gV,  ModelStatistic(:timeToDrop_gV, :gpaS),
        fn_gpa("timeToDrop"),  nothing,  time_to_drop_by_gpa, show_dev_by_gpa)
end

function dm_time_to_grad_by_gpa()
    return DataMoment(:timeToGrad_gV,  ModelStatistic(:timeToGrad_gV, :gpaS),
        fn_gpa("timeToGrad"),  nothing,  time_to_grad_by_gpa, show_dev_by_gpa)
end

# Hours worked, year 1
function dm_work_hours_by_gpa()
    return DataMoment(:workTime_gV,  ModelStatistic(:workTime_gV, :gpaS),   
        fn_gpa("workHours"),  nothing,  work_hours_by_gpa, show_dev_by_gpa)
end

function dm_grad_rate_by_gpa()
    return DataMoment(:fracGrad_gV,  ModelStatistic(:fracGrad_gV, :gpaS),   
        fn_gpa("fracGrad"),  nothing,  grad_rate_by_gpa, show_dev_by_gpa)
end

function dm_frac_enter_by_gpa()
    return DataMoment(:fracEnter_gV,  ModelStatistic(:fracEnter_gV, :gpaS),   
        fn_gpa("fracEnter"),  nothing,  frac_enter_by_gpa, show_dev_by_gpa)
end


# -----------  By parental

fn_parental(baseName) = file_name(baseName, :parental, ".dat");

# Hours worked, year 1
function dm_work_hours_by_parental()
    return DataMoment(:workTime_pV,  ModelStatistic(:workTime_gV, :parentalS),
        fn_parental("workHours"), nothing,  
        work_hours_by_parental, show_dev_by_parental)
end

function dm_frac_enter_by_parental()
    return DataMoment(:fracEnter_pV,  ModelStatistic(:fracEnter_gV, :parentalS),
        fn_parental("fracEnter"), nothing,  
        frac_enter_by_parental, show_dev_by_parental)
end

# ----------  Regressions

# Wage regression pooling all workers
# Deviation is for intercepts. Slopes are imposed on the model.
function dm_wage_regression_all()
    target = :wageRegrIntercepts;
    return DataMoment(target,  ModelStatistic(target),  "wageRegrAll.dat",
        nothing,  wage_regr_intercepts, nothing);
end

# Wage regression; grads, with quality dummies
dm_wage_regression_grads() = 
    DataMoment(:wageRegrGrads,  ModelStatistic(:wageRegrGrads),  "wageRegrGrads.dat",
        nothing,  wage_regr_grads, nothing);

# Transfer regression on gpa, parental, quality. Year 1.
function dm_transfer_regr()
    target = :transferRegr;
    return DataMoment(target, ModelStatistic(target),  "transferRegr.dat", 
        raw_transfer_regr(),  dev_transfer_regr, nothing);
end

# Tuition (net price) regression on gpa, parental, quality. Year 1.
function dm_tuition_regr()
    target = :tuitionRegr;
    return DataMoment(target, ModelStatistic(target),  "tuitionRegr.dat", 
        nothing,  dev_tuition_regr, nothing);
end

"""
    $(SIGNATURES)

Make the moment table. Contains all known data moments.
"""
function make_moment_table()
    mTable = MomentTable([
        # By gpa
        dm_time_to_drop_by_gpa(),
        dm_time_to_grad_by_gpa(),
        dm_work_hours_by_gpa(),
        dm_grad_rate_by_gpa(),
        dm_frac_enter_by_gpa(),
        # By gpa / yp
        dm_entry_gpa_yp(),
        dm_mass_gpa_yp(),
        # By gpa / yp / quality
        dm_qual_entry_gpa_yp(),
        # :fracGradGpaYp => dm_grad_rate_gpa_yp(),
        # By Quality
        dm_afqt_mean_by_quality(),
        dm_frac_enroll_by_quality(),
        dm_grad_rate_by_quality(),
        dm_time_to_drop_by_qual(),
        dm_time_to_grad_by_qual(),
        dm_work_hours_by_qual(),
        dm_cum_loans_qual_year(),
        dm_courses_tried_qual_year(),
        dm_net_price_by_quality(),
        # By quality / parental
        dm_frac_qual_by_parental(),
        dm_frac_grad_qual_parental(),
        dm_time_to_grad_qual_parental(),
        # By quality / gpa
        dm_grad_rate_qual_gpa(),
        dm_mass_entry_qual_gpa(),
        dm_time_to_drop_qual_gpa(),
        dm_study_time_qual_gpa(),
        # By parental
        dm_frac_enter_by_parental(),
        dm_work_hours_by_parental(),
        # Aggregates
        dm_corr_gpa_yp(),
        dm_mean_study_time(),
        dm_grad_rate(),
        # Regressions
        dm_wage_regression_all(),
        dm_wage_regression_grads(),
        dm_transfer_regr(),
        dm_tuition_regr(),
        # dm_transfer_regr(),
        # Penalties
        dm_pen_earn_qual_grad(),
        dm_pen_lty_school(),
        dm_pen_h_gains()
        ]);
    return mTable
end


# -----------------