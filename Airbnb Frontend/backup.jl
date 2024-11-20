using CSV
using DataFrames
using LinearAlgebra
using PlotlyJS

# Initialize default values
# Specify the filter parameters (set nothing if not filtering by that parameter)
selected_neighbourhood_group = nothing  # Set to nothing if not filtering by this
selected_neighbourhood = nothing       # Set to nothing if not filtering by this
selected_room_type = nothing          # Set to nothing if not filtering by this
println(selected_neighbourhood_group, selected_neighbourhood, selected_room_type)

# Check the length of ARGS and assign values conditionally
if length(ARGS) > 0
    # Parse the first argument if it exists and is not empty
    if length(ARGS) >= 1 && ARGS[1] != ""
        selected_neighbourhood_group = ARGS[1]
    end

    # Parse the second argument if it exists and is not empty
    if length(ARGS) >= 2 && ARGS[2] != ""
        selected_neighbourhood = ARGS[2]
    end

    # Parse the third argument if it exists and is not empty
    if length(ARGS) >= 3 && ARGS[3] != ""
        selected_room_type = ARGS[3]
    end
end

println(ARGS)
println(selected_neighbourhood_group, selected_neighbourhood, selected_room_type)

# Step 1: Load the AB_NYC_2019.csv dataset
ab_nyc_data = CSV.File("data/AB_NYC_2019.csv") |> DataFrame

# Dynamic filtering logic
filtered_rows = filter(row -> 
    (selected_neighbourhood_group === nothing || row["neighbourhood_group"] == selected_neighbourhood_group) &&
    (selected_neighbourhood === nothing || row["neighbourhood"] == selected_neighbourhood) &&
    (selected_room_type === nothing || row["room_type"] == selected_room_type),
    eachrow(ab_nyc_data)
)

# Select the top 5 recommendations
top_5_recommendations = filtered_rows[1:min(5, length(filtered_rows))]

# Print and save the recommendations
# Print and save the recommendations
if length(top_5_recommendations) > 0
    println("\nTop 5 recommended rows:")
    for (i, row) in enumerate(top_5_recommendations)
        println("Recommendation $i: ", row)
    end

    # Save the recommendations to a CSV file
    CSV.write("public/top_5_recommendations.csv", DataFrame(top_5_recommendations))
    println("\nRecommendations saved to 'top_5_recommendations.csv'.")
else
    println("\nNo recommendations found for the selected filters.")
end

println("Generating map from the recommendations...")

# Dataset Format: column names
# id,name,host_id,host_name,neighbourhood_group,neighbourhood,latitude,longitude,
# room_type,price,minimum_nights,number_of_reviews,last_review,reviews_per_month,
# calculated_host_listings_count,availability_365

file_path = "data/AB_NYC_2019.csv"
data_for_map = CSV.read(file_path, DataFrame) #not used again

mapbox_token = "pk.eyJ1Ijoia3NpbW9uMjQiLCJhIjoiY20za3QwaG01MGp0eTJsb2t6Ym0xZnIzcSJ9.Wp_XPaY7rPuRBKXE0XfJ4Q" #using ksimon24 account

recommendations_file = "data/AB_NYC_2019.csv"
recommendations = CSV.read(recommendations_file, DataFrame)

lats = recommendations.latitude
lons = recommendations.longitude
names = recommendations.name
prices = recommendations.price
ids = recommendations.id

# Create hover text with detailed information
hover_text = ["ID: $(id_i)<br>Name: $(n_i)<br>Price: \$$(p_i)" for (id_i, n_i, p_i) in zip(ids, names, prices)]

# Create the map using PlotlyJS and scattermapbox w/ Mapbox
p = plot(
    PlotlyJS.scattermapbox(
        lat = lats,
        lon = lons,
        mode = "markers",
        marker = PlotlyJS.attr(
            size = 12,
            color = "black",
            opacity = 1,
            symbol = "star"  # Use predefined symbol like "marker" or "circle"
        ),
        text = hover_text,
        hoverinfo = "text"
    ),
    PlotlyJS.Layout(
        title = "Airbnb Listings in NYC",
        mapbox = PlotlyJS.attr(
            accesstoken = mapbox_token,
            style = "streets",
            center = PlotlyJS.attr(lat = 40.7128, lon = -74.0060),
            zoom = 10
        )
    )
)

savefig(p, "public/top_5_recommendations_map.html")
end