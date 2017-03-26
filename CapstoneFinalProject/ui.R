#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  titlePanel("Data Science Capstone Project - Word Prediction Application"),
  sidebarLayout(
    sidebarPanel(
      p("Input a word or text and press Predict to see the next word suggestions:"),
      textInput("inp", "Input Sentence", ""),
      br(),
      actionButton("goButton", "Predict!")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Result", dataTableOutput("nText")),
        tabPanel("Documentation", p("this app was developed by sairam praneeth vegesana.\nTo test this app, enter a text into the input box and press predict to get the top 5 word suggestions 
                                    for the input text.\nThis Algorithm uses (Trigram,Unigram), (Bigram,Unigram) and (Unigram,Unigram) pairs stored in three seperate dataframe
                                     to find the top 5 word suggestions with highest frequency of occuring.\n
                                    It first checks the (Trigram,Unigram) dataframe, then the (Bigram,Unigram) dataframe if no result is found in the previous table and finally it 
                                    searches in the (Unigram,Unigram) dataframe."))
      )
    )
  )
))