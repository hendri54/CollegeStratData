## Read matrix by [HS GPA, parental income]
# These are transposed in the raw files. Transpose, but then make into a Matrix.
function read_by_gpa_yp(ds :: DataSettings, fPath :: AbstractString)
	df = read_by_xy(fPath);
	m = Matrix{Float64}(data_matrix(df)');
	return m
end

read_by_gpa_yp(ds :: DataSettings, mName :: Symbol) =
	read_by_gpa_yp(ds, raw_file_path(ds, mName));


## -------------  Individual moments


function load_entry_gpa_yp(ds :: DataSettings)
	m = read_by_gpa_yp(ds, :fracEnter_gpM);
    @assert all(m .< 1.0)  &&  all(m .> 0.0)
    @assert size(m) == (n_gpa(ds), n_parental(ds))
	return m
end


## ------  Mass by HS GPA / parental. Sums to 1.

# function dm_mass_gpa_yp()
#     target = :mass_gpM;
#     return DataMoment(target, ModelStatistic(:mass_xyM, :gpaYpS),  
#         fn_gpa_yp("mass"), nothing,  
#         mass_by_gpa_yp, plot_gpa_yp)
# end

function mass_by_gpa_yp(ds :: DataSettings)
	m = read_by_gpa_yp(ds, :mass_gpM);
    @assert all(m .< 0.5)  &&  all(m .> 0.0)
	@assert size(m) == (n_gpa(ds), n_parental(ds))
	@check sum(m) ≈ 1.0
	return m
	# return Deviation{Double}(name = target, dataV = m, modelV = m,
	# 	scalarWt = 1.0 / sum(m),
	# 	shortStr = "massGpaYp",
	# 	longStr = "Mass by HSgpa/parental background",
	# 	showPath = fn_gpa_yp("mass"))
end


## College graduation rates, by HS GPA, parental income.
# This is conditional on entry b/c that helps the calibration.
# Currently not constructed
# function grad_rate_by_gpa_yp(ds :: DataSettings)
# 	target = :fracGradGpaYp;
# 	fPath = data_file()
# 	m = read_by_gpa_yp(ds, target);
#     @assert all(m .< 1.0)  &&  all(m .> 0.0)
#     @assert size(m) == (n_gpa(ds), n_parental(ds))

# 	# Make NOT conditional on entry
# 	# dev = entry_by_gpa_yp(ds);
# 	# m = m .* dev.dataV;
# 	return Deviation{Double}(name = target, dataV = m, modelV = m,
# 		wtV = 1.0 ./ m,  scalarWt = 6.0 ./ length(m),
# 		shortStr = String(target),
# 		longStr = "Graduation rates by HSgpa/parental background (conditional on entry)",
# 		showPath = "fracGradGpaYp.txt")
# end


# ---------------