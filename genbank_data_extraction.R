# Load necessary libraries
library(rentrez)
library(stringr)
library(tidyverse)

# Read data from the BLAST output file
df <- read.table("mcr.blast")

# Sort the data frame by the third column in descending order and then select a specific range
df_sorted <- df[order(-df$Identity), ]


# Extract Genebank IDs from the dataframe
genebank_ids_list <- df1$ID

# Initialize an empty data frame to store results
results <- data.frame(
  Genebank_ID = character(),
  Title = character(),
  Organism = character(),
  Isolate = character(),
  Isolation_Source = character(),
  Host = character(),
  Country = character(),
  Collection_Date = character(),
  Lat_Lon = character(),
  stringsAsFactors = FALSE
)

# Initialize an empty list to store results temporarily
results_list <- list()

# Loop through each Genebank ID to fetch and parse information
for (id in genebank_ids_list) {
  # Fetch GenBank records in GenBank format
  record <- entrez_fetch(db="protein", id=id, rettype="gb", retmode="text")
  
  # Extract fields using regular expressions
  title <- str_match(record, "DEFINITION  (.+)")
  organism <- str_match(record, "ORGANISM  (.+)")
  isolate <- str_match(record, "isolate=(.+)")
  isolation_source <- str_match(record, "isolation_source=(.+)")
  host <- str_match(record, "host=(.+)")
  country <- str_match(record, "country=(.+)")
  collection_date <- str_match(record, "collection_date=(.+)")
  lat_lon <- str_match(record, "lat_lon=(.+)")
  
  # Add the extracted fields to the results list
  results_list[[id]] <- c(
    Genebank_ID = id,
    Title = ifelse(is.na(title), NA, title[1]),
    Organism = ifelse(is.na(organism), NA, organism[1]),
    Isolate = ifelse(is.na(isolate), NA, isolate[1]),
    Isolation_Source = ifelse(is.na(isolation_source), NA, isolation_source[1]),
    Host = ifelse(is.na(host), NA, host[1]),
    Country = ifelse(is.na(country), NA, country[1]),
    Collection_Date = ifelse(is.na(collection_date), NA, collection_date[1]),
    Lat_Lon = ifelse(is.na(lat_lon), NA, lat_lon[1])
  )
  
  # Set a pause to avoid hitting API request limits
  #Sys.sleep(0.5)
}

# Convert the results list to a data frame
results <- do.call(rbind, results_list)
results <- as.data.frame(results)

# Write the results to a CSV file
write.csv(x = results, "information.csv", row.names = FALSE)