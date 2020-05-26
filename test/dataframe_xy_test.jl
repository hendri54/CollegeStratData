function dataframe_xy_test()
	@testset "DataFrameXY" begin
		rf = CollegeStratData.raw_entry_gpa_parental();
		fPath = data_file(rf);
		df = CollegeStratData.read_by_xy(fPath);
		@test size(df) == (5,6)

		colHeaderV = CollegeStratData.col_headers(df);
		@test colHeaderV[1] == CollegeStratData.col_header(:gpa, 1)
		rowHeaderV = CollegeStratData.row_headers(df);
		@test rowHeaderV[2] == CollegeStratData.row_header(2)

		m = CollegeStratData.data_matrix(df);
		@test isa(m, Matrix{Float64})
		@test size(m) == (length(rowHeaderV), length(colHeaderV))

		total = CollegeStratData.total(df);
		@test isa(total, Float64)
		@test total > 0.0

		colTotalV = CollegeStratData.col_totals(df);
		@test isa(colTotalV, Vector{Float64})
		@test all(colTotalV .> 0.0)
		@test all(isfinite.(colTotalV))
		rowTotalV = CollegeStratData.row_totals(df);
		@test isa(rowTotalV, Vector{Float64})
		@test all(rowTotalV .> 0.0)
		@test all(isfinite.(rowTotalV))
	end
end


function dataframe_x_test()
	@testset "DataFrame by X" begin
		rf = CollegeStratData.raw_afqt_pct_qual();
		fPath = data_file(rf);
		@test isfile(fPath)
		d = CollegeStratData.read_by_x(fPath);
		@test isa(d, CollegeStratData.DataFrameX)
		@test length(d) > 3
		v = CollegeStratData.data_vector(d);
		@test length(v) == length(CollegeStratData.row_indices(d))
		@test all(isfinite.(v))
		@test all(v .> 0.0)
		v2 = CollegeStratData.read_vector_by_x(fPath);
		@test v ≈ v2
	end
end





@testset "DataFrameXY" begin
	dataframe_xy_test()
	dataframe_x_test()
end

# -----------