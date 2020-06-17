## --------  By college quality
# Since there is no switching in the model, several statstics do not make sense for two year colleges. They are set to 0 in model and data.


# -------------  Individual moments


## Tuition (out of pocket). Average by college type
function college_tuition(ds :: DataSettings)
    load_fct =  mt -> read_row_totals(
        raw_net_price_qual_gpa(ds, ds.tuitionYear; momentType = mt));
    tuitionV, ses, cnts = mean_from_xy(load_fct);
    # rf = raw_net_price_qual_gpa(ds, ds.tuitionYear);
    # tuitionV = read_row_totals(data_file(rf));
    @assert all(tuitionV .> 400.0)  &&  all(tuitionV .< 20000.0)
    @assert length(tuitionV) == n_colleges(ds)
    return tuitionV, ses, cnts
end


# Mean work hours PER YEAR
function work_hours_by_qual(ds :: DataSettings)
    load_fct = 
        mt -> read_row_totals(raw_work_hours_qual_parental(ds; momentType = mt));
    m, ses, cnts = mean_from_xy(load_fct);
    # m, ses, cnts = mean_from_row_total(ds, :workTime_qV);
    # rf = raw_work_hours_qual_gpa(ds, ds.workTimeYear);
    # m = read_row_totals(data_file(rf));
    @assert all(m .> 400.0)  &&  all(m .< 1800.0)
    @assert length(m) == n_colleges(ds)
    @assert all(cnts .> 100)
    return m, ses, cnts
end


## Graduation rate by quality
function grad_rate_by_quality(ds :: DataSettings)
    load_fct = 
        mt -> read_row_totals(raw_grad_rate_qual_gpa(ds; momentType = mt));
    m, ses, cnts = choice_prob_from_xy(load_fct);
    # m, ses, cnts = choice_prob_from_row_total(ds, :fracGrad_qV);
    # rf = raw_grad_rate_qual_gpa(ds);
    # m = read_row_totals(data_file(rf));
    # @assert all(m .> 0.0)  &&  all(m .< 1.0)
    @assert length(m) == n_colleges(ds)
    # Set to 0 for 2 year colleges
    m[no_grad_idx(ds)] .= 0.0;
    cnts[no_grad_idx(ds)] .= 0.0;
    return m, ses, cnts
end


## Mean time to drop out by quality
function time_to_drop_by_quality(ds :: DataSettings)
    load_fct = 
        mt -> read_row_totals(raw_time_to_drop_qual_gpa(ds; momentType = mt));
    m, ses, cnts = mean_from_xy(load_fct);
    # m, ses, cnts = mean_from_row_total(ds, :timeToDrop_qV);
    # rf = raw_time_to_drop_qual_gpa(ds);
    # m = read_row_totals(data_file(rf));
    @assert all(m .> 1.4)  &&  all(m .< 4.0)
    @assert length(m) == n_colleges(ds)
    return m, ses, cnts
end


## Mean time to graduate by quality (conditional on graduation)
function time_to_grad_by_quality(ds :: DataSettings)
    load_fct = 
        mt -> read_row_totals(raw_time_to_grad_qual_gpa(ds; momentType = mt));
    m, ses, cnts = mean_from_xy(load_fct);
    # m, ses, cnts = mean_from_row_total(ds, :timeToGrad_qV);
    # m = read_row_totals(raw_file_path(ds, :timeToGrad_qV));
    @assert all(m .> 3.0)  &&  all(m .< 7.0)
    @assert length(m) == n_colleges(ds)
    # Set to 0 for 2 year colleges
    m[no_grad_idx(ds)] .= 0.0;
    cnts[no_grad_idx(ds)] .= 0;
    return m, ses, cnts
end


## Mean AFQT percentile
function afqt_mean_by_quality(ds :: DataSettings)
    # target = :gpaMean_qV;
    rf = raw_afqt_pct_qual(ds);
    m = read_vector_by_x(data_file(rf)) ./ 100.0;
    @assert isa(m, Vector{Double})
	@argcheck size(m) == (n_colleges(ds), )
	@assert all(m .> 0.0)  &&  all(m .< 1.0)

    rfCnts = raw_afqt_pct_qual(ds; momentType = :count);
    cnts = read_vector_by_x(data_file(rfCnts));
    @assert all(cnts .> 100)

    ses = m ./ (cnts .^ 0.5);
    cnts = round.(Int, cnts);
    # m = read_by_quality(ds, data_file(rf)) ./ 100.0;
	return m, ses, cnts
end


## Fraction of enrollment by quality (conditional on entry)
# function dm_frac_enroll_by_quality()
#     return DataMoment(:fracEnroll_qV,  ModelStatistic(:fracEnroll_gV, :qualS),
#         file_name("fracEnroll", :quality, ".dat"), nothing,
#         frac_enroll_by_quality,  show_dev_by_quality);
# end

# function frac_enroll_by_quality(ds :: DataSettings)
#     dataV = load_frac_enroll_by_qual(ds);
#     target = :fracEnroll_qV;
#     d = Deviation{Double}(name = target, dataV = dataV,
#         modelV = dataV,  
#         scalarWt = 2.0,  shortStr = String(target),
#         longStr = "Fraction enrollment by quality (conditional)",
#         showPath = "fracEnrollByQuality.txt")
# end


# Enrollment by quality, sums to 1
function frac_enroll_by_qual(ds :: DataSettings)
    load_fct = 
        mt -> read_row_totals(raw_entry_qual_parental(ds; momentType = mt));
    m, ses, cnts = choice_prob_from_xy(load_fct);
    # dataV, ses, cnts = choice_prob_from_row_total(ds, :fracEnroll_qV);
    # rf = raw_entry_qual_parental(ds);
    # dataV = read_row_totals(data_file(rf));
    @assert check_float_array(m, 0.05, 1.0);
    @check sum(m) ≈ 1.0
    return m, ses, cnts
