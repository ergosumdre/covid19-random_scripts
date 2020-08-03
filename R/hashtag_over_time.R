library("data.table")
library("stringr")
library("ggplot2")
library("lubridate")
library("parallel")
library("scales")
library("RColorBrewer")
library("dplyr")


convertDate <- function(dir, hashtag){
  x <- list.files(path =dir, pattern = paste0(".",hashtag), full.names = TRUE)
  x <- do.call(rbind, lapply(x, fread, integer64 = "character"))
  x$created_at <- as.POSIXct(strptime(x$created_at, format ="%a %b %d %H:%M:%S %z %Y", tz="EST"))
  x$retweeted_status.created_at <- as.POSIXct(strptime(x$retweeted_status.created_at, format ="%a %b %d %H:%M:%S %z %Y", tz="EST"))
  return(x)
}


scamdemicTweets <- convertDate(dir = "/Users/dre/Downloads/coronaVirus/hashtagsKeywords/", 
                               hashtag = "scamdemic")
reopenTweets <- convertDate(dir = "/Users/dre/Downloads/coronaVirus/hashtagsKeywords/", 
                            hashtag = "reopen")
plandemicTweets <- convertDate(dir = "/Users/dre/Downloads/coronaVirus/hashtagsKeywords/", 
                               hashtag = "plandemic")
maskoffTweets <- convertDate(dir = "/Users/dre/Downloads/coronaVirus/hashtagsKeywords/", 
                             hashtag = "maskoff")
id2020Tweets <- convertDate(dir = "/Users/dre/Downloads/coronaVirus/hashtagsKeywords/", 
                            hashtag = "id2020")
filmTweets <- convertDate(dir = "/Users/dre/Downloads/coronaVirus/hashtagsKeywords/", 
                          hashtag = "film")
dontwearTweets <- convertDate(dir = "/Users/dre/Downloads/coronaVirus/hashtagsKeywords/", 
                              hashtag = "dontwear")
covid84Tweets <- convertDate(dir = "/Users/dre/Downloads/coronaVirus/hashtagsKeywords/", 
                             hashtag = "covid84")


allTweets <- rbind(covid84Tweets, dontwearTweets, 
                   filmTweets, id2020Tweets,
                   maskoffTweets, plandemicTweets,
                   reopenTweets, scamdemicTweets)



###########---------------------------#########
###########      General Analysis     #########
###########---------------------------#########

# number of unique tweets vs RTs
uniqueTweets <- allTweets[which(str_detect(allTweets$text, "^RT") == FALSE),]
rt_tweets <- allTweets[which(str_detect(allTweets$text, "^RT") == TRUE),]

tweetCounts <- data.frame(RTs_count = nrow(rt_tweets), 
                unique_tweet_count = nrow(uniqueTweets))



## plot the frequency of tweets for each user over time
colorsForVis <- c("mediumpurple1", "lightgoldenrod2", "lightslategray", "slategray1",
                  "black","firebrick1", "green2", "dodgerblue")
allTweets %>%
  dplyr::filter(!is.na(created_at)) %>%
  dplyr::group_by(matched_str) %>%
  ts_plot("days", trim = 1L, tz = "EST") +
  ggplot2::geom_point() +
  ggplot2::theme_linedraw() +
  scale_colour_manual(values = colorsForVis, aesthetics = "colour", breaks = waiver()) +
  ggplot2::theme(
    legend.title = ggplot2::element_blank(),
    legend.position = "bottom",
    plot.title = ggplot2::element_text(face = "bold")) +
  ggplot2::labs(
    x = NULL, y = NULL,
    title = "Frequency of Tweets by Hashtags",
    subtitle = "Tweet counts aggregated by day"
  )
