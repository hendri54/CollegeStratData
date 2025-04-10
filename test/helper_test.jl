function helper_test()
	@testset "Helpers" begin
        @test isequal(regressor_name(:gpa, 2), :AFQT2);
        @test isequal(regressor_name(ClassHsGpa(), 1), :AFQT1);
	end
end

@testset "Helpers" begin
    helper_test()
end


# ---------------