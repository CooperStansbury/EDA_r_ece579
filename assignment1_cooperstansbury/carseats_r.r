
library(leaps)
library(modelr)
library(mgcv)
library(ggplot2)
library(DataExplorer)
library(dplyr)
library(GGally)
library(ggExtra)
library(caret)
library(reshape2)
library(RColorBrewer)
library(plotly)

sessionInfo()
sapply(c('repr', 'IRdisplay', 'IRkernel'), function(p) paste(packageVersion(p)))

# show raw file via bash
print(system("head -n 5 data/Carseats_org.csv", intern=TRUE))

carseats <- read.csv("data/Carseats_org.csv", header = T, stringsAsFactors = T)

drops <- c("X")
carseats <- carseats[ , !(names(carseats) %in% drops)]
head(carseats, 10)

# get vectors of continuous and categorical cols
nums <- dplyr::select_if(carseats, is.numeric)
cats <- dplyr::select_if(carseats, is.factor)

nums[sample(nrow(nums), 10), ]

cats[sample(nrow(cats), 10), ]

str(carseats)

print(paste('Number of Columns:', ncol(carseats)))
print(paste('Number of Numeric Columns:', ncol(nums)))
print(paste('Number of Categorical Columns:', ncol(cats)))

# # get summary 
print(DataExplorer::introduce(data=carseats))

plot_ly(data=carseats, 
        x=~Age, 
        y=~Sales, 
        mode = 'markers', 
        type = 'scatter', 
        color=~ShelveLoc) %>%
            layout(title = "Age, Shelf Location, and Sales Scatter Plot") 

plot_ly(data=carseats, 
        x=~Price, 
        y=~Sales, 
        mode = 'markers', 
        type = 'scatter', 
        color=~ShelveLoc) %>%
            layout(title = "Price, Shelf Location, and Sales Scatter Plot")

plot_ly(data=carseats, 
        x=~Price, 
        y=~Sales, 
        mode = 'markers', 
        type = 'scatter', 
        size=~Price,
        colors = "Set1",
        color = ~US,
        alpha = .6) %>%
            layout(title = "Price, US, and Sales Scatter Plot") 

# normalize continuous columns
preObj <- preProcess(nums, method=c("center", "scale"))
scaled.nums <- predict(preObj, nums)

head(scaled.nums)

scaled.nums %>%
    tidyr::gather() %>% 
        ggplot(aes(x=value,y=..density..))+

            ggtitle('Distributions of Continous Variables (scaled)') +

            facet_wrap(~ key, scales = "free") +
            geom_histogram(fill=I("orange"), col=I("black")) +

            facet_wrap(~ key, scales = "free") +
            geom_density(color="blue", fill='light blue', alpha = 0.4)

scaled.nums %>%
    tidyr::gather() %>% 
        plot_ly(x=~key, y=~value,
                type = "box", 
                boxpoints = "all", 
                jitter = 0.4,
                pointpos = 0,
                color = ~key,
                colors = "Dark2") %>%
                      subplot(shareX = TRUE)  %>%
                            layout(title = "Numeric Variable Distributions (scaled)", 
                                  yaxis=list(title='Standard Deviation'),
                                  xaxis=list(title='Variable'),
                                  autosize=FALSE,
                                  width=900,
                                  height=900)

scaled.nums %>%
    tidyr::gather(-Sales, key = "var", value = "value") %>%
    split(.$var) %>%
       lapply(function(d) plot_ly(d, x=~value, y=~Sales, 
                mode = 'markers', 
                type = 'scatter',
                colors = 'Set3',
                size = ~Sales^2,
                marker = list(line = list(
                color = 'black',
                width = 2)),
                name=~var)) %>%
                      subplot(nrows=7, shareY=TRUE)  %>%
                            layout(title = "Scatterplot Numeric vs Sales (scaled)<br>Size=Sales^2",
                                   autosize=FALSE,
                                   width=900,
                                   height=1500,
                                   yaxis=list(title='Sales'))

fit.Pop <- lm(Sales ~ Population, data = scaled.nums)
fit.Age <- lm(Sales ~ Age, data = scaled.nums)
fit.CompPrice <- lm(Sales ~ CompPrice, data = scaled.nums)
fit.Price <- lm(Sales ~ Price, data = scaled.nums)

p1 <-  plot_ly(scaled.nums, 
               x = ~Population,
               name = 'Population vs Sales Regression Line') %>% 
                   add_markers(y = ~Sales,
                               name = 'Population vs Sales Observations') %>% 
                                    add_lines(x = ~Population, 
                                              y = fitted(fit.Pop)) 
p2 <-  plot_ly(scaled.nums, 
               x = ~Age,
               name = 'Age vs Sales Regression Line') %>% 
                   add_markers(y = ~Sales,
                               name = 'Age vs Sales Observations') %>% 
                                    add_lines(x = ~Age, 
                                              y = fitted(fit.Age)) 

p3 <-  plot_ly(scaled.nums, 
               x = ~CompPrice,
               name = 'CompPrice vs Sales Regression Line') %>% 
                   add_markers(y = ~Sales,
                               name = 'CompPrice vs Sales Observations') %>% 
                                    add_lines(x = ~CompPrice, 
                                              y = fitted(fit.CompPrice)) 

p4 <-  plot_ly(scaled.nums, 
               x = ~Price,
               name = 'Price vs Sales Regression Line') %>% 
                   add_markers(y = ~Sales,
                               name = 'Price vs Sales Observations') %>% 
                                    add_lines(x = ~Price, 
                                              y = fitted(fit.Price)) 

subplot(p1, p2, p3, p4, nrows=2, shareY=TRUE) %>%
    layout(title = "Scatterplot Numeric vs Sales (scaled) <br> With Regression Lines",
           autosize=FALSE,
           width=1000,
           height=700,
           yaxis=list(title='Sales'))


scaled.nums %>%
    plot_ly(y = ~Sales) %>%
      add_lines(x= ~Population, y = fitted(fit.Pop), 
                name = "fit.Pop slope", line = list(shape = "linear")) %>%
      add_lines(x= ~Age, y = fitted(fit.Age), 
                name = "fit.Age slope", line = list(shape = "linear")) %>%
      add_lines(x= ~CompPrice, y = fitted(fit.CompPrice), 
                name = "fit.CompPrice slope", line = list(shape = "linear")) %>%
      add_lines(x= ~Price, y = fitted(fit.Price), 
                name = "fit.Price slope", line = list(shape = "linear")) %>%
            
    layout(title = "Regression Lines vs Sales (scaled)",
           autosize=FALSE,
           width=700,
           height=500,
           yaxis=list(title='Sales'),
           xaxis=list(title='Scaled Numeric Variable'))


y = scaled.nums$Sales
x = scaled.nums$Price

s <- subplot(
  plot_ly(x = x, color = I("black"), type = 'histogram'), 
  plotly_empty(), 
  plot_ly(x = x, y = y, type = 'histogram2dcontour', showscale = F), 
  plot_ly(y = y, color = I("black"), type = 'histogram'),
  nrows = 2, heights = c(0.2, 0.8), widths = c(0.8, 0.2),
  shareX = TRUE, shareY = TRUE, titleX = FALSE, titleY = FALSE
)

layout(s, showlegend = FALSE, autosize=FALSE,
           width=700,
           height=500, 
           yaxis=list(title='Sales'),
           xaxis=list(title='Price'))

categorical.by.sales = cbind(Sales = scaled.nums$Sales, cats)

# sample colors to make each subplot more unique
colr = brewer.pal(9, "Set1")

categorical.by.sales %>%
    tidyr::gather(-Sales, key = "var", value = "value") %>%
    split(.$var) %>%
       lapply(function(d) plot_ly(d, x=~paste(var, '<br>' , value), y=~Sales,
                type = "box", 
                boxpoints = "all", 
                jitter = .2,
                pointpos = 0,
                color =~paste(var, ":", value),
                colors = sample(colr, length(unique(d$value))))) %>%
#                 colors = "Set1")) %>%
                      subplot(shareY = TRUE, nrows=3)  %>%
                            layout(title = "Categorical Variable Distributions vs Sales (scaled)", 
                                  yaxis=list(title='Sales Standard Deviation'),
                                  xaxis=list(title=''),
                                  autosize=FALSE,
                                  width=900,
                                  height=1500)
              
# help(layout)

categorical.by.sales %>%               
    plot_ly(x = ~US, y = ~Sales,
        split = ~US,
        type = 'violin',
        box = list(visible = TRUE),
        meanline = list(visible = TRUE)) %>% 
              layout(xaxis = list(title = "US"),
                     yaxis = list(title = "Sales",zeroline = FALSE))

categorical.by.sales %>%               
    plot_ly(x = ~Urban, y = ~Sales,
        split = ~Urban,
        type = 'violin',
        box = list(visible = TRUE),
        meanline = list(visible = TRUE)) %>% 
              layout(xaxis = list(title = "Urban"),
                     yaxis = list(title = "Sales",zeroline = FALSE))

categorical.by.sales %>%               
    plot_ly(x = ~ShelveLoc, y = ~Sales,
        split = ~ShelveLoc,
        type = 'violin',
        box = list(visible = TRUE),
        meanline = list(visible = TRUE)) %>% 
              layout(xaxis = list(title = "ShelveLoc"),
                     yaxis = list(title = "Sales",zeroline = FALSE))


