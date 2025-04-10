using CollegeStratData, Test;

mdl = CollegeStratData;

function grad_rates_test(dsName, xVar)
    @testset "Grad rates [q, $(xVar)]" begin
        ds = make_data_settings(dsName);
        mEntry = Symbol("massEntry_q$(xVar)M");
        mFracGrad = Symbol("fracGrad_q$(xVar)M");
        mMassGrad = Symbol("massGrad_q$(xVar)M");
        mFracGradX = Symbol("fracGrad_$(xVar)V");

        massEnter_qgM, _ = load_moment(ds, mEntry);
        mass_gV = vec(sum(massEnter_qgM, dims = 1));
        mass_qV = vec(sum(massEnter_qgM, dims = 2));
        fracGrad_qgM, _ = load_moment(ds, mFracGrad);
        massGrad_qgM = massEnter_qgM .* fracGrad_qgM;

        massGrad2_qgM, _ = load_moment(ds, mMassGrad);
        @test isapprox(massGrad_qgM ./ sum(massGrad_qgM), 
            massGrad2_qgM ./ sum(massGrad2_qgM), atol = 1e-3);

        fracGrad, _ = load_moment(ds, :fracGrad);
        fracGrad2 = sum(massGrad_qgM) / sum(massEnter_qgM);
        # The large tolerance b/c entry rate differs between [q,p] and [q,g] samples.
        @test isapprox(fracGrad, fracGrad2, atol = 0.02);

        fracGrad_gV, _ = load_moment(ds, mFracGradX);
        massGrad_gV = vec(sum(massGrad_qgM, dims = 1));
        @test isapprox(fracGrad_gV, massGrad_gV ./ mass_gV, atol = 1e-3);

        # This is less precise for one of the `xVar` b/c it is
        # constructed from the joint entry mass of the other xVar.
        fracGrad_qV, _ = load_moment(ds, :fracGrad_qV);
        massGrad_qV = vec(sum(massGrad_qgM, dims = 2));
        @test isapprox(fracGrad_qV, massGrad_qV ./ mass_qV, atol = 1e-2);
    end
end


@testset "Cross-restrictions" begin
	for dsName ∈ CollegeStratData.data_settings_list()
        for xVar in (:g, :p)
            grad_rates_test(dsName, xVar);
        end
    end
end

# -------------------