"""
    grdinfo(cmd0::String="", arg1=nothing; kwargs...)

Reads a 2-D grid file and reports metadata and various statistics for the (x,y,z) data in the grid file

Full option list at [`grdinfo`]($(GMTdoc)grdinfo.html)

Parameters
----------

- **C** | **oneliner** | **numeric** :: [Type => Str | Number]

    Formats the report using tab-separated fields on a single line.
    ($(GMTdoc)grdinfo.html#c)
- **D** | **tiles** :: [Type => Number | Str]  

    Divide a single grid’s domain (or the -R domain, if no grid given) into tiles of size
    dx times dy (set via -I).
    ($(GMTdoc)grdinfo.html#d)
- **E** | **extrema** | **extreme** :: [Type => Bool]

    Report the extreme values found on a per column (E=:x) or per row (E=:y) basis.
- **F** | **report_ingeog** :: [Type => Bool]

    Report grid domain and x/y-increments in world mapping format.
    ($(GMTdoc)grdinfo.html#f)
- **G** | **force** :: [Type => Bool]

    Force (possible) download and mosaicing of all tiles of tiled global remote grids in order
    to report the requested information.
    ($(GMTdoc)grdinfo.html#g)
- **I** | **nearest** :: [Type => Number | Str]     ``Arg = [dx[/dy]|b|i|r]``

    Report the min/max of the region to the nearest multiple of dx and dy, and output
    this in the form -Rw/e/s/n
    ($(GMTdoc)grdinfo.html#i)
- **L** | **force_scan** :: [Type => Number | Str]

    Report stats after actually scanning the data.
    ($(GMTdoc)grdinfo.html#l)
- **M** | **minmax_pos** :: [Type => Bool]

    Find and report the location of min/max z-values.
    ($(GMTdoc)grdinfo.html#m)
- **Q** | **cube** :: [Type => Bool]

    Input files must be data 3-D netCDF data cube. Not compatible with **D**, **E**, **F**, and **Ib** (GMT6.2)
    ($(GMTdoc)grdinfo.html#q)
- $(GMT._opt_R)
- **T** | **minmax** :: [Type => Number | Str]
    Determine min and max z-value.
    ($(GMTdoc)grdinfo.html#t)
- $(GMT.opt_V)
- $(GMT._opt_f)
- $(GMT.opt_o)
"""
function grdinfo(cmd0::String="", arg1=nothing; kwargs...)

	d = init_module(false, kwargs...)[1]		# Also checks if the user wants ONLY the HELP mode
	cmd, = parse_common_opts(d, "", [:R :V_params :f :o])
	(is_in_dict(d, [:numeric], del=true) !== nothing) && (cmd *= " -Cn")
	cmd  = parse_these_opts(cmd, d, [[:C :oneliner], [:D :tiles], [:E :extrema :extreme], [:F :report_ingeog],
                                     [:G :force :force_download], [:I :nearest], [:L :force_scan], [:Q :cube], [:T :minmax :zmin_max]])
	opt_M = add_opt(d, "", "M", [:M :minmax_pos]);  (opt_M != "") && (cmd *= opt_M)
	opt_L = add_opt(d, "", "L", [:L :force_scan]);  (opt_L != "") && (cmd *= opt_L)

	(isa(arg1, GMTgrid) && size(arg1,3) > 1 && !occursin("-Q", cmd)) && (cmd *= " -Q")  # arg1 is a CUBE
	R = common_grd(d, cmd0, cmd, "grdinfo ", arg1)		# Finish build cmd and run it
	if (isa(R, GMTdataset) && contains(cmd, " -C"))
		hdims = (R[end] == 1) ? ["lon_min", "lon_max", "lat_min", "lat_max"] : ["x_min", "x_max", "y_min", "y_max"]
		if (opt_M == "" && opt_L == "")            # 
			(length(R) == 12) ?
				append!(hdims, ["z_min","z_max","dx","dy","n_cols","n_rows","reg","isgeog"]) :
				append!(hdims, ["b(?)","t(?)","z_min","z_max","dx","dy","dz","n_cols","n_rows","n_layers","reg","isgeog"])
			R.colnames = hdims
		elseif (opt_M != "" && opt_L == "")
			(length(R) == 17) &&    # It can be 19 for cubes (not implemented yet)
				(R.colnames = append!(hdims, ["z_min","z_max","dx","dy","n_cols","n_rows","xmin_pos","ymin_pos","xmax_pos","ymax_pos","n_NaNs","reg","isgeog"]))
		end
	end
	return R
end

# ---------------------------------------------------------------------------------------------------
grdinfo(arg1; kw...) = grdinfo("", arg1; kw...)