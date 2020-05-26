## -----------  By quality / parental


## Fraction in each quality, conditional on entry, by parental
function frac_qual_by_parental(ds :: DataSettings)
    target = :fracQual_qpM;
    rf = raw_entry_qual_parental();
    dataV = CollegeStrat.read_matrix_by_xy(CollegeStrat.data_file(rf));
    @assert check_float_array(dataV, 0.01, 1.0);
    @check sum(dataV) ≈ 1.0

    # Make conditional on entry (columns sum to 1)
    dataV = dataV ./ sum(dataV, dims = 1);
    @assert all(isapprox.(sum(dataV, dims = 1), 1.0))

    d = Deviation{Double}(name = target, dataV = dataV,
        modelV = dataV,  
        scalarWt = 0.2,  shortStr = String(target),
        longStr = "Fraction each quality by parental",
        showPath = "fracQualityByParental.txt")
end


## Graduation rates (conditional on entry) by (quality, parental)
function frac_grad_qual_parental(ds :: DataSettings)
    dataM = load_frac_grad_qual_parental(ds);
    # zero out 2 year colleges
    dataM[two_year_colleges(ds), :] .= 0.0;
    wtM = ones(size(dataM));
    wtM[dataM .== 0.0] .= 0.0;

    target = :fracGrad_qpM;
    d = Deviation{Double}(name = target, dataV = dataM,
        modelV = dataM,  wtV = wtM, 
        scalarWt = 0.4,  shortStr = String(target),
        longStr = "Graduation rate by quality/parental",
        showPath = "fracGradQualityParental.txt")
end


function load_frac_grad_qual_parental(ds :: DataSettings)
    rf = raw_frac_grad_qual_parental();
    dataM = CollegeStrat.read_matrix_by_xy(CollegeStrat.data_file(rf));
    @assert check_float_array(dataM, 0.0, 1.0);
    @assert size(dataM) == (n_colleges(ds), n_parental(ds))
    return dataM
end


function time_to_grad_qual_parental(ds :: DataSettings)
    dataM = load_time_to_grad_qual_parental(ds);
    # zero out 2 year colleges
    dataM[two_year_colleges(ds), :] .= 0.0;
    wtM = 1.0 ./ dataM;
    wtM[dataM .== 0.0] .= 0.0;

    target = :timeToGrad_qpM;
    d = Deviation{Double}(name = target, dataV = dataM,
        modelV = dataM,  wtV = wtM, 
        scalarWt = 0.3,  shortStr = String(target),
        longStr = "Time to graduate by quality/parental",
        showPath = "timeToGradQualityParental.txt")
end


function load_time_to_grad_qual_parental(ds :: DataSettings)
    rf = raw_time_to_grad_qual_parental();
    dataM = CollegeStrat.read_matrix_by_xy(CollegeStrat.data_file(rf));

    @assert check_float_array(dataM, 3.0, 7.0);
    @assert size(dataM) == (n_colleges(ds), n_parental(ds))
    return dataM
end
    
# ---------------