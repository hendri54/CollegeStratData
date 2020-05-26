using DataFrames, Test, CommonLH, CollegeStrat

# include("../src/constantsCQ.jl")





# Test making individual data moments
# There is no point testing each one. Test one of each "kind" (e.g. by gpa/yp)
# and then test making the entire moment vector with deviations
function make_target_test()
	@testset "Make target" begin
		ds = CollegeStrat.default_data_settings();
		d1 = CollegeStrat.entry_by_gpa_yp(ds);
		@test all(d1.dataV .> 0.0)  &&  all(d1.dataV .< 1.0)
		@test d1.dataV[2,1] .≈ 0.37438369
		filePath = joinpath(test_dir(), "plot_gpa_yp_test.pdf");
		p = CollegeStrat.plot_gpa_yp(ds, d1, true, filePath);
		@test isfile(filePath)

		# Read from file by quality / gpa
		d2 = CollegeStrat.grad_rate_by_gpa(ds);
		@test d2.dataV[2] ≈ 0.29254061

		# Read from file by quality only
		d3 = CollegeStrat.afqt_mean_by_quality(ds);
		@test all(d3.dataV .> 0.0)  &&  all(d3.dataV .< 1.0)
		@test d3.dataV[2] ≈ 0.5847987
		
		# By qual/gpa
		d4 = CollegeStrat.time_to_drop_qual_gpa(ds);
		@test all(d4.dataV .> 1.0)  &&  all(d4.dataV .< 6.0)
		# Two values, depending on whether we use transcripts or self reports
		@test (d4.dataV[1,2] ≈ 2.8366325) || (d4.dataV[1,2] ≈ 1.8828769)

		d5 = CollegeStrat.work_hours_by_parental(ds;  modelUnits = false);
		@test all(d5.dataV .> 400.0)  &&  all(d5.dataV .< 1800.0)
		@test d5.dataV[2] ≈ 1056.0529

		d6 = CollegeStrat.cum_loans_qual_year(ds; modelUnits = false);
		@test d6.dataV[2,3] > 8000.0  #  ≈ 8146.27

		d7 = CollegeStrat.cdf_gpa_by_qual([20], 1:4);
		@test size(d7) == (1, 4)
		@test all(d7 .< 80)
		@test all(d7[2:end] .> 30)
		# Table is by percentile/quality
		d7a = CollegeStrat.cdf_gpa_by_qual(10:10:90, 1:4);
		# GPA means should rise with college quality and percentile
		@test all(diff(d7a, dims = 1) .>= 0.0)
		@test all(diff(d7a, dims = 2) .>= 0.0)

		test_header("Scalar moments");
		df = CollegeStrat.read_scalar_moments();
		@test isa(df, DataFrame)

		corr1 = CollegeStrat.corr_gpa_yp(ds);
		@test isa(corr1, ScalarDeviation)

		tuitionV = CollegeStrat.college_tuition(ds, modelUnits = false);
		@test all(tuitionV .> 500.0)
		@test all(tuitionV .< 50000.0)

		rf = CollegeStrat.raw_mass_entry_qual_gpa();
		@test isfile(CollegeStrat.data_file(rf))
		dev = CollegeStrat.mass_entry_qual_gpa(ds);
		@test isa(dev, ModelParams.Deviation)

		t = 1;
		dev = CollegeStrat.courses_tried_qual_year(ds; modelUnits = false);
		for t = 1 : ds.Tmax
			coursesV = CollegeStrat.courses_tried_qual(ds, t; modelUnits = false);
			@test length(coursesV) == CollegeStrat.n_colleges(ds)
			# In Deviation, two year colleges are zeroed out after year 2
			@test all((coursesV .≈ dev.dataV[:, t]) .| (dev.dataV[:, t] .== 0.0))
		end
	end
end


function make_vector_test()
	@testset "Make vector" begin
		ds = CollegeStrat.default_data_settings();
		caseS = Case(:test);
		dv = CollegeStrat.make_deviation_vector(ds, caseS.calTargetV); 
		@test isa(dv, DevVector)
		@test ModelParams.length(dv) > 2

		# enable +++
		# d1 = ModelParams.retrieve(dv, :corrGpaYp);
		# @test isa(d1, Deviation)
		# d11 = CollegeStrat.corr_gpa_yp();
		# @test d1.dataV ≈ d11.dataV

		CollegeStrat.show_deviations(ds, dv, true, test_dir())
	end
end



function regr_file_test()
	@testset "Regression files" begin
		# Read regression file
		fPath = joinpath(test_dir(), "regression_test.dat");
		rt = CollegeStrat.read_regression_file(fPath);
		@test CollegeStrat.get_coefficient(rt, "b1") ≈ 1.0  &&  CollegeStrat.get_coefficient(rt, "b3") ≈ 3.0
		@test CollegeStrat.get_std_error(rt, "b1") ≈ 11.0  &&  CollegeStrat.get_std_error(rt, "b2") ≈ 12.0
	end
end


function worker_moments_test()
	@testset "Worker moments" begin
		ds = CollegeStrat.default_data_settings();
		yV = CollegeStrat.exper_profile(2, T = 30);
		@test length(yV) == 30
		@test all(yV .>= 0.0)
		@test all(yV .< 1.5)
		@test all(diff(yV[1:14]) .> 0)
		@test yV[1] ≈ 0.0

		rd = CollegeStrat.wage_regr_intercepts(ds);
		@test isa(rd, RegressionDeviation)

		rt = CollegeStrat.load_regr_intercepts();
		earn11 = CollegeStrat.workstart_earnings(rt, 1, 1; modelUnits = false);
		earn22 = CollegeStrat.workstart_earnings(rt, 2, 2; modelUnits = false);
		@test earn11 > 5_000
		@test earn11 < 15_000
		@test earn22 > earn11
		@test earn22 < 30_000

		rt = CollegeStrat.load_regr_grads();
		earn11 = CollegeStrat.workstart_earnings(rt, 1, 0; quality = 1, modelUnits = false);
		@test earn11 > 15_000
		@test earn11 < 25_000
		earn24 = CollegeStrat.workstart_earnings(rt, 2, 0; quality = 4, modelUnits = false);
		@test earn24 > 15_000
		@test earn24 < 25_000
		@test earn24 > earn11
	end
end


function show_moments_test()
	@testset "Show moments" begin
		ds = CollegeStrat.default_data_settings();
		filePath = joinpath(test_dir(), "exper_wage.pdf")
		CollegeStrat.plot_exper_wage_profiles(ds, filePath);
		@test isfile(filePath);

		modelV = collect(range(2.0, 4.0, length = 5));
		dataV = modelV .+ 1.0;
		dev = Deviation{Double}(name = :test, dataV = dataV, modelV = modelV,
        	wtV = 1.0 ./ dataV,  scalarWt = 1.0,
			shortStr = "test", longStr = "Test", showPath = "test");
		fPath = joinpath(test_dir(), "plot_dev_vector_test.pdf");
		isfile(fPath)  &&  rm(fPath);
		xStrV = ["x$j" for j = 1 : length(modelV)];
		CollegeStrat.plot_dev_vector(dev, xStrV, true, fPath);
		@test isfile(fPath)
	end
end


@testset "Data" begin
	helper_test()
	moment_table_test()
    make_target_test()
	make_vector_test()
	dataframe_xy_test()
	dataframe_x_test()
	data_files_test()
	regr_file_test()
	worker_moments_test()
	show_moments_test()
end


# --------------
