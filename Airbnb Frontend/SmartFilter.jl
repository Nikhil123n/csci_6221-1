using CSV
using DataFrames
using LinearAlgebra
using PlotlyJS


# Load the AB_NYC_2019.csv dataset
ab_nyc_data = CSV.File("data/AB_NYC_2019.csv") |> DataFrame

# Check the length of ARGS and assign values conditionally
if length(ARGS) > 0
    # Parse the first argument if it exists and is not empty
    if length(ARGS) >= 1 && ARGS[1] != ""
        println("ARG 1 ", ARGS[1])
        selected_neighbourhood_group = String(ARGS[1])
    end

    # Parse the second argument if it exists and is not empty
    if length(ARGS) >= 2 && ARGS[2] != ""
        selected_neighbourhood = String(ARGS[2])
    end

    # Parse the third argument if it exists and is not empty
    if length(ARGS) >= 3 && ARGS[3] != ""
        println("ARG 3 ", ARGS[3])
        selected_room_type = strip(ARGS[3])
    end
end
println("Filters: ", selected_neighbourhood_group, ", ", selected_neighbourhood, ", ", selected_room_type)

# Dynamic filtering logic
filtered_rows = filter(row -> 
    (selected_neighbourhood_group === "" || row["neighbourhood_group"] == selected_neighbourhood_group) &&
    (selected_neighbourhood === "" || row["neighbourhood"] == selected_neighbourhood) &&
    (selected_room_type === "" || row["room_type"] == selected_room_type),
    eachrow(ab_nyc_data)
)

# Select the top 5 recommendations
top_5_recommendations = filtered_rows[1:min(5, length(filtered_rows))]

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