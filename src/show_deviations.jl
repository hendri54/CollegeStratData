## ------------  Show deviations


"""
    $(SIGNATURES)

Show all deviations implied by a `ModelParam.DevVector`.

Depending on the format of the deviation, a matching function is called for the display.

If the `DataMoment` defined in `MomentTable` specifies a `showFct`, use it. Otherwise, use the default functions from `ModelParams`.

Scalar deviations are reported together.
"""
function show_deviations(ds :: DataSettings, devV :: DevVector, 
    showModel :: Bool, outDir :: String)

    mTable = make_moment_table();
    println("Showing deviations model / data")
    for i1 = 1 : length(devV)
        dev = devV[i1];
        if has_moment(mTable, dev.name)
            dm = get_moment(mTable, dev.name);
            devPath = show_dev_path(dm, showModel, outDir);
            if has_show_function(dm)
                dm.showFct(ds, dev, showModel, devPath);
            elseif isa(dev, RegressionDeviation)
                show_regression_deviation(dev, showModel, devPath);
            elseif isa(dev, Deviation)
                # Use `ModelParams` method for matrix deviations
                ModelParams.deviation_show_fct(dev, showModel = showModel,
                    fPath = devPath);
            elseif !is_scalar_deviation(dev)
                @warn "No method for showing deviation $(dev.name)"
            end
        else
            @warn "Moment $(dev.name) does not appear in MomentTable"
        end
    end

    show_scalar_deviations(devV, showModel, outDir);
    return nothing
end


function is_scalar_deviation(dev :: AbstractDeviation)
    return isa(dev, ScalarDeviation)
end


# Path for deviation output, no extension
# Extension is automatically added by the show function
function show_dev_path(dm :: DataMoment, showModel :: Bool, outDir :: String)
    # Moments are shown using the same name as the local data file
    fName = local_file(dm);
    # Append "_data" if only data are shown
    if !showModel
        fName = fName * "_data";
    end
    return joinpath(outDir, fName)
end


"""
	$(SIGNATURES)

Show a regression deviation. Simply use the function from `ModelParams`.
"""
function show_regression_deviation(dev :: RegressionDeviation, 
    showModel :: Bool, fPath :: String)

    ModelParams.regression_show_fct(dev, showModel = showModel, 
        fPath = change_extension(fPath, ".txt"));
end


"""
    $(SIGNATURES)
"""
function show_scalar_deviations(devV :: DevVector,  showModel :: Bool,  outDir :: String)
    println("Showing scalar deviations model / data");
    fs = FormatExpr("{1}: {2:.2f}");
    newPath = joinpath(outDir, "scalar_moments.txt");
    open(newPath, "w") do io
        # Header
        write(io, "Moment  Data  Model \n");
        # Write each moment (if scalar)
        for i1 = 1 : length(devV)
            dev = devV[i1];
            if is_scalar_deviation(dev)
                write(io, format(fs, dev.name, get_data_values(dev)[1]));
                if showModel
                    write(io, format(fs, "  model", get_model_values(dev)[1]));
                end
                write(io, "\n");
            end
        end
    end
    return nothing
end


"""
    $(SIGNATURES)

Fallback function for comparing model and data.
Makes a simple table of model and data values.
"""
function show_deviation_fallback(ds :: DataSettings, dev :: Deviation, 
    showModel :: Bool, fPath :: String)

    if isa(dev.dataV, Vector)
        show_deviation_vector(ds, dev, showModel, fPath);
    elseif isa(dev.dataV, Matrix{Double})
        nx, ny = size(dev.dataV);
        xStrV = ["x$j"  for j in 1 : nx];
        yStrV = ["y$j"  for j in 1 : ny];
        plot_dev_xy(dev,  xStrV,   yStrV,  showModel,  fPath);
    else
        show_deviation_vector(ds, dev, showModel, fPath);
    end

    pathV = splitpath(fPath);
    println("Saved deviation output $(pathV[end])")
    return nothing
end


