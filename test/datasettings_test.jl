using CommonLH
using Test

function data_settings_test()
    @testset "DataSettings" begin
        ds = default_data_settings();
        @test n_school(ds) > 2
        @test n_colleges(ds) > 2
        @test n_2year(ds) < n_colleges(ds)
        @test n_gpa(ds) > 2
        @test n_parental(ds) > 2
        @test all(diff(hsgpa_ub(ds)) .> 0.0)
        @test all(diff(parental_ub(ds)) .> 0.0)
        @test all(hsgpa_masses(ds) .> 0.0)
        @test all(parental_masses(ds) .> 0.0)
        @test size(mass_gpa_yp(ds)) == (n_gpa(ds), n_parental(ds))

		@test is_two_year(ds, 1)
		@test !is_two_year(ds, 3)
		idx2V = two_year_colleges(ds);
		for ic in idx2V
			@test is_two_year(ds, ic)
		end

		idxNoV = no_grad_idx(ds);
		idxGradV = grad_idx(ds);
		@test vcat(idxNoV, idxGradV) == collect(1 : n_colleges(ds))

		g_edgeV = CollegeStratData.hsgpa_edges(ds);
		@test check_float_array(g_edgeV, 0.0, 1.0)
		g_massV = CollegeStratData.hsgpa_masses(ds)
		@test check_float_array(g_massV, 0.0, 0.5)
		@test isapprox(sum(g_massV), 1.0)
		@test isapprox(sum(parental_masses(ds)), 1.0)
		oneV = ones(length(g_massV))
		@test isapprox(mean_by_gpa(oneV, ds), 1.0)

		mass_gpM = mass_gpa_yp(ds);
		@test isapprox(sum(mass_gpM), 1.0)
		@test isapprox(vec(sum(mass_gpM, dims = 1)),  parental_masses(ds))
		@test isapprox(sum(mass_gpM, dims = 2),  hsgpa_masses(ds))

	end
end

@testset "DataSettings" begin
    data_settings_test()
end

# ------------