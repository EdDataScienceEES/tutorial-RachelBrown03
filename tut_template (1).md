<center><img src="{{ site.baseurl }}/tutheaderbl.png" alt="Img"></center>

To add images, replace `tutheaderbl1.png` with the file name of any image you upload to your GitHub repository.

### Tutorial Aims

#### <a href="#section1"> 1. The first section</a>

#### <a href="#section2"> 2. The second section</a>

#### <a href="#section3"> 3. The third section</a>

This tutorial will guide you through the process of analyzing and visualizing population trends using the Living Planet Index (LPI) dataset, specifically focusing on a single species (House Sparrow). It covers data manipulation, statistical modeling (including mixed models), and visualization techniques to help you understand population dynamics over time. 

# Steps:

1. [**Introduction**](#intro)
    - [Prerequisites](#Prerequisites)
    - [Overview of the Living Planet Index (LPI) dataset](#Overview)
    - [Importance of analyzing population trends in ecology](#Importance)
2. [**Part I: Data Preparations**](#Preparations)
    - [Loading the data](#load)
    - [Reshaping and cleaning data for analysis](#cleaning)
    - [Filtering data for House Sparrows](#filter)
3. [**Exploratory Data Analysis (EDA)**](#EDA)
    - [Visualizing population distributions using histograms](#Histogram)
    - [Plotting population trends over time](#Trends)
    - [Investigating population trends by sampling method](#SampleMeth)
4. [**Part III: Statistical Analysis**](#statisticalanalysis)
    - [Fitting a mixed-effects model to examine population trends over time](#GLMM)
    - [Model diagnostics: Checking residuals for model assumptions](#Diagnostics)
5. [**Part IIII: Model Interpretation and Predictions**](#interpretation)
    - [Visualizing model predictions and confidence intervals](#visualise)
    - [Understanding predictions by country and residuals over time](#predictions)
6. [**Summary**](#Summary)
7. [**Challenge**](#Challenge)

----
# 1. Introduction
{: #intro}

The **Living Planet Index (LPI)** tracks the population trends of species around the world. By analyzing these trends, we can better understand biodiversity changes and potential threats to species survival.

## Prerequisites
{: #Prerequisites}

This tutorial is suitable for learners with a basic to intermediate understanding of data analysis and statistical modeling. If you are a beginner, you'll gain an understanding of key concepts such as data reshaping, data visualization, and basic statistical models. Intermediate learners will be able to extend these concepts by applying mixed-effects models, model diagnostics, and interpretation of results.

To get the most out of this tutorial, you should have a basic understanding of the following:

- **Descriptive statistics:** A fundamental understanding of measures like mean, median, variance, and how to interpret distributions.
- **Linear models:** Knowledge of how to work with simple regression models (e.g., lm() function in R) and understanding of fixed vs. random effects in modeling.
- **Algebra:** Basic algebraic concepts (e.g., manipulating equations and understanding functions) will help you grasp the underlying statistical models.

Throughout the tutorial, we will be using `R`. While the statistical concepts can be applied across different languages, familiarity with R will enhance your experience. Specifically, you should be comfortable with:

- **Data manipulation with `dplyr`:** Transforming, cleaning, and filtering data.
- **Data reshaping with `tidyr`:** Pivoting data into long format and handling missing values.
- **Data visualization with `ggplot2`:** Creating plots to explore and communicate data patterns.
  
If you are new to any of these tools or want to refresh your skills, we recommend reviewing the following tutorials on the Coding Club website:

- [Intro to R](https://ourcodingclub.github.io/tutorials/intro-to-r/)   
- [Basic Data Manipulation](https://ourcodingclub.github.io/tutorials/data-manip-intro/)
- [Data Visualization](https://ourcodingclub.github.io/tutorials/datavis/)

Having these skills will help you fully engage with the content and follow along with the hands-on coding examples.

## Data and Materials
{: #DataMat}

You can find all the data that you require for completing this tutorial on this [GitHub repository](https://github.com/EdDataScienceEES/tutorial-RachelBrown03/tree/master). We encourage you to download the data to your computer and work through the examples along the tutorial as this reinforces your understanding of the concepts taught in the tutorial.

Now we are ready to dive into the investigation!

----
# Data Preparations
{: #Preparations}

To start off, open `RStudio`,  and create a new script by clicking on `File/ New File/ R Script`, and start writing your script with the help of this tutorial.
```r
# Purpose of the script
# Your name, date and email

# Your working directory, set to the folder you just downloaded from Github, e.g.:
setwd("~/Downloads/CC-Analyzing-Pop-Trends")

# Libraries - if you haven't installed them before, run the code install.packages("package_name")
library(tidyverse)  # Data manipulation and visualization
library(lme4)       # Mixed models
library(broom)      # Tidying model outputs
library(ggplot2)    # Visualization
library(DHARMa)     # Residual diagnostics for mixed models
library(ggeffects)  # Model predictions
library(stargazer)  # Model summary formatting
```

We will use data from the [Living Planet Index](https://www.livingplanetindex.org/), which you have already downloaded from the [Github repository](https://github.com/EdDataScienceEES/tutorial-RachelBrown03/tree/master/data) (Click on `Clone or Download/Download ZIP` and then unzip the files).

```r
# Import data from the Living Planet Index - population trends of species from 1970 to 2014
LPI <- read.csv("LPI_data.csv")
```
The data are in wide format - the different years are column names, when really they should be rows in the same column, so we will use `pivot_longer()` to change the data into long format. Also note, there is an ‘X’ in front of all the years because when we imported the data, all column names became characters. (The X is R’s way of turning numbers into characters.) Now that the years are rows, not columns, we need them to be proper numbers, so we will transform them using `parse_number()` from the `readr` package. We then remove NA or infinite values to make the dta easier to work with for modelling and visualisation.

```r
# Reshape data into long format for easier analysis
LPI_long <- data %>%
  pivot_longer(cols = 25:69, names_to = "Year", values_to = "Population") %>%
  mutate(
    Year = parse_number(Year),  # Convert year to numeric
    genus_species = paste(Genus, Species, sep = "_"),
    genus_species_id = paste(Genus, Species, id, sep = "_")
  ) %>%
  filter(is.finite(Population), !is.na(Population))  # Remove NA or infinite values
```

Now, we must filter out just the records for just the species we are interested in, in this case House sparrows. We can do this by fitering for where `Common.Name` is House sparrow. and we then round the population to the nearest integer as it is count data so half a sparrow is not much use to us!

```r
# Filter data for House Sparrows
house_sparrow_data <- LPI_long %>%
  filter(Common.Name == "House sparrow")

house_sparrow_data$Population <- round(house_sparrow_data$Population)  # Round population numbers for analysis
```

----
# Exploratory Data Analysis (EDA)
{: #EDA}

Before diving into statistical modeling, it’s crucial to explore the data visually to understand patterns and distributions. We will use `ggplot2` library for most of our visualizations.

## Visualizing the Population Distribution with a Histogram
{: #Histogram}

Let’s look at the distribution of the data to get some idea of what the data look like and what model we could use to answer our research question. Remember, if you put the whole code in the brackets it will display in the plot viewer right away!

```r
# Histogram of House Sparrow population data
(sparrow_hist <- ggplot(house_sparrow_data, aes(Population)) + 
   geom_histogram(binwidth = 500, fill = "#69b3a2", alpha = 0.7) +  
   labs(title = "Distribution of House Sparrow Population", 
        x = "Population Abundance", 
        y = "Frequency") + 
   theme_bw())
```
We can save the figure and give it exact dimensions using `ggsave` from the `ggplot2` package. The file will be saved to wherever your working directory is, which you can check by running `getwd()` in the console.

```r
ggsave("figures/data_histogram.png", plot = sparrow_hist, width = 10, height = 5)
```
![alt text](https://github.com/EdDataScienceEES/challenge-3-RachelBrown03/blob/master/figures/data_histogram.png)

We can see that our data are very right-skewed (i.e. most of the values are relatively small), indicating that most recorded populations are relatively small, with fewer locations reporting very high population counts. This distribution justifies the use of a GLMM with a Poisson distribution to model count data.

## Plotting Population Trends Over Time
{: #Trends}

Next, to further explore temporal trends in the population of House sparrows, we can generate a scatter plot of house sparrow population abundance over time, with data points color-coded by country). This plot provides an initial visual indication of any observable trends in population over time and any regional differences.

```r
# Scatter plot of population over time
(sparrow_scatter <- ggplot(data = house_sparrow_data) +
    geom_point(aes(x = Year, y = Population, colour = Country.list), alpha = 0.9) +
    labs(x = 'Year', y = 'Population Abundance', title = 'Population Trends of House Sparrow') +
    theme_bw())

# Save the plot
ggsave("figures/population_scatter.png", plot = sparrow_scatter, width = 10, height = 5)
```
![alt text](https://github.com/EdDataScienceEES/challenge-3-RachelBrown03/blob/master/figures/population_scatter.png)

Each point represents a population measurement for a given location and year, color-coded by country. The plot shows possible declining trends, motivating a model that includes time and regional effects.

## Investigating Population by Sampling Method
{: #SampleMeth}

Another factor worth considering is sampling method, different methods of collecting data will likely lead to different counts. To examine potential methodological effects, we can plot population counts by sampling method using a boxplot. Differences in counts across sampling methods might indicate that methodological choices impact population estimates, and mean that this is worth including as a random effect in our model.

```r
# Boxplot of population counts by sampling method
(sampling_boxplot <- ggplot(house_sparrow_data, aes(x = Sampling.method, y = Population)) +
    geom_boxplot(fill = '#69b3a2') +
    labs(x = 'Sampling Method', y = 'Population Count', title = 'Population Count by Sampling Method') +
    theme_minimal())

# Save the plot
ggsave("figures/sampling_method_boxplot.png", plot = sampling_boxplot, width = 10, height = 5)
```
![alt text](https://github.com/EdDataScienceEES/challenge-3-RachelBrown03/blob/master/figures/sampling_method_boxplot.png)

The plot shows that there is a clear variation in population estimates due to different sampling methodologies, supporting the decision to include Sampling Method as a random effect in the model to control for these differences. `Weekly Counts` appears to have a massively inflated count comapred to other methods.

----
# Statistical Analysis
{: #statisticalanalysis}

To investigate the relationship between time, region, and sparrow population trends, a **Generalized Linear Mixed Model (GLMM)** was used. This model is well-suited for our data and research goals because it accommodates:

- **Non-normal count data:** Sparrows are counted, not continuously measured
- **Random Effects:** Sampling method, country, population location (nested within country), and  `genus_species_id` (unique identifier for each population) capture effects of methodological differences, regional variations, local effects, and individual population differences.

### Fitting a Mixed-Effects Model
```r
# Scale Year for Model Stability
house_sparrow_data$Year_scaled <- house_sparrow_data$Year - min(house_sparrow_data$Year)

# Fit the model
sparrow.model <- glmer(Population ~ Year_scaled + (1|Sampling.method) + 
                       (1 | Country.list/Location.of.population) + (1|genus_species_id), 
                       data = house_sparrow_data, 
                       family = "poisson")

# Summarize the model
summary(sparrow.model)
```

Here we have used, 

- **Fixed Effects:** Year (to observe trends over time) 
- **Random Effects:** Country (to capture regional differences), Location of Population nested within Country (to capture local variations within each country), Sampling Method (to account for variations due to differing methodologies), and `genus_species_id` (to account for population-specific differences).

Incorporating `genus_species_id` adds precision by allowing the model to capture unique characteristics of each population, enhancing the accuracy of temporal and regional effect estimations.

This hierarchical structure allows the model to account for the dataset's nested nature, improving estimation of both time-based and regional impacts on house sparrow populations while controlling for variability across regions, specific locations, sampling methods, and population identities.

If we want to display the model summary table, a nice way to do this is using the `stargazer` package.  Simply plug in your model name, in this case `sparrow.model` into the `stargazer` function. Here we have set `type = "html"`, however there are many other options for outputs, e.g. `type = "latex"`.

```r
# Summarize Model Output in HTML Table
stargazer(sparrow.model, type = "html",
          digits = 3,
          star.cutoffs = c(0.05, 0.01, 0.001),
          digit.separator = "")
```
Where we get the following outut:

<table style="text-align:center"><tr><td colspan="2" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"></td><td><em>Dependent variable:</em></td></tr>
<tr><td></td><td colspan="1" style="border-bottom: 1px solid black"></td></tr>
<tr><td style="text-align:left"></td><td>Population</td></tr>
<tr><td colspan="2" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">Year_scaled</td><td>-0.066<sup>***</sup></td></tr>
<tr><td style="text-align:left"></td><td>(0.0003)</td></tr>
<tr><td style="text-align:left"></td><td></td></tr>
<tr><td style="text-align:left">Constant</td><td>5.322<sup>***</sup></td></tr>
<tr><td style="text-align:left"></td><td>(0.566)</td></tr>
<tr><td style="text-align:left"></td><td></td></tr>
<tr><td colspan="2" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">Observations</td><td>1211</td></tr>
<tr><td style="text-align:left">Log Likelihood</td><td>-14655.630</td></tr>
<tr><td style="text-align:left">Akaike Inf. Crit.</td><td>29323.250</td></tr>
<tr><td style="text-align:left">Bayesian Inf. Crit.</td><td>29353.850</td></tr>
<tr><td colspan="2" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"><em>Note:</em></td><td style="text-align:right"><sup>*</sup>p<0.05; <sup>**</sup>p<0.01; <sup>***</sup>p<0.001</td></tr>
</table>

The model output indicates a statistically significant negative effect of time (`Year_scaled`) on population counts, suggesting an overall decline in house sparrow populations over the study period. Specifically, the fixed effect of `Year_scaled` has an estimated coefficient of -0.066 (p < 0.001), which implies a decline rate of about 6.39% per year. In other words, each year, the expected house sparrow population decreases to approximately 93.61% of the population size from the previous year. 


You may wonder how we calculated the decline rate of 6.39% from the coefficient of -0.066. This is because the model uses a Poisson distribution with a log link function. In such a model, the coefficients are on the log scale, meaning that to interpret the effect in terms of the original population counts, we must exponentiate the coefficient.

Exponentiating the coefficient of -0.066 gives us approximately 0.9361, which corresponds to a 6.39% decline each year (1 - 0.9361 = 0.0639, or 6.39%). This means that, each year, the expected population of house sparrows decreases by about 6.39% relative to the previous year.

------

## Model Diagnostics: Checking Residuals
```r
# Generate QQ plot for residuals to check for normality
qqnorm(resid(sparrow.model))
qqline(resid(sparrow.model))

# Simulated residuals to check model assumptions
sim_res <- simulateResiduals(sparrow.model)
plot(sim_res)  # Displays QQ plots and additional diagnostics
```

----
# Model Interpretation and Predictions

Once we’ve fit the model, we can make predictions and visualize them.

## Visualizing Model Predictions with Confidence Intervals
```r
# Model predictions over time
pred.mm <- ggpredict(sparrow.model, terms = c("Year_scaled"))

# Plot overall predictions with confidence intervals
(reg_line_plot <- ggplot(pred.mm) + 
  geom_line(aes(x = x, y = predicted)) +
  geom_ribbon(aes(x = x, ymin = predicted - std.error, ymax = predicted + std.error), fill = "lightgrey", alpha = 0.5) +
  geom_point(data = house_sparrow_data, aes(x = Year_scaled, y = Population, colour = Country.list)) +
  labs(x = "Year (scaled)", y = "Population Count", title = "House Sparrow Population Trends"))
ggsave("figures/Overall_House_Sparrow_Population_Trends.png", plot = reg_line_plot, width = 8, height = 6)
```

## Predictions by Country
```r
# Predictions by Country with individual trends
pred.mm1 <- ggpredict(sparrow.model, terms = c("Year_scaled", "Country.list"), type = "re")

# Plot predictions by country
(reg_by_country <- ggplot(pred.mm1) + 
  geom_line(aes(x = x, y = predicted)) +
  geom_ribbon(aes(x = x, ymin = predicted - std.error, ymax = predicted + std.error), fill = "lightgrey", alpha = 0.5) +
  geom_point(data = house_sparrow_data, aes(x = Year_scaled, y = Population, colour = Country.list)) +
  labs(x = "Year (scaled)", y = "Population Count", title = "House Sparrow Population Trends by Country"))
ggsave("figures/House_Sparrow_Population_Trends_by_Country.png", plot = reg_by_country, width = 8, height = 6)
```

---
# Conclusion
In this tutorial, we have:

- Reshaped and cleaned the LPI dataset to focus on the House Sparrow population.
- Conducted exploratory data analysis with visualizations.
- Fitted a mixed-effects model to analyze population trends over time.
- Generated predictions and visualizations to interpret the results.

This workflow demonstrates a typical approach in ecological data science, allowing us to analyze trends and understand the factors influencing species population dynamics.

---

You can read this text, then delete it and replace it with your text about your tutorial: what are the aims, what code do you need to achieve them?
---------------------------
We are using `<a href="#section_number">text</a>` to create anchors within our text. For example, when you click on section one, the page will automatically go to where you have put `<a name="section_number"></a>`.

To create subheadings, you can use `#`, e.g. `# Subheading 1` creates a subheading with a large font size. The more hashtags you add, the smaller the text becomes. If you want to make text bold, you can surround it with `__text__`, which creates __text__. For italics, use only one understore around the text, e.g. `_text_`, _text_.

# Subheading 1
## Subheading 2
### Subheading 3

This is some introductory text for your tutorial. Explain the skills that will be learned and why they are important. Set the tutorial in context.

You can get all of the resources for this tutorial from <a href="https://github.com/ourcodingclub/CC-EAB-tut-ideas" target="_blank">this GitHub repository</a>. Clone and download the repo as a zip file, then unzip it.

<a name="section1"></a>

## 1. The first section


At the beginning of your tutorial you can ask people to open `RStudio`, create a new script by clicking on `File/ New File/ R Script` set the working directory and load some packages, for example `ggplot2` and `dplyr`. You can surround package names, functions, actions ("File/ New...") and small chunks of code with backticks, which defines them as inline code blocks and makes them stand out among the text, e.g. `ggplot2`.

When you have a larger chunk of code, you can paste the whole code in the `Markdown` document and add three backticks on the line before the code chunks starts and on the line after the code chunks ends. After the three backticks that go before your code chunk starts, you can specify in which language the code is written, in our case `R`.

To find the backticks on your keyboard, look towards the top left corner on a Windows computer, perhaps just above `Tab` and before the number one key. On a Mac, look around the left `Shift` key. You can also just copy the backticks from below.

```r
# Set the working directory
setwd("your_filepath")

# Load packages
library(ggplot2)
library(dplyr)
```

<a name="section2"></a>

## 2. The second section

You can add more text and code, e.g.

```r
# Create fake data
x_dat <- rnorm(n = 100, mean = 5, sd = 2)  # x data
y_dat <- rnorm(n = 100, mean = 10, sd = 0.2)  # y data
xy <- data.frame(x_dat, y_dat)  # combine into data frame
```

Here you can add some more text if you wish.

```r
xy_fil <- xy %>%  # Create object with the contents of `xy`
	filter(x_dat < 7.5)  # Keep rows where `x_dat` is less than 7.5
```

And finally, plot the data:

```r
ggplot(data = xy_fil, aes(x = x_dat, y = y_dat)) +  # Select the data to use
	geom_point() +  # Draw scatter points
	geom_smooth(method = "loess")  # Draw a loess curve
```

At this point it would be a good idea to include an image of what the plot is meant to look like so students can check they've done it right. Replace `IMAGE_NAME.png` with your own image file:

<center> <img src="{{ site.baseurl }}/IMAGE_NAME.png" alt="Img" style="width: 800px;"/> </center>

<a name="section1"></a>

## 3. The third section

More text, code and images.

This is the end of the tutorial. Summarise what the student has learned, possibly even with a list of learning outcomes. In this tutorial we learned:

##### - how to generate fake bivariate data
##### - how to create a scatterplot in ggplot2
##### - some of the different plot methods in ggplot2

We can also provide some useful links, include a contact form and a way to send feedback.

For more on `ggplot2`, read the official <a href="https://www.rstudio.com/wp-content/uploads/2015/03/ggplot2-cheatsheet.pdf" target="_blank">ggplot2 cheatsheet</a>.

Everything below this is footer material - text and links that appears at the end of all of your tutorials.

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
