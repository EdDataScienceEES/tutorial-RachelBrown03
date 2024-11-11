# Data Science in EES 2024
# Rachel Brown (s2206797)
# 11th November 2024

# Starter code ----

# Libraries
library(tidyverse)  # Data manipulation and visualization
library(lme4)       # Mixed models
library(broom)      # Tidying model outputs
library(ggplot2)    # Visualization
library(DHARMa)     # Residual diagnostics for mixed models
library(ggeffects)  # Model predictions
library(stargazer)  # Model summary formatting

# Load Living Planet Data
load("data/LPI_data.Rdata")

# Filter for House Sparrows----

# Reshape the data into long format
LPI_long <- data %>%
  pivot_longer(cols = 25:69, names_to = "Year", values_to = "Population") %>%
  mutate(
    Year = parse_number(Year),  # Convert year column to numeric
    genus_species = paste(Genus, Species, sep = "_"),  # Concatenate genus and species
    genus_species_id = paste(Genus, Species, id, sep = "_")  # Unique identifier for each population
  ) %>%
  filter(is.finite(Population), !is.na(Population))  # Remove rows with NA or infinite values

# Filter for house sparrow
house_sparrow_data <- LPI_long %>%
  filter(Common.Name == "House sparrow")  # Filter data for the target species

house_sparrow_data$Population <- round(house_sparrow_data$Population)  # Round Population to integer


# Statistical analysis ----

# histogram of the data
(sparrow_hist <- ggplot(house_sparrow_data, aes(Population)) + 
   geom_histogram(binwidth = 500, fill = "#69b3a2", alpha = 0.7) +  
   labs(title = "Distribution of House Sparrow Population", 
        x = "Population Abundance", 
        y = "Frequency") +  # Add titles and axis labels 
   theme_bw() +
   theme(panel.grid = element_blank(), 
         axis.text = element_text(size = 12), 
         axis.title = element_text(size = 12), 
         plot.title = element_text(size = 14, hjust = 0.5, face = "bold"), 
         plot.margin = unit(c(0.5,0.5,0.5,0.5), units = , "cm"), 
         legend.title = element_text(face = "bold"),
         legend.position = "bottom", 
         legend.box.background = element_rect(color = "grey", size = 0.3)))

ggsave("figures/data_histogram.png", plot = sparrow_hist, width = 10, height = 5)


# Scatter Plot of Population over Time
(sparrow_scatter <- ggplot(data = house_sparrow_data) +
    geom_point(aes(x = Year, y = Population, , colour = Country.list),  
               alpha = 0.9) +
    labs(x = 'Year',
         y = 'Population Abundance',
         title = 'Population abundance of House sparrow') +
    theme_bw() +
    theme(panel.grid = element_blank(), 
          axis.text = element_text(size = 12), 
          axis.title = element_text(size = 12), 
          plot.title = element_text(size = 14, hjust = 0.5, face = "bold"), 
          plot.margin = unit(c(0.5,0.5,0.5,0.5), units = , "cm"), 
          legend.title = element_text(face = "bold"),
          legend.position = "bottom", 
          legend.box.background = element_rect(color = "grey", size = 0.3)))

ggsave("figures/population_scatter.png", plot = sparrow_scatter, width = 10, height = 5)

# Plot population counts by sampling method
(sampling_boxplot <- ggplot(house_sparrow_data, aes(x = Sampling.method, y = Population)) +
    geom_boxplot(fill = '#69b3a2') +
    labs(x = 'Sampling Method',
         y = 'Population Count',
         title = 'Population Count by Sampling Method') +
    theme_minimal() +  # Apply minimal theme for a clean look
    theme_bw() +
    theme(panel.grid = element_blank(), 
          axis.text = element_text(angle = 45, hjust = 1, size = 6), 
          axis.title = element_text(size = 12), 
          plot.title = element_text(size = 14, hjust = 0.5, face = "bold"), 
          plot.margin = unit(c(0.5,0.5,0.5,0.5), units = , "cm"), 
          legend.title = element_text(face = "bold"),
          legend.position = "bottom", 
          legend.box.background = element_rect(color = "grey", size = 0.3)))

ggsave("figures/sampling_method_boxplot.png", plot = sampling_boxplot, width = 10, height = 5)


# Hierarchical linear model ----

# Scale Year for Model Stability
house_sparrow_data$Year_scaled <- house_sparrow_data$Year - min(house_sparrow_data$Year)

