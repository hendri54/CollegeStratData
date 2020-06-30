# Scalar moment file currently does not exist. Oksana needs to make it.

## Read scalar moments from a single dedicated file
# I currently created this as a dummy file
function read_scalar_moments(ds :: DataSettings)
    fPath = joinpath(data_dir(ds), "scalar_moments.csv");
    csvFile = CSV.File(fPath, header = [:name, :value],  
        delim = ',', comment = commentStr);
    return csvFile |> DataFrame!
end


"""
	$(SIGNATURES)

Read one scalar moments from the scalar moments file.
"""
function read_scalar_moment(ds :: DataSettings, name :: String)
    df = read_scalar_moments(ds);
    outV = df[df.name .== name, :value];
    @assert length(outV) == 1
    outVal = outV[1];
    return outVal :: Float64
end


## Graduation rate (conditional on entry)
function grad_rate(ds :: DataSettings)
    gradRate = read_all_from_delim_file(raw_grad_rate_qual_gpa(ds));
    cnt = read_all_from_delim_file(raw_grad_rate_qual_gpa(ds; momentType = :count));
    @assert check_float(gradRate, lb = 0.3, ub = 0.7);
    ses = (gradRate * (1.0 - gradRate) / cnt) ^ 0.5;
    return gradRate, ses, cnt
end


## Correlation HS GPA / parental income
# in which units? +++
function corr_gpa_yp(ds :: DataSettings)
    corr = read_scalar_moment(ds, "corrGpaYp");
    @assert corr > 0.3  &&  corr < 0.8
    return corr, 0.0, 1000
    # return ScalarDeviation{Double}(name = :corrGpaYp, dataV = corr, modelV = 0.0,
    #     wtV = 1.0 ./ corr,
    #     shortStr = "corrGpaYp", longStr = "Correlation HSgpa/parental background")
end


# Number of college entrants in the sample
# Useful for computing std errors
function n_entrants(ds :: DataSettings)
    cntM = read_matrix_by_xy(count_file(ds, :fracEnter_gpM));
    cnt = round(Int, sum(cntM));
    @assert 4000 < cnt < 7_000
    return cnt
end



## Average study time
#=
We have NLSY79 moments in xls, but not 97 moments.
This is based on Babcock/Marks 2011, table 2, HERI and NSSE
For full time 4 year students. So likely a bit high

Setting `wtV = 1/dataV` makes this a percentage deviation.
=#
# function dev_mean_study_time(ds :: DataSettings)
#     dataV = mean_study_time(ds; modelUnits = true);
#     return ScalarDeviation{Double}(name = :meanStudyTime, dataV = dataV, modelV = dataV,
#         wtV = 1 ./ dataV,
#         shortStr = "meanStudyTime", longStr = "Mean study time, hours per week")
# end

# Mean study time (hours per week)
# function mean_study_time(; modelUnits :: Bool = true)
#     mst = 25.0;
#     if modelUnits
#         mst = hours_per_week_to_mtu(mst);
#     end
#     return mst
# end


## Average work hours in college
#=
No good basis right now +++
=#
# function mean_work_time(; modelUnits :: Bool = true)
#     mwt = 15.0;
#     if modelUnits
#         mwt = hours_per_week_to_mtu(mwt);
#     end
#     return mwt
# end


## Wage earned in college (per hour worked)
#=
Based on xls table "Average hourly wage" which does not seem to vary by quality
=#
# function college_wage(ds :: DataSettings; modelUnits :: Bool = true)
#     wage = 7.0;
#     if modelUnits
#         wage = dollars_data_to_model(wage, :perHour);
#     end
#     return wage
# end


# function mean_course_load(; modelUnits :: Bool = true)
#     mcl = 10;
#     if !modelUnits
#         mcl = mcl * dataCoursesPerCourse;
#     end
#     return mcl
# end


# ------------