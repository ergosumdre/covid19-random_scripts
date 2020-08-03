#install.packages("DistributionUtils", )
library("DistributionUtils")
library("utils")
library("data.table")
library("httr")



consumer_key <- "xxxxxxxxxxxxxxxxxxxxxxxxx"
consumer_secret <- "xxxxxxxxxxxxxxxxxxxxxxxxx"
access_token <- "xxxxxxxxxxxxxxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxx"
access_secret <- "xxxxxxxxxxxxxxxxxxxxxxxxx"



consumer_key = consumer_key
consumer_secret = consumer_secret



# Auth for Twitter
secret <- jsonlite::base64_enc(paste(consumer_key, consumer_secret, sep = ":"))
req <- httr::POST("https://api.twitter.com/oauth2/token",
                  httr::add_headers(
                    "Authorization" = paste("Basic", gsub("\n", "", secret)),
                    "Content-Type" = "application/x-www-form-urlencoded;charset=UTF-8"
                  ),
                  body = "grant_type=client_credentials"
)
httr::stop_for_status(req, "authenticate with twitter")
token <- paste("Bearer", httr::content(req)$access_token)

# read in users
userTable2 <- fread("/shares_bgfs/si_twitter/covid19/tables/tweet/2020-03-19-18_tweetData.csv", integer64 = "character)
unqiueUsers <- userTable2$user.id_str
userURL <- ""

# create user url for api call
for(i in 1:length(unqiueUsers)){
  userURL[i] <- paste0("https://api.twitter.com/1.1/users/lookup.json?user_id=", unqiueUsers[i])
}

# check user status. 
checkUserStatus2 <- ""
for(i in 1:length(userURL)){
  if(is.wholenumber(i/250)){
    message("sleeping for 15 minutes")
    Sys.sleep(900)
    message("starting...")
  }
  message("doing user: ", userTable2$user.screen_name[i], " indexed at: ", i)
  checkUserStatus2[i] <- httr::GET(userURL[i], httr::add_headers(Authorization = token))$status_code
}

checkUserStatus2 <- data.frame(checkUserStatus2)
write.csv(checkUserStatus2, "userStatus.csv")
