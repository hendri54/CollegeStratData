using CollegeStratData, Test

csd = CollegeStratData;

function worker_moments_test(dsName)
	@testset "Worker moments" begin
		ds = make_data_settings(dsName);
		yV = exper_profile(ds, :HSG, T = 30);
		yV = exper_profile(ds, :CG, T = 30);
		@test length(yV) == 30
		@test all(yV .>= 0.0)
		@test all(yV .< 1.5)
		@test all(diff(yV[1:10]) .> 0)
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

function rupert_zanella_test(s)
    @testset "Rupert/Zanella $s" begin
        age1 = 35;
        age2 = 65;
        logEffV = csd.read_rupert_zanella(age1, age2, s);
        @test logEffV isa Vector{Float64};
        @test all(logEffV .> log(0.5));
        @test length(logEffV) == (age2 - age1 + 1);

        T = 40;
        logEffV = collect(LinRange(0.0, 2.3, T));
        logEff2V = copy(logEffV);
        maxExper = 11;
        csd.splice_rupert_zanella!(logEffV, maxExper, s);
        @test all(isapprox(logEffV[1 : maxExper], logEff2V[1 : maxExper]));
        @test all(logEffV .>= 0.0)
    end
end


@testset "Load data moments" begin
	for dsName ∈ CollegeStratData.data_settings_list()
		worker_moments_test(dsName)
	end
    for s ∈ (:HSG, :SC, :CG)
        rupert_zanella_test(s);
    end
end

# ------------