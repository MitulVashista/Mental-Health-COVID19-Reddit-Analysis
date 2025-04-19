# Updated Python Script: reddit_mental_health_data.py

import praw
import pandas as pd
from datetime import datetime
import re
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
import nltk
import ssl

try:
    _create_unverified_https_context = ssl._create_unverified_context
except AttributeError:
    pass
else:
    ssl._create_default_https_context = _create_unverified_https_context

nltk.download('stopwords')
nltk.download('punkt')
stop_words = set(stopwords.words('english'))

# Initialize Reddit API client
reddit = praw.Reddit(client_id='ViYPEkv-cD0kYY1RxNdvbQ',
                     client_secret='4Y3tYII0wzjATDcWZqgY2fGony7nGQ',
                     user_agent='_x_x_spiderman_x_x_ ')

# List of updated mental health subreddits
subreddits = ['depression', 'Anxiety', 'mentalhealth', 'SuicideWatch', 'bipolar']
all_posts = []

# Fetch COVID-related posts from each subreddit
for sub in subreddits:
    subreddit = reddit.subreddit(sub)
    for post in subreddit.search('covid', limit=1000):
        if post.selftext and len(post.selftext) > 50:
            all_posts.append([sub, post.id, datetime.fromtimestamp(post.created_utc), post.selftext])

# Create DataFrame
df = pd.DataFrame(all_posts, columns=['subreddit', 'post_id', 'date', 'text'])

# Preprocessing

def preprocess(text):
    text = re.sub(r'http\S+', '', text)
    tokens = word_tokenize(text.lower())
    return ' '.join([word for word in tokens if word.isalnum() and word not in stop_words])

df['processed_text'] = df['text'].apply(preprocess)

# Save to CSV
df.to_csv('mental_health_covid_posts.csv', index=False)
