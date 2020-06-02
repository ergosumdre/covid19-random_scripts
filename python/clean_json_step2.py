# FOR USF SAIL
# ~ Mihir

import csv
import pandas as pd
import numpy as np
import requests
import re
from bs4 import BeautifulSoup
import string
import glob
import sys
import os

#****************** NOTE **************#
#   Made for USC stuff, USF LATER      #
#**************************************#

#**************************************#
# UPDATE THE FILE NAME HERE!!!         #
exportFileName= r'USC_march_100K_file.csv'

# UPDATE NUM SAMPLE HERE!!! (Without replacement, DON'T NEED IT YET)
#rowsToSample= 100
#**************************************#

#------ read in all usc csv files
#Read the csvs and make a dataframe
path = r'C:\Users\ThinkPad\PycharmProjects\jsonstuff\venv\USC_MARCH_STUFF\all_usc_csv_files' # use your path
all_files = glob.glob(path + "/*.csv")

li = []

for filename in all_files:
    df = pd.read_csv(filename, index_col=None, header=0, encoding= 'utf-8-sig')
    li.append(df)

df_main= pd.concat(li, axis=0, ignore_index=True)

#------ read the 100k screen names
# Recall that we have already have 100K samples of usernames for botometer so let's import those screen_names
path = r'C:\Users\ThinkPad\PycharmProjects\jsonstuff\venv\USC_MARCH_STUFF\rand_100k_screen_names' # use your path
all_files = glob.glob(path + "/*.csv")

li = []

for filename in all_files:
    df = pd.read_csv(filename, index_col=None, header=0, encoding= 'utf-8-sig')
    li.append(df)

df_100k = pd.concat(li, axis=0, ignore_index=True)

#------ join the 100k screen_name with main_frame (that is to keep screen_names we have bot scores for)
# create a column marking df_100 values
df_100k['marker'] = 1

# join the two, keeping all of df1's indices
df_joined = pd.merge(df_main, df_100k, on=['user_screen_name'], how='left')

# extract desired columns where marker is NaN
df_joined= df_joined[pd.notnull(df_joined['marker'])][df_main.columns]

#df_joined.to_csv(exportFileName, encoding='utf-8-sig', index=False)

#------ read the all processed bot files
# since not every user got a bot score, we will need to attach them seperately
path = r'C:\Users\ThinkPad\PycharmProjects\jsonstuff\venv\USC_MARCH_STUFF\all_bots_scores' # use your path
all_files = glob.glob(path + "/*.csv")

li = []

for filename in all_files:
    df = pd.read_csv(filename, index_col=None, header=0, encoding= 'utf-8-sig')
    li.append(df)

df_botscores = pd.concat(li, axis=0, ignore_index=True)

#------ now merge the file again
df_joined_bots = pd.merge(df_joined,df_botscores, on = ['user_screen_name'],how='left')

#df_joined_bots.to_csv(exportFileName, encoding='utf-8-sig', index=False)

#------ replace urls with <title> tag
#(1) function to get title tag from URL
#NOTE: For twitter urls, this will not work, because they don't have "title" even if it
#       exists in the console when looking at a browser

def get_title_from_url(url):

    try:
        #check if it's a word of https string
        if(url.startswith('http')):
            #check if url is valid
            page = requests.get(url)

            #if the url is valid, sometimes phisy/ssl-missing site throw error
            html = BeautifulSoup(page.content, 'html.parser').encode('utf-8-sig')

            #finally get the title if everyting is good
            page_title = html.find('title').text.strip()

            return page_title
        else:
            return url
    except:
        return ''

# iterate over rows with iterrows()
for index, row in df_joined_bots.iterrows():
    # access data using column names

    #first let's take care of tweet_text

    s = df_joined_bots.at[index, 'tweet_text']
    l = list(map(lambda x: x, s.split()))
    m = list(map(get_title_from_url, l))
    n = ' '.join(m)
    df_joined_bots.at[index, 'tweet_text']= n

    # then take care of retweets

    s = df_joined_bots.at[index, 'retweet_text']
    l = list(map(lambda x: x, s.split()))
    m = list(map(get_title_from_url, l))
    n = ' '.join(m)
    df_joined_bots.at[index, 'retweet_text']= n

    # lastly, quoted_text

    # s = df_joined_bots.at[index, 'quoted_text']
    # l = list(map(lambda x: x, s.split()))
    # m = list(map(get_title_from_url, l))
    # n = ' '.join(m)
    # df_joined_bots.at[index, 'quoted_text'] = n

#(2) Finally write the csv file
df_joined_bots.to_csv(exportFileName, encoding='utf-8-sig', index=False)

#EOF