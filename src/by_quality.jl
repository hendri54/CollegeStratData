## --------  By college quality
# Since there is no switching in the model, several statstics do not make sense for two year colleges. They are set to 0 in model and data.


# Plot model and data by quality / year
# function plot_quality_year(ds :: DataSettings, dev :: Deviation,  plotModel :: Bool, 
#     filePath :: String)

#     T = size(get_data_values(dev), 2);
#     p = plot_dev_xy(dev, quality_labels(n_colleges(ds)), 
#         year_labels(T), plotModel, filePath);
#     return p
# end


# Plot data (and model) by [quality group, parental quartile]
# function plot_quality_yp(ds :: DataSettings, dev :: Deviation,  plotModel :: Bool, 
#     filePath :: String)

#     p = plot_dev_xy(dev, quality_labels(n_colleges(ds)), 
#         parental_labels(n_parental(ds)), plotModel, filePath);
#     return p
# end


# -------------  Individual moments


## Tuition (out of pocket). Average by college type
function college_tuition(ds :: DataSettings)
    rf = raw_net_price_qual_gpa(ds, ds.tuitionYear);
    tuitionV = read_row_totals(data_file(rf));
    @assert all(tuitionV .> 400.0)  &&  all(tuitionV .< 20000.0)
    @assert length(tuitionV) == n_colleges(ds)
    return tuitionV
    # if modelUnits
    #     # In model dollars
    #     tuitionV = dollars_data_to_model(tuitionV, :perYear);
    # end
    # return tuitionV
end


## Net price of college by quality
# function net_college_price(ds :: DataSettings)
#     m = college_tuition(ds; modelUnits = true);
#     target = :netPriceQual;
#     dev = Deviation{Double}(name = target, dataV = m, modelV = m,
#         wtV = 1.0 ./ m,  scalarWt = 1.5 / length(m),
#         shortStr = String(target),
#         longStr = "Net price by college quality", 
#         showPath = "netPriceByQuality.txt")
#     return dev

# end


## Hours worked, year 1
# function work_hours_by_quality(ds :: DataSettings)
#     m = mean_work_hours_by_qual(ds; modelUnits = true);
#     target = :workTime_qV;
#     dev = work_hours_dev(target, m, :quality);
#     return dev
# end

# Mean work hours PER YEAR
function work_hours_by_qual(ds :: DataSettings)
    rf = raw_work_hours_qual_gpa(ds, ds.workTimeYear);
    m = read_row_totals(data_file(rf));
    @assert all(m .> 400.0)  &&  all(m .< 1800.0)
    @assert length(m) == n_colleges(ds)
    # modelUnits  &&  (m = hours_data_to_mtu(m, :hoursPerYear));
    return m
end


## Graduation rate by quality
function grad_rate_by_quality(ds :: DataSettings)
    # target = :fracGrad_qV;
    rf = raw_grad_rate_qual_gpa(ds);
    m = read_row_totals(data_file(rf));
    @assert all(m .> 0.0)  &&  all(m .< 1.0)
    @assert length(m) == n_colleges(ds)
    # Set to 0 for 2 year colleges
    m[no_grad_idx(ds)] .= 0.0;
    return m
    # dev = frac_grad_dev(target, m, :quality);
    # return dev
end


## Mean time to drop out by quality
function time_to_drop_by_quality(ds :: DataSettings)
    # target = :timeToDrop_qV;
    rf = raw_time_to_drop_qual_gpa(ds);
    m = read_row_totals(data_file(rf));
    @assert all(m .> 1.4)  &&  all(m .< 4.0)
    @assert length(m) == n_colleges(ds)
    return m
    # dev = time_to_drop_dev(target, m, :quality);
    # return dev
end


## Mean time to graduate by quality (conditional on graduation)
function time_to_grad_by_quality(ds :: DataSettings)
    m = read_row_totals(raw_file_path(ds, :timeToGrad_qV));
    @assert all(m .> 3.0)  &&  all(m .< 7.0)
    @assert length(m) == n_colleges(ds)
    # Set to 0 for 2 year colleges
    m[no_grad_idx(ds)] .= 0.0;
    return m
    # dev = time_to_grad_dev(target, m, :quality);
    # return dev
end


## Mean AFQT percentile
function afqt_mean_by_quality(ds :: DataSettings)
    # target = :gpaMean_qV;
    rf = raw_afqt_pct_qual(ds);
    m = read_vector_by_x(data_file(rf)) ./ 100.0;
    # m = read_by_quality(ds, data_file(rf)) ./ 100.0;
    @assert isa(m, Vector{Double})
	@argcheck size(m) == (n_colleges(ds), )
	@assert all(m .> 0.0)  &&  all(m .< 1.0)
	return m
    # return Deviation{Double}(name = target, dataV = m, modelV = m,
    #     scalarWt = 1.0 / sum(m),
    #     shortStr = String(target),
    #     longStr = "Mean AFQT percentile by college quality", 
    #     showPath = "afqtMeanByQuality.txt")
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

