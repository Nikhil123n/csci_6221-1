module form
using GenieFramework
using DataFrames
using CSV
@genietools

data = CSV.read(joinpath(@__DIR__, "data", "AB_NYC_2019.csv"), DataFrame)

@app begin  
    @in location_selection = [""]
    @out location_list = String.(unique(data[!, :neighbourhood_group]))

    @in area_selection = [""]
    @out area_list = String.(unique(data[!, :neighbourhood]))

    @in room_selection = [""]
    @out room_type_list = String.(unique(data[!, :room_type]))
    
    @in N = 3
    @in name_input = ""
    @in latitude_input = ""  
    @in longitude_input = ""

    @in ratings = ""

    # == Reactive handlers ==
    @onchange N, location_selection, area_selection, room_selection, latitude_input, longitude_input, name_input begin
        @show N
        @show room_selection
        @show latitude_input
        @show longitude_input
        @show name_input
        @show ratings
    end 
end

@page("/form", "form.jl.html")
end