# Fit the Mixed Model
sparrow.model <- glmer(Population ~ Year_scaled + (1|Sampling.method) + (1 | Country.list/Location.of.population)+ (1|genus_species_id), 
                       data = house_sparrow_data, 
                       family = "poisson")

summary(sparrow.model)

# Summarize Model Output in HTML Table
stargazer(sparrow.model, type = "html",
          digits = 3,
          star.cutoffs = c(0.05, 0.01, 0.001),
          digit.separator = "")


# Model and data visualisation ----

# Generate QQ plot of residuals for normality check
qqnorm(resid(sparrow.model))
qqline(resid(sparrow.model))

# Save QQ plot of residuals as a PNG
png("figures/qqplot_residuals.png", width = 800, height = 600)

# Generate QQ plot
qqnorm(resid(sparrow.model))
qqline(resid(sparrow.model))

# Close the device
dev.off()


# Set up file output for the diagnostic plots
png("figures/diag_plot.png", width = 800, height = 600)

# Generate diagnostic plots in a 2x2 grid
par(mfrow = c(2, 2))  # Set up a 2x2 plot grid
plot(sparrow.model, ylim = c(-20, 20), xlim = c(0, 100))  # Diagnostic plots for model fit

# Close the graphics device to save the file
dev.off()
par(mfrow = c(2, 2))  # Set up a 2x2 plot grid
(diag_plot <- plot(sparrow.model, ylim = c(-20, 20), xlim = c(0, 100)) )# Diagnostic plots for model fit



# Simulated residuals to check model assumptions
sim_res <- simulateResiduals(sparrow.model)
plot(sim_res)  # Displays QQ plots and additional diagnostics

# Save DHARMa diagnostic plots to a file
png("figures/DHARMa_diagnostic_plots.png", width = 800, height = 600)
plot(sim_res)  # Generates QQ plot, residuals, outlier, and autocorrelation checks
dev.off()  # Closes the device and saves the file

# Model Predictions ----

# Overall Model Predictions
pred.mm <- ggpredict(sparrow.model, terms = c("Year_scaled"))

# Plot Overall Predictions with Confidence Interval
(reg_line_plot <- ggplot(pred.mm) + 
    geom_line(aes(x = x, y = predicted)) +
    geom_ribbon(aes(x = x, ymin = predicted - std.error, ymax = predicted + std.error), fill = "lightgrey", alpha = 0.5) +
    geom_point(data = house_sparrow_data, aes(x = Year_scaled, y = Population, colour = Country.list)) +
    labs(
      x = "Year (scaled)",
      y = "Population Count",
      title = "Overall House Sparrow Population Trends"
    ) +
    theme_minimal())

ggsave("figures/Overall_House_Sparrow_Population_Trends.png", plot = reg_line_plot, width = 8, height = 6)

# Predictions by Country with Individual Trends
pred.mm1 <- ggpredict(sparrow.model, terms = c("Year_scaled", "Country.list"), type = "re")

# Plot Predictions by Country with Model Fit Lines
(reg_by_country <- ggplot(pred.mm) + 
    geom_line(aes(x = x, y = predicted)) +
    geom_ribbon(aes(x = x, ymin = predicted - std.error, ymax = predicted + std.error), fill = "lightgrey", alpha = 0.5) +
    geom_point(data = house_sparrow_data, aes(x = Year_scaled, y = Population, colour = Country.list)) +
    geom_line(data = pred.mm1, aes(x = x, y = predicted, group = group, color = group)) +
    labs(
      x = "Year (scaled)",
      y = "Population Count",
      title = "House Sparrow Population Trends by Country"
    ) +
    theme_minimal() +
    ylim(0, 350))

ggsave("figures/House_Sparrow_Population_Trends_by_Country.png", plot = reg_by_country, width = 8, height = 6)

# Residuals Plot Over Time
residuals_data <- data.frame(
  Year = house_sparrow_data$Year,
  residuals = residuals(sparrow.model)
)

(res_plot <- ggplot(residuals_data, aes(x = Year, y = residuals)) +
    geom_point(color = '#69b3a2') +
    theme_minimal() +
    labs(
      title = "Residuals from Mixed Model Over Years",
      x = "Year",
      y = "Residuals"
    ))

ggsave("figures/Residuals_from_Mixed_Model.png", plot = res_plot, width = 8, height = 6)