end



## --------------  By quality / year

# Multiple raw data files
# function dm_cum_loans_qual_year()
#     target = :cumLoans_qtM;
#     return DataMoment(target, ModelStatistic(:cumLoans_gtM, :qualYearS),
#         file_name("cumLoans", [:quality, :year], ".dat"),  nothing,
#         cum_loans_qual_year,  plot_quality_year);
# end

# Cumulative loans by [quality, year]
function cum_loans_qual_year(ds :: DataSettings)
    # target = :cumLoans_qtM;

    T = ds.Tmax;
    outM = zeros(n_colleges(ds), T);
    sesM = zeros(n_colleges(ds), T);
    cntM = zeros(Int, n_colleges(ds), T);
    for t = 1 : T
        outM[:, t], sesM[:,t], cntM[:,t] = cum_loans_qual(ds, t);
    end

    # Ignore 2 year colleges after year 2 while there is no switching
    outM[two_year_colleges(ds), 3 : end] .= 0.0;
    cntM[two_year_colleges(ds), 3 : end] .= 0;
    return outM, sesM, cntM
end

# The same for one year
function cum_loans_qual(ds :: DataSettings,  t :: Integer)
    load_fct = 
        mt -> read_row_totals(raw_cum_loans_qual_year(ds, t; momentType = mt));
    m, ses, cnts = mean_from_xy(load_fct);
    # m, ses, cnts = mean_from_row_total(load_fct);
    # rawFn = raw_cum_loans_qual_year(ds, t);
    # m = read_row_totals(raw_cum_loans_qual_year(ds, t));
    # cnts = read_row_totals(raw_cum_loans_qual_year(ds, t; momentType = :count));
    # stdV = read_row_totals(raw_cum_loans_qual_year(ds, t; momentType = :std));
    # ses = stdV ./ (max.(1.0, cnts) .^ 0.5);
    # cnts = round.(Int, cnts);
    return m, ses, cnts
end


# Courses attempted by quality, one year
# function dm_courses_tried_qual_year()
#     return DataMoment(:coursesTried_qtM, 
#         ModelStatistic(:nTriedMean_gtM, :qualYearS),
#             file_name("coursesTried", [:quality, :year], ".dat"), nothing,
#         courses_tried_qual_year, plot_quality_year);
# end


function courses_tried_qual(ds :: DataSettings, t :: Integer)
    load_fct = 
        mt -> read_row_totals(raw_credits_taken_qual_gpa(ds, t; momentType = mt));
    m, ses, cnts = mean_from_xy(load_fct);
    # m, ses, cnts = mean_from_row_total(load_fct);
    # rawFn = raw_credits_taken_qual_gpa(ds, t);
    # v = read_row_totals(data_file(rawFn));
    @assert check_float_array(m, 1.0, 50.0)
    @assert length(m) == n_colleges(ds)
    m = credits_to_courses(ds, m);
    return m, ses, cnts
end


# Courses attempted by quality / year
# Sets two year colleges to 0 after year 2
function courses_tried_qual_year(ds :: DataSettings)
    target = :coursesTried_qtM;

    T = ds.Tmax;
    outM = zeros(n_colleges(ds), T);
    sesM = zeros(n_colleges(ds), T);
    cntsM = zeros(Int, n_colleges(ds), T);
    for t = 1 : T
        outM[:, t], sesM[:,t], cntsM[:,t] = courses_tried_qual(ds, t);
    end

    # Ignore 2 year colleges after year 2 while there is no switching
    outM[two_year_colleges(ds), 3 : end] .= 0.0;
    cntsM[two_year_colleges(ds), 3 : end] .= 0.0;
    return outM, sesM, cntsM
end


# CDF of HS GPA by college quality
# Each row is a percentile (e.g. p10 is the 10th percentile of GPA in each college).
# Each entry means: The p10-th percentile in this college is the X-th percentile in the population.
# Numbers are between 0 and 100
function read_cdf_gpa_by_qual(ds :: DataSettings; momentType :: Symbol = :mean)
    rawFn = RawDataFile(:transcript, :freshmen, momentType, 
        "cdf_afqt_byquality.dat", ds);
    fPath = data_file(rawFn);
    df = read_delim_file_to_df(fPath);
    if momentType == :mean
        @check all_greater(df.quality2, 1)
        @check all_at_most(df.quality4, 100)
    end
    return df
end


# Returns a matrix of afqt percentiles by [percentile, quality]
# Element [j, k] means: In College of quality k, the percentile[j]-th GPA percentile corresponds to the outM[j,k] percentile in the data.
# Currently only works for percentiles in the data file. Should interpolate +++++
function cdf_gpa_by_qual(ds :: DataSettings, 
    percentileV :: AbstractVector, qualityV :: AbstractVector)

    df = read_cdf_gpa_by_qual(ds; momentType = :mean);
    pctColV = df[!, :pctile];
    np = length(percentileV);
    nq = length(qualityV);
    outM = zeros(np, nq);
    for iq = 1 : nq
        dataV = df[!, Symbol("quality$(qualityV[iq])")];
        for ip = 1 : np
            rIdx = findfirst(x -> x == "p$(percentileV[ip])", pctColV);
            @assert rIdx > 0
            outM[ip, iq] = dataV[rIdx];
        end
    end
    @assert all_greater(outM, 1.0);
    @assert all_at_most(outM, 100.0)
    return outM
end


# ---------------