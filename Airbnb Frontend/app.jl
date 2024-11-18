module App
using GenieFramework
using DataFrames
using CSV
@genietools

data = CSV.read(joinpath(@__DIR__, "data", "AB_NYC_2019.csv"), DataFrame)


# == Reactive code ==
# add reactive code to make the UI interactive
@app begin    
    @in location_selection = [""]
    @out location_list = String.(unique(data[!, :neighbourhood_group]))

    @in area_selection = [""]
    @out area_list = String.(unique(data[!, :neighbourhood]))

    @in room_selection = [""]
    @out room_type_list = String.(unique(data[!, :room_type]))  

    @in N = 50
    @out x = collect(1:10)
    @out y = randn(10) # plot data must be an array or a DataFrame
    @out msg = "The average is 0."
    @in shift = false
    @in form = false


    # == Reactive handlers ==
    # reactive handlers watch a variable and execute a block of code when
    # its value changes
    @onchange N, location_selection, area_selection, room_selection begin

        x = collect(1:N)
        y = rand(N)
        # result =y # mean_value(rand(N))
        # msg = "The average is $result."
        @show location_selection
        @show area_selection
        @show room_selection
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
