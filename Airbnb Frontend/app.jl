module App
using GenieFramework
using DataFrames
using CSV
using PlotlyJS
using Statistics
using LinearAlgebra
@genietools

# Function to generate recommendations and map
function generate_recommendations(location_selection, area_selection, room_selection)
    # Passing the input to make recommendations
    # feature_str = string(selected_feature)
    location_str = string(location_selection)
    area_str = string(area_selection)
    room_str = string(room_selection)

    try
        run(`julia SmartFilter.jl $location_str $area_str $room_str`)
        println("Successfully executed SmartFilter.jl with feature $location_str")
    catch e
        println("Error executing SmartFilter.jl:")
        println(e)
    end
end

# Function to load and process data dynamically
function load_and_process_data()
    # Importing the CSV for input data and Recommended sheet
    data = CSV.read(joinpath(@__DIR__, "data", "AB_NYC_2019.csv"), DataFrame)
    recommendation = CSV.read(joinpath(@__DIR__, "public", "top_5_recommendations.csv"), DataFrame)
    return data, recommendation
end

data, recommendation = load_and_process_data()
room_type_count = combine(groupby(data, :room_type), nrow => :count)
neighborhood_counts = combine(groupby(data, :neighbourhood_group), nrow => :count)
# Compute availability stats for each location
availability_stats = combine(groupby(data, :neighbourhood_group), 
    :availability_365 => first => :open,
    :availability_365 => minimum => :low,
    :availability_365 => maximum => :high,
    :availability_365 => mean => :close
)


# == Reactive code ==
# add reactive code to make the UI interactive
@app begin        

    @in location_selection = ""
    @out location_list = String.(unique(data[!, :neighbourhood_group]))
    # Group by neighborhood_group and count
    @out location_counts = Int64.(neighborhood_counts.count)

    # @out latitude = Float64.(data.latitude)
    # @out longitude = Float64.(data.longitude)
    # @out neighbor = String.(data.neighbourhood_group)

    @out availability_365_list = Int64.(unique(data[!, :availability_365]))
    @out availability_open = Int64.(availability_stats.open)
    @out availability_low = Int64.(availability_stats.low)
    @out availability_high = Int64.(availability_stats.high)
    @out availability_close = round.(Int64, availability_stats.close)
    
    @in area_selection = ""
    @out area_list = String.(unique(data[!, :neighbourhood]))

    @in room_selection = ""
    @out unique_room_types = String.(unique(data[!, :room_type]))  
    @out room_type_counts = Int64.(room_type_count.count)
# ["shhsd"] [""]
    
    @out recommended_names = String.(first(recommendation[!, :name], 3))
    @out recommended_areas = String.(first(recommendation[!, :neighbourhood_group], 3))
    @out recommended_neighborhoods = String.(first(recommendation[!, :neighbourhood], 3))
    @out recommended_room_types = String.(first(recommendation[!, :room_type], 3))
    @out recommended_prices = Int64.(first(recommendation[!, :price], 3))

    @in N = 50
    @out x = collect(1:10)
    @out y = randn(10) # plot data must be an array or a DataFrame
    @out msg = "The average is 0."
    @in shift = false
    @in form = false

    @in selected_feature = 224  # Add this to make it reactive


    # == Reactive handlers ==
    # reactive handlers watch a variable and execute a block of code when
    # its value changes
    @onchange shift begin
        generate_recommendations(location_selection, area_selection, room_selection)
        data, recommendation = load_and_process_data()
        recommended_names = String.(first(recommendation[!, :name], 3))
        recommended_areas = String.(first(recommendation[!, :neighbourhood_group], 3))
        recommended_neighborhoods = String.(first(recommendation[!, :neighbourhood], 3))
        recommended_room_types = String.(first(recommendation[!, :room_type], 3))
        recommended_prices = Int64.(first(recommendation[!, :price], 3))
        redirect("/")
    end
    @onchange N, location_selection, area_selection, room_selection, recommended_room_types, recommended_areas begin

        plot_x = collect(1:N)
        plot_y = rand(N)
        @show location_selection
        @show recommended_areas
        @show recommended_room_types
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
  # New route for the form page
end
