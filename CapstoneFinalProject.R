if(!file.exists('fgram.Rda') || !file.exists('bi.Rda') || !file.exists('tri.Rda')){
  if(!file.exists("final/en_US/sampledata.txt")){
    furl <- "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"
    
    if(!file.exists("Coursera-SwiftKey.zip")){ #checks whether the file Exists.
      download.file(furl, destfile = "Coursera-SwiftKey.zip", method = "curl")
    }
    if(!dir.exists("final")){ # Check if Directory Exists or not
      unzip("Coursera-SwiftKey.zip")
    }
    c <- file("final/en_US/en_US.blogs.txt","rb")
    blogs <- readLines(c,encoding = "UTF-8",skipNul = TRUE)
    close(c)
    
    c <- file("final/en_US/en_US.news.txt","rb")
    news <- readLines(c,encoding = "UTF-8",skipNul = TRUE)
    close(c)
    
    c <- file("final/en_US/en_US.twitter.txt","rb")
    twitter <- readLines(c,encoding = "UTF-8",skipNul = TRUE)
    close(c)
    
    blogslc <- length(blogs)
    newslc <- length(news)
    twitterlc <- length(twitter)
    
    set.seed(12345)
    sampleblogs <- sample(blogs,blogslc * 0.01)
    samplenews <- sample(news,newslc * 0.01)
    sampletwitter <- sample(twitter,twitterlc * 0.01)
    sampledata <- c(sampleblogs, samplenews, sampletwitter)
    writeLines(sampledata, "final/en_US/sampledata.txt")
    rm(sampleblogs, samplenews, sampletwitter, sampledata, blogs, news, twitter)
  }
  
  require(NLP)
  require(tm)
  require(RWeka)
  require(SnowballC)
  c <- file.path(getwd(),"final/en_US/sampledata.txt")
  sdata <- Corpus(URISource(c, encoding = "UTF-8"))
  
  sdata <- tm_map(sdata, content_transformer(tolower))
  sdata <- tm_map(sdata, content_transformer(removeNumbers))
  sdata <- tm_map(sdata, content_transformer(removePunctuation))
  sdata <- tm_map(sdata, content_transformer(stripWhitespace))
  sdata <- tm_map(sdata, content_transformer(stemDocument))
  sdata <- tm_map(sdata, removeWords, stopwords(kind = "en"))
}

if(!file.exists('fgram.Rda')){
  fgramfun <- function(x) NGramTokenizer(x, Weka_control(min = 4, max = 4))
  fgram <- DocumentTermMatrix(sdata, control = list(tokenize = fgramfun))
  fgram <- as.matrix(fgram)
  fgram <- colSums(fgram)
  fgram <- sort(fgram, decreasing = TRUE)
  fgram_df <- data.frame(wrd = names(fgram), freq = fgram)
  rm(fgram)
  rm(fgramfun)
  save(fgram_df,file = "fgram.Rda")
}else{
  load("fgram.Rda")
}

if(!file.exists("tri.Rda")){
  trigramfun <- function(x) NGramTokenizer(x, Weka_control(min = 3, max = 3))
  tri <- DocumentTermMatrix(sdata, control = list(tokenize = trigramfun))
  tri <- as.matrix(tri)
  tri <- colSums(tri)
  tri <- sort(tri, decreasing = TRUE)
  tri_df <- data.frame(wrd = names(tri), freq = tri)
  rm(tri)
  rm(trigramfun)
  save(tri_df,file = "tri.Rda")
}else{
  load("tri.Rda")
}

if(!file.exists("bi.Rda")){
  bgramfun <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))
  bi <- DocumentTermMatrix(sdata, control = list(tokenize = bgramfun))
  bi <- as.matrix(bi)
  bi <- colSums(bi)
  bi <- sort(bi, decreasing = TRUE)
  bi_df <- data.frame(wrd = names(bi), freq = bi)
  rm(bi)
  rm(bgramfun)
  save(bi_df,file = "bi.Rda")
}else{
  load("bi.Rda")
}

if(exists('sdata')){
  rm(sdata)
  rm(c)
}

predictor <- function(sentence){
  toks <- tolower(strsplit(sentence," ")[[1]])
  regex <- ""
  result <- data.frame(wrd = as.character(),freq = as.numeric())
  if(length(toks) >= 3){
    regex <- paste(toks[(length(toks)-2):length(toks)],collapse = " ")
    regex <- paste("^",regex,sep = "")
    regex <- paste(regex,".*",sep = "")
    match <- grep(regex,fgram_df$wrd)
    final <- match[1:min(5,length(match))]
    temp <- fgram_df[final,]
    if(!is.na(temp[1,]$freq)){
      for(i in 1:nrow(temp)){
        word <- tail(tolower(strsplit(as.character(temp[i,]$wrd)," ")[[1]]),n = 1)
        if(word %in% result$wrd){
          result[which(result$wrd == word),]$freq <- result[which(result$wrd == word),]$freq + temp[i,]$freq
        }else{
          result <- rbind(result,data.frame(wrd = word,freq = temp[i,]$freq))
        }
      }
      return(result[order(-result[2]),])
    }
  }
  
  if(length(toks) >= 2){
    regex <- paste(toks[(length(toks)-1):length(toks)],collapse = " ")
    regex <- paste("^",regex,sep = "")
    regex <- paste(regex,".*",sep = "")
    match <- grep(regex,tri_df$wrd)
    final <- match[1:min(5,length(match))]
    temp <- tri_df[final,]
    if(!is.na(temp[1,]$freq)){
      for(i in 1:nrow(temp)){
        word <- tail(tolower(strsplit(as.character(temp[i,]$wrd)," ")[[1]]),n = 1)
        if(word %in% result$wrd){
          result[which(result$wrd == word),]$freq <- result[which(result$wrd == word),]$freq + temp[i,]$freq
        }else{
          result <- rbind(result,data.frame(wrd = word,freq = temp[i,]$freq))
        }
      }
      return(result[order(-result[2]),])
    }
  }
  
  if(length(toks) >= 1){
    regex <- paste("^",toks[length(toks)],sep = "")
    regex <- paste(regex,".*",sep = "")
    match <- grep(regex,bi_df$wrd)
    final <- match[1:min(5,length(match))]
    temp <- bi_df[final,]
    if(!is.na(temp[1,]$freq)){
      for(i in 1:nrow(temp)){
        word <- tail(tolower(strsplit(as.character(temp[i,]$wrd)," ")[[1]]),n = 1)
        if(word %in% result$wrd){
          result[which(result$wrd == word),]$freq <- result[which(result$wrd == word),]$freq + temp[i,]$freq
        }else{
          result <- rbind(result,data.frame(wrd = word,freq = temp[i,]$freq))
        }
      }
      return(result[order(-result[2]),])
    }
  }
}
