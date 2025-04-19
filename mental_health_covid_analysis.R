# Updated R Script: mental_health_covid_analysis.R

library(readr)
library(dplyr)
library(syuzhet)
library(ggplot2)
library(lubridate)
library(tidyr)
library(stringr)
library(tidytext)
library(topicmodels)
library(scales)

# Load data
data <- read_csv("mental_health_covid_posts.csv")
data$date <- as.Date(data$date)

# Sentiment analysis
data$sentiment_syuzhet <- get_sentiment(data$processed_text, method="syuzhet")
data$sentiment_bing <- get_sentiment(data$processed_text, method="bing")
data$sentiment_afinn <- get_sentiment(data$processed_text, method="afinn")

# Emotion analysis
emotions <- get_nrc_sentiment(data$processed_text)
data <- cbind(data, emotions)

# Sentiment trends over time by subreddit
sentiment_by_sub <- data %>%
  group_by(subreddit, date) %>%
  summarize(mean_sentiment = mean(sentiment_syuzhet, na.rm = TRUE))

# Plot trends with light background and black text
p1 <- ggplot(sentiment_by_sub, aes(x = date, y = mean_sentiment, color = subreddit)) +
  geom_smooth(se = FALSE, linewidth = 1) +
  labs(title = "Sentiment Trends Across Mental Health Subreddits",
       x = "Date", y = "Average Sentiment") +
  theme_light(base_size = 14) +
  theme(
    plot.title = element_text(color = "black"),
    axis.title = element_text(color = "black"),
    axis.text = element_text(color = "black"),
    legend.text = element_text(color = "black"),
    legend.title = element_text(color = "black")
  )

ggsave("sentiment_trends_by_subreddit.png", p1, width = 10, height = 6)

# Emotion distribution comparison
emotion_summary <- data %>%
  group_by(subreddit) %>%
  summarize(across(anger:trust, mean))

emotion_long <- pivot_longer(emotion_summary, cols = -subreddit,
                              names_to = "emotion", values_to = "avg_score")

p2 <- ggplot(emotion_long, aes(x = emotion, y = avg_score, fill = subreddit)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Emotion Distribution by Subreddit",
       x = "Emotion", y = "Average Score") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("emotion_distribution_comparison.png", p2)

