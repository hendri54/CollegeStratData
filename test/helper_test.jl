function helper_test()
	@testset "Helpers" begin
        @test isequal(regressor_name(:gpa, 2), :afqt2)

	end
end

@testset "Helpers" begin
    helper_test()
end


# ---------------