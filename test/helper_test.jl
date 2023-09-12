function helper_test()
	@testset "Helpers" begin
        @test isequal(regressor_name(:gpa, 2), :Afqt2);
        @test isequal(regressor_name(ClassHsGpa(), 1), :Afqt1);
	end
end

@testset "Helpers" begin
    helper_test()
end


# ---------------