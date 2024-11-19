module App
using GenieFramework
using DataFrames
using CSV
using PlotlyJS
# using StatsBase
@genietools

# Importing the CSV for input data and Recommended sheet
data = CSV.read(joinpath(@__DIR__, "data", "AB_NYC_2019.csv"), DataFrame)
recommendation = CSV.read(joinpath(@__DIR__, "public", "top_5_recommendations.csv"), DataFrame)

# == Reactive code ==
# add reactive code to make the UI interactive
@app begin    
    @in location_selection = [""]
    @out location_list = String.(unique(data[!, :neighbourhood_group]))
    # Group by neighborhood_group and count
    @in neighborhood_counts = combine(groupby(data, :neighbourhood_group), nrow => :count)
    @out location_counts = Int64.(neighborhood_counts.count)

    @out availability_365_list = String.(unique(data[!, :availability_365]))
    
    @in area_selection = [""]
    @out area_list = String.(unique(data[!, :neighbourhood]))

    @in room_selection = [""]
    @out room_type_list = String.(unique(data[!, :room_type]))  
    @out room_type_count = combine(groupby(data, :room_type), nrow => :count)
    @out room_type_counts = Int64.(room_type_count.count)

    
    @out listing_name_list = String.(first(recommendation[!, :name], 3))
    @out neighbourhood_group_list = String.(first(recommendation[!, :neighbourhood_group], 3))
    @out neighbourhood_list = String.(first(recommendation[!, :neighbourhood], 3))
    @out room_type_list = String.(first(recommendation[!, :room_type], 3))
    @out price_list = Int.(first(recommendation[!, :price], 3))

    @in N = 50
    @out x = collect(1:10)
    @out y = randn(10) # plot data must be an array or a DataFrame
    @out msg = "The average is 0."
    @in shift = false
    @in form = false


    # == Reactive handlers ==
    # reactive handlers watch a variable and execute a block of code when
    # its value changes
    @onchange N, location_selection, area_selection, room_selection, location_counts, room_type_list, neighbourhood_group_list begin

        x = collect(1:N)
        y = rand(N)
        # result =y # mean_value(rand(N))
        # msg = "The average is $result."
        @show location_selection
        @show neighbourhood_group_list
        @show room_type_list
        @show location_counts
    end
    # the onbutton handler will set the variable to false after the block is executed
    @onbutton shift begin
        y = circshift(y, 1)
    end
    @onbutton form begin
        redirect("/form")
    end
end

# == Pages ==
# register a new route and the page that will be loaded on access
@page("/", "app.jl.html")
include("form.jl")  # New route for the form page
end
