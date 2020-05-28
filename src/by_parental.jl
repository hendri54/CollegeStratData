function frac_enter_by_parental(ds :: DataSettings)
    # Read ROW totals b/c file is transposed
    m = read_row_totals(raw_file_path(ds, :fracEnter_pV));
    @assert all(m .> 0.0)  &&  all(m .< 1.0)
    return m
end


## Hours worked, year 1
function work_hours_by_parental(ds :: DataSettings)
    m = read_col_totals(raw_file_path(ds, :workTime_pV));
    @assert all(m .> 300.0)  &&  all(m .< 2200.0)
    return m
    # if modelUnits
    #     m = hours_data_to_mtu(m, :hoursPerYear);
    #     @assert all(m .> 0.0)  &&  all(m .< 0.9)
    # end
end


# ------------------------