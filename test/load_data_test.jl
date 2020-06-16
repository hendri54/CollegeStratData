using CommonLH, EconometricsLH, Test

function load_moments_test()
    @testset "Load moments" begin
        ds = test_data_settings();
        gradRate = load_moment(ds, :fracGrad);
        @test check_float(gradRate, lb = 0.4, ub = 0.7)
        corrGP = load_moment(ds, :corrGpaYp)
        @test check_float(corrGP, lb = 0.3, ub = 0.7)

        mm = CollegeStratData.moment_map();
        for mName in keys(mm)
            dataM = load_moment(ds, mName);
            if isa(dataM, Array)  &&  eltype(dataM) <: AbstractFloat
                @test check_float_array(dataM, -1e6, 1e6)
            elseif isa(dataM, AbstractFloat)
                @test check_float(dataM);
            elseif isa(dataM, RegressionTable)
                # nothing
            else
                @warn "$mName of type $(typeof(dataM))"
                @test check_float_array(dataM, lb = -1e6, ub = 1e6)
            end
        end
	end
end



# Test making individual data moments
# There is no point testing each one. Test one of each "kind" (e.g. by gpa/yp)
# and then test making the entire moment vector with deviations
function make_target_test()
	@testset "Make target" begin
		ds = test_data_settings();
		d1 = load_moment(ds, :fracEnter_gpM);
		@test all(d1 .> 0.0)  &&  all(d1 .< 1.0)
		@test isapprox(d1[2,1], 0.37, atol = 0.01)

		# Read from file by quality / gpa
		d2 = load_moment(ds, :fracGrad_gV);
		@test isapprox(d2[2], 0.29254061, atol = 0.01)

		# Read from file by quality only
		d3 = load_moment(ds, :gpaMean_qV);
		@test all(d3 .> 0.0)  &&  all(d3 .< 1.0)
		@test isapprox(d3[2], 0.5847987, atol = 0.01)
		
		# By qual/gpa
		d4 = load_moment(ds, :timeToDrop_qgM);
		@test all(d4 .>= 1.0)  &&  all(d4 .< 6.0)
		# Two values, depending on whether we use transcripts or self reports
        @test isapprox(d4[1,2], 2.8366325, atol = 0.01) || 
            isapprox(d4[1,2], 1.8828769, atol = 0.01)

		d5 = load_moment(ds, :workTime_pV);
		@test all(d5 .> 400.0)  &&  all(d5 .< 1800.0)
		@test isapprox(d5[2], 1000.0, atol = 100.0)

		d6 = load_moment(ds, :cumLoans_qtM);
		@test d6[2,3] > 8000.0  #  ≈ 8146.27

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
		# df = CollegeStrat.read_scalar_moments();
		# @test isa(df, DataFrame)

		# corr1 = load_moment(ds, :corrGpaYp);
		# @test isa(corr1, ScalarDeviation)

		tuitionV = load_moment(ds, :tuition_qV);
		@test all(tuitionV .> 500.0)
		@test all(tuitionV .< 50000.0)

		# rf = CollegeStrat.raw_mass_entry_qual_gpa();
		# @test isfile(CollegeStrat.data_file(rf))
		m = load_moment(ds, :massEntry_qgM);
		@test size(m) == (n_colleges(ds), n_gpa(ds))

        coursesM = load_moment(ds, :coursesTried_qtM);
		@test size(coursesM, 1) == n_colleges(ds)
	end
end


function worker_moments_test()
	@testset "Worker moments" begin
		ds = test_data_settings();
		yV = exper_profile(ds, 2, T = 30);
		@test length(yV) == 30
		@test all(yV .>= 0.0)
		@test all(yV .< 1.5)
		@test all(diff(yV[1:14]) .> 0)
		@test yV[1] ≈ 0.0

		rt = wage_regr_intercepts(ds);
		earn11 = workstart_earnings(rt, 1, 1);
		earn22 = workstart_earnings(rt, 2, 2);
		@test earn11 > 5_000
		@test earn11 < 15_000
		@test earn22 > earn11
		@test earn22 < 30_000

		rt = wage_regr_grads(ds);
		earn11 = workstart_earnings(rt, 1, 0; quality = 1);
		@test earn11 > 15_000
		@test earn11 < 25_000
		earn24 = workstart_earnings(rt, 2, 0; quality = 4);
		@test earn24 > 15_000
		@test earn24 < 25_000
		@test earn24 > earn11
	end
end


function regr_file_test()
	@testset "Regression files" begin
		# Read regression file
		fPath = joinpath(CollegeStratData.test_sub_dir(), "regression_test.dat");
		rt = CollegeStratData.read_regression_file(fPath);
		@test get_coefficient(rt, "b1") ≈ 1.0  &&  get_coefficient(rt, "b3") ≈ 3.0
		@test get_std_error(rt, "b1") ≈ 11.0  &&  get_std_error(rt, "b2") ≈ 12.0
	end
end




@testset "Load data moments" begin
    load_moments_test()
    make_target_test()
    worker_moments_test()
    regr_file_test()
end

# --------------