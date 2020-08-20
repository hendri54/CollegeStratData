using EconometricsLH

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
	for dsName ∈ CollegeStratData.data_settings_list()
		raw_data_files_test(dsName)
	end
end

# -------------