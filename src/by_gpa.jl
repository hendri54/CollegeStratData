# """
# 	$(SIGNATURES)

# Read a file by [x, gpa]. GPA is in the columns.
# Return the moments for the gpa marginal.
# """
# function read_by_x_gpa(ds :: DataSettings, target :: Symbol)
#     df = read_delim_file_to_df(target);
#     colV = col_headers(:gpa, 1 : n_gpa(ds));
#     m = all_row_to_vector(df, colV);
#     @argcheck length(m) == n_gpa(ds)
#     return m :: Vector{Double}
# end


# Entry rate by GPA
function frac_enter_by_gpa(ds :: DataSettings)
    # Read COL totals b/c file is transposed
    load_fct = 
        mt -> read_col_totals(raw_entry_gpa_parental(ds; momentType = mt));
    m, ses, cnts = choice_prob_from_xy(load_fct);
    # m, ses, cnts = choice_prob_from_col_total(ds, :fracEnter_gV);
    # m = read_col_totals(raw_file_path(ds, :fracEnter_gV));
    @assert all(m .> 0.0)  &&  all(m .< 1.0)
    @assert length(m) == n_gpa(ds)

    # cnts = read_col_totals(raw_file_path(ds, :fracEnter_gV; momentType = :count));
    @assert all(cnts .> 100)
    # ses = (m .* (1.0 .- m) ./ cnts) .^ 0.5;
    return m, ses, cnts
end


"""
Compute from joint distribution of graduates by [q, g]. The marginals are otherwise wrong b/c we set frac grad of 2y colleges to 0.
"""
function frac_gradc_by_gpa(ds :: DataSettings)
    massEnter_qgM, _ = load_moment(ds, :massEntry_qgM);
    massGrad_qgM, _ = load_moment(ds, :massGrad_qgM);
    massEnter_gV = vec(sum(massEnter_qgM, dims = 1));
    massGrad_gV = vec(sum(massGrad_qgM, dims = 1));
    m = massGrad_gV ./ massEnter_gV;

    # This now just for counts and std errors.
    load_fct = 
        mt -> read_col_totals(raw_frac_gradc_qual_gpa(ds; momentType = mt));
    _, ses, cnts = choice_prob_from_xy(load_fct);
    @assert all(m .> 0.0)  &&  all(m .< 1.0)
    @assert length(m) == n_gpa(ds)
    @assert all(cnts .> 100)
    return m, ses, cnts
end


# Mean time to drop by quality / gpa
# Contains one 0 cell that needs to be interpolated. 4Y only.
function time_to_drop_4y_by_gpa(ds :: DataSettings)
    load_fct = 
        mt -> read_col_totals(ds, :timeToDrop4y_qgM, mt);
    m, ses, cnts = load_mean_ses_counts(load_fct);
    @assert all(m .> 1.5)  &&  all(m .< 4.0)
    @assert length(m) == n_gpa(ds)
    @assert all(cnts .> 30)  "Low counts: $cnts";
    return m, ses, cnts
end


"""
	$(SIGNATURES)

Mean time to graduation by GPA. 4Y colleges only.
"""
function time_to_grad_4y_by_gpa(ds :: DataSettings)
    load_fct = 
        mt -> read_col_totals(ds, :timeToGrad4y_qgM, mt);
    m, ses, cnts = load_mean_ses_counts(load_fct);
    @assert all(m .> 3.0)  &&  all(m .< 7.0)
    @assert length(m) == n_gpa(ds)
    @assert all(cnts .>= 30)  "Low counts: $cnts";
    return m, ses, cnts
end


"""
	$(SIGNATURES)

Work hours, year 1, by GPA.
"""
function work_hours_by_gpa(ds :: DataSettings)
    m = read_col_totals(raw_work_hours_qual_gpa(ds, ds.workTimeYear));
    stdV = read_col_totals(
        raw_work_hours_qual_gpa(ds, ds.workTimeYear; momentType = MtStd()));
    cnts = read_col_totals(
        raw_work_hours_qual_gpa(ds, ds.workTimeYear; momentType = MtCount()));
    ses = stdV ./ (max.(cnts, 1.0) .^ 0.5);
    cnts = clean_cnts(cnts);
    @assert all(m .> 400.0)  &&  all(m .< 1800.0)
    @assert length(m) == n_gpa(ds)
    @assert all(cnts .> 100)
    return m, ses, cnts
end


## ----------  Dropout rates by GPA / year

# Fraction of initial entrants dropping out at end of each year.
# Standard errors are questionable. The `N`s are given as the total number of students in each college in year 1. 
# Dropout rates for 2y starters only sum to about 0.9. But 1/3 occur after year 2.
function frac_drop_gpa_year(ds :: DataSettings)
    # target = :fracDrop_gtM;

    T = ds.Tmax;
    outM = zeros(n_colleges(ds), T);
    sesM = zeros(n_colleges(ds), T);
    cntsM = zeros(Int, n_gpa(ds), T);
    for t = 1 : T
        outM[:, t], sesM[:,t], cntsM[:,t] = frac_drop_gpa(ds, t);
    end
    return outM, sesM, cntsM
end


function frac_drop_gpa(ds :: DataSettings, t :: Integer)
    # Data files contains dropout rates by AFQT as col totals.
    load_fct = 
        mt -> read_col_totals(raw_frac_drop_qual_gpa(ds, t; momentType = mt));
    m, ses, cnts = choice_prob_from_xy(load_fct);
    @assert check_float_array(m, 0.0, 1.0)
    @assert length(m) == n_gpa(ds)
    return m, ses, cnts
end



# ------------------