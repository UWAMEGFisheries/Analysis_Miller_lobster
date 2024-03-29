# Part 3 - plots of the most parsimonious models----

### now  make a nice plot of the most interesting models-----
library(gridExtra)
library(ggplot2)
library(grid)
detach("package:plyr", unload=TRUE)#will error - don't worry
library(tidyr)
library(dplyr)
options(dplyr.width = Inf) #enables head() to display all coloums
library(mgcv)

rm(list=ls())



# Plotting Theme-
Theme1 <-
  theme( # use theme_get() to see available options
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    # legend.background = element_rect(fill="white"),
    legend.background = element_blank(),
    legend.key = element_blank(), # switch off the rectangle around symbols in the legend
    legend.text = element_text(size=15),
    legend.title = element_blank(),
    legend.position = c(0.2, 0.8),
    text=element_text(size=15),
    strip.text.y = element_text(size = 15,angle = 0, colour="black"),
    axis.title.x=element_text(vjust=0, size=15, colour="black",face="bold"),
    axis.title.y=element_text(vjust=0.6, angle=90, size=15,,face="bold", colour="black"),
    axis.text.x=element_text(size=15, colour="black"),
    axis.text.y=element_text(size=15, colour="black"),
    axis.line.x=element_line(colour="black", size=0.5,linetype='solid'),
    axis.line.y=element_line(colour="black", size=0.5,linetype='solid'),
    strip.background = element_blank())


# Bring in and format the raw data----

# Set work directory----

# work.dir=("~/workspace/Analysis_Miller_WRL") #for ecocloud server
work.dir=("Z://Analysis_Miller_lobster") #for laptop



## Sub directories ----
data.dir<-paste(work.dir,"Data",sep="/")
map.dir<-paste(work.dir,"Map Layers",sep="/")
plots.dir<-paste(work.dir,"Plots",sep="/")
model.dir<-paste(work.dir,"Model_out_catch",sep="/")


# Bring in and format the data----
name<-"catch"

setwd(data.dir)
dir()


dat <-read_csv("sub.legal.sw.sst.csv")%>%
  
  dplyr::rename(response=Count,
                Taxa=sizeclass)%>%
  # #   Transform variables
  mutate(Date=as.factor(yday(Date)))%>% #as julian day
  # mutate(recap.Date=as.factor(yday(recap.Date)))%>% #as julian day
  mutate(Site=as.factor(Site))%>%
  mutate(Location=as.factor(Location))%>%
  # mutate(Taxa="catch")%>%
  # na.omit()%>%
  glimpse()

names(dat)


# Model for legal----
# Hs.m.sw+Location+T1.s.sw
use.dat<-dat%>%
  filter(Taxa=="Legal")%>%
  glimpse()

mod=gam(response~s(Hs.m.sw,k=3,bs='cr')+s(T1.s.sw,k=3,bs='cr')+Location+s(Site,bs='re')+s(Date,bs='re'),family=tw(),data=use.dat)

summary(mod)


# Legal_predict - Location------
testdata <- expand.grid(Hs.m.sw=mean(mod$model$Hs.m.sw),
                        T1.s.sw=mean(mod$model$T1.s.sw),
                        Date=(mod$model$Date),
                        Site=(mod$model$Site),
                        Location = c("Cliff Head","Golden Ridge","Irwin Reef","Seven Mile"))%>%
  distinct()%>%
  glimpse()

fits <- predict.gam(mod, newdata=testdata, type='response', se.fit=T)
#head(fits,2)
predicts.catch.legal = testdata%>%data.frame(fits)%>%
  group_by(Location)%>% #only change here
  summarise(response=mean(fit),se.fit=mean(se.fit))%>%
  ungroup()%>%
  glimpse()


# Plot legal catch - location ----
catch.legal.location<- ggplot(aes(x=Location,y=response,
                              fill=Location,colour=Location), 
                              data=predicts.catch.legal) +
  
  ylab(bquote('Lobster (' *pot^-1*')'))+
  xlab('Location')+
  # scale_fill_manual(labels = c("Fished", "No-take"),values=c("red", "black"))+
  # scale_colour_manual(labels = c("Fished", "No-take"),values=c("red", "black"))+
  # scale_x_discrete(limits = rev(levels(predicts.bds.status$Status)))+
  geom_bar(stat = "identity")+
  geom_errorbar(aes(ymin = response-se.fit,ymax = response+se.fit),width = 0.5) +
  theme_classic()+
  Theme1+
  theme(legend.position = "none")+
  # scale_y_continuous(breaks=seq(0,12,2))+
  ylim(0,12)+
  ggtitle("Legal")
catch.legal.location


