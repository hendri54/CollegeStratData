using CommonLH, EconometricsLH, Test
using CollegeStratData

csd = CollegeStratData;

function load_moments_test(dsName)
    @testset "Load moments" begin
        ds = make_data_settings(dsName);
        gradRate, ses, cnt = load_moment(ds, :fracGrad);
		@test check_float(gradRate, lb = 0.4, ub = 0.7)
		@test check_float(ses, lb = 0.01, ub = 0.1)
		@test cnt > 1000

        # corrGP, _ = load_moment(ds, :corrGpaYp)
        # @test check_float(corrGP, lb = 0.3, ub = 0.7)

        mm = CollegeStratData.moment_map();
		for mName in keys(mm)
			println("Loading $mName")
            dataM = load_moment(ds, mName);
            if isa(dataM, RegressionTable)
				# nothing
			else
				m = dataM[1];
				ses = dataM[2];
				cnts = dataM[3];
				@test isequal(size(m), size(ses))
				@test isequal(size(m), size(cnts))
				if isa(m, Array)  &&  eltype(m) <: AbstractFloat
					@test check_float_array(m, -1e6, 1e6)
					@test check_float_array(ses, 0.0, 9999.0)
					@test eltype(cnts) <: Integer
				elseif isa(m, AbstractFloat)
					@test check_float(m);
					@test check_float(ses, lb = 0.0, ub = 9999.9)
					@test isa(cnts, Integer)
				else
					@warn "$mName of type $(typeof(m))"
					@test check_float_array(m, lb = -1e6, ub = 1e6)
				end
            end
        end
	end
end



# Test making individual data moments
# There is no point testing each one. Test one of each "kind" (e.g. by gpa/yp)
# and then test making the entire moment vector with deviations
function make_target_test(dsName)
	@testset "Make target" begin
		ds = make_data_settings(dsName);
		d1, _ = load_moment(ds, :fracEnter_gpM);
		@test all(d1 .> 0.0)  &&  all(d1 .< 1.0)
		@test isapprox(d1[2,1], 0.37, atol = 0.01)

		# Read from file by quality / gpa
		d2, _ = load_moment(ds, :fracGrad_gV);
		@test 0.2 < d2[2] < 0.3

		# Read from file by quality only
		d3, _ = load_moment(ds, :gpaMean_qV);
		@test all(d3 .> 0.0)  &&  all(d3 .< 1.0)
		@test isapprox(d3[2], 0.58, atol = 0.03)
		
		# By qual/gpa
		d4, ses, cnts = load_moment(ds, :timeToDrop4y_qgM);
		@test all((d4 .>= 1.0)  .|  (cnts .== 0))  &&  all(d4 .< 6.0)
		# Two values, depending on whether we use transcripts or self reports
        @test isapprox(d4[1,2], 2.0, atol = 0.5)

		d5, _ = load_moment(ds, :workTime_pV);
		@test all(d5 .> 600.0)  &&  all(d5 .< 1200.0)

		d6, _ = load_moment(ds, :cumLoans_qtM);
		@test d6[2,3] > 7500.0 

		d7 = CollegeStratData.cdf_gpa_by_qual(ds, [20], 1:4);
		@test size(d7) == (1, 4)
		@test all(d7 .< 80)
		@test all(d7[2:end] .> 30)
		# Table is by percentile/quality
		d7a = CollegeStratData.cdf_gpa_by_qual(ds, 10:10:90, 1:4);
		# GPA means should rise with college quality and percentile
		@test all(diff(d7a, dims = 1) .>= 0.0)
		@test all(diff(d7a, dims = 2) .>= 0.0)

		# test_header("Scalar moments");
		# df = CollegeStratData.read_scalar_moments();
		# @test isa(df, DataFrame)

		# corr1 = load_moment(ds, :corrGpaYp);
		# @test isa(corr1, ScalarDeviation)

		tuitionV, _ = load_moment(ds, :tuition_qV);
		@test all(tuitionV .> 400.0)
		@test all(tuitionV .< 50000.0)

		# rf = CollegeStratData.raw_mass_entry_qual_gpa();
		# @test isfile(CollegeStratData.data_file(rf))
		m, _ = load_moment(ds, :massEntry_qgM);
		@test size(m) == (csd.n_colleges(ds), csd.n_gpa(ds))

        coursesM, _ = load_moment(ds, :coursesTried_qtM);
		@test size(coursesM, 1) == csd.n_colleges(ds)

		# Courses by [grad outcome, year]]
		courses_otM, _ = load_moment(ds, :coursesTried_otM);
		@test size(courses_otM, 1) == 2
		@test all(6.0 .< courses_otM[1,:] .< 10.0)
		@test all(9.0 .< courses_otM[2,:] .< 14.0)

		# Cumulative loans by year; percentile
		t = 2;
		cumLoans = csd.cum_loans_year(ds, t; percentile = 90);
		@test 10_000.0 < cumLoans < 13_000.0
		cumLoansV = csd.cum_loans_year(ds; percentile = 90);
		@test cumLoansV[t] == cumLoans

		cumLoans = csd.cum_loans_year(ds, t);
		@test 3_000.0 < cumLoans < 5_000.0
	end
end


function regr_file_test()
	@testset "Regression files" begin
		# Read regression file
		fPath = joinpath(CollegeStratData.test_sub_dir(), "regression_test.dat");
		rt = CollegeStratData.read_regression_file(fPath; renameRegr = false);
		@test get_coefficient(rt, "afqt1") ≈ 1.0  &&  get_coefficient(rt, "afqt3") ≈ 3.0
		@test get_std_error(rt, "afqt1") ≈ 11.0  &&  get_std_error(rt, "afqt2") ≈ 12.0
	end
end




@testset "Load data moments" begin
	for dsName ∈ CollegeStratData.data_settings_list()
		load_moments_test(dsName)
		make_target_test(dsName)
	end
    regr_file_test()
end

# --------------