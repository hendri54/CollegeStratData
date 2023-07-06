function frac_enter_by_parental(ds :: DataSettings)
    # Read ROW totals b/c file is transposed
    load_fct = 
        mt -> read_row_totals(raw_entry_gpa_parental(ds; momentType = mt));
    m, ses, cnts = choice_prob_from_xy(load_fct);
    # m, ses, cnts = choice_prob_from_row_total(ds, :fracEnter_pV);
    # m = read_row_totals(raw_file_path(ds, :fracEnter_pV));
    @assert all(m .> 0.0)  &&  all(m .< 1.0)
    @assert all(cnts .> 100)
    return m, ses, cnts
end


## College earnings, year 1
function coll_earn_by_parental(ds :: DataSettings; year = 1)
    @assert (year == 1)  "Implement other years";
    load_fct = 
        mt -> read_col_totals(ds, :collEarn_qpM, mt);
    m, ses, cnts = load_mean_ses_counts(load_fct);
    @assert all(m .> 2_000.0)  &&  all(m .< 10_000.0);
    @assert all(cnts .> 100);
    return m, ses, cnts
end


## Hours worked, year 1
function work_hours_by_parental(ds :: DataSettings)
    load_fct = 
        mt -> read_col_totals(ds, :workTime_qpM, mt);
    m, ses, cnts = load_mean_ses_counts(load_fct);
    @assert all(m .> 300.0)  &&  all(m .< 2200.0)
    @assert all(cnts .> 100)
    return m, ses, cnts
end

# 4y colleges only
function time_to_grad_4y_by_parental(ds :: DataSettings)
    load_fct = 
        mt -> read_col_totals(ds, :timeToGrad4y_pV, mt);
    m, ses, cnts = load_mean_ses_counts(load_fct);
    @assert all(m .< 6.0);
    @assert all(cnts .> 100);
    return m, ses, cnts
end


# ------------------------