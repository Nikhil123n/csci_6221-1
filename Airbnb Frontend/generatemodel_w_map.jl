using CSV
using DataFrames
using LinearAlgebra
using PlotlyJS

# -----------------------------------------------------------------------------------------
#                           STEP 1: Run front end and get user input
# -----------------------------------------------------------------------------------------
if length(ARGS) > 0
    selected_feature = parse(Int, ARGS[1])  # Get the first command line argument
else
    selected_feature = 1  # Default value if no argument provided
end
println("Using feature: $selected_feature")


#TODO

# -----------------------------------------------------------------------------------------
#                           STEP 2: generate recommendations
# -----------------------------------------------------------------------------------------
# Step 1: Load the dataset from the CSV file
data = CSV.File("data/data_normalized.csv") |> DataFrame

# Print the first few rows and the shape of the data to validate
println("Data preview:")
println(first(data, 5))  # Print first 5 rows
println("Shape of data: ", size(data))  # Print dimensions of the data

# Step 2: Ensure that the data contains only numeric values and no missing values
# Convert to a matrix of floats, ensuring no missing values
data_matrix = Matrix{Float64}(data)  # Convert DataFrame to matrix

# Print a preview of the matrix and its dimensions to check
println("Data Matrix preview (first 5 rows):")
println(data_matrix[1:5, :])  # Print the first 5 rows of the matrix
println("Shape of Data Matrix: ", size(data_matrix))  # Print dimensions of the matrix

# Step 3: Compute the cosine similarity between two vectors
function cosine_similarity(a, b)
    return dot(a, b) / (norm(a) * norm(b))
end

# Step 4: Select a feature (let's assume we are selecting the first feature)
selected_feature = 1

# Step 5: Calculate cosine similarity between the selected feature and all other features
similarities = []  # Initialize an empty list for storing similarities
for i in 1:size(data_matrix, 2)  # Loop through columns (features)
    if i != selected_feature
        similarity_value = cosine_similarity(data_matrix[:, selected_feature], data_matrix[:, i])
        push!(similarities, (i, similarity_value))
    end
end

# Ensure similarities are populated before proceeding
println("Number of similarities calculated: ", length(similarities))
if length(similarities) == 0
    println("No similarities found. Please check your data for issues.")
else
    # Step 6: Sort the features by similarity and recommend the top 5 most similar features
    sorted_similarities = sort(similarities, by = x -> -x[2])
    top_5_similar_features = sorted_similarities[1:5]
    
    println("Top 5 similar features to feature $selected_feature:")
    for (feature, similarity) in top_5_similar_features
        println("Feature $feature with similarity $similarity")
    end
    
    # Step 7: Load the AB_NYC_2019.csv file to fetch records based on the selected feature
    ab_nyc_data = CSV.File("data/AB_NYC_2019.csv") |> DataFrame
    
    # Step 8: Fetch and store rows corresponding to the most similar features
    top_5_rows = []
    for (feature, _) in top_5_similar_features
        # Ensure the feature index is within bounds
        if feature <= size(ab_nyc_data, 2)
            # Find rows based on this feature
            selected_feature_column = ab_nyc_data[:, feature]
            
            # Take the first 5 rows for simplicity
            for i in 1:min(5, size(ab_nyc_data, 1))
                push!(top_5_rows, ab_nyc_data[i, :])
            end
        else
            println("Feature index $feature is out of bounds in AB_NYC_2019.csv.")
        end
    end
    
    # Step 9: Print and save the recommendations
    println("\nTop 5 recommended rows based on similarity:")
    for (i, row) in enumerate(top_5_rows)
        println("Recommendation $i: ", row)
    end
    
    recommendations_df = DataFrame(top_5_rows)  # Convert list to DataFrame
    CSV.write("public/top_5_recommendations.csv", recommendations_df)  # Save to CSV
    println("\nRecommendations saved to 'top_5_recommendations.csv'.")
    
    # Step 10: Directly test a specific row
    test_row_id = selected_feature  # Example row index for testing
    println("\nTesting with row ID: $test_row_id")
    println("Selected record: ", ab_nyc_data[test_row_id, :])  # Print the selected row
end

# -----------------------------------------------------------------------------------------
#                   STEP 3: generate the map from the recommendations
# -----------------------------------------------------------------------------------------

println("Generating map from the recommendations...")

# Dataset Format: column names
# id,name,host_id,host_name,neighbourhood_group,neighbourhood,latitude,longitude,
# room_type,price,minimum_nights,number_of_reviews,last_review,reviews_per_month,
# calculated_host_listings_count,availability_365

file_path = "data/AB_NYC_2019.csv"
data_for_map = CSV.read(file_path, DataFrame) #not used again

mapbox_token = "pk.eyJ1Ijoia3NpbW9uMjQiLCJhIjoiY20za3QwaG01MGp0eTJsb2t6Ym0xZnIzcSJ9.Wp_XPaY7rPuRBKXE0XfJ4Q" #using ksimon24 account

recommendations_file = "public/top_5_recommendations.csv"
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


# -----------------------------------------------------------------------------------------
#                   STEP 4: Run the map with the Front-End UI
# -----------------------------------------------------------------------------------------

#TODO

