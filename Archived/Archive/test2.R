# Explore catch data----
rm(list=ls()) #clear memory

# librarys----

library(tidyr)
library(dplyr)
library(googlesheets)
library(ggplot2)
library(stringr)

# Study name----

study <-"Growth.Rate.All"

# Set work directory----

#work.dir=("C:/Users/00097191/Google Drive/MEG/Projects/Projects_WRL/Project_WRL_low-catch zone/Fieldwork and Reporting/03_Trapping/Analysis_WRL_Reds_2018") 

# setwd("~/Documents/University/Masters Project/Plots/Plot per recapture")

work.dir=("~/GitHub/Analysis_Miller_WRL") #for Tim's github

work.dir=("~/workspace/Analysis_Miller_WRL") #for ecocloud server


# Set sub-directories----
data.dir=paste(work.dir,"Data",sep="/")
plot.dir=paste(work.dir,"Plots",sep="/")

#### Trips All (Reds & White) ----

# Import length data from googlesheet----

# # For Rstudio Server
options(httr_oob_default=TRUE)
# options(httr_oob_default=FALSE) #for desktop
# gs_auth(new_user = TRUE) #only run once

dat.length.all<-gs_title("Lobsters_data_2018_All_1")%>% 
  gs_read_csv(ws = "Lobster.var" )%>%
  glimpse()

dat.length.all<-dat.length.all%>%
  mutate(Count=1)%>%
  filter(!is.na(Carapace.length))%>%
  filter(!is.na(Tag.number))%>%
  mutate(Colour=str_replace_all(.$Colour,c("W"="White", "R"="Red")))%>%
  mutate(Sex=str_replace_all(.$Sex, c("M"="Male", "F"="Female")))%>%
  mutate(Carapace.length=as.numeric(as.character(Carapace.length)))%>%
  mutate(trip.day.trap=paste(Trip,Day,Trap.Number,sep="."))%>%
  glimpse()

# Checks ---

summary(dat.length.all$Carapace.length) 
length(dat.length.all$Carapace.length) #8825 individual length measurements (after filtering out NA cl and tag.no)
length(unique(dat.length.all$trip.day.trap)) #1048
unique(dat.length.all$Trap.ID) # 522 levels

# # Import pot data----

dat.pot.all<-gs_title("Lobsters_data_2018_All_1")%>% 
  gs_read_csv(ws = "Pot.var")%>%
  mutate(trip.day.trap=paste(Trip,Day,Pot.Number,sep="."))%>%
  mutate(Site.Name=str_replace_all(.$Site.Name,c( "SM"="Seven Mile", "DM"="Davids Marks",  "RM"="Rivermouth", "IR"="Irwin Reef", "LR"="Long Reef", "SD"="South Dummy", "LH"="Little Horseshoe", "CHin1_"="Cliff Head Mid","CHin2_"="Cliff Head South","CHout1_" = "Cliff Head OUT1","CHout2_" = "Cliff Head North", "CHN"="Cliff Head North", "CHM"="Cliff Head Mid", "CHS"="Cliff Head South", "JB"="Jim Bailey", "GR"="Golden Ridge", "SR"="South Rig", "WL"="Whites Lump")))%>% 
  filter(Johns=="No")%>% # turn off if you add in john's data
  glimpse()


unique(dat.pot.all$Trap.ID)  # 601 levels

# Checks----
unique(dat.pot.all$trip.day.trap)
length(unique(dat.pot.all$trip.day.trap)) #1379


#Create "sites" for dat.pot----

sites<-dat.pot.all%>%
  distinct(Trap.ID,Site.Name)%>% #Keeps only distinct rows (Trap.ID & Site.Name)
  mutate(Trap.ID=as.character(Trap.ID))%>%
  dplyr::rename(Site=Site.Name)%>%
  glimpse()


#Add a column of "Site" by Trap.ID to dat.length----


dat.length.all<-left_join(dat.length.all, sites, by="Trap.ID") 



#Check for missing sites: ones in dat.length but not in dat.pot
missing.site<-anti_join(dat.length.all,sites) 

# 116 missing in dat.po <_Neeeed to check this!!!

# Checks---
unique(dat.pot.all$trip.day.trap)
length(unique(dat.pot.all$trip.day.trap)) # 1379

