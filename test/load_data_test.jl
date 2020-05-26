using CommonLH, Test

function load_moments_test()
    @testset "Load moments" begin
        ds = default_data_settings();
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
            else
                @warn "$mName of type $(typeof(dataM))"
                @test check_float_array(dataM, -1e6, 1e6)
            end
        end
	end
end

@testset "Load data moments" begin
    load_moments_test()
end

# --------------