function show_deviation_vector(ds :: DataSettings, dev :: Deviation, 
    showModel :: Bool, fPath :: String)

    fs = FormatExpr("{1:.2f}");
    n = length(dev.dataV);
    m = Matrix{String}(undef, n, 3);
    for i1 = 1 : n
        m[i1, 1] = string(i1);
        m[i1, 2] = format(fs, dev.dataV[i1]);
        if showModel
            m[i1, 3] = format(fs, dev.modelV[i1]);
        else
            m[i1, 3] = "";
        end
    end

    newPath = change_extension(fPath, ".txt");
    open(newPath, "w") do io
        pretty_table(io, m, ["Row", "Data", "Model"])
    end
end


"""
    $(SIGNATURES)

Plot data and optionally model by [x, y].
2x2 bar graph. One graph for each y category.
Returns plot object for further customization or saving.
    
IN
	dev :: Deviation
	plotModel :: Bool
		If `false`, only plot data
	filePath :: String
		Complete file path without extension
"""
function plot_dev_xy(dev :: ModelParams.AbstractDeviation,  xStrV :: Vector{String},
    yStrV :: Vector{String},  plotModel :: Bool,  filePath :: String)
    
    dataM = get_data_values(dev);
    modelM = get_model_values(dev; matchData = true);
    plot_model_data_xy(modelM, dataM, xStrV, yStrV, plotModel, filePath);
end

# For matrix inputs: plot data against model. Grouped bar graphs. One for each `y`.
function plot_model_data_xy(modelM :: Matrix{F1}, dataM :: Matrix{F1},  
    xStrV :: Vector{String},  yStrV :: Vector{String},  
    plotModel :: Bool,  filePath :: String) where F1 <: AbstractFloat

    nx, ny = size(dataM);
    @check length(xStrV) == nx
    @check length(yStrV) == ny

	pV = Vector{Any}(undef, ny);
	for i1 = 1 : ny
		if plotModel
			pV[i1] = groupedbar(xStrV, hcat(dataM[:,i1],  modelM[:,i1]),
				leg = (i1 == 1),  labels = ["Data" "Model"], xlabel = yStrV[i1]);
		else
			pV[i1] = bar(xStrV, dataM[:,i1],  leg = false,  xlabel = yStrV[i1]);
		end
	end

    if iseven(ny)
        nRows = round(Int, ny / 2);
        nCols = round(Int, 2);
    else
        error("Not implemented");
    end
    p = plot(pV...,  layout = (nRows, nCols),  link = :all);
    newPath = change_extension(filePath, ".pdf");
	figsave(p, newPath);
	return p
end


# Plot deviation model/data for a vector deviation
function plot_dev_vector(dev :: AbstractDeviation, xStrV,  plotModel :: Bool,  
    filePath :: String)
    
    dataV = get_data_values(dev);
    modelV = get_model_values(dev; matchData = true);
    nx = length(dataV);

    @check length(xStrV) == nx
    @check isa(dataV, Vector{<:AbstractFloat})  "Expecting a vector valued deviation"

    if plotModel
        p = groupedbar(xStrV, hcat(dataV,  modelV),
            leg = :best,  labels = ["Data" "Model"]);
    else
        p = bar(xStrV, dataV,  leg = false);
    end

    newPath = change_extension(filePath, ".pdf");
	figsave(p, newPath);
	return p
end

show_dev_by_quality(ds :: DataSettings, dev :: AbstractDeviation, showModel :: Bool, fPath :: AbstractString) = 
    plot_dev_vector(dev, quality_labels(ds), showModel, fPath);

show_dev_by_gpa(ds :: DataSettings, dev :: AbstractDeviation, showModel :: Bool, fPath :: AbstractString) = 
    plot_dev_vector(dev, gpa_labels(ds), showModel, fPath);

show_dev_by_parental(ds :: DataSettings, dev :: AbstractDeviation, showModel :: Bool, fPath :: AbstractString) = 
    plot_dev_vector(dev, parental_labels(ds), showModel, fPath);

    
## Plot experience wage profile
function plot_exper_wage_profiles(ds :: DataSettings, filePath :: String)
    nx = 25;
    p = plot();
    for i_s = 1 : nSchool
        yV = exper_profile(i_s);
        plot!(p, 1 : nx, yV[1 : nx])
    end
    xaxis!("Experience");
    yaxis!("Log wage index")
    figsave(p, filePath);
end

# --------------------