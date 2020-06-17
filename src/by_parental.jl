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


## Hours worked, year 1
function work_hours_by_parental(ds :: DataSettings)
    load_fct = 
        mt -> read_col_totals(raw_work_hours_qual_parental(ds; momentType = mt));
    m, ses, cnts = mean_from_xy(load_fct);
    # m, ses, cnts = mean_from_col_total(ds, :workTime_pV);
    # read_col_totals(raw_file_path(ds, :workTime_pV));
    @assert all(m .> 300.0)  &&  all(m .< 2200.0)
    @assert all(cnts .> 100)
    return m, ses, cnts
end


# ------------------------