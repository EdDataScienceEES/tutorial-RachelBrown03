# Purpose of the script
# Your name, date and email

# Your working directory, set to the folder you want to save to, e.g.:
setwd("~/Downloads/CC-intro-to-CLT")

# Install the package (if not already installed)
# install.packages("palmerpenguins")

# Load the package and other necessary libraries
library(palmerpenguins)
library(tidyverse)
library(dplyr)
library(ggplot2)

# Load the penguins dataset
data("penguins")

# View the first few rows of the data to get familiar with its structure
head(penguins)

# Remove rows with missing values for simplicity
penguins_clean <- na.omit(penguins)

# Plot the distributions of body mass and flipper length
(body_mass <- ggplot(penguins_clean, aes(x = body_mass_g)) +
    geom_histogram(binwidth = 200, color = "black", fill = "skyblue") +
    labs(title = "Distribution of Penguin Body Mass", x = "Body Mass (g)") +
    theme_minimal()
)

ggsave("figures/body_mass.png", plot = body_mass, width = 10, height = 5)


(flipper_len <- ggplot(penguins_clean, aes(x = flipper_length_mm)) +
  geom_histogram(binwidth = 3, color = "black", fill = "salmon") +
  labs(title = "Distribution of Penguin Flipper Length", x = "Flipper Length (mm)") +
  theme_minimal()
)

ggsave("figures/flipper_len.png", plot = flipper_len, width = 10, height = 5)

# Set parameters for simulation
set.seed(123)  # For reproducibility
n_samples <- 1000  # Number of samples to draw
sample_size <- 30  # Number of observations in each sample

# Draw samples and calculate sample means
sample_means <- replicate(n_samples, {
  sample_mean <- mean(sample(penguins_clean$body_mass_g, sample_size, replace = TRUE))
  return(sample_mean)
})

# Plot the distribution of sample means
(samplemean_plot <- ggplot(data.frame(sample_means = sample_means), aes(x = sample_means)) +
  geom_histogram(binwidth = 10, color = "black", fill = "lightgreen") +
  labs(title = "Sampling Distribution of Body Mass Means", x = "Mean Body Mass (g)", y = "Frequency") +
  theme_minimal()
)

ggsave("figures/samplemean_plot.png", plot = samplemean_plot, width = 10, height = 5)


# Function to calculate sample means for different sample sizes
calculate_sample_means <- function(size, n_samples = 1000) {
  replicate(n_samples, mean(sample(penguins_clean$body_mass_g, size, replace = TRUE)))
}

# Calculate sample means for different sample sizes
sample_means_10 <- calculate_sample_means(10)
sample_means_50 <- calculate_sample_means(50)
sample_means_100 <- calculate_sample_means(100)

# Combine data and plot distributions
sample_means_df <- data.frame(
  sample_mean = c(sample_means_10, sample_means_50, sample_means_100),
  sample_size = factor(rep(c(10, 50, 100), each = n_samples))
)

(sampledist_plot <- ggplot(sample_means_df, aes(x = sample_mean, fill = sample_size)) +
  geom_histogram(binwidth = 50, color = "black", alpha = 0.6, position = "identity") +
  facet_wrap(~ sample_size) +
  labs(title = "Sampling Distributions of Body Mass Means", x = "Mean Body Mass (g)", y = "Frequency")+
  theme_minimal()
)

ggsave("figures/sampledist_plot.png", plot = sampledist_plot, width = 10, height = 5)


# Calculate summary statistics for each sample size
summary_stats <- sample_means_df %>%
  group_by(sample_size) %>%
  summarize(
    mean = mean(sample_mean),
    sd = sd(sample_mean)
  )

# Add normal distribution curves to the plot
normal_curves <- summary_stats %>%
  rowwise() %>%
  mutate(
    x = list(seq(
      min(sample_means_df$sample_mean), 
      max(sample_means_df$sample_mean), 
      length.out = 100
    )),
    y = list(dnorm(x, mean, sd))
  ) %>%
  unnest(cols = c(x, y))

# Plot the sampling distributions with normal overlays
(curves_plot <- ggplot(sample_means_df, aes(x = sample_mean, fill = sample_size)) +
  geom_histogram(binwidth = 50, color = "black", alpha = 0.6) +
  facet_wrap(~ sample_size, labeller = as_labeller(c("10" = "Sample Size: 10", 
                                                     "50" = "Sample Size: 50", 
                                                     "100" = "Sample Size: 100"))) +
  labs(
    title = "Sampling Distributions of Body Mass Means with Normal Distribution Overlay",
    x = "Mean Body Mass (g)", 
    y = "Frequency"
  ) +
  theme_minimal() +
  geom_line(
    data = normal_curves,
    aes(x = x, y = y * n_samples * 50, color = as.factor(sample_size)), # Scale y to match the histogram
    inherit.aes = FALSE,
    size = 1
  ) +
  scale_color_manual(values = c("red", "green", "blue")) +
  theme(legend.position = "none")
)

ggsave("figures/curves_plot.png", plot = curves_plot, width = 10, height = 5)
