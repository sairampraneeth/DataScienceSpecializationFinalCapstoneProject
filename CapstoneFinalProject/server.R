library(shiny)
cat("loading fourgram data")
load("fgram.Rda")

cat("loading trigram data")
load("tri.Rda")


cat("loading bigram data")
load("bi.Rda")

cat("Data is loaded completely")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  ntext <- eventReactive(input$goButton, {
    sentence = trimws(input$inp)
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
        res = as.data.frame(result[order(-result[2]),]$wrd)
        colnames(res) <- c("Top 5 Words")
        return(res)
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
        res = as.data.frame(result[order(-result[2]),]$wrd)
        colnames(res) <- c("Top 5 Words")
        return(res)
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
        res = as.data.frame(result[order(-result[2]),]$wrd)
        colnames(res) <- c("Top 5 Words")
        return(res)
      }
    }
  })
  
  output$nText <- renderDataTable({
    ntext()
  },options = list(search=FALSE))
  
})
