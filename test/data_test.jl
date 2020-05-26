using DataFrames, Test, CommonLH, CollegeStrat

# include("../src/constantsCQ.jl")






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
