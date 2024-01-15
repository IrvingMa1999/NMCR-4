# Load the necessary libraries
library(ggplot2)
library(RColorBrewer)
library(countrycode)
library(rnaturalearth)
library(dplyr)

# Read the outbreak data from CSV file
outbreak_data <- read.csv("count_60.csv", header = TRUE)

# Convert country names to ISO Alpha-3 country codes
iso_a3_codes <- countrycode(outbreak_data$Country, "country.name", "iso3c")
outbreak_data$isoa3 <- iso_a3_codes

# Save the data with ISO Alpha-3 country codes to a new CSV file
write.csv(x=outbreak_data, "outbreak_counts.csv", row.names = FALSE)

# Read the data with the country counts
outbreak_counts <- read.csv("outbreak_counts.csv")

# Fetch world map data at a medium scale as an 'sf' object
world <- ne_countries(scale = "medium", returnclass = "sf")

# Merge the world map data with the outbreak data by ISO Alpha-3 country codes
world_data <- left_join(world, outbreak_data, by = c("iso_a3" = "isoa3"))

# Create a world map plot color-coded by the frequency of outbreaks
world_map <- ggplot(data = world_data) +
  geom_sf(fill = "white", color = "white") + # Draw background of all countries
  geom_sf(aes(fill = Freq), color = "white") + # Fill colors based on frequency value
  scale_fill_gradientn(colors = brewer.pal(8, "YlOrRd"), 
                       trans = 'log', 
                       name = "Frequency (Log Scale)", 
                       na.value = "grey80",
                       limits = c(1, max(world_data$Freq, na.rm = TRUE)),
                       breaks = c(1, 10, 100, 1000, max(world_data$Freq, na.rm = TRUE))) + # Define gradient colors, use grey for unknown values
  theme_minimal() +
  labs(fill = "Outbreak Frequency") 

# Display the world map plot
world_map