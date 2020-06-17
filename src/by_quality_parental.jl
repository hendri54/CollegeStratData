## -----------  By quality / parental


## Fraction in each quality, conditional on entry, by parental
# Counts returned are totals by parental, but returned by [qual, parental]
function frac_qual_by_parental(ds :: DataSettings)
    # This is enrollment by [quality, parental]
    dataV = read_matrix_by_xy(raw_entry_qual_parental(ds));
    @assert check_float_array(dataV, 0.01, 1.0);
    @check sum(dataV) ≈ 1.0
    nr = size(dataV, 1);

    # Make conditional on entry (columns sum to 1)
    # Now we have the fraction in each parental who attends each college (cond on entry)
    dataV = dataV ./ sum(dataV, dims = 1);
    @assert all(isapprox.(sum(dataV, dims = 1), 1.0))

    # Count in each cell
    cnts = read_matrix_by_xy(raw_entry_qual_parental(ds; momentType = :count));
    # Count by parental
    cnts = sum(cnts, dims = 1);
    cnts = repeat(cnts, outer = (nr, 1));

    ses = ses_from_choice_probs(dataV, cnts);
    cnts = round.(Int, cnts);
    return dataV, ses, cnts
end


## Graduation rates (conditional on entry) by (quality, parental)
function frac_grad_qual_parental(ds :: DataSettings)
    load_fct = 
        mt -> read_matrix_by_xy(raw_frac_grad_qual_parental(ds; momentType = mt));
    m, ses, cnts = choice_prob_from_xy(load_fct);
    # rf = raw_frac_grad_qual_parental(ds);
    # dataM = read_matrix_by_xy(data_file(rf));
    # @assert check_float_array(dataM, 0.0, 1.0);
    @assert size(m) == (n_colleges(ds), n_parental(ds))
    # dataM = load_frac_grad_qual_parental(ds);
    # zero out 2 year colleges
    m[two_year_colleges(ds), :] .= 0.0;
    cnts[two_year_colleges(ds), :] .= 0;
    return m, ses, cnts
end


# function load_frac_grad_qual_parental(ds :: DataSettings)
#     rf = raw_frac_grad_qual_parental();
#     dataM = CollegeStrat.read_matrix_by_xy(CollegeStrat.data_file(rf));
#     @assert check_float_array(dataM, 0.0, 1.0);
#     @assert size(dataM) == (n_colleges(ds), n_parental(ds))
#     return dataM
# end


function time_to_grad_qual_parental(ds :: DataSettings)
    load_fct = 
        mt -> read_matrix_by_xy(raw_file_path(ds, :timeToGrad_qpM; momentType = mt));
    # dataM = read_matrix_by_xy(raw_file_path(ds, :timeToGrad_qpM));
    m, ses, cnts = mean_from_xy(load_fct);
    @assert check_float_array(m, 3.0, 7.0);
    @assert size(m) == (n_colleges(ds), n_parental(ds))
    # zero out 2 year colleges
    m[two_year_colleges(ds), :] .= 0.0;
    cnts[two_year_colleges(ds), :] .= 0;
    return m, ses, cnts
end


# function load_time_to_grad_qual_parental(ds :: DataSettings)
#     rf = raw_time_to_grad_qual_parental();
#     dataM = CollegeStrat.read_matrix_by_xy(CollegeStrat.data_file(rf));

#     @assert check_float_array(dataM, 3.0, 7.0);
#     @assert size(dataM) == (n_colleges(ds), n_parental(ds))
#     return dataM
# end
    
# ---------------