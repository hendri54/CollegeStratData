## ----------------  Individual moments

## Mean time to dropout (conditional on dropping out)
# Some small cells
function time_to_drop_qual_gpa(ds :: DataSettings)
    load_fct = 
        mt -> read_matrix_by_xy(raw_time_to_drop_qual_gpa(ds; momentType = mt));
    m, ses, cnts = load_mean_ses_counts(load_fct);
    @assert all(m .< 6.0)  &&  all(m .>= 0.0)
    return m, ses, cnts
end


## Fraction in each quality, conditional on entry, by gpa
function frac_qual_by_gpa(ds :: DataSettings)
    dataV = read_matrix_by_xy(raw_entry_qual_gpa(ds));
    @assert check_float_array(dataV, 0.001, 1.0);
    @assert isapprox(sum(dataV), 1.0, atol = 1e-6);

    # Make conditional on entry (columns sum to 1)
    dataV = dataV ./ sum(dataV, dims = 1);
    @assert all(isapprox.(sum(dataV, dims = 1), 1.0))
    nc = size(dataV, 1);

    # Counts by GPA
    cntV = read_row_totals(raw_entry_qual_gpa(ds; momentType = :count));
    @assert length(cntV) == size(dataV, 2)
    cnts = repeat(cntV', outer = (nc, 1));
    @assert size(cnts) == size(dataV)

    ses = ses_from_choice_probs(dataV, cnts);
    cnts = round.(Int, cnts);
    return dataV, ses, cnts
end


## Mass of freshmen by quality / gpa. Sums to 1.
function mass_entry_qual_gpa(ds :: DataSettings)
    m = read_matrix_by_xy(raw_file_path(ds, :massEntry_qgM));
    # SES treats this as a discrete choice problem with total count.
    cnts = read_matrix_by_xy(raw_file_path(ds, :massEntry_qgM; momentType = :count));
    cnts = fill(sum(cnts), size(cnts));
    @assert all(m .< 1.0)  &&  all(m .> 0.0)
    @assert isapprox(sum(m), 1.0,  atol = 0.0001)
    ses = ses_from_choice_probs(m, cnts);
    cnts = round.(Int, cnts);
    return m, ses, cnts
end


"""
	$(SIGNATURES)

Graduation rates by [quality, gpa].
"""
function grad_rate_qual_gpa(ds :: DataSettings)
    load_fct = 
        mt -> read_matrix_by_xy(raw_file_path(ds, :fracGrad_qgM; momentType = mt));
    m, ses, cnts = choice_prob_from_xy(load_fct);
    # m = read_matrix_by_xy(raw_file_path(ds, :fracGrad_qgM));
    @assert all(m .<= 1.0)  &&  all(m .> 0.0)

    # Set to 0 for colleges that do not produce graduates
    m[no_grad_idx(ds), :] .= 0.0;
    cnts[no_grad_idx(ds), :] .= 0;
    # wtM = 1.0 ./ max.(0.1, m);
    return m, ses, cnts
end


## --------------  Study time

"""
	$(SIGNATURES)

Study time from NLSY79. Class and study time combined.
Files are copied BY HAND from Dropbox to DataCollegeStrat.
But need to adjust b/c grand mean should be lower for NLSY97.
"""
function study_time_qual(ds :: DataSettings)
    studyV = [read_row_totals(study_time79_path(ds; momentType = mt)) 
        for mt in (:mean, :std, :count)];
    classV = [read_row_totals(class_time79_path(ds; momentType = mt)) 
        for mt in (:mean, :std, :count)];

    m, ses, cnts = total_study_time(studyV, classV);
    return m, ses, cnts
end

function study_time79_path(ds; momentType = :mean)
    fPath = data_file(raw_study_time_qual_gpa(ds; momentType = momentType));
    fPath = nlsy79_path(fPath);
    return fPath
end

function class_time79_path(ds; momentType = :mean)
    fPath = data_file(raw_class_time_qual_gpa(ds; momentType = momentType));
    fPath = nlsy79_path(fPath);
    return fPath
end

nlsy79_path(fPath) = replace(fPath, "97" => "79");

function total_study_time(studyV, classV)
    @assert size(studyV) == size(classV) == (3, );
    for j = 1 : 3
        @assert size(studyV[j]) == size(studyV[1]);
        @assert size(classV[j]) == size(studyV[1]);
    end

    # Multiply by mean of NSSE relative to NLSY79
    # Babcock/Marks 2011 tb 2
    studyFactor = 13.28 / 19.75;
    # Adjust to match HERI 2004 mean (NSSE does not have class time)
    classFactor = 13.01 / 15.84;

    cnts = round.(Int, 0.5 .* (studyV[3] .+ classV[3]));
    m = studyV[1] .* studyFactor .+ classV[1] .* classFactor;
    ses = (studyV[2] .* studyFactor .+ classV[2] .* classFactor) ./ 
        sqrt.(cnts);
    return m, ses, cnts
end


function study_time_qual_gpa(ds :: DataSettings)
    studyV = [read_matrix_by_xy(study_time79_path(ds; momentType = mt)) 
        for mt in (:mean, :std, :count)];
    classV = [read_matrix_by_xy(class_time79_path(ds; momentType = mt)) 
        for mt in (:mean, :std, :count)];

    dataM, ses, cnts = total_study_time(studyV, classV);

    # fPath = data_file(raw_study_time_qual_gpa(ds; momentType = :mean));
    # fPath = replace(fPath, "97" => "79");
    # m = read_row_totals(fPath);

    # # Study time only, by quality, gpa
    # studyM = [10.7	12.9	12.5	16.2;
    #         19.3	21.6	18.2	15.2;
    #         19.3	13.1	19.5	20.2;
    #         15.1	24.2	28.5	24.8];
    # # Multiply by mean of NSSE relative to NLSY79
    # # Babcock/Marks 2011 tb 2
    # dFactor = 13.28 / 19.75;
    # studyM = studyM .* dFactor;

    # # Class time
    # classM = [13.5	16.0	13.4	17.3;
    #         17.7	18.3	18.3	13.9;
    #         20.1	17.5	15.2	15.9;
    #         32.6	15.9	16.3	16.1];
    # # Adjust to match HERI 2004 mean (NSSE does not have class time)
    # dFactor = 13.01 / 15.84;
    # classM = classM .* dFactor;

    # dataM = studyM .+ classM;
    # # if modelUnits
    # #     dataM = hours_per_week_to_mtu(dataM);
    # #     validate_mtu(dataM);
    # # end

    # # These are made up
    # ses = ones(size(dataM));
    # cnts = fill(100, size(dataM)...);

    @check size(dataM) == (n_colleges(ds), n_gpa(ds))

    return dataM, ses, cnts
end

function study_time(ds :: DataSettings)
    studyV = [read_total(study_time79_path(ds; momentType = mt)) 
        for mt in (:mean, :std, :count)];
    classV = [read_total(class_time79_path(ds; momentType = mt)) 
        for mt in (:mean, :std, :count)];

    m, ses, cnts = total_study_time(studyV, classV);
    return m, ses, cnts
end


# function nlsy79_dir(ds)
#     @assert occursin(data_dir(ds), "97")  "Expecting 97 NLSY";
#     d2 = replace(data_dir(ds), "97" => "79");
#     return d2
# end

# study_time_dir79(ds) = joinpath(nlsy79_dir(ds), "dat_files");


# function study_time_qual_gpa(ds :: DataSettings)
#     dataM = load_study_time_qual_gpa(ds; modelUnits = true);    
#     return Deviation{Double}(name = :studyTime_qgM, dataV = dataM, modelV = dataM,
#         scalarWt = 1.0 / sum(dataM),
#         shortStr = "studyTimeQualGpa",  
#         longStr = "Average study time by (quality, gpa)",
#         showPath = "studyTimeQualGpa");
# end



# In hours per week
# function mean_study_times_by_qual(ds :: DataSettings)
#     st_qgM, _ = study_time_qual_gpa(ds);
#     st_qV = [mean_by_gpa(vec(st_qgM[ic,:]), ds)  for ic = 1 : n_colleges(ds)];
#     @check size(st_qV) == (n_colleges(ds), )
#     @assert all(st_qV .> 7.0)
#     ses = ones(size(st_qV));
#     cnts = fill(100, size(st_qV));
#     return st_qV, ses, cnts
# end

# In hours per week
# function mean_study_time(ds :: DataSettings)
#     st_qV, _ = mean_study_times_by_qual(ds);
#     st = mean_by_qual(st_qV, ds);
#     return st, 1.0, 100
# end

# -----------------