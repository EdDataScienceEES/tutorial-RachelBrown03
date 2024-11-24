# Investigating The Central Limit Theorem

In this tutorial, we'll apply the **Central Limit Theorem (CLT)** to sample data from the Palmer Penguins dataset, demonstrating how sampling distributions of the mean approach a normal distribution as sample size increases. This is useful for understanding how ecological data, even when skewed or not normally distributed, can be analyzed with the CLT. We'll focus on penguin flipper lengths and body mass as non-normally distributed variables to illustrate the process.

<center><img src="{{ site.baseurl }}/Images/Long%20penguins%20pic.png" alt="Img" style="width: 100%; height: auto;"></center>

# Turorial Aims:

1. Understand the Central Limit Theorem (CLT) and its importance in ecological data analysis.
2. Generate and visualize sampling distributions in R.
3. Apply the CLT to different variables and evaluate its effects on data interpretation.
  
# Steps:

1. [**Introduction**](#intro)
    - [Prerequisites](#Prerequisites)
    - [Data and Materials](#DataMat)
2. [**What is the Central Limit Theorem?**](#Overview)
    - [Central Limit Theorem Formula](#Formula)
    - [Sample Size and the Central Limit Theorem](#Size)
    - [Conditions of the Central Limit Theorem](#Condtitions)
    - [Importance of the Central Limit Theorem](#Importance)
3. [**Data Preparations**](#Preparations)
    - [Loading and Inspecting the Data](#Load)
    - [Explore the Distribution of the Population Data](#PopData)
4. [**Sampling Distributions**](#Sampling)
    - [Setting the Seed for Reproducibility](#Seed)
    - [Generating Sampling Distributions](#Generating)
    - [Visualizing the Sampling Distribution](#Histogram)
5. [**Exploring Different Sample Sizes**](#Explore)
    - [Adding Normal Distribution Curves](#Normal)
6. [**Summary and Interpretation**](#Summary)
7. [**Challenge**](#Challenge)

----
# 1. Introduction
{: #intro}

The **Central Limit Theorem** is fundamental in ecological studies, especially for analysing population distributions where full population data collection is often impractical. The CLT states that the distribution of sample means approximates a normal distribution as sample size increases, even when the population distribution is not normal.

In ecology, data often come from field observations of wildlife populations, which tend to be non-normal. However, many statistical tests assume normality, which raises a key question: **How can we work with data that doesn’t follow a normal distribution?** The CLT is crucial here because it allows us to make inferences using sample means, even if the original data are not normally distributed. By studying the CLT, we can understand the behavior of sample means and use this information in statistical modeling and hypothesis testing.

This tutorial will use the Palmer Penguins dataset, which contains data on three penguin species. We’ll focus on measurements like body mass and flipper length to see how sample means approximate a normal distribution, regardless of the underlying population shape.

By the end of this tutorial, you will have a practical understanding of the Central Limit Theorem and how to apply it to data analysis, allowing you to draw meaningful insights from ecological data, even in situations where traditional assumptions do not hold.

## Prerequisites
{: #Prerequisites}

This tutorial is designed for learners with a basic understanding of statistics and data analysis. If you're familiar with concepts like the mean, variance, and probability distributions, you’ll find it easier to follow along. A working knowledge of R programming, particularly data manipulation (`dplyr`, `tidyr`) and visualization (`ggplot2`), will also enhance your experience.

If you are new to any of these tools or want to refresh your skills, we recommend reviewing the following tutorials on the Coding Club website:

- [Intro to R](https://ourcodingclub.github.io/tutorials/intro-to-r/)   
- [Basic Data Manipulation](https://ourcodingclub.github.io/tutorials/data-manip-intro/)
- [Data Visualization](https://ourcodingclub.github.io/tutorials/datavis/)

Once you’ve reviewed these foundational skills, you’ll be ready to dive into the world of sampling distributions and explore the Central Limit Theorem in ecological data analysis!

## Data and Materials
{: #DataMat}

For this tutorial, we’ll be using the `palmerpenguins` dataset in R, which provides ecological data on penguin's physical characteristics. If you’d like to follow along, install the `palmerpenguins` package and load the data using R. Throughout the tutorial, we’ll explore sampling distributions of penguin body mass to see how the Central Limit Theorem helps us understand and interpret sample-based measurements from a larger population.

Let’s dive into the Central Limit Theorem and how it works!

----
# 2. What is the Central Limit Theorem?
{: #Overview}

The **Central Limit Theorem (CLT)** is a key concept in statistics, relying on the idea of a **sampling distribution**. A sampling distribution is the probability distribution of a statistic, like the mean, calculated from a large number of samples taken from a population.

Imagining an experiment may help you to understand sampling distributions:

1. Draw a random sample from a population and calculate a statistic, such as the mean.
2. Draw another random sample of the same size and calculate the mean again.
3. Repeat this process many times to obtain a large number of means, one for each sample.

The resulting distribution of these sample means is an example of a sampling distribution.

The **CLT** states that:
- The sampling distribution of the mean will **always** approximate a normal distribution as long as the sample size is large enough, regardless of the population’s distribution (e.g., Normal, Poisson, Binomial).
- This applies even when the population distribution is non-normal.

A **normal distribution** is a symmetrical, bell-shaped curve with most observations concentrated near the center.

<center><img src="{{ site.baseurl }}/Images/Normal_Curve.png" alt="Img"></center>

## Central Limit Theorem Formula
{: #Formula}

Fortunately, you don’t need to repeatedly sample a population to understand the shape of the sampling distribution. The parameters of the sampling distribution of the mean can be determined directly from the population’s parameters. Therefore, we can describe the sampling distribution of the mean using the following notation:

<left><img src="{{ site.baseurl }}/Images/Equations.png" alt="Img"></left>

This notation may appear a bit daunting if your not familiar with maths but do not worry, keep following along and it will all soon make sense!
   
## Sample Size and the Central Limit Theorem
{: #Size}

The **sample size (n)** influences the properties of the sampling distribution in two main ways:

### 1. **Sample Size and Normality**
- **Small sample sizes (n < 30)**: The sampling distribution may not be normal and will resemble the shape of the population distribution.
- **Large sample sizes (n greater than or equal to 30)**: The CLT applies, and the sampling distribution will approximate a normal distribution, regardless of the population’s distribution.

### 2. **Sample Size and Standard Deviations**
- **Small n**: The standard deviation of the sampling distribution is large, indicating greater variability in the sample means. This reflects imprecise estimates of the population mean.
- **Large n**: The standard deviation of the sampling distribution is smaller, indicating less variability and more precise estimates of the population mean.


## Conditions of the Central Limit Theorem
{: #Conditions}

For the CLT to hold, the following conditions must be met:
1. **Sufficiently large sample size**: Typically, n greater than or equal to 30 is considered sufficient.
2. **Independent and identically distributed (i.i.d.) random variables**: This is usually satisfied if the sampling is random.
3. **Finite variance**: The population’s distribution must have finite variance.


## Importance of the Central Limit Theorem
{: #Importance}

The CLT is fundamental to statistical theory. The term "**central**" in its name highlights the theorem's importance in statistics.

The key takeaway from the CLT is that statistical theories that apply to normal distributions can also be applied to many problems that involve non-normal distributions.

----
# 3. Data Preparations
{: #Preparations}

To start off, open `RStudio`,  and create a new script by clicking on `File/ New File/ R Script`, and start writing your script with the help of this tutorial.

```r
# Purpose of the script
# Your name, date and email

# Your working directory, set to the folder you want to save to, e.g.:
setwd("~/Documents/CC-intro-to-CLT")

# Install the package (if not already installed)
install.packages("palmerpenguins")

# Load the package and other necessary libraries
library(palmerpenguins)
library(tidyverse)
library(dplyr)
library(ggplot2)
```

## Loading and Inspecting the Data
{: #Load}

After loading the package, you can load and view the penguins dataset directly:

```r
# Load the penguins data
data("penguins")

# View the first few rows of the data to get familiar with its structure
head(penguins)
```
Now that the dataset is loaded, you’re ready to dive into the tutorial and explore the Central Limit Theorem in action!

<left><img src="{{ site.baseurl }}/Images/penguins%20peering.jpeg" alt="Img"></left>


## Explore the Distribution of the Population Data
{: #PopData}

Let’s begin by examining the distribution of the original penguin body mass and flipper length measurements.

First we will remove the rows with missing values to make our data easier to work with

```r
# Remove rows with missing values for simplicity
penguins_clean <- na.omit(penguins)
```
Now we are ready to plot, we will begin by looking at penguin's body mass, `body_mass_g` in the dataset.

```r
# Plot the distribution of body mass
(body_mass <- ggplot(penguins_clean, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 200, color = "black", fill = "skyblue") +
  labs(title = "Distribution of Penguin Body Mass", x = "Body Mass (g)") +
theme_minimal()
)
```

We can save the figure and give it exact dimensions using `ggsave` from the `ggplot2` package. The file will be saved to wherever your working directory is, which you can check by running `getwd()` in the console.

```r
ggsave("figures/body_mass.png", plot = body_mass, width = 10, height = 5)
```

<center><img src="{{ site.baseurl }}/figures/body_mass.png" alt="Img"></center>

Here we can see, the data appears **skewed** and does not follow the 'bell shaped curve' of the normal distribution.

Note that putting your entire ggplot code in brackets () creates the graph and then shows it in the plot viewer. If you don’t have the brackets, you’ve only created the object, but haven’t visualised it. You would then have to call the object such that it will be displayed by just typing `body_mass` after you’ve created the “body_mass” object.

We now will look at flipper length.

```r
# Plot the distribution of flipper length
(flipper_len <- ggplot(penguins_clean, aes(x = flipper_length_mm)) +
  geom_histogram(binwidth = 3, color = "black", fill = "salmon") +
  labs(title = "Distribution of Penguin Flipper Length", x = "Flipper Length (mm)") +
  theme_minimal()
)

ggsave("figures/flipper_len.png", plot = flipper_len, width = 10, height = 5)
```
<center><img src="{{ site.baseurl }}/figures/flipper_len.png" alt="Img"></center>

Again we can see that these measurements do not perfectly follow a normal distribution, so we must turn to the CLT.

---
# 4. Sampling Distributions
{: #SamplingDist}

The goal of this section is to demonstrate how sampling distributions evolve as sample size changes. To illustrate this concept clearly, we will focus exclusively on the body mass of the penguins.

## Setting the Seed for Reproducibility
{: #Seed}

In statistical simulations, we often draw random samples from a population. To ensure that our results are reproducible (i.e., we get the same results if we run the code multiple times), we set the seed using `set.seed()`.

### What does `set.seed()` do?
The `set.seed()` function in R initializes the random number generator. It allows us to "reproduce" random results, meaning that every time we run our code with the same seed, we will get the same sequence of random numbers or random samples. This is important because, without it, each time we run the simulation, the results would be different, making it difficult to compare outcomes across runs.

For example, here we will use:
```r
set.seed(123)
```

## Generating Sampling Distributions
{: #Generating}

Now, let’s simulate sampling distributions of body mass means by drawing random samples from the penguin's data. We’ll create samples of different sizes and calculate the mean of each sample.

```r
# Set parameters for simulation
n_samples <- 1000  # Number of samples to draw
sample_size <- 30  # Number of observations in each sample

# Draw samples and calculate sample means
sample_means <- replicate(n_samples, {
  sample_mean <- mean(sample(penguins_clean$body_mass_g, sample_size, replace = TRUE))
  return(sample_mean)
})
```
In this code, we are:

- Drawing 1000 samples (`n_samples`), each with 30 observations (`sample_size`).
- The `replace = TRUE` argument means we allow **sampling with replacement**, so the same observation could appear in multiple samples.

## Visualising the Sampling Distribution
{: #Histogram}

After generating the sample means, we can visualise the **sampling distribution** (i.e., the distribution of the sample means). The Central Limit Theorem tells us that as the sample size increases, the sampling distribution will tend to become more **normal**, even if the original data is not normally distributed.

```r
# Plot the distribution of sample means
(samplemean_plot <- ggplot(data.frame(sample_means = sample_means), aes(x = sample_means)) +
  geom_histogram(binwidth = 10, color = "black", fill = "lightgreen") +
  labs(title = "Sampling Distribution of Body Mass Means", x = "Mean Body Mass (g)", y = "Frequency") +
  theme_minimal()
)

ggsave("figures/samplemean_plot.png", plot = samplemean_plot, width = 10, height = 5)
```
<center><img src="{{ site.baseurl }}/figures/samplemean_plot.png" alt="Img"></center>

Here we can see the distribution is looking much more similar to the normal distribution curve.

This plot highlights the Central Limit Theorem in action: the sample means form a distribution that closely approximates a normal distribution, demonstrating the key idea that the sampling distribution of the mean tends to normality, even when the original data may not be normally distributed.

---
# 5. Exploring Different Sample Sizes
{: #Explore}

Let’s extend the analysis by calculating the sampling distributions for different sample sizes (e.g., 10, 50, 100). We’ll compare how the distribution of sample means behaves as the sample size increases.

```r
# Function to calculate sample means for different sample sizes
calculate_sample_means <- function(size, n_samples = 1000) {
  replicate(n_samples, mean(sample(penguins_clean$body_mass_g, size, replace = TRUE)))
}
```
You may be wondering, **what is this code doing?**

- `calculate_sample_means` function: This custom function calculates sample means. It takes two arguments:
   - `size`: The sample size (i.e., how many observations to include in each sample).
   - `n_samples`: The number of samples to draw (default is 1000).
- Inside the function:
    - `sample()`: Randomly selects `size` observations from the `penguins_clean$body_mass_g` data with replacement (meaning the same observation can be selected multiple times in a sample).
    - `mean()`: Calculates the mean (average) of the selected sample.
    - `replicate()`: Repeats the sampling process `n_samples` times (1000 by default), creating a collection of sample means.

Next, we shall call the `calculate_sample_means` function three times with different sample sizes: 10, 50, and 100.

For each sample size, the function will generate 1000 random samples, calculate the mean for each sample, and store these means in the corresponding variables: `sample_means_10`, `sample_means_50`, and `sample_means_100`.
     
```r
# Calculate sample means for different sample sizes
sample_means_10 <- calculate_sample_means(10)
sample_means_50 <- calculate_sample_means(50)
sample_means_100 <- calculate_sample_means(100)
```

Now, we combine the sample means into a data frame.
 - `sample_mean`: The collection of sample means (from `sample_means_10`, `sample_means_50`, and `sample_means_100`).
 - `sample_size`: A factor (categorical variable) indicating the sample size for each corresponding mean. We use the `rep()` function to repeat the sample sizes 1000 times for each set of sample means.

We then plot the distributions.

```r
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
```
<center><img src="{{ site.baseurl }}/figures/sampledist_plot.png" alt="Img"></center>

Here we can see, with a smaller sample size (e.g., 10), the distribution of sample means might be more spread out and less normal in shape. As the sample size increases (e.g., 50 or 100), the sample means tend to cluster more tightly around the population mean, and the distribution becomes more bell-shaped and closer to normal, which aligns with the CLT.

## Adding Normal Distribution Curves
{: #Normal}

Now, let's add a **normal distribution curve** to the plot to visually compare how well the sample means approximate a normal distribution. The normal curve will be based on the mean and standard deviation of the sample means.

```r
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
```
<center><img src="{{ site.baseurl }}/figures/curves_plot.png" alt="Img"></center>

You may be wondering: Why More Bars for Sample Size 10?
 - **Bin Width and Range:** In this code, the `geom_histogram` uses a fixed bin width of `50`. For smaller sample sizes (e.g., 10), the spread (range) of the sample means is generally larger because smaller samples tend to vary more from the population mean. As a result, more bins are needed to cover this wider range, leading to more bars.
- **Narrower Range for Larger Samples:** For larger sample sizes (e.g., 100), the sample means cluster more tightly around the population mean, reducing the spread. Fewer bins are needed to cover the narrower range, resulting in fewer bars.

This plot beautifully illustrates the core idea of the **Central Limit Theorem (CLT)**: as the sample size increases, the sampling distribution of the mean becomes narrower and more normal, regardless of the shape of the original population distribution. At a larger sample size, the distribution is tightly concentrated around the mean and appears nearly perfectly normal. This is a clear example of the CLT in action: no matter the underlying shape of the original data, the distribution of sample means approaches normality as the sample size increases.

This demonstrates how the CLT helps us make reliable inferences about population means, even when data is skewed or non-normal. It also shows why larger sample sizes are crucial in statistical analysis - they reduce uncertainty and make the sampling distribution of the mean look increasingly like a normal distribution, improving the accuracy and precision of estimates.

---
# 6. Summary and Interpretation
{: #Summary}

Congratulations, you've made it to the end of this tutorial! The Central Limit Theorem (CLT) is a valuable tool for ecologists working with real-world data, which is often skewed or irregular. In this tutorial, you’ve seen how the CLT helps approximate normality in sampling distributions, making it easier to apply statistical methods like confidence intervals and hypothesis tests. With this knowledge, you can confidently analyse population metrics, such as penguin body mass, and make reliable inferences even when the data isn’t perfectly shaped.

----
# 7. Challenge
{: #Challenge}

Now that you've seen how the Central Limit Theorem works using the penguin dataset, it's time to apply your knowledge to a new challenge! Here’s your opportunity to experiment with sampling distributions using a different variable from the dataset, such as flipper length, which we observed earlier is not normally distributed.

Experiment with increasing the number of samples (e.g., `change n_samples = 1000` to `n_samples = 5000`) and see how this affects the sampling distribution. Do you notice a change in the shape of the distribution as you increase the number of samples?

---

<hr>
<hr>

#### Check out our <a href="https://ourcodingclub.github.io/links/" target="_blank">Useful links</a> page where you can find loads of guides and cheatsheets.

#### If you have any questions about completing this tutorial, please contact us on ourcodingclub@gmail.com

#### <a href="INSERT_SURVEY_LINK" target="_blank">We would love to hear your feedback on the tutorial, whether you did it in the classroom or online!</a>

<ul class="social-icons">
	<li>
		<h3>
			<a href="https://twitter.com/our_codingclub" target="_blank">&nbsp;Follow our coding adventures on Twitter! <i class="fa fa-twitter"></i></a>
		</h3>
	</li>
</ul>

### &nbsp;&nbsp;Subscribe to our mailing list:
<div class="container">
	<div class="block">
        <!-- subscribe form start -->
		<div class="form-group">
			<form action="https://getsimpleform.com/messages?form_api_token=de1ba2f2f947822946fb6e835437ec78" method="post">
			<div class="form-group">
				<input type='text' class="form-control" name='Email' placeholder="Email" required/>
			</div>
			<div>
                        	<button class="btn btn-default" type='submit'>Subscribe</button>
                    	</div>
                	</form>
		</div>
	</div>
</div>
