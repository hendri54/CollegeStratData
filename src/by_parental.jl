function frac_enter_by_parental(ds :: DataSettings)
    # target = :fracEnter_pV;
    # Read ROW totals b/c file is transposed
    m = read_row_totals(raw_entry_gpa_parental(ds));
    @assert all(m .> 0.0)  &&  all(m .< 1.0)
    return m
    # dev = frac_enter_dev(target, m, :parental);
    # return dev
end


## Hours worked, year 1
function work_hours_by_parental(ds :: DataSettings)
    # target = :workTime_pV;
    m = read_col_totals(raw_work_hours_qual_parental(ds));
    @assert all(m .> 300.0)  &&  all(m .< 2200.0)
    return m
    # if modelUnits
    #     m = hours_data_to_mtu(m, :hoursPerYear);
    #     @assert all(m .> 0.0)  &&  all(m .< 0.9)
    # end

    # dev = work_hours_dev(target, m, :parental);
    # return dev
end


# ------------------------