# Legal_predict - T1.s.sw------
testdata <- expand.grid(Hs.m.sw=mean(mod$model$Hs.m.sw),
                        T1.s.sw=seq(min(use.dat$T1.s.sw),max(use.dat$T1.s.sw),length.out = 20),
                        Date=(mod$model$Date),
                        Site=(mod$model$Site),
                        Location = c("Cliff Head","Golden Ridge","Irwin Reef","Seven Mile"))%>%
  distinct()%>%
  glimpse()


fits <- predict.gam(mod, newdata=testdata, type='response', se.fit=T)
#head(fits,2)
predicts.catch.legal.period = testdata%>%data.frame(fits)%>%
  group_by(T1.s.sw)%>% #only change here
  summarise(response=mean(fit),se.fit=mean(se.fit))%>%
  ungroup()%>%
  glimpse()


# Plot legal catch - T1.s.sw - Period ----
# PLOTS Bivalve M.striata lobster ----
catch.legal.period<- ggplot() +
  ylab(bquote('Lobster' *pot^-1*''))+
  xlab(bquote('Swell period (' *sec^-1*')'))+
  # scale_color_manual(labels = c("Fished", "SZ"),values=c("red", "black"))+
  # geom_point(data=use.dat,aes(x=lobster,y=response,colour=Status),  alpha=0.75, size=2,show.legend=FALSE)+
  geom_line(data=predicts.catch.legal.period,aes(x=T1.s.sw,y=response),alpha=0.5)+
  geom_line(data=predicts.catch.legal.period,aes(x=T1.s.sw,y=response - se.fit),linetype="dashed",alpha=0.5)+
  geom_line(data=predicts.catch.legal.period,aes(x=T1.s.sw,y=response + se.fit),linetype="dashed",alpha=0.5)+
  theme_classic()+
  Theme1
  # annotate("text", x = -Inf, y=Inf, label = "(d)",vjust = 1, hjust = -.1,size=5)+
  # annotate("text", x = -Inf, y=Inf, label = "   Myadora striata",vjust = 1, hjust = -.1,size=5,fontface="italic")+
  # geom_blank(data=dat.bms,aes(x=lobster,y=response*1.05))#to nudge data off annotations
catch.legal.period





# Model for sub-legal----
# Hs.m.sw+Location+T1.s.sw
use.dat<-dat%>%
  filter(Taxa=="Sublegal")%>%
  glimpse()

mod=gam(response~s(Hs.m.sw,k=3,bs='cr')+s(T1.s.sw,k=3,bs='cr')+Location+s(Site,bs='re')+s(Date,bs='re'),family=tw(),data=use.dat)
summary(mod)


# Sublegal_predict - Location------
testdata <- expand.grid(Hs.m.sw=mean(mod$model$Hs.m.sw),
                        T1.s.sw=mean(mod$model$T1.s.sw),
                        Date=(mod$model$Date),
                        Site=(mod$model$Site),
                        Location = c("Cliff Head","Golden Ridge","Irwin Reef","Seven Mile"))%>%
  distinct()%>%
  glimpse()

fits <- predict.gam(mod, newdata=testdata, type='response', se.fit=T)
#head(fits,2)
predicts.catch.sublegal = testdata%>%data.frame(fits)%>%
  group_by(Location)%>% #only change here
  summarise(response=mean(fit),se.fit=mean(se.fit))%>%
  ungroup()%>%
  glimpse()


# Plot sublegal catch - location ----
catch.sublegal.location<- ggplot(aes(x=Location,y=response,fill=Location,colour=Location), data=predicts.catch.sublegal) +
  ylab(bquote('Lobster (' *pot^-1*')'))+
  xlab('Location')+
  geom_bar(stat = "identity")+
  geom_errorbar(aes(ymin = response-se.fit,ymax = response+se.fit),width = 0.5) +
  theme_classic()+
  Theme1+
  theme(legend.position = "none")+
  #scale_y_continuous(breaks=seq(0,12,2))+
  ylim(0,12)+
  ggtitle(label="Subegal")
catch.sublegal.location



# Save plots----
setwd(plots.dir)
# To see what they will look like use grid.arrange() - make sure Plot window is large enough! - or will error!
grid.arrange(catch.legal.location,catch.sublegal.location,nrow=1,ncol=2)

# Use arrangeGrob ONLY - as we can pass this to ggsave! Note use of raw ggplot's
combine.plot<-arrangeGrob(catch.legal.location,catch.sublegal.location,nrow=1,ncol=2)

# ggsave(combine.plot,file="catch.location.png", width = 40, height = 15,units = "cm")

ggsave(combine.plot,file="catch.location.png", width = 30, height = 10,units = "cm")






