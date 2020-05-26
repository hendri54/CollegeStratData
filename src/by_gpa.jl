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
    target = :fracEnter_gV;
    # Read COL totals b/c file is transposed
    m = read_col_totals(raw_entry_gpa_parental(ds));
    @assert all(m .> 0.0)  &&  all(m .< 1.0)
    @assert length(m) == n_gpa(ds)
    return m
    # dev = frac_enter_dev(target, m, :gpa);
    # return dev
end


"""
	$(SIGNATURES)

Mean time to graduation by GPA.
"""
function grad_rate_by_gpa(ds :: DataSettings)
    target = :fracGrad_gV;
    rf = raw_grad_rate_qual_gpa(ds);
    m = read_col_totals(data_file(rf));
    @assert all(m .> 0.0)  &&  all(m .< 1.0)
    @assert length(m) == n_gpa(ds)
    return m
    # dev = frac_grad_dev(target, m, :gpa);
    # return dev
end


# Mean time to drop by quality / gpa
# Contains one 0 cell that needs to be interpolated.
function time_to_drop_by_gpa(ds :: DataSettings)
    target = :timeToDrop_gV;
    rf = raw_time_to_drop_qual_gpa(ds);
    m = read_col_totals(data_file(rf));
    @assert all(m .> 1.5)  &&  all(m .< 4.0)
    @assert length(m) == n_gpa(ds)
    return m
    # dev = time_to_drop_dev(target, m, :gpa);
    # return dev
end


"""
	$(SIGNATURES)

Mean time to graduation by GPA.
"""
function time_to_grad_by_gpa(ds :: DataSettings)
    target = :timeToGrad_gV;
    rf = raw_time_to_grad_qual_gpa(ds);
    m = read_col_totals(data_file(rf));
    @assert all(m .> 3.0)  &&  all(m .< 7.0)
    @assert length(m) == n_gpa(ds)
    return m
    # dev = time_to_grad_dev(target, m, :gpa);
    # return dev
end


"""
	$(SIGNATURES)

Work hours, year 1, by GPA.
"""
function work_hours_by_gpa(ds :: DataSettings)
    target = :workTime_gV;
    rf = raw_work_hours_qual_gpa(ds, ds.workTimeYear);
    m = read_col_totals(data_file(rf));
    @assert all(m .> 400.0)  &&  all(m .< 1800.0)
    @assert length(m) == n_gpa(ds)
    return m
    # # Make model units
    # m = hours_data_to_mtu(m, :hoursPerYear);

    # # Scalar weight as sum = scale by 1/mean and 1/length
    # dev = work_hours_dev(target, m, :gpa);
    # return dev
end

# ------------------