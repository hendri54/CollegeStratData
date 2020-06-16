## ----------------  Individual moments

## Mean time to dropout (conditional on dropping out)
# Some small cells
function time_to_drop_qual_gpa(ds :: DataSettings)
    m = read_matrix_by_xy(raw_file_path(ds, :timeToDrop_qgM));
    # cntM = read_matrix_by_xy(count_file(ds, :timeToDrop_qgM));
    # Interpolate a missing entry
    (m[4,1] == 0.0)  &&  (m[4,1] = m[3,1]);
    @assert all(m .< 6.0)  &&  all(m .>= 0.0)
    return m
end


## Fraction in each quality, conditional on entry, by gpa
function frac_qual_by_gpa(ds :: DataSettings)
    rf = raw_entry_qual_gpa(ds);
    dataV = read_matrix_by_xy(data_file(rf));
    @assert check_float_array(dataV, 0.001, 1.0);
    @check sum(dataV) ≈ 1.0

    # Make conditional on entry (columns sum to 1)
    dataV = dataV ./ sum(dataV, dims = 1);
    @assert all(isapprox.(sum(dataV, dims = 1), 1.0))
    return dataV
end


## Mass of freshmen by quality / gpa. Sums to 1.
function mass_entry_qual_gpa(ds :: DataSettings)
    m = read_matrix_by_xy(raw_file_path(ds, :massEntry_qgM));
    @assert all(m .< 1.0)  &&  all(m .> 0.0)
    @assert isapprox(sum(m), 1.0,  atol = 0.0001)
    return m
end


"""
	$(SIGNATURES)

Graduation rates by [quality, gpa].
"""
function grad_rate_qual_gpa(ds :: DataSettings)
    m = read_matrix_by_xy(raw_file_path(ds, :fracGrad_qgM));
    @assert all(m .<= 1.0)  &&  all(m .> 0.0)

    # Set to 0 for colleges that do not produce graduates
    m[no_grad_idx(ds), :] .= 0.0;
    # wtM = 1.0 ./ max.(0.1, m);
    return m
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
function mean_study_time(ds :: DataSettings)
    st_qV = mean_study_times_by_qual(ds);
    st = mean_by_qual(st_qV, ds);
    return st
end

# -----------------