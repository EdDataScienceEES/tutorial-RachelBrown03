<center><img src="{{ site.baseurl }}/tutheaderbl.png" alt="Img"></center>

To add images, replace `tutheaderbl1.png` with the file name of any image you upload to your GitHub repository.

### Tutorial Aims

#### <a href="#section1"> 1. The first section</a>

#### <a href="#section2"> 2. The second section</a>

#### <a href="#section3"> 3. The third section</a>

# Investigating The Central Limit Theorem

In this tutorial, we'll apply the **Central Limit Theorem (CLT)** to sample data from the Palmer Penguins dataset, demonstrating how sampling distributions of the mean approach a normal distribution as sample size increases. This is useful for understanding how ecological data, even when skewed or not normally distributed, can be analyzed with the CLT. We'll focus on penguin flipper lengths and body mass as non-normally distributed variables to illustrate the process.

# Steps:

1. [**Introduction**](#intro)
    - [Prerequisites](#Prerequisites)
    - [Data and Materials](#DataMat)
    - [Overview of the Central Limit Theorem](#Overview)
    - [Importance of Sampling Distributions in Ecology](#Importance)
2. [**Data Preparations**](#Preparations)
    - [Loading and Inspecting the Data](#load)
    - [Selecting a Non-Normally Distributed Variable](#selection)
3. [**Sampling Distributions**](#Sampling)
    - [Generating Sampling Distributions for Different Sample Sizes](#generating)
    - [Visualizing Sampling Distributions Using Histograms](#histogram)
    - [Investigating population trends by sampling method](#SampleMeth)
4. [**Applying the Central Limit Theorem**](#CLT)
    - [Effect of Sample Size on Distribution Shape](#effect)
6. [**Summary and Interpretation**](#Summary)
7. [**Challenge**](#Challenge)

----
# 1. Introduction
{: #intro}

The **Central Limit Theorem (CLT)** is fundamental in ecological studies, especially for analyzing population distributions where full population data collection is often impractical. The CLT states that the distribution of sample means approximates a normal distribution as sample size increases, even when the population distribution is not normal.

In ecology, data often come from field observations of wildlife populations, which tend to be non-normal. However, many statistical tests assume normality, which raises a key question: **How can we work with data that doesn’t follow a normal distribution?** The CLT is crucial here because it allows us to make inferences using sample means, even if the original data are not normally distributed. By studying the CLT, we can understand the behavior of sample means and use this information in statistical modeling and hypothesis testing in ecology.

This tutorial will use the Palmer Penguins dataset, which contains data on three penguin species. We’ll focus on measurements like body mass and flipper length to see how sample means approximate a normal distribution, regardless of the underlying population shape.

By the end of this tutorial, you will have a practical understanding of the Central Limit Theorem and how to apply it to data analysis, allowing you to draw meaningful insights from ecological data, even in situations where traditional assumptions do not hold.


## Prerequisites
{: #Prerequisites}

This tutorial is designed for beginners and intermediate learners in statistics and data analysis. Depending on your familiarity with statistical concepts, you may find different parts of the tutorial useful. If you’re new to the Central Limit Theorem, this tutorial will provide a solid introduction, while those with some statistical background will gain a deeper understanding of sampling distributions and practical applications of the CLT.

To get the most out of this tutorial, a basic understanding of descriptive statistics (e.g., mean, variance) and probability will be helpful. Familiarity with linear models is also recommended, as we’ll discuss their assumptions briefly. Some knowledge of algebra, particularly with functions and basic manipulations, can enhance your understanding, but it’s not essential, no prior knowledge of advanced mathematics is required, as we’ll focus on applying concepts rather than complex math.

The tutorial is structured around the `R` programming language, but the concepts apply across other statistical software as well. If you’re following along in `R`, you’ll benefit from a foundational understanding of data manipulation with `dplyr` and `tidyr` and basic data visualization with `ggplot2`. If these packages are new to you, consider reviewing introductory resources, as they will help you interpret and create visualizations of the data used in this tutorial.

If you are new to any of these tools or want to refresh your skills, we recommend reviewing the following tutorials on the Coding Club website:

- [Intro to R](https://ourcodingclub.github.io/tutorials/intro-to-r/)   
- [Basic Data Manipulation](https://ourcodingclub.github.io/tutorials/data-manip-intro/)
- [Data Visualization](https://ourcodingclub.github.io/tutorials/datavis/)

Once you’ve reviewed these foundational skills, you’ll be ready to dive into the world of sampling distributions and explore the Central Limit Theorem in ecological data analysis!

## Data and Materials
{: #DataMat}

For this tutorial, we’ll be using the `palmerpenguins` dataset in R, which provides ecological data on penguins’ physical characteristics. If you’d like to follow along, install the `palmerpenguins` package and load the data using R. Throughout the tutorial, we’ll explore sampling distributions of penguin flipper lengths to see how the Central Limit Theorem helps us understand and interpret sample-based measurements from a larger population.

Let’s dive into how the Central Limit Theorem can simplify data analysis and allow us to derive meaningful insights from a wide range of ecological data!

----
# Data Preparations
{: #Preparations}

To start off, open `RStudio`,  and create a new script by clicking on `File/ New File/ R Script`, and start writing your script with the help of this tutorial.
```r
# Purpose of the script
# Your name, date and email

# Your working directory, set to the folder you just downloaded from Github, e.g.:
setwd("~/Downloads/CC-intro-to-CLT")

# Install the package (if not already installed)
install.packages("palmerpenguins")

# Load the package
library(palmerpenguins)
```
After loading the package, you can load and view the penguins dataset directly:

```r
# Load the penguins data
data("penguins")

# View the first few rows of the data to get familiar with its structure
head(penguins)
```
Now that the dataset is loaded, you’re ready to dive into the tutorial and explore the Central Limit Theorem in action!

----
# 4. Part I: Understanding the Central Limit Theorem

The CLT states that if you take sufficiently large random samples from any population, the distribution of the sample means will approximate a normal distribution, even if the population itself is not normally distributed. Let’s see how this applies to our penguin data.

## Step 1: Explore the Distribution of the Population Data
Before diving into the CLT, let’s examine the distribution of the original penguin body mass and flipper length measurements.

First we will remove the rows with missing values to make our data easier to work with

```r
# Remove rows with missing values for simplicity
penguins_clean <- na.omit(penguins)
```
Now we are ready to plot, we will begin by looking at body mass.

```r
# Plot the distributions of body mass and flipper length
body_mass <- ggplot(penguins_clean, aes(x = body_mass_g)) +
  geom_histogram(binwidth = 200, color = "black", fill = "skyblue") +
  labs(title = "Distribution of Penguin Body Mass", x = "Body Mass (g)") +
theme_minimal()

```

We can save the figure and give it exact dimensions using `ggsave` from the `ggplot2` package. The file will be saved to wherever your working directory is, which you can check by running `getwd()` in the console.

```r
ggsave("figures/body_mass.png", plot = sparrow_hist, width = 10, height = 5)
```
![alt text](https://github.com/EdDataScienceEES/tutorial-RachelBrown03/blob/master/figures/body_mass.png)

We now will look at flipper length.

```r
flipper_len <- ggplot(penguins_clean, aes(x = flipper_length_mm)) +
  geom_histogram(binwidth = 3, color = "black", fill = "salmon") +
  labs(title = "Distribution of Penguin Flipper Length", x = "Flipper Length (mm)") +
  theme_minimal()

ggsave("figures/flipper_len.png", plot = flipper_len, width = 10, height = 5)
```
![alt text](https://github.com/EdDataScienceEES/tutorial-RachelBrown03/blob/master/figures/flipper_len.png)

You’ll notice that these measurements do not perfectly follow a normal distribution, with body mass being slightly skewed.

---
# Sampling Distributions
{: #SamplingDist}

The goal here is to illustrate how sampling distributions change with sample size.

## Generating Sampling Distributions
{: #GenerateSamples}

We'll take random samples of different sizes (n = 10, 30, 50, and 100) from the `flipper_length_mm` variable and calculate the sample means. For each sample size, we’ll repeat the sampling 1000 times to create a distribution of sample means.

```r
# Function to generate sampling distributions
generate_sampling_distribution <- function(data, sample_size, num_samples) {
    sample_means <- replicate(num_samples, mean(sample(data$flipper_length_mm, sample_size, replace = TRUE), na.rm = TRUE))
    return(sample_means)
}

# Generate sampling distributions for sample sizes of 10, 30, 50, and 100
set.seed(42)
samples_10 <- generate_sampling_distribution(penguins, 10, 1000)
samples_30 <- generate_sampling_distribution(penguins, 30, 1000)
samples_50 <- generate_sampling_distribution(penguins, 50, 1000)
samples_100 <- generate_sampling_distribution(penguins, 100, 1000)
```

## Visualizing Sampling Distributions
{: #Histograms}

Using `ggplot2`, we’ll visualize these sampling distributions to see the CLT at work.

```r
# Combine sampling distributions into a data frame for visualization
sample_data <- tibble(
    Sample_Mean = c(samples_10, samples_30, samples_50, samples_100),
    Sample_Size = factor(rep(c(10, 30, 50, 100), each = 1000))
)

# Plot the sampling distributions
ggplot(sample_data, aes(x = Sample_Mean, fill = Sample_Size)) +
    geom_histogram(position = "identity", alpha = 0.6, bins = 30) +
    facet_wrap(~Sample_Size, scales = "free_y") +
    labs(title = "Sampling Distributions of Mean Flipper Length",
         x = "Sample Mean of Flipper Length (mm)",
         y = "Frequency") +
    theme_minimal() +
    scale_fill_brewer(palette = "Set3")
```

Each facet shows the distribution of sample means for different sample sizes. As sample size increases, the distribution becomes more bell-shaped.

---
# Applying the Central Limit Theorem
{: #CLT}

## Effect of Sample Size on Distribution Shape
{: #EffectSampleSize}

Using these plots, you can see that as sample size grows, the shape of the sampling distribution converges towards a normal distribution.

---
# Summary and Interpretation
{: #Summary}

The Central Limit Theorem allows ecologists to make inferences about population means, even when data are skewed. For example, in estimating penguin population metrics across different regions, the CLT ensures that as sample sizes grow, the sampling distribution will approximate a normal distribution, allowing for the use of confidence intervals and hypothesis tests based on normality.

This tutorial demonstrates how to leverage CLT to approximate normality in ecological data, facilitating robust statistical inferences.

----


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
