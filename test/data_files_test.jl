using EconometricsLH

function directories_test()
	@testset "Directories" begin
		baseDir = rstrip(CollegeStratData.base_dir(), '/');
		@test endswith(baseDir, "college_stratification")
		@test isdir(baseDir)
		projectDir = CollegeStratData.project_dir();
		@test endswith(projectDir, "CollegeStratData")
		@test isdir(projectDir)
	end
end

function data_files_test(dsName)
	@testset "Data files" begin
		ds = make_data_settings(dsName);
        rf = CollegeStratData.raw_wage_regr(ds);
        rt = read_regression_file(data_file(rf));
        @test isa(rt, RegressionTable)
		# @test isdir(CollegeStrat.raw_data_dir(:selfReport, :mean, :hsGrads))

		# mStat = CollegeStrat.ModelStatistic(:mAbc);
		# dm = CollegeStrat.DataMoment(:abc, mStat, "abc.dat", nothing, 
		# 	CollegeStrat.entry_by_gpa_yp, CollegeStrat.show_deviation_fallback);
		# # @test !CollegeStrat.has_raw_data_file(dm)

		# mTable = CollegeStrat.make_moment_table();
		# dm = CollegeStrat.get_moment(mTable, :fracEnter_gpM);
		# @test isa(dm, CollegeStrat.DataMoment)

		# # Regression file
		# dm = CollegeStrat.DataMoment(:abc, mStat, "abc.dat", 
		# 	CollegeStrat.RawDataFile(:selfReport, :none, :regression, "loginc_reg1.dat"), nothing, nothing);
		# @test isfile(CollegeStrat.raw_data_file(dm.rawFile));
		# @test isfile(CollegeStrat.raw_data_file(dm))

	end
end


function raw_data_files_test(dsName)
	@testset "Raw data files" begin
		ds = make_data_settings(dsName);
        for rf in [CollegeStratData.raw_entry_qual_parental(ds),
            CollegeStratData.raw_transfer_regr(ds)]

            @test isfile(CollegeStratData.data_file(rf));
		end
		
		# Mapping of moments to files
		missList = missing_file_list(ds);
		@test isempty(missList)

		# copy_raw_data_files(trialRun = true);
    end
end


@testset "DataFiles" begin
	directories_test()
	for dsName ∈ CollegeStratData.data_settings_list()
		data_files_test(dsName)
		raw_data_files_test(dsName)
	end
end

# -------------