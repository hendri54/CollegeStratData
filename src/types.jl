## ------------  Types

"""
	DataSettings

Settings for data files. These are baked into the data construction (by Oksana), but should still be changeable.
"""
Base.@kwdef mutable struct DataSettings
	name :: Symbol = :default
	dataSubDir :: String = "data"
	rawBaseDir :: String = "/Users/lutz/Dropbox/Dropout Policies/Data/empiricaltargets/NLSY 97 moments by AFQT"
    "Number of school groups"
    nSchool :: UInt8 = 3
	"Number of colleges (qualities)"
    nColleges :: CollInt = 4
    "Number of two year colleges"
    n2Year :: CollInt = 1
	"HS GPA groups"
	hsGpaUbV :: Vector{Float64} = collect(0.25 : 0.25 : 1.0)
	"Parental income groups"
	parentalUbV :: Vector{Float64} = collect(0.25 : 0.25 : 1.0)
	"Number of years for which stats by year are constructed"
	Tmax :: TimeInt = 4
	"Number of data credits per data course"
	creditsPerCourse :: ncInt = 3
	"Year for transfer regression moments"
	transferYear :: TimeInt = 1
	"Year for cross-sectional study time moments"
	studyTimeYear :: TimeInt = 1
	"Year for cross-sectional hours worked moments"
	workTimeYear :: TimeInt = 1
	"Year for cross-sectional tuition moments"
	tuitionYear :: TimeInt = 1
end


"""
	RawDataFile

Raw data file info.

Raw data files sit in a nested directory structure, such as
`SelfReport/dat_files/Means/HS_Char/`
The object contains info for constructing the path.
"""
struct RawDataFile
	# :self or :transcript
	selfOrTranscript  ::  Symbol
	# E.g. :finance
	group  ::  Symbol
	# E.g. :mean or :regression
	momentType :: Symbol
	# E.g. "regression.dat"
	rawFile  ::  String
	ds :: DataSettings
end


# DataFrame holding data by (x,y) loaded from a raw data file
struct DataFrameXY
    df :: DataFrame
end


"""
	$(SIGNATURES)

DataFrame that is loaded from the delimited file.
"""
struct DataFrameX
    df :: DataFrame
end


# ----------------