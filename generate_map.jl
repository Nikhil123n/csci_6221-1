using CSV, DataFrames, PlotlyJS

# Dataset Format: column names
# id,name,host_id,host_name,neighbourhood_group,neighbourhood,latitude,longitude,
# room_type,price,minimum_nights,number_of_reviews,last_review,reviews_per_month,
# calculated_host_listings_count,availability_365

file_path = "../AB_NYC_2019.csv"
data = CSV.read(file_path, DataFrame)

mapbox_token = "pk.eyJ1Ijoia3NpbW9uMjQiLCJhIjoiY20za3QwaG01MGp0eTJsb2t6Ym0xZnIzcSJ9.Wp_XPaY7rPuRBKXE0XfJ4Q" #using ksimon24 account


# TODO: change the input to come from recommendation (eg. given id, look up name and price in dataframe and pass to hover_text)
lats = data.latitude[1:20]
lons = data.longitude[1:20]
names = data.name[1:20]
prices = data.price[1:20]
ids = data.id[1:20]

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

savefig(p, "airbnb_map.html")