function frac_enroll_by_qual(ds :: DataSettings)
    rf = raw_entry_qual_parental(ds);
    dataV = read_row_totals(data_file(rf));
    @assert check_float_array(dataV, 0.05, 1.0);
    @check sum(dataV) ≈ 1.0
    return dataV
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
    for t = 1 : T
        outM[:, t] = cum_loans_qual(ds, t);
    end

    # Ignore 2 year colleges after year 2 while there is no switching
    outM[two_year_colleges(ds), 3 : end] .= 0.0;
    return outM
    # # wtM = 1.0 ./ max.(0.1, outM);
    # wtM = fill(1.0 / mean(outM), size(outM));
    # wtM[outM .== 0.0] .= 0.0;

    # # Only years available in data are to be compared
    # idxV = collect(axes(outM));

    # d = Deviation{Double}(name = target, dataV = outM, modelV = outM,
    #     wtV = wtM,  scalarWt = 0.6,  idxV = idxV,
    #     shortStr = String(target),
    #     longStr = "Cumulative loans by quality, year (unconditional)",
    #     showPath = "cumLoansQualYear.dat");
    # return d
end

# The same for one year
function cum_loans_qual(ds :: DataSettings,  t :: Integer)
    rawFn = raw_cum_loans_qual_year(ds, t);
    m = read_row_totals(data_file(rawFn));
    # if modelUnits
    #     m = dollars_data_to_model(m, :perYear);
    # end
    return m :: Vector{Float64}
end


# Courses attempted by quality, one year
# function dm_courses_tried_qual_year()
#     return DataMoment(:coursesTried_qtM, 
#         ModelStatistic(:nTriedMean_gtM, :qualYearS),
#             file_name("coursesTried", [:quality, :year], ".dat"), nothing,
#         courses_tried_qual_year, plot_quality_year);
# end

function courses_tried_qual(ds :: DataSettings, t :: Integer)
    rawFn = raw_credits_taken_qual_gpa(ds, t);
    v = read_row_totals(data_file(rawFn));
    @assert check_float_array(v, 1.0, 50.0)
    @assert length(v) == n_colleges(ds)
    v = credits_to_courses(ds, v);
    # if modelUnits
    #     v = courses_data_to_model(v);
    # end
    return v
end


# Courses attempted by quality / year
# Sets two year colleges to 0 after year 2
function courses_tried_qual_year(ds :: DataSettings)
    target = :coursesTried_qtM;

    T = ds.Tmax;
    outM = zeros(n_colleges(ds), T);
    for t = 1 : T
        outM[:, t] = courses_tried_qual(ds, t);
    end

    # Ignore 2 year colleges after year 2 while there is no switching
    outM[two_year_colleges(ds), 3 : end] .= 0.0;
    return outM
    # # Only years available in data are to be compared
    # idxV = collect(axes(outM));

    # d = Deviation{Double}(name = target, dataV = outM, modelV = outM,
    #     wtV = 1.0 ./ max.(0.1, outM),  scalarWt = 0.5,  idxV = idxV,
    #     shortStr = String(target),
    #     longStr = "Courses tried by [qual, year]",
    #     showPath = "coursesTriedQualYear.dat");
    # return d
end


# CDF of HS GPA by college quality
# Each row is a percentile (e.g. p10 is the 10th percentile of GPA in each college).
# Each entry means: The p10-th percentile in this college is the X-th percentile in the population.
# Numbers are between 0 and 100
function read_cdf_gpa_by_qual(ds :: DataSettings)
    rawFn = RawDataFile(:transcript, :freshmen, :mean, "cdf_afqt_byquality.dat", ds);
    fPath = data_file(rawFn);
    df = read_delim_file_to_df(fPath);
    @check all_greater(df.quality2, 1)
    @check all_at_most(df.quality4, 100)
    return df
end


# Returns a matrix of afqt percentiles by [percentile, quality]
# Element [j, k] means: In College of quality k, the percentile[j]-th GPA percentile corresponds to the outM[j,k] percentile in the data.
# Currently only works for percentiles in the data file. Should interpolate +++++
function cdf_gpa_by_qual(ds :: DataSettings, 
    percentileV :: AbstractVector, qualityV :: AbstractVector)

    df = read_cdf_gpa_by_qual(ds);
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