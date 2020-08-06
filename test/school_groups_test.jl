using CollegeStratData, Test

csd = CollegeStratData;

function school_groups_test(sg); # :: csd.AbstractSchoolGroups)
    @testset "School groups" begin
        sGroupV = csd.s_groups(sg);
        @test length(sGroupV) == csd.n_school(sg)
        for j = 1 : csd.n_school(sg)
            @test csd.s_idx(sg, sGroupV[j]) == j
        end
	end
end

@testset "SchoolGroups" begin
    school_groups_test(csd.SchoolGroups3());
end

# ------------