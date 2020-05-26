using EconometricsLH

function data_files_test()
    @testset "Data files" begin
        rf = CollegeStratData.raw_wage_regr();
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


function raw_data_files_test()
    @testset "Raw data files" begin
        for rf in [CollegeStratData.raw_entry_qual_parental(),
            CollegeStratData.raw_transfer_regr()]

            @test isfile(CollegeStratData.data_file(rf));
        end

		# copy_raw_data_files(trialRun = true);
    end
end


@testset "DataFiles" begin
    data_files_test()
    raw_data_files_test()
end

# -------------