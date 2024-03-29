### Secure access to lobster data held within GlobalArchive

### OBJECTIVES ###
# 1. use an API token to access Project shared with you.
# 2. securely download any number of Campaigns within a Project
# 3. combine multiple Campaigns into single Metadata and Length files for subsequent validation and data analysis.

rm(list=ls()) # Clear memory

## Load Libraries ----
# To connect to GlobalArchive
library(devtools)
install_github("UWAMEGFisheries/GlobalArchive") #to check for updates
library(GlobalArchive)
library(httr)
library(jsonlite)
library(R.utils)
# To connect to GitHub
library(RCurl)
# To tidy data
library(plyr)
library(tidyverse)
library(stringr)
library(lubridate)
# For googlesheets
library(googlesheets)

## Set your working directory ----
working.dir=("C:/GitHub/Analysis_Miller_lobster")
#working.dir=("Z:/Analysis_Miller_lobster") # FOr Ash's laptop using Git

## Save these directory names to use later----
data.dir<-paste(working.dir,"Data",sep="/") 
download.dir<-paste(data.dir,"Downloads",sep="/")
tidy.dir<-paste(data.dir,"Tidy data",sep="/")

## Delete Downloads folder ----
setwd(working.dir)
unlink(download.dir, recursive=TRUE)

## Create Downloads, Staging and Tidy data folders ----
dir.create(file.path(working.dir, "Data"))
dir.create(file.path(data.dir, "Downloads"))
dir.create(file.path(data.dir, "Tidy data"))

## Query from GlobalArchive----
# Load default values from GlobalArchive ----
source("https://raw.githubusercontent.com/UWAMEGFisheries/GlobalArchive/master/values.R")

# Set as tims at the moment
# Add your personal API user token ----
API_USER_TOKEN <- "993ba5c4267b9f8cd21de73b0434c95bc72f518a4f6e725226986022"

# Set up your query ----
## Download data ----
ga.get.campaign.list(API_USER_TOKEN, process_campaign_object, q=ga.query.project("FRDC+low+catch+zone"))

# Combine all downloaded data----
## Metadata files ----
metadata <-ga.list.files("Metadata.csv")%>%
  purrr::map_df(~ga.read.files_csv(.))%>%
  dplyr::mutate(Latitude=as.numeric(latitude))%>%
  dplyr::mutate(Longitude=as.numeric(longitude))%>%
  dplyr::mutate(Trip=as.numeric(trip))%>%
  dplyr::mutate(Date=paste((str_sub(date,1,4)),(str_sub(date,5,6)),(str_sub(date,7,8)),sep="-"))%>%
  dplyr::mutate(Date=lubridate::as_date(ymd(Date)))%>%
  dplyr::rename(Pot.remarks=comment)%>%
  dplyr::select(-c(date,latitude,longitude,trip))%>%
  glimpse()

## Length files ----
length <-ga.list.files("Length.csv")%>%
  purrr::map_df(~ga.read.files_csv(.))%>%
  dplyr::mutate(Carapace.length=as.numeric(length))%>%
  dplyr::mutate(Trip=as.numeric(trip))%>%
  dplyr::mutate(Damage.new.a=as.numeric(damage.new.a))%>%
  dplyr::mutate(Damage.old.a=as.numeric(damage.old.a))%>%
  dplyr::mutate(Damage.new.l=as.numeric(damage.new.l))%>%
  dplyr::mutate(Damage.old.l=as.numeric(damage.old.l))%>%
  dplyr::select(-c(length,trip,damage.new.a,damage.new.l,damage.old.a,damage.old.l))%>%
  glimpse()


# Import Tag Return data sent to Fisheries----
fisheries.returns <- gs_title("Fisheries.Tag.Returns")%>%
  gs_read_csv(ws="Sheet1")%>%
  dplyr::mutate(Recapture=TRUE)%>%
  dplyr::mutate(Colour="Unknown")%>%
  dplyr::mutate(Source= "fisheries-returns")%>%
  dplyr::mutate(Sex=str_replace_all(.$Sex, c("M"="Male", "F"="Female")))%>%
  dplyr::rename(Tag.number=SpeciesTag, Carapace.length=SpeciesSize, Date=ReportCreatedDate, Fisher=ReportersUserName)%>%
  dplyr::mutate(Setose.state=str_replace_all(.$SpeciesName,c("Western rock lobster - "="","male"="","Western rock lobster"="","Western rock lobster- "="","- "="","setose no tarspot"="Mature","setose with tarspot"="Mature","non setose"="Immature")))%>%
  dplyr::mutate(Tarspot=ifelse(SpeciesName%in%c("Western rock lobster - setose with tarspot"),TRUE,NA))%>%
  dplyr::mutate(Retention.Status=ifelse(RetentionStatus%in%c("KEPT","kept"),"Retained",RetentionStatus))%>%
  replace_na(list(Sex="Unknown"))%>%
  dplyr::mutate(Dead=ifelse(Comments%in%c("Eaten by octopus"),"Dead",NA))%>%
  dplyr::rename(Individual.Remarks=Comments,Fisher.Email=ReportersUserEmail,Depth.fms=depth.fms)%>%
  dplyr::select(-c(ReportId,SpeciesName,SpeciesCategory,ReportersPhoneNumber,ReportersBoatRegistrationNumber,address,X19,X20,X21,X22,RetentionStatus))%>%
  dplyr::mutate(Date=lubridate::as_date(mdy(Date)))%>%
  glimpse()

# Change format of Longitude and Latitude
dm <- fisheries.returns%>%
  filter(PositionFormat%in%c("Decimal Minutes"))%>%
  dplyr::mutate(Latitude=measurements::conv_unit(.$Latitude, from = 'deg_dec_min', to = 'dec_deg'))%>%
  dplyr::mutate(Longitude=measurements::conv_unit(.$Longitude, from = 'deg_dec_min', to = 'dec_deg'))%>%
  glimpse()

dd <- fisheries.returns%>%
  filter(PositionFormat%in%c("Decimal Degrees"))%>%
  glimpse()

fisheries.returns <- bind_rows(dd, dm)%>%
  dplyr::mutate(Latitude=as.numeric(Latitude))%>%
  dplyr::mutate(Longitude=as.numeric(Longitude))%>%
  dplyr::mutate(row=1:nrow(.))%>%
  dplyr::mutate(Sample=paste(row,Tag.number,sep="."))%>%
  glimpse()

names(fisheries.returns)

metadata.fisheries<-fisheries.returns%>%
  dplyr::select(Source,Sample,Latitude,Longitude,Fisher,Fisher.Email,Date,Depth.fms,Exclude.Pots,Pot.Remarks)

length.fisheries<-fisheries.returns%>%
  dplyr::mutate(Recapture=as.character(Recapture))%>%
  dplyr::mutate(Tarspot=as.character(Tarspot))%>%
  dplyr::select(Source,Sample,Tag.number,Sex,Colour,Carapace.length,Recapture,Setose.state,Tarspot,Individual.Remarks,Retention.Status,Dead)

# Import Tag Return data sent to UWA----
fisher.returns <- gs_title("UWA.Tag.Returns")%>%
  gs_read_csv(ws="Sheet1")%>%
  dplyr::mutate(Recapture=TRUE)%>%
  dplyr::mutate(Source = "fisher-returns")%>%
  dplyr::mutate(Sex=str_replace_all(.$Sex, c("M"="Male", "F"="Female","U"="Unknown")))%>%
  dplyr::mutate(Colour=str_replace_all(.$Colour, c("W"="White", "R"="Red")))%>%
  dplyr::rename(Fisher= Reporter, Latitude=`Latitude(deg_dec_min)`, Longitude=`Longitude(deg_dec_min)`,Setose.state=Setose,Fisher.Email=Email,Pot.Remarks=Comments,Retention.Status=RetentionStatus)%>%
  dplyr::mutate(Date=as_date(dmy(Date)))%>%
  dplyr::mutate(Latitude=measurements::conv_unit(.$Latitude, from = 'deg_dec_min', to = 'dec_deg'))%>%
  dplyr::mutate(Longitude=measurements::conv_unit(.$Longitude, from = 'deg_dec_min', to = 'dec_deg'))%>%
  dplyr::mutate(Latitude=as.numeric(Latitude))%>%
  dplyr::mutate(Longitude=as.numeric(Longitude))%>%
  dplyr::mutate(row=1:nrow(.))%>%
  dplyr::mutate(Sample=paste(row,Tag.number,sep="."))%>%
  dplyr::mutate(Retention.Status=str_replace_all(.$Retention.Status, c("Returned"="Released")))%>%
  glimpse()

names(fisher.returns)

metadata.fisher<-fisher.returns%>%
  dplyr::select(Source,Sample,Date,Latitude,Longitude,Fisher,Fisher.Email,Pot.Remarks)

length.fisher<-fisher.returns%>%
  dplyr::mutate(Recapture=as.character(Recapture))%>%
  dplyr::select(Source,Sample,Tag.number,Carapace.length,Sex,Colour,Setose.state,Retention.Status,Recapture)

# Clean up enviroment
rm(dd,dm,fisher.returns,fisheries.returns)

# Seven Mile Data ----
sevenmile<-gs_title("Lobster_Data_Fisheries_SMB_All")%>%
  gs_read_csv("SMB2",col_types = "cccnnnnnccnnnnnnncccnnnnnnnn")%>%
  dplyr::mutate(Source="ben-seven-mile")%>%
  dplyr::mutate(Location="Seven Mile")%>%
  dplyr::mutate(Site="Seven Mile North")%>%
  dplyr::mutate(Trip="10")%>%
  dplyr::mutate(Trip=as.numeric(Trip))%>%
  dplyr::mutate(Sample=as.character(POT_NO))%>%
  dplyr::mutate(sample.date=paste(y,m,d,sep="-"))%>%
  dplyr::mutate(Sample=paste(Sample,sample.date,sep="."))%>%
  dplyr::rename(Tag.number=VTAGNO)%>%
  dplyr::mutate(Tag.number=as.character(Tag.number))%>%
  dplyr::mutate(Tag.number=str_replace_all(.$Tag.number,c("V"="")))%>% #Removes V
  dplyr::filter(m%in%c(5:12))%>% #filter Jan-April
  dplyr::mutate(Date=lubridate::ymd(sprintf('%04d%02d%02d',y,m,d)))%>% #Make date col
  dplyr::mutate(Outlier=ifelse(Tag.number%in%c("190428","190188","190124","190443"),"y",NA))%>%
  dplyr::rename(Recapture= REC, Sex=SEX, Colour=COLOUR, Carapace.length=CLENGTH, Setose.state= SETOSE, Individual.Remarks=REMARKS, Damage.new.a=NEW_ANT, Damage.new.L=NEW_LEGS, Damage.old.a=OLD_ANT, Damage.old.L=OLD_LEGS,Pot.Number=POT_NO, Pot.Type=POT_TYPE_ID, Day.Pull=DAY_PULL)%>%
  replace_na(list(Damage.old.a = 0, Damage.old.L = 0,Damage.new.a = 0, Damage.new.L = 0))%>%
  dplyr::mutate(Damage.old.a=if_else(is.na(Damage.old.a),0,Damage.old.a))%>% # Fix Damaged data
  mutate(Damage.old.a=if_else(Damage.new.a==9,0,Damage.old.a))%>% # Fix Damaged data
  mutate(Damage.new.L=if_else(Damage.new.a==9,0,Damage.new.L))%>%
  mutate(Damage.old.L=if_else(Damage.new.a==9,0,Damage.old.L))%>%
  mutate(Damage.new.a=if_else(Damage.new.a==9,0,Damage.new.a))%>%
  dplyr::mutate(Total.damage=(Damage.old.a+Damage.old.L+Damage.new.a+Damage.new.L))%>%
  dplyr::mutate(Total.damage=as.character(Total.damage))%>%
  dplyr::mutate(Colour=str_replace_all(.$Colour,c("W"="White", "R"="Red")))%>%
  dplyr::mutate(Sex=str_replace_all(.$Sex, c("M"="Male", "F"="Female","U"="Unknown")))%>%
  dplyr::mutate(Sex=if_else((!is.na(Colour)&!Sex%in%c("Female","Male")),"Unknown",Sex))%>%
  dplyr::mutate(Recapture=str_replace_all(.$Recapture, c("1"= "TRUE")))%>%
  filter(!is.na(Sample))%>%
  glimpse()

#####"))%>%
#Lots of repeats in SM data i.e. same tag numbers in same pots (Sample)
#Need to filter out
sevenmile<- sevenmile[!duplicated(sevenmile[,c("Tag.number","Sample")]),]%>%
  glimpse

######
catch.sm<-sevenmile%>%
  select(Carapace.length, Tag.number, Date, m)%>%
  mutate(Count=1)%>%
  mutate(sizeclass=ifelse(Carapace.length>=76.0,"Legal", "Sublegal"))%>%
  glimpse()

mutate(sizeclass= ifelse(Carapace.length>=76.0,"Legal", "Sublegal"))%>% 
  
#####

unique(sevenmile$Total.damage)
names(sevenmile)

metadata.sevenmile<-sevenmile%>%
  distinct(Source,Trip,Sample,Date,Longitude,Latitude,Location,Site,PWO,WKW,PWF,Pot.Remarks)%>%
  dplyr::mutate(PWO=as.character(PWO))

length.sevenmile<-sevenmile%>%
  dplyr::select(Source,Trip,Sample,Tag.number,Carapace.length,Sex,Colour,Recapture,Damage.new.a, Damage.new.L, Damage.old.a, Damage.old.L,Total.damage, Outlier)%>%
  filter(!is.na(Carapace.length)&!is.na(Sex))%>%
  glimpse()

# tidy names to join length ----
names(length)<-ga.capitalise(names(length))
names(length.fisheries)<-ga.capitalise(names(length.fisheries))
names(length.fisher)<-ga.capitalise(names(length.fisher))
names(length.sevenmile)<-ga.capitalise(names(length.sevenmile))

# tidy names to join metadata ----
names(metadata)<-ga.capitalise(names(metadata))
names(metadata.fisheries)<-ga.capitalise(names(metadata.fisheries))
names(metadata.fisher)<-ga.capitalise(names(metadata.fisher))
names(metadata.sevenmile)<-ga.capitalise(names(metadata.sevenmile))

# Add data from other sources to UWA data ----
metadata.final<-bind_rows(metadata,metadata.fisheries,metadata.fisher,metadata.sevenmile)%>%
  select(-c(Time,Status,Depth,Observer,Depth.echosounder,Distance.from.shore.perpendicular.kilometer,Days.from.new.moon,Slope,Aspect,Rugosity,Curvature,Curv.plan,Curv.profile,Distance.from.shore.nearestpoint.kilometer,Sd.10m,Sd.15m,Sd.20m,Sd.25m,Sd.50m,Sd.75m,Sd.100m,Sd.200m,Sd.500m,Sd.1000m,Puerulus.count.1k,Puerulus.count.2k,Puerulus.count.3k,Substrate,Project,Campaignid))


length.final<-bind_rows(length,length.fisheries,length.fisher,length.sevenmile)%>%
  replace_na(list(Dead="Alive",Cable.tie=FALSE))%>%
  select(-c(Family,Genus,Species,Project,Campaignid))

unique(metadata.final$Pwo)

names(metadata.final)
names(length.final)

# Final check of metadata format before saving ----
unique(metadata.final$Source)
unique(metadata.final$Location) # OK
unique(metadata.final$Pot.remarks) # OK
unique(metadata.final$Pwf) # OK
unique(metadata.final$Trip) # OK - one missing though?
unique(metadata.final$Exclude.pots) # Ok

# Final check of length format before saving ----
unique(length.final$Source) # OK
unique(length.final$Recapture) # OK
unique(length.final$Sex) # OK
unique(length.final$Colour) # OK
unique(length.final$Dead) # OK
unique(length.final$Individual.remarks) # OK
unique(length.final$Reproductive.stage) # OK
unique(length.final$Setose.state) # OK
unique(length.final$Egg.stage) # OK
unique(length.final$Moult.stage) # OK
unique(length.final$Cable.tie) # OK
unique(length.final$Outlier) # OK
unique(length.final$Tarspot) # OK
unique(length.final$Reproductive.stage) # OK

#Change Location now, will change later in first script if analysis is good- AM
unique(metadata.final$Site)
unique(metadata.final$Location)
metadata.final%<>%
  mutate(Location=str_replace_all(.$Site,c("Little Horseshoe"="Little Horseshoe", "White Point"="White Point", "Whites Lump"="White Point", "South Dummy"="White Point","Cliff Head North"= "Cliff Head", "Kevin Healy"="Cliff Head", "Long Reef"="Irwin Reef","South Rig" ="Irwin Reef",  "Cliff Head Mid"="Cliff Head", "Cliff Head South"= "Cliff Head", "Seven Mile Mid"="Seven Mile","Seven Mile North" ="Seven Mile","Little HorseshoeS"="Little Horseshoe")))%>%
  glimpse()

## Save metadata, count and length files ----
setwd(data.dir)

write.csv(metadata.final,"metadata.csv",row.names = FALSE)
write.csv(length.final,"length.csv",row.names = FALSE)

