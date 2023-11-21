## -----------  By quality / parental

function coll_earn_qual_parental(ds :: DataSettings; year = 1)
    @assert (year == 1)  "Implement other years";
    load_fct = 
        mt -> read_matrix_by_xy(ds, :collEarn_qpM, mt); 
    m, ses, cnts = load_mean_ses_counts(load_fct);
    @assert size(m) == (n_colleges(ds), n_parental(ds))
    return m, ses, cnts    
end

## College earnings, by quality
function coll_earn_by_qual(ds :: DataSettings; year = 1)
    @assert (year == 1)  "Implement other years";
    load_fct = 
        mt -> read_row_totals(ds, :collEarn_qpM, mt);
    m, ses, cnts = load_mean_ses_counts(load_fct);
    @assert all(m .> 2_000.0)  &&  all(m .< 10_000.0);
    @assert all(cnts .> 100);
    return m, ses, cnts
end



## Fraction in each quality, conditional on entry, by parental
# Counts returned are totals by parental, but returned by [qual, parental]
function frac_qual_by_parental(ds :: DataSettings)
    # This is enrollment by [quality, parental]
    dataV = read_matrix_by_xy(raw_entry_qual_parental(ds));
    @assert check_float_array(dataV, 0.005, 1.0);
    @check sum(dataV) ≈ 1.0
    nr = size(dataV, 1);

    # Make conditional on entry (columns sum to 1)
    # Now we have the fraction in each parental who attends each college (cond on entry)
    dataV = dataV ./ sum(dataV, dims = 1);
    @assert all(isapprox.(sum(dataV, dims = 1), 1.0))

    # Count in each cell
    cnts = read_matrix_by_xy(raw_entry_qual_parental(ds; momentType = MtCount()));
    # Count by parental
    cnts = sum(cnts, dims = 1);
    cnts = repeat(cnts, outer = (nr, 1));
    cnts = clean_cnts(cnts);

    ses = ses_from_choice_probs(dataV, cnts);
    return dataV, ses, cnts
end


## Graduation rates (conditional on entry) by (quality, parental)
function frac_gradc_qual_parental(ds :: DataSettings)
    load_fct = 
        mt -> read_matrix_by_xy(ds, :fracGrad_gpM, mt);
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


"""
Compute from joint distribution of graduates by [q, p]. The marginals are otherwise wrong b/c we set frac grad of 2y colleges to 0.
"""
function frac_gradc_by_parental(ds :: DataSettings)
    massEnter_qpM, _ = load_moment(ds, :massEntry_qpM);
    massGrad_qpM, _ = load_moment(ds, :massGrad_qpM);
    massEnter_gV = vec(sum(massEnter_qpM, dims = 1));
    massGrad_gV = vec(sum(massGrad_qpM, dims = 1));
    m = massGrad_gV ./ massEnter_gV;

    # This now just for counts and std errors.
    load_fct = 
        mt -> read_col_totals(raw_frac_gradc_qual_parental(ds; momentType = mt));
    _, ses, cnts = choice_prob_from_xy(load_fct);
    @assert all(m .> 0.0)  &&  all(m .< 1.0)
    @assert length(m) == n_gpa(ds)
    @assert all(cnts .> 100)
    return m, ses, cnts
end


function mass_entry_qual_parental(ds :: DataSettings)
    m, ses, cnts = mass_entry_qual_x(ds, :p);
    @assert size(m) == (n_colleges(ds), n_parental(ds));
    return m, ses, cnts
end


# No std errors
# Counts are from frac grad by [q, g]
function mass_grad_qual_parental(ds :: DataSettings)
    massEnter_qpM, _ = mass_entry_qual_parental(ds);
    fracGrad_qpM, _, cnts = frac_gradc_qual_parental(ds);
    massGrad_qpM = massEnter_qpM .* fracGrad_qpM;
    ses = zeros(size(massGrad_qpM));
    return massGrad_qpM, ses, cnts
end

    

## Mass of freshmen by quality / other grouping. Sums to 1.
function mass_entry_qual_x(ds :: DataSettings, xVar)
    suffix = "_q$(xVar)M";
    mName = Symbol("massEntry$suffix");
    m = read_matrix_by_xy(ds, mName, MtMean());
    @assert size(m, 1) == n_colleges(ds);
    # SES treats this as a discrete choice problem with total count.
    cnts = read_matrix_by_xy(ds, mName, MtCount());
    cnts = fill(sum(cnts), size(cnts));
    cnts = clean_cnts(cnts);
    @assert all(m .< 1.0)  &&  all(m .> 0.0)
    @assert isapprox(sum(m), 1.0,  atol = 0.0001)
    ses = ses_from_choice_probs(m, cnts);
    return m, ses, cnts
end


# function load_frac_grad_qual_parental(ds :: DataSettings)
#     rf = raw_frac_grad_qual_parental();
#     dataM = CollegeStratData.read_matrix_by_xy(CollegeStratData.data_file(rf));
#     @assert check_float_array(dataM, 0.0, 1.0);
#     @assert size(dataM) == (n_colleges(ds), n_parental(ds))
#     return dataM
# end


# 4y colleges only
function time_to_grad_4y_qual_parental(ds :: DataSettings)
    load_fct = 
        mt -> read_matrix_by_xy(ds, :timeToGrad4y_qpM, mt);
    m, ses, cnts = load_mean_ses_counts(load_fct);
    @assert check_float_array(m, 3.0, 7.0);
    @assert size(m) == (n_4year(ds), n_parental(ds))
    # zero out 2 year colleges
    # m[two_year_colleges(ds), :] .= 0.0;
    # cnts[two_year_colleges(ds), :] .= 0;
    return m, ses, cnts
end


# function load_time_to_grad_qual_parental(ds :: DataSettings)
#     rf = raw_time_to_grad_qual_parental();
#     dataM = CollegeStratData.read_matrix_by_xy(CollegeStratData.data_file(rf));

#     @assert check_float_array(dataM, 3.0, 7.0);
#     @assert size(dataM) == (n_colleges(ds), n_parental(ds))
#     return dataM
# end
    
# ---------------