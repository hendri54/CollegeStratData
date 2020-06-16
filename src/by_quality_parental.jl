## -----------  By quality / parental


## Fraction in each quality, conditional on entry, by parental
function frac_qual_by_parental(ds :: DataSettings)
    target = :fracQual_qpM;
    rf = raw_entry_qual_parental(ds);
    dataV = read_matrix_by_xy(data_file(rf));
    @assert check_float_array(dataV, 0.01, 1.0);
    @check sum(dataV) ≈ 1.0

    # Make conditional on entry (columns sum to 1)
    dataV = dataV ./ sum(dataV, dims = 1);
    @assert all(isapprox.(sum(dataV, dims = 1), 1.0))
    return dataV
end


## Graduation rates (conditional on entry) by (quality, parental)
function frac_grad_qual_parental(ds :: DataSettings)
    rf = raw_frac_grad_qual_parental(ds);
    dataM = read_matrix_by_xy(data_file(rf));
    @assert check_float_array(dataM, 0.0, 1.0);
    @assert size(dataM) == (n_colleges(ds), n_parental(ds))
    # dataM = load_frac_grad_qual_parental(ds);
    # zero out 2 year colleges
    dataM[two_year_colleges(ds), :] .= 0.0;
    return dataM
end


# function load_frac_grad_qual_parental(ds :: DataSettings)
#     rf = raw_frac_grad_qual_parental();
#     dataM = CollegeStrat.read_matrix_by_xy(CollegeStrat.data_file(rf));
#     @assert check_float_array(dataM, 0.0, 1.0);
#     @assert size(dataM) == (n_colleges(ds), n_parental(ds))
#     return dataM
# end


function time_to_grad_qual_parental(ds :: DataSettings)
    dataM = read_matrix_by_xy(raw_file_path(ds, :timeToGrad_qpM));

    @assert check_float_array(dataM, 3.0, 7.0);
    @assert size(dataM) == (n_colleges(ds), n_parental(ds))
    # dataM = load_time_to_grad_qual_parental(ds);
    # zero out 2 year colleges
    dataM[two_year_colleges(ds), :] .= 0.0;
    return dataM
    # wtM = 1.0 ./ dataM;
    # wtM[dataM .== 0.0] .= 0.0;

end


# function load_time_to_grad_qual_parental(ds :: DataSettings)
#     rf = raw_time_to_grad_qual_parental();
#     dataM = CollegeStrat.read_matrix_by_xy(CollegeStrat.data_file(rf));

#     @assert check_float_array(dataM, 3.0, 7.0);
#     @assert size(dataM) == (n_colleges(ds), n_parental(ds))
#     return dataM
# end
    
# ---------------