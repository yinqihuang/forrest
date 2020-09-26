#### neat ####
## set relative path
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

## yay
library(tidyverse)
library(viridis)
library(patchwork)
library(hrbrthemes)
library(igraph)
library(ggraph)
library(colormap)

## read intrusion file
df <- list.files(path = '/Users/yinqi/Downloads/intrusions', pattern = '*.csv', full.names = TRUE) %>% tibble(filename = .) %>% mutate(file_contents = map(filename, ~read_csv(.))) %>% unnest() %>% select(-filename,-X7,-X8,-X9,-X10,-X11,-X12,-X13,-X14,-X15,-X16)
# OR
# df <- list.files(path = '/Users/yinqi/Downloads/intrusions', pattern = '*.csv', full.names = TRUE) %>% tibble(filename = .) %>% mutate(file_contents = map(filename, ~read_csv(.))) %>% unnest() %>% select(-filename)
# df <- subset(df, select = -c(X7:X16))

## read condition file
# be careful of the orientation of /
# make sure to rename filename so the two dfs match
cb <- list.files(path = '/Users/yinqi/Downloads', pattern = 'counterbalance', full.names = TRUE) %>% tibble(filename = .) %>% mutate(file_contents = map(filename, ~ read_csv(.))) %>% unnest() %>% mutate(filename = case_when(str_detect(filename, "counterbalance") ~ str_remove(filename, "Users(.*)/counterbalance")), filename = str_remove(filename, ".csv"), filename = str_remove(filename, "/")) %>% select(-imgStim) %>% rename(counterbalance = filename)

## merge dfs
# reduce human error aka sleepy yinqi
df <- df %>% left_join(cb, by = c('counterbalance', 'trial'))

## remove text 
df <- subset(df, select = -c(subID,trial,counterbalance,testTime,intrusionText,lag,narrativeCross,cond))

#### survival #### 
## left censoring
# Q: first exposure unclear > missing 

#### clustering ####
## freq
# sort freq to get the top 5 for each event

## matrix WHY??
# try: http://www.r-tutor.com/r-introduction/matrix/matrix-construction
# A1 > 1,2 ... 83 OR
# A1, B1 ... A60 > 1 (merge participants)

## artificial neural network
# try: https://www.datacamp.com/community/tutorials/neural-network-models-r

#### ??? ####
# prediction - observation = frequency $ n $ parameters
# look for n-min

#### pca ####
## use correlation from frequency, map it back to the eight variable
# OR
## date from http://studyforrest.org/data.html
## pca combined all 8 dims > can generate one new category
# need to score all of them
## do it within a group so the pca can explain the intrusion happening within that group
## eg., for lag vs event boundary that 4 conditions: eg., short lag cross boundaries, intrusion can be explained by 80% of temporal, 10% of semantic, 10% of emotional

## after pca, can try graphical models to find causality
# try: https://probmlcourse.github.io/csc412/lectures/week_3/

#### chisq ####
# intru <- df[,1]
# event <- df[,2]
tbl <- table(df)
result <- (chisq.test(tbl))
print(result)

#### arc ####
## create edge list (no need its just a df)

## arrange nodes: tbl <- tbl %>% arrange(intrusionEvent, event)
# CORN oops now its two separate cols

## direction matters: arrow = arrow ()
## merge lines based on counts
# df <- df %>% group_by(intrusionEvent, event) %>% summarise(weight = n())
# why NA? Coerce?
# is.na (df)
# CORN need an argument to remove all True

# OR
tbl <- as.data.frame(tbl)
tbl <- subset(tbl, Freq >= 100) #100 is arbitrary

# - SKIP - 
## prepare vector of color
# mycolor <- colormap(colormap = colormaps$viridis, nshades = 83)
# mycolor <- sample(mycolor, length(mycolor))

## convert to igraph
mygraph <- graph_from_data_frame(tbl)
p1 <-  ggraph(mygraph, layout="linear") + geom_edge_arc(edge_colour="grey", edge_alpha=0.3, fold = TRUE, end_cap = circle(0.2, 'cm'), start_cap = circle(0.2, 'cm'), aes(width = Freq)) + geom_node_point(color="black", size=0.3) + geom_node_text(aes(label=name), size=3, color="black", nudge_y = -0.5)

## group them by narratives
# 13 19 26 34 59 68 71 72 76 82 83

## try if else if
# p1 <-  ggraph(mygraph, layout="linear") + geom_edge_arc(edge_colour="grey", edge_alpha=0.3, fold = TRUE, end_cap = circle(0.2, 'cm'), start_cap = circle(0.2, 'cm'), aes(width = Freq)) + geom_node_point(if (node <= 13) {color = "red"} else if (node <= 19) {color = "orange"} else if (node <= 26) {color = "yellow"} else if (node <= 34) {color = "pink"} else if (node <= 59) {color = "green"} else if (node <= 68) {color = "blue"} else if (node <= 71) {color = "purple"} else if (node <= 72) {color = "gray"} else if (node <= 76) {color = "red"} else if (node <= 82) {color = "orange"} else {color = "yellow"}, size=0.3) + geom_node_text(aes(label=name), size=3, color="black", nudge_y = -0.5)
# Error in as.list(aes1) : object 'node' not found
# CORN label nodes > name () <- c(1:83)