using CollegeStratData, Test

csd = CollegeStratData;

function wage_regr_test(wr :: csd.WageRegressions)
    @testset "Wage regressions" begin
        @test csd.max_exper(wr) > 10
        @test 2 ≤ csd.max_exper_exponent(wr) ≤ 4
        @test length(csd.s_groups(wr)) == csd.n_school(wr)
        @test isa(csd.s_groups(wr), Vector{Symbol})
	end
end

@testset "Wage Regressions" begin
    wage_regr_test(csd.default_wage_regressions());
end

# ------------