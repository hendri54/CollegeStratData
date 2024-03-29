using BaseMM, CollegeStratData
using Test

@testset "All" begin
    include("wage_regr_test.jl")
    include("datasettings_test.jl")
    include("helper_test.jl")
    include("data_files_test.jl")
    include("dataframe_xy_test.jl")
    include("load_data_test.jl");
    include("worker_moments_test.jl");
    include("cross_restrictions_test.jl");
end

# -----------