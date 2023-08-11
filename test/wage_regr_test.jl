using BaseMM, CollegeStratData, Test

csd = CollegeStratData;

function regr_files_test()
    @testset "Regression files" begin
        @test csd.validate_regressor_name(:inc_quartile2)
        @test csd.validate_regressor_name(:quartile3)
        @test csd.validate_regressor_name(:quality4)
        @test !csd.validate_regressor_name(:qq4)
    end
end

function wage_regr_test(wr :: csd.WageRegressions)
    @testset "Wage regressions" begin
        @test csd.max_exper(wr) > 10
        @test 2 ≤ csd.max_exper_exponent(wr) ≤ 4
        @test length(ed_symbols(wr)) == n_school(wr)
        @test isa(ed_symbols(wr), Vector{Symbol})
	end
end

@testset "Wage Regressions" begin
    wage_regr_test(csd.default_wage_regressions());
    regr_files_test()
end

# ------------