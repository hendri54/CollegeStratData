## Read matrix by [quality, HS GPA]
# read_by_quality_gpa(ds :: DataSettings, fPath :: AbstractString) =
#     read_matrix_by_xy(fPath);

# read_by_quality_gpa(ds :: DataSettings, target :: Symbol) =
#     read_by_quality_gpa(ds, data_file(target));


"""
    plot_quality_gpa

Plot data (and model) by [quality group, gpa quartile]
"""
# function plot_quality_gpa(ds :: DataSettings, dev :: Deviation,  plotModel :: Bool, 
#     filePath :: String)

#     p = plot_dev_xy(dev, quality_labels(n_colleges(ds)), 
#         gpa_labels(n_gpa(ds)), plotModel, filePath);
#     return p
# end


## ----------------  Individual moments

## Mean time to dropout (conditional on dropping out)
function time_to_drop_qual_gpa(ds :: DataSettings)
    # target = :timeToDrop_qgM;
    rf = raw_time_to_drop_qual_gpa(ds);
    m = read_matrix_by_xy(rf);
    # Interpolate a missing entry
    (m[4,1] == 0.0)  &&  (m[4,1] = m[3,1]);
    @assert all(m .< 6.0)  &&  all(m .>= 0.0)
    return m
    # return Deviation{Double}(name = target, dataV = m, modelV = m,
    #     wtV = 1.0 ./ m,  scalarWt = 1.0 ./ length(m),
    #     shortStr = "timeToDropByQualGpa",
    #     longStr = "Mean time to dropping out, by quality, gpa", 
    #     showPath = "timeToDropByQualGpa")
end


## Mass of freshmen by quality / gpa. Sums to 1.
function mass_entry_qual_gpa(ds :: DataSettings)
    # target = :massEntry_qgM;
    rf = raw_mass_entry_qual_gpa(ds);
    m = read_matrix_by_xy(rf);
    @assert all(m .< 1.0)  &&  all(m .> 0.0)
    @assert isapprox(sum(m), 1.0,  atol = 0.0001)
    return m
    # return Deviation{Double}(name = target, dataV = m, modelV = m,
    #     scalarWt = 1.0 ./ sum(m),
    #     shortStr = string(target),
    #     longStr = "Mass of freshmen, by quality, gpa", 
    #     showPath = "massEntryByQualGpa")
end


"""
	$(SIGNATURES)

Graduation rates by [quality, gpa].
"""
function grad_rate_qual_gpa(ds :: DataSettings)
    # target = :fracGrad_qgM;

    rf = raw_grad_rate_qual_gpa(ds);
    m = read_matrix_by_xy(data_file(rf));
    @assert all(m .<= 1.0)  &&  all(m .> 0.0)

    # Set to 0 for colleges that do not produce graduates
    m[no_grad_idx(ds), :] .= 0.0;
    # wtM = 1.0 ./ max.(0.1, m);
    return m

    # d = Deviation{Double}(name = target, dataV = m, modelV = m,
    #     scalarWt = 1.0 ./ length(m),
    #     shortStr = string(target),
    #     longStr = "Graduate rate, by quality, gpa", 
    #     showPath = "fracGradQualGpa");
    # @assert validate_deviation(d)
    # return d
end


## Study time from NLSY79. Class and study time combined.
#=
Hand copied (b/c we don't have NLSY79 data) from xls +++
But need to adjust b/c grand mean should be lower for NLSY97
=#
# function study_time_qual_gpa(ds :: DataSettings)
#     dataM = load_study_time_qual_gpa(ds; modelUnits = true);    
#     return Deviation{Double}(name = :studyTime_qgM, dataV = dataM, modelV = dataM,
#         scalarWt = 1.0 / sum(dataM),
#         shortStr = "studyTimeQualGpa",  
#         longStr = "Average study time by (quality, gpa)",
#         showPath = "studyTimeQualGpa");
# end

function study_time_qual_gpa(ds :: DataSettings)
    # Study time only
    studyM = [10.7	12.9	12.5	16.2;
            19.3	21.6	18.2	15.2;
            19.3	13.1	19.5	20.2;
            15.1	24.2	28.5	24.8];
    # Multiply by mean of NSSE relative to NLSY79
    # Babcock/Marks 2011 tb 2
    dFactor = 13.28 / 19.75;
    studyM = studyM .* dFactor;

    # Class time
    classM = [13.5	16.0	13.4	17.3;
            17.7	18.3	18.3	13.9;
            20.1	17.5	15.2	15.9;
            32.6	15.9	16.3	16.1];
    # Adjust to match HERI 2004 mean (NSSE does not have class time)
    dFactor = 13.01 / 15.84;
    classM = classM .* dFactor;

    dataM = studyM .+ classM;
    # if modelUnits
    #     dataM = hours_per_week_to_mtu(dataM);
    #     validate_mtu(dataM);
    # end
    return dataM
end

# In hours per week
function mean_study_times_by_qual(ds :: DataSettings)
    st_qgM = study_time_qual_gpa(ds);
    st_qV = [mean_by_gpa(vec(st_qgM[ic,:]), ds)  for ic = 1 : n_colleges(ds)];
    return st_qV
end

# In hours per week
function mean_study_time(ds :: DataSettings; modelUnits :: Bool = true)
    st_qV = mean_study_times_by_qual(ds);
    st = mean_by_qual(st_qV, ds);
    return st
end

# -----------------