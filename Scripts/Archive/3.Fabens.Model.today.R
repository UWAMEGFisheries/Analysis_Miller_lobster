# Explore catch data----
rm(list=ls()) # Clears memory

# Study name----
study<-"Fabens.Simon"

#library----
library(scales)
library(lubridate)
library(tidyr)
library(magrittr)
library(dplyr)
library(googlesheets)
library(stringr)

#For Simon
# setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# getwd()

# Set work directory----

work.dir=("~/GitHub/Analysis_Miller_WRL") #for Tim's github
work.dir=("~/workspace/Analysis_Miller_WRL") #for ecocloud server

## Sub directories ----
data.dir<-paste(work.dir,"Data",sep="/")
map.dir<-paste(work.dir,"Map Layers",sep="/")
plots.dir<-paste(work.dir,"Plots",sep="/")

# Functions----
se <- function(x) sd(x) / sqrt(length(x))
se.min <- function(x) (mean(x)) - se(x)
se.max <- function(x) (mean(x)) + se(x)
sd.min <- function(x) (mean(x)) - sd(x)
sd.max <- function(x) (mean(x)) + sd(x)
scaleFUN <- function(x) sprintf("%.0f", x)

#Import Data
# Bring in from ecocloud----
# dir()
setwd("~/workspace/Analysis_Miller_WRL/Data")

dat.rr<-read_csv("dat.rr.clean.csv")%>%
#dat.rr<-read_csv("dat.rr.all.csv")%>%
glimpse()


#2,235 with all of seven mile data (dat.rr.all)

dat.rr%<>%
  dplyr::rename(rel.date = Date, Date= recap.Date, rlloc= Location.int, Sex=Sex.int, Carapace.length=recap.cl, Total.damage=Total.damage.int, Colour= Colour.int, rlclength=initial.cl, site=mini.site.x)%>%
  select(Date, Tag.number, Carapace.length, Sex, rlloc, Total.damage, rel.date, rlclength)%>%
  glimpse()

dat.rr<-dat.rr%>%
  #mutate(Lyrs=(rel.date-Date)/365, growth=rlclength-Carapace.length)%>%
  mutate(Lyrs=as.numeric(as.Date(Date, '%d/%m/%Y')-as.Date(rel.date, '%d/%m/%Y'))/365,growth=Carapace.length-rlclength)%>%
  mutate(sex=tolower(substr(Sex,1,1))) %>% filter(sex%in% c('f','m'), !is.na(sex)) %>%
  mutate(rcyear=format(as.Date(Date, '%d/%m/%Y'),'%Y'),rlyear=format(as.Date(rel.date, '%d/%m/%Y'),'%Y')) %>%
  mutate(rcmonth=format(as.Date(Date, '%d/%m/%Y'),'%m'),rlmonth=format(as.Date(rel.date, '%d/%m/%Y'),'%m'))%>%
  glimpse()


rec<-dat.rr%>%
  dplyr::mutate(rlmonth = as.integer(rlmonth))%>%
  dplyr::mutate(rcmonth = as.integer(rcmonth))%>%
  dplyr::mutate(rlyear = as.integer(rlyear))%>%
  dplyr::mutate(rcyear = as.integer(rcyear))%>%
  glimpse()

unique(rec$rlloc)


#OR Simon's from googlesheets: however includes individuals caught within same sampling trip
#and missing dates?
# rec1<-gs_title("Lobster_Data_Simon")%>%
#   gs_read_csv("data.w.smb")%>%
#   glimpse()
  

# rec<- gs_title("data.w.smb")%>%
#   gs_read_csv(ws="data.w.smb")%>%
#   glimpse()
# 

# glimpse(rec1)

#For Simon
##Open up link to IBSS and down load latest
# library(TagLoss)
# dat <- read.csv('data.csv')
# dat %<>% filter(!is.na(Tag.number), !is.na(Carapace.length), !is.na(Sex)) %>%
#   mutate(Site=str_replace_all(.$Site,c("Seven Mile Beach"= "Seven Mile","Little Horseshoe"="Horse", "Cliff Head North"="Cliff Head","Cliff Head Mid"= "Cliff Head","Cliff Head South"="Cliff Head","Cliff Head OUT1"= "Horse","CHM"="Cliff Head", "Davids Marks"="Horse","CHM"= "Cliff Head", "CHS"="Cliff Head", "CHN"="Cliff Head", "Jim Bailey"="Irwin Reef", "Rivermouth"="River", "Long Reef"="Irwin Reef", "South Dummy"="Irwin Reef","South Rig"= "White","Whites Lump"= "White","WP"= "White","Whitepoint"="White")))

# rec <- dat %>% filter(!is.na(Recapture))
# rec$rel.date <- dat$Date[match(rec$Tag.number, dat$Tag.number)]
# rec$rlclength <- dat$Carapace.length[match(rec$Tag.number, dat$Tag.number)]
# rec$rlloc <- dat$Site[match(rec$Tag.number, dat$Tag.number)]
# rec %<>% 
# %>%
#   mutate(sex=tolower(substr(Sex,1,1))) %>% filter(sex%in% c('f','m'), !is.na(sex)) %>%
#   mutate(rcyear=format(as.Date(Date, '%d/%m/%Y'),'%Y'),rlyear=format(as.Date(rel.date, '%d/%m/%Y'),'%Y')) %>%
#   mutate(rcmonth=format(as.Date(Date, '%d/%m/%Y'),'%m'),rlmonth=format(as.Date(rel.date, '%d/%m/%Y'),'%m'))
# rec2 <- rec %>% dplyr::select(Date, Tag.number,Carapace.length, Sex,rlloc, Total.damage, rel.date, rlclength)
# smdat %<>% mutate(Date=as.Date(Date,'%Y-%m-%d'), rel.date=as.Date(rel.date,'%Y-%m-%d'))
# rec2 %<>% mutate(Date=as.Date(Date,'%d/%m/%Y'), rel.date=as.Date(rel.date,'%d/%m/%Y'))
# rec2 <- rbind(rec2,smdat)
# rec2 %<>% mutate() %>%
#   mutate(Lyrs=as.numeric(as.Date(Date)-as.Date(rel.date))/365,growth=Carapace.length-rlclength) %>%
#   mutate(sex=tolower(substr(Sex,1,1))) %>% filter(sex%in% c('f','m'), !is.na(sex)) %>%
#   mutate(rcyear=format(as.Date(Date),'%Y'),rlyear=format(as.Date(rel.date),'%Y')) %>%
#   mutate(rcmonth=format(as.Date(Date),'%m'),rlmonth=format(as.Date(rel.date),'%m'))
# head(rec2)
# write.csv(rec2, 'data.w.smb.csv', row.names = F)

#For Simon
# rec <- read.csv('C:/Users/snd/Rock Lobster/Minor stuff/Other people/Ash/data.w.smb.csv')

#Set Fabens model
fab <- function(pin,tmp=tmp,flag='solve',sex='split'){
  pin <- as.numeric(pin)
  if(sex=='split'){Linf <- ifelse(tmp$sex=='f', pin[1],pin[3])
  K <- ifelse(tmp$sex=='f', pin[2],pin[4])
  sd=pin[5]}
  if(sex=='comb'){Linf <- pin[1]
  K <- pin[2]
  sd=pin[3]}
  est = (Linf-tmp$rlclength)*(1-exp(-K*tmp$Lyrs))
  LL <- -sum(dnorm(tmp$growth, est, sd,T))
  if(flag=='print') return(est)
  if(flag=='solve') return(LL)
}

rec %<>% filter(rlloc!='Golden Ridge') %>% mutate(loc=as.numeric(as.factor(rlloc))) %>% 
  mutate(sloc=(as.numeric(as.factor(sex))-1)*3+loc)
tapply(rec$sloc, list(rec$sex,rec$rlloc), mean)

tmp <- rec[rec$Lyrs>0.1 & rec$rlloc!='Golden Ridge' ,] #Filtered to more than 2 months at liberty
tmp <- tmp[!is.na(tmp$Sex),]

head(tmp)
sort(unique(rec$rlloc))
pin <- log(c(1,rep(0.3,6),1))
head(tmp)

fab3 <- function(pin,tmp=tmp,flag='solve',split=T){   ## split by all
  pin <- exp(as.numeric(pin))
  Linf <- pin[1]*100
  K <- pin[2:7][tmp$sloc] 
  sd <- pin[8]
  est <- (Linf-tmp$rlclength)*(1-exp(-K*tmp$Lyrs))
  LL <- -sum(dnorm(tmp$growth, est, sd,T))
  if(flag=='print') return(est)
  if(flag=='solve') return(LL)
}

fab5 <- function(pin,tmp=tmp,flag='solve',split=T){   ## split by sex
  pin <- exp(as.numeric(pin))
  Linf <- pin[1]*100
  K <- pin[2:3][as.numeric(as.factor(tmp$sex))] 
  sd <- pin[4]
  est <- (Linf-tmp$rlclength)*(1-exp(-K*tmp$Lyrs))
  LL <- -sum(dnorm(tmp$growth, est, sd,T))
  if(flag=='print') return(est)
  if(flag=='solve') return(LL)
}

fab4 <- function(pin,tmp=tmp,flag='solve'){  ## no splits
  pin <- exp(as.numeric(pin))
  Linf <- pin[1]*100
  K <- pin[2]
  sd <- pin[3]
  est <- (Linf-tmp$rlclength)*(1-exp(-K*tmp$Lyrs))
  LL <- -sum(dnorm(tmp$growth, est, sd,T))
  if(flag=='print') return(est)
  if(flag=='solve') return(LL)
}

fab2 <- function(pin,tmp=tmp,flag='solve',split=T){  ### splits by loc
  pin <- exp(as.numeric(pin))
  Linf <- pin[1]*100
  if(split){ 
    K <- pin[2:4][tmp$loc] 
    sd <- pin[5]
  }else {
    K <- pin[2]
    sd <- pin[3]}
  est <- (Linf-tmp$rlclength)*(1-exp(-K*tmp$Lyrs))
  LL <- -sum(dnorm(tmp$growth, est, sd,T))
  if(flag=='print') return(est)
  if(flag=='solve') return(LL)
}

(aout.spl <- nlminb(pin, fab3, tmp=tmp, control = list(iter.max=1000, eval.max=1000)))
exp(aout.spl$par)*c(100,1,1,1,1,1,1,1)

(aout.splLoc <- nlminb(log(c(1,0.5,0.5,0.5,1)), fab2, tmp=tmp, control = list(iter.max=1000, eval.max=1000)))
exp(aout.splLoc$par)*c(100,1,1,1,1)

(aout.splSex <- nlminb(log(c(1,0.5,0.5,1)), fab5, tmp=tmp, control = list(iter.max=1000, eval.max=1000)))
exp(aout.splSex$par)*c(100,1,1,1)

# (aout.comb <- nlminb(log(c(1,0.5,1)), fab4, tmp=tmp, control = list(iter.max=1000, eval.max=1000)))
# exp(aout.comb$par)*c(100,1,1)

#all split vs split by location 
LR_test = 1-pchisq(abs(aout.splLoc$objective-aout.spl$objective), 2)
LR_test  ## very much an improvement therefore sexes are different
         ## We should split by sex and keep looking

#all split vs split by sex 
LR_test = 1-pchisq(abs(aout.splSex$objective-aout.spl$objective), 2)
LR_test  ## very much an improvement therefore sexes are different
## We should split by location as well

pars <- exp(aout.spl$par)*c(100,1,1,1,1,1,1,1)

#Plot Residuals----
par(mfrow=c(3,3))

#Seven Mile----
tmp.sm <- rec[rec$Lyrs>0.1 & rec$growth<20 & rec$rlloc=='Seven Mile',]
glimpse(tmpsm)

tmp.sm$est <- fab3(aout.spl$par, tmp=tmp.sm, flag='print',  split=T)
glimpse(tmp.sm)
tmp.sm$resid<-tmp.sm$growth-tmp.sm$est
with(tmp.sm, plot(rlmonth, resid, pch=16, ylab='SM Residual', xlab='Release Month', col=alpha(ifelse(sex=='f',2,4),0.2), bty='l', cex.lab=1.5, cex.axis=1.3, ylim=c(-5, 15)))
abline(h=0, lty=3)
with(tmp.sm,plot(rlclength, resid, pch=16, ylab='SM Residual', xlab='Release CL (mm)', col=alpha(ifelse(sex=='f',2,4),0.2), bty='l', cex.lab=1.5, cex.axis=1.3, ylim=c(-5, 15)))
abline(h=0, lty=3)
with(tmp.sm,plot(Lyrs, resid, pch=16, ylab='SM Residual', xlab='Liberty (years)', col=alpha(ifelse(sex=='f',2,4),0.2), bty='l', cex.lab=1.5, cex.axis=1.3, ylim=c(-5, 15)))
abline(h=0, lty=3)

#Cliff Head----
tmp.ch <- rec[rec$Lyrs>0.1 & rec$growth<20 & rec$rlloc=='Cliff Head',]

tmp.ch$est <- fab3(aout.spl$par, tmp=tmp.ch, flag='print',  split=T)
glimpse(tmp.ch)
tmp.ch$resid<-tmp.ch$growth-tmp.ch$est
with(tmp.ch, plot(rlmonth, resid, pch=16, ylab='CH Residual', xlab='Release Month', col=alpha(ifelse(sex=='f',2,4),0.2), bty='l', cex.lab=1.5, cex.axis=1.3 , ylim=c(-5, 15)))
abline(h=0, lty=3)
with(tmp.ch,plot(rlclength, resid, pch=16, ylab='CH Residual', xlab='Release CL (mm)', col=alpha(ifelse(sex=='f',2,4),0.2), bty='l', cex.lab=1.5, cex.axis=1.3, ylim=c(-5, 15)))
abline(h=0, lty=3)
with(tmp.ch,plot(Lyrs, resid, pch=16, ylab='CH Residual', xlab='Liberty (years)', col=alpha(ifelse(sex=='f',2,4),0.2), bty='l', cex.lab=1.5, cex.axis=1.3, ylim=c(-5, 15)))
abline(h=0, lty=3)

#Irwin Reef----
tmp.ir <- rec[rec$Lyrs>0.1 & rec$growth<20 & rec$rlloc=='Irwin Reef',]

tmp.ir$est <- fab3(aout.spl$par, tmp=tmp.ir, flag='print',  split=T)
glimpse(tmp.ir)
tmp.ir$resid<-tmp.ir$growth-tmp.ir$est
with(tmp.ir, plot(rlmonth, resid, pch=16, ylab='IR Residual', xlab='Release Month', col=alpha(ifelse(sex=='f',2,4),0.2), bty='l', cex.lab=1.5, cex.axis=1.3, ylim=c(-5, 15)))
abline(h=0, lty=3)
with(tmp.ir,plot(rlclength, resid, pch=16, ylab='IR Residual', xlab='Release CL (mm)', col=alpha(ifelse(sex=='f',2,4),0.2), bty='l', cex.lab=1.5, cex.axis=1.3, ylim=c(-5, 15)))
abline(h=0, lty=3)
with(tmp.ir,plot(Lyrs, resid, pch=16, ylab='IR Residual', xlab='Liberty (years)', col=alpha(ifelse(sex=='f',2,4),0.2), bty='l', cex.lab=1.5, cex.axis=1.3, ylim=c(-5, 15)))
abline(h=0, lty=3)

#Dummy plot----

sort(unique(tmp$rlloc))
dum <- data.frame(age=2:15) #Or (age=2:10)
dum$Fch<- pars[1]*(1-exp(-pars[2]*dum$age))
dum$Fir<- pars[1]*(1-exp(-pars[3]*dum$age))
dum$Fsm<- pars[1]*(1-exp(-pars[4]*dum$age))
dum$Mch<- pars[1]*(1-exp(-pars[5]*dum$age))
dum$Mir<- pars[1]*(1-exp(-pars[6]*dum$age))
dum$Msm<- pars[1]*(1-exp(-pars[7]*dum$age))

par(mfrow=c(1,1))
plot(dum$age, dum$Fir, type='l', col="blue",lwd=2, xlab='Relative age (years)', ylab='Carapace length (mm)', ylim=c(20,130), bty='l') #or  ylim=c(20,110)
lines(dum$age, dum$Fch, type='l', col=3, lwd=2)
lines(dum$age, dum$Fsm, type='l', col=6, lwd=2)

#plot(dum$age, dum$Mir, type='l', col='red',lwd=2, lty=2, xlab='Relative age (years)',ylab='', ylim=c(20,140), bty='l') #or  ylim=c(20,110)
lines(dum$age, dum$Mir, type='l', lwd=2, lty=2, col="blue")
lines(dum$age, dum$Mch, type='l', lwd=2, lty=2, col=3)
lines(dum$age, dum$Msm, type='l', lwd=2, lty=2, col=6)

legend("bottomright", title = "Location                      ",
       legend=c("Irwin Reef", "Cliff Head", "Seven Mile", "Female", "Male"), 
       col = c("blue", "3", "6", "black", "black"), 
       lty= c(1,1,1,1,2), lwd=c(2,2,2,2,2), box.lty=0, ncol=2, cex=1.1)

#Plot growth----
# Plotting Themes ----
Theme1 <-
  theme( # use theme_get() to see available options
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(), 
    panel.background = element_blank(),
    text=element_text(size=12),
    strip.text.y = element_text(size = 12,angle = 270),
    axis.title.x=element_text(vjust=0.3, size=12),
    axis.title.y=element_text(vjust=0.6, angle=90, size=12),
    axis.text.x=element_text(size=12,colour="black"),
    axis.text.y=element_text(size=12,colour="black"),
    axis.line.x=element_line(colour="black", size=0.5,linetype='solid'),
    axis.ticks.x=element_line(colour="black", size=0.5,linetype='solid'),
    axis.line.y=element_line(colour="black", size=0.5,linetype='solid'),
    strip.background = element_blank(),
    strip.text.x = element_text(size = 12),
    plot.background = element_blank()) # Brooke added


par(mfrow=c(2,2))
plot(tmp$rlclength, tmp$growth)
plot(tmp$Lyrs, tmp$growth)
library(ggplot2)

cl.plot<- ggplot(tmp, aes(x=rlclength, y=growth, col=rlloc, ,shape=rlloc))+
  geom_point(size=3)+
  scale_color_manual(values = c("Irwin Reef"="plum3","Cliff Head"="darkorange3", "Seven Mile"= "turquoise4"))+
  ylim(-2, 18)+
  theme_bw()+Theme1+
  xlab("Release Carapace Length (mm")+
  ylab("Growth")+
  labs(col="Location" ,shape="Location")+
  facet_wrap(~Sex)
cl.plot

lyrs.plot<- ggplot(tmp, aes(x=Lyrs, y=growth, col=rlloc,shape=rlloc))+#
  geom_point(size=3)+
  #scale_colour_manual(values = c("3", "blue", "red"))+
  scale_color_manual(values = c("Irwin Reef"="plum3","Cliff Head"="darkorange3", "Seven Mile"= "turquoise4"))+
  theme_bw()+Theme1+
  ylim(-2, 18)+
  xlab("Time at liberty (years)")+
  ylab("Growth")+
  labs(col="Location" ,shape="Location")+
  facet_wrap(~Sex)
lyrs.plot

help('labs')

tmp$rlloc<-factor(tmp$rlloc, levels = c("Seven Mile", "Irwin Reef", "Cliff Head"))

box.plot <-ggplot(tmp, aes(x=rlloc, y=growth))+
  geom_boxplot(outlier.color = NA, notch=FALSE)+
  geom_jitter(width = 0.1, height = NULL, alpha=0.35)+
  theme_bw()+Theme1+
  theme(panel.background = element_blank(),
        axis.line = element_line(colour = "black"))+
  stat_summary(fun.y=mean, geom="point", shape=23, size=4)+ #Adds mean
  theme(plot.title = element_text(hjust = 0, size=12, face = "plain"))+
  theme(axis.text.x = element_text(angle=90))+     #Changes angle of site names
  ylab("Growth (mm)")+
  xlab("Location") +
  facet_grid(. ~ Sex)
box.plot



#Female ----
tmp <- rec[rec$Lyrs>0.1 & rec$rlloc!='Golden Ridge' & rec$sex=='f',] #Filtered to more than 2 months at liberty
tmp <- tmp[!is.na(tmp$Sex),]

## Loc split
(fout.spl <- nlminb(log(c(1,0.5,0.5,0.5,1)), fab2, tmp=tmp, control = list(iter.max=1000, eval.max=1000)))
exp(fout.spl$par)*c(100,1,1,1,1)

tmp %<>% mutate(loc=1)
(fout.all <- nlminb(log(c(1,0.5,1)), fab2, tmp=tmp, split=F, control = list(iter.max=1000, eval.max=1000)))
exp(fout.all$par)*c(100,1,1)

LR_test = 1-pchisq(abs(fout.all$objective-fout.spl$objective), 2)
LR_test  ## No improvement - therefore no need to split by klocation - growth is the same for girls

dum <- data.frame(age=2:15) #Or (age=2:10)
dum$ch<- 100*exp(fout.spl$par[1])*(1-exp(-exp(fout.spl$par[2])*dum$age))
dum$ir<- 100*exp(fout.spl$par[1])*(1-exp(-exp(fout.spl$par[3])*dum$age))
dum$sm<- 100*exp(fout.spl$par[1])*(1-exp(-exp(fout.spl$par[4])*dum$age))

par(mfrow=c(1,1))
plot(dum$age, dum$ir, type='l', col='red', xlab='Relative age (years)', ylab='Carapace length (mm)', ylim=c(20,120), bty='l') #or  ylim=c(20,110)
#lines(dum$age, dum$gr, type='l', col='blue')
lines(dum$age, dum$ch, type='l', col=3)
lines(dum$age, dum$sm, type='l', col=6)
legend("bottomright", legend=c("IR", "CH", "SM"), col = c("red", "3", "6"), lty=1, box.lty=0)


#Male ----
tmp <- rec[rec$Lyrs>0.1 & rec$rlloc!='Golden Ridge' & rec$sex=='m',] #Filtered to more than 2 months at liberty
tmp <- tmp[!is.na(tmp$Sex),]

par(mfrow=c(2,1))
plot(tmp$rlclength, tmp$growth, col=tmp$loc, pch=16)
plot(tmp$Lyrs, tmp$growth, col=tmp$loc, pch=16)

## Loc split
(mout.spl <- nlminb(log(c(1,0.5,0.5,0.5,1)), fab2, tmp=tmp, control = list(iter.max=1000, eval.max=1000)))
exp(mout.spl$par)*c(100,1,1,1,1)

tmp %<>% mutate(loc=1)
(mout.all <- nlminb(log(c(1,0.5,1)), fab2, tmp=tmp, split=F, control = list(iter.max=1000, eval.max=1000)))
exp(mout.all$par)*c(100,1,1)

LR_test = 1-pchisq(abs(mout.all$objective-mout.spl$objective), 2)
LR_test  ## very much an improvement sdo differsd by location

#Plot----
dum <- data.frame(age=2:15) #Or (age=2:10)
dum$ch<- 100*exp(mout.spl$par[1])*(1-exp(-exp(mout.spl$par[2])*dum$age))
dum$ir<- 100*exp(mout.spl$par[1])*(1-exp(-exp(mout.spl$par[3])*dum$age))
dum$sm<- 100*exp(mout.spl$par[1])*(1-exp(-exp(mout.spl$par[4])*dum$age))

par(mfrow=c(1,1))
plot(dum$age, dum$ir, type='l', col='red', xlab='Relative age (years)', ylab='Carapace length (mm)', ylim=c(20,120), bty='l') #or  ylim=c(20,110)
lines(dum$age, dum$ch, type='l', col=3)
lines(dum$age, dum$sm, type='l', col=6)
legend("bottomright", legend=c("IR", "CH", "SM"), col = c("red", "3", "6"), lty=1, box.lty=0)


### Now test locations for Males----

# fab2 <- function(pin,tmp=tmp,flag='solve',loc='split',loc1){
#   pin <- as.numeric(pin)
#   if(loc=='split'){Linf <- ifelse(tmp$rlloc==loc1, pin[1],pin[3])
#   K <- ifelse(tmp$rlloc==loc1, pin[2],pin[4])
#   sd=pin[5]}
#   if(loc=='comb'){Linf <- pin[1]
#   K <- pin[2]
#   sd=pin[3]}
#   est = (Linf-tmp$rlclength)*(1-exp(-K*tmp$Lyrs))
#   LL <- -sum(dnorm(tmp$growth, est, sd,T))
#   if(flag=='print') return(est)
#   if(flag=='solve') return(LL)
# }
# 
# pin <- log(c(1,rep(0.5,3),1))

fab2 <- function(pin,tmp=tmp,flag='solve',split=T){  ### splits by loc
  pin <- exp(as.numeric(pin))
  Linf <- pin[1]*100
  if(split){ 
    K <- pin[2:4][tmp$loc] 
    sd <- pin[5]
  }else {
    K <- pin[2]
    sd <- pin[3]}
  est <- (Linf-tmp$rlclength)*(1-exp(-K*tmp$Lyrs))
  LL <- -sum(dnorm(tmp$growth, est, sd,T))
  if(flag=='print') return(est)
  if(flag=='solve') return(LL)
}


#Cloff Head & Irwin Reef----
## Locations split
tmp <- rec[rec$Lyrs>0.1 & rec$rlloc%in%c('Cliff Head',"Irwin Reef")& rec$sex=='m',]
tmp <- tmp[!is.na(tmp$Sex),]
glimpse(tmp)
(sout.ch_ir <- nlminb(log(c(1,0.5,0.5,0.5,1)), fab2, tmp=tmp, split=T))
exp(mout.spl$par)*c(100,1,1,1,1)

## Locations combined
glimpse(tmp)
(bout.ch_ir <- nlminb(log(c(1,0.5,0.5,0.5,1)), fab2, tmp=tmp, split=F))
exp(mout.spl$par)*c(100,1,1,1,1)
##Test whether we need two lots of parameters
LR_test = 1-pchisq(abs(bout.ch_ir$objective-sout.ch_ir$objective), 2)
LR_test  ## very much an improvement
#0.01779759

#Cliff Head & Seven Mile
## Locations split
tmp <- rec[rec$Lyrs>0.1 & rec$rlloc%in%c('Cliff Head',"Seven Mile")& rec$sex=='m',]
tmp <- tmp[!is.na(tmp$Sex),]
glimpse(tmp)
(sout.ch_sm <- nlminb(log(c(1,0.5,0.5,0.5,1)), fab2, tmp=tmp, split=T))
exp(mout.spl$par)*c(100,1,1,1,1)

## Locations combined
glimpse(tmp)
(bout.ch_sm <- nlminb(log(c(1,0.5,0.5,0.5,1)), fab2, tmp=tmp, split=F))
exp(mout.spl$par)*c(100,1,1,1,1)
##Test whether we need two lots of parameters
LR_test = 1-pchisq(abs(bout.ch_sm$objective-sout.ch_sm$objective), 2)
LR_test  ## very much an improvement
#0.8658872

#Irwin Reef & Seven Mile
## Locations split
tmp <- rec[rec$Lyrs>0.1 & rec$rlloc%in%c('Irwin Reef',"Seven Mile")& rec$sex=='m',]
tmp <- tmp[!is.na(tmp$Sex),]
glimpse(tmp)
(sout.ir_sm <- nlminb(log(c(1,0.5,0.5,0.5,1)), fab2, tmp=tmp, split=T))
exp(mout.spl$par)*c(100,1,1,1,1)

## Locations combined
glimpse(tmp)
(bout.ir_sm <- nlminb(log(c(1,0.5,0.5,0.5,1)), fab2, tmp=tmp, split=F))
exp(mout.spl$par)*c(100,1,1,1,1)
##Test whether we need two lots of parameters
LR_test = 1-pchisq(abs(bout.ir_sm$objective-sout.ir_sm$objective), 2)
LR_test  ## very much an improvement
#0.2091085







## Locations combined
(bout.ir_sm <- nlminb(c(120,0.5,1), fab2, tmp=tmp, loc='comb', loc1='Irwin Reef'))

##Test whether we need two lots of parameters
LR_test = 1-pchisq(abs(bout.ir_sm$objective-sout.ir_sm$objective), 2)
LR_test  ## very much an improvement
#0.01166341




# tmp <- data.frame(tmp)
# tmp$est <- fab2(fout$par,tmp=tmp,flag='print')
# head(tmp)
# tmp$resid <- tmp$growth-tmp$est
# par(mfrow=c(2,3),mar=c(5,5,2,2),las=1)
# with(tmp,plot(rlmonth, resid, pch=16, ylab='IR Residual', xlab='Release Month', col=alpha(as.numeric(as.factor(tmp$rlloc)),0.2), bty='l'))
# abline(h=0, lty=3)
# with(tmp,plot(rlclength, resid, pch=16, ylab='IR Residual', xlab='Release Carapace Length (mm)', col=alpha(as.numeric(as.factor(tmp$rlloc)),0.2), bty='l'))
# abline(h=0, lty=3)
# with(tmp,plot(Lyrs, resid, pch=16, ylab='IR Residual', xlab='Liberty (years)', col=alpha(as.numeric(as.factor(tmp$rlloc)),0.2), bty='l'))
# abline(h=0, lty=3)

# ## Golden Ridge
# tmp <- rec[rec$Lyrs>0.2 & rec$rlloc=='Golden Ridge',]
# tmp <- tmp[!is.na(tmp$Sex),]
# (sout.gr <- nlminb(c(120,0.5,120,0.5,1), fab, tmp=tmp))
# ## Sexes combined
# (bout.gr <- nlminb(c(120,0.5,1), fab, tmp=tmp, sex='comb'))
# ##Test whether we need two lots of parameters
# LR_test = 1-pchisq(abs(bout.gr$objective-sout.gr$objective), 2)
# LR_test  ## very much an improvement
# tmp$est <- fab(bout.gr$par,tmp=tmp,flag='print',sex='comb')
# tmp$resid <- tmp$growth-tmp$est
# with(tmp,plot(rlmonth, resid, pch=16, ylab='GR Residual', xlab='Release Month', col=alpha(ifelse(sex=='f',2,4),0.2), bty='l'))
# abline(h=0, lty=3)
# with(tmp,plot(rlclength, resid, pch=16, ylab='GR Residual', xlab='Release Carapace Length (mm)', col=alpha(ifelse(sex=='f',2,4),0.2), bty='l'))
# abline(h=0, lty=3)
# with(tmp,plot(Lyrs, resid, pch=16, ylab='GR Residual', xlab='Liberty (years)', col=alpha(ifelse(sex=='f',2,4),0.2), bty='l'))
# abline(h=0, lty=3)


## Cliff Head----

# tmp <- rec[rec$Lyrs>0.2 & rec$growth<20 & rec$rlloc=='Cliff Head',] # rec[rec$Lyrs>0.2 & rec$rlloc=='Cliff Head'  ,] # & rec$rlmonth!=12
# tmp <- tmp[!is.na(tmp$Sex),]
# glimpse(tmp)
# par(mfrow=c(2,1))
# plot(tmp$rlclength, tmp$growth, col=as.numeric(as.factor(tmp$sex)), pch=16)
# plot(tmp$Lyrs, tmp$growth, col=as.numeric(as.factor(tmp$sex)), pch=16)

#104
#356 without filtering liberty

#par(mfrow=c(2,2))
#plot(tmp$rlclength, tmp$growth)
#plot(tmp$Lyrs, tmp$growth)
# (sout.ch <- nlminb(c(120,0.5,120,0.5,1), fab, tmp=tmp, control = list(iter.max=1000, eval.max=1000)))
# ## Sexes combined
# (bout.ch <- nlminb(c(120,0.5,1), fab, tmp=tmp, sex='comb'))
# LR_test = 1-pchisq(abs(bout.ch$objective-sout.ch$objective), 2)
# LR_test  ## very much an improvement
# #0.1365168
# 
# 
# tmp$est <- fab(bout.ch$par,tmp=tmp,flag='print',sex='comb')
# tmp$resid <- tmp$growth-tmp$est
# with(tmp,plot(rlmonth, resid, pch=16, ylab='CH Residual', xlab='Release Month', col=alpha(ifelse(sex=='f',2,4),0.2), bty='l'))
# abline(h=0, lty=3)
# with(tmp,plot(rlclength, resid, pch=16, ylab='CH Residual', xlab='Release Carapace Length (mm)', col=alpha(ifelse(sex=='f',2,4),0.2), bty='l'))
# abline(h=0, lty=3)
# with(tmp,plot(Lyrs, resid, pch=16, ylab='CH Residual', xlab='Liberty (years)', col=alpha(ifelse(sex=='f',2,4),0.2), bty='l'))
# abline(h=0, lty=3)
# 
# ## Seven Mile Beach-----
# tmp <- rec[rec$Lyrs>0.2&rec$Lyrs<1.5& rec$rlmonth%in%5:11& rec$rlloc=='Seven Mile'&rec$growth<15,] # & #& rec$rlmonth%in%5:11 or rec$Lyrs<1.3
# tmp <- tmp[!is.na(tmp$Sex),]
# par(mfrow=c(2,1))
# plot(tmp$rlclength, tmp$growth, col=as.numeric(as.factor(tmp$sex)), pch=16)
# plot(tmp$Lyrs, tmp$growth, col=as.numeric(as.factor(tmp$sex)), pch=16)
# glimpse(tmp)
# #122
# #313 wihtout filtering liberty
# #358 including Jan-April
# 
# #Sexes split
# summary(tmp)
# #(sout.sm <- nlminb(c(120,0.2,120,0.2,1), fab, tmp=tmp, control = list(iter.max=1000, eval.max=1000)))
# (sout.sm <- nlminb(c(120,0.5,120,0.5,1), fab, tmp=tmp, control = list(iter.max=1000, eval.max=1000)))
# 
# summary(sout.sm)
# #(sout.sm <- nlminb(c(120,-5,120,-5,2), fab, tmp=tmp, control = list(iter.max=1000, eval.max=1000)))
# #(sout.sm <- optim(c(120,0.5,120,0.5,1), fab, tmp=tmp))
# 
# ## Sexes combined
# (bout.sm <- nlminb(c(120,0.5,1), fab, tmp=tmp, sex='comb'))
# LR_test = 1-pchisq(abs(bout.sm$objective-sout.sm$objective), 2)
# LR_test  ## very much an improvement
# #0.4522249
# #or 0.01842719 with jan-April
# 
# tmp$est <- fab(bout.sm$par,tmp=tmp,flag='print',sex='comb')
# tmp$resid <- tmp$growth-tmp$est
# with(tmp,plot(rlmonth, resid, pch=16, ylab='SM Residual', xlab='Release Month', col=alpha(ifelse(sex=='f',2,4),0.2), bty='l'))
# abline(h=0, lty=3)
# with(tmp,plot(rlclength, resid, pch=16, ylab='SM Residual', xlab='Release Carapace Length (mm)', col=alpha(ifelse(sex=='f',2,4),0.2), bty='l'))
# abline(h=0, lty=3)
# with(tmp,plot(Lyrs, resid, pch=16, ylab='SM Residual', xlab='Liberty (years)', col=alpha(ifelse(sex=='f',2,4),0.2), bty='l'))
# abline(h=0, lty=3)
# 
# 
# #Dummy Variable----
# #original dum$location line creates negative values
# 
# dum <- data.frame(age=2:15) #Or (age=2:10)
# 
# dum$ir<- bout.ir$par[1]*(1-exp(-bout.ir$par[2]*dum$age))
# #dum$ir<- bout.ir$par[1]*(1-exp(bout.ir$par[2]*dum$age))
# dum$ch<- bout.ch$par[1]*(1-exp(-bout.ch$par[2]*dum$age))
# #dum$ch<- bout.ch$par[1]*(1-exp(bout.ch$par[2]*dum$age))
# dum$sm<- bout.sm$par[1]*(1-exp(-bout.sm$par[2]*dum$age))
# #dum$sm<- bout.sm$par[1]*(1-exp(bout.sm$par[2]*dum$age))
# 
# glimpse(dum)
# 
# par(mfrow=c(1,1))
# plot(dum$age, dum$ir, type='l', col='red', xlab='Relative age (years)', ylab='Carapace length (mm)', ylim=c(20,120), bty='l') #or  ylim=c(20,110)
# #lines(dum$age, dum$gr, type='l', col='blue')
# lines(dum$age, dum$ch, type='l', col=3)
# lines(dum$age, dum$sm, type='l', col=6)
# legend("bottomright", legend=c("IR", "CH", "SM"), col = c("red", "3", "6"), lty=1, box.lty=0)
# 

### Now test locations

fab2 <- function(pin,tmp=tmp,flag='solve',loc='split',loc1){
  pin <- as.numeric(pin)
  if(loc=='split'){Linf <- ifelse(tmp$rlloc==loc1, pin[1],pin[3])
  K <- ifelse(tmp$rlloc==loc1, pin[2],pin[4])
  sd=pin[5]}
  if(loc=='comb'){Linf <- pin[1]
  K <- pin[2]
  sd=pin[3]}
  est = (Linf-tmp$rlclength)*(1-exp(-K*tmp$Lyrs))
  LL <- -sum(dnorm(tmp$growth, est, sd,T))
  if(flag=='print') return(est)
  if(flag=='solve') return(LL)
}

pin <- c(120,0.5,125,0.55,1)


#Cloff Head & Irwin Reef----
## Locations split
tmp <- rec[rec$Lyrs>0.2 & rec$rlloc%in%c('Cliff Head',"Irwin Reef"),]
tmp <- tmp[!is.na(tmp$Sex),]
(sout.ch_ir <- nlminb(c(120,0.5,120,0.5,1), fab2, tmp=tmp, loc1='Cliff Head'))

## Locations combined
(bout.ch_ir <- nlminb(c(120,0.5,1), fab2, tmp=tmp, loc='comb', loc1='Cliff Head'))
##Test whether we need two lots of parameters
LR_test = 1-pchisq(abs(bout.ch_ir$objective-sout.ch_ir$objective), 2)
LR_test  ## very much an improvement
#0.2970663

#Cliff Head & Seven Mile
## Locations split
tmp <- rec[rec$Lyrs>0.2 & rec$rlloc%in%c('Cliff Head',"Seven Mile"),] # & rec$Lyrs<1.3 & rec$rlmonth%in%5:11,
tmp <- tmp[!is.na(tmp$Sex),]
(sout.ch_sm <- nlminb(c(120,0.5,120,0.5,1), fab2, tmp=tmp, loc1='Cliff Head'))
## Locations combined
(bout.ch_sm <- nlminb(c(120,0.5,1), fab2, tmp=tmp, loc='comb', loc1='Cliff Head'))
##Test whether we need two lots of parameters
LR_test = 1-pchisq(abs(bout.ch_sm$objective-sout.ch_sm$objective), 2)
LR_test  ## very much an improvement
#0.6914948

#Irwin Reef & Seven Mile
## Locations split
tmp <- rec[rec$Lyrs>0.2 & rec$rlloc%in%c('Irwin Reef',"Seven Mile") ,] #& rec$Lyrs<1.3 & rec$rlmonth%in%5:11
table(tmp$rlloc)
tmp <- tmp[!is.na(tmp$Sex),]
(sout.ir_sm <- nlminb(c(120,0.5,120,0.5,1), fab2, tmp=tmp, loc1='Irwin Reef'))

## Locations combined
(bout.ir_sm <- nlminb(c(120,0.5,1), fab2, tmp=tmp, loc='comb', loc1='Irwin Reef'))

##Test whether we need two lots of parameters
LR_test = 1-pchisq(abs(bout.ir_sm$objective-sout.ir_sm$objective), 2)
LR_test  ## very much an improvement
#0.01166341

#Irwin Reef
tmp <- rec[rec$Lyrs>0.2 & rec$rlloc%in%c('Irwin Reef')  ,] #& rec$Lyrs<1.3 & rec$rlmonth%in%5:11
tmp <- tmp[!is.na(tmp$Sex),]

## Bootsstrap to get better error estimates
bstrap <- 1000
ages <- seq(2,10,0.1)
bsout <- matrix(NA,ncol=3,nrow=bstrap)
bsout2 <- array(NA,dim=c(bstrap, length(ages),1))
for (i in 1:bstrap){
  tmp2 <- tmp[sample(1:nrow(tmp),nrow(tmp),T),]
  sout <- nlminb(c(120,0.5,1), fab, tmp=tmp2, sex='comb')
  bsout[i,]<- sout$par
  bsout2[i,,1] <- sout$par[1]*(1-exp(-sout$par[2]*ages))
}

ir.par_out <- apply(bsout, 2, quantile,probs=c(0.125,0.5,0.875))
ir.est_out <- apply(bsout2, c(2,3), quantile,probs=c(0.125,0.5,0.875))
lines(ages, ir.est_out[2,,],col=2, lty=3)

tmp <- rec[rec$Lyrs>0.2 & rec$rlloc%in%c('Cliff Head') &  rec$growth<20,]#rec$Lyrs<1.3 & rec$rlmonth%in%5:12 &
tmp <- tmp[!is.na(tmp$Sex),]

## Bootsstrap to get better error estimates
bstrap <- 1000
ages <- seq(2,10,0.1)
bsout <- matrix(NA,ncol=3,nrow=bstrap)
bsout2 <- array(NA,dim=c(bstrap, length(ages),1))

for (i in 1:bstrap){
  tmp2 <- tmp[sample(1:nrow(tmp),nrow(tmp),T),]
  sout <- nlminb(c(120,0.5,1), fab, tmp=tmp2, sex='comb')
  bsout[i,]<- sout$par
  bsout2[i,,1] <- sout$par[1]*(1-exp(-sout$par[2]*ages))
}


ch.par_out <- apply(bsout, 2, quantile,probs=c(0.125,0.5,0.875))
ch.est_out <- apply(bsout2, c(2,3), quantile,probs=c(0.125,0.5,0.875))
lines(ages, ch.est_out[2,,],col=3, lty=3)
tmp <- rec[rec$Lyrs>0.2 & rec$rlloc%in%c('Seven Mile') ,] # & rec$Lyrs<1.3 & rec$rlmonth%in%5:11
tmp <- tmp[!is.na(tmp$Sex),]

## Bootsstrap to get better error estimates
bstrap <- 1000
ages <- seq(2,10,0.1)
bsout <- matrix(NA,ncol=3,nrow=bstrap)
bsout2 <- array(NA,dim=c(bstrap, length(ages),1))

for (i in 1:bstrap){
  tmp2 <- tmp[sample(1:nrow(tmp),nrow(tmp),T),]
  sout <- nlminb(c(120,0.5,1), fab, tmp=tmp2, sex='comb')
  bsout[i,]<- sout$par
  bsout2[i,,1] <- sout$par[1]*(1-exp(-sout$par[2]*ages))
}



sm.par_out <- apply(bsout, 2, quantile,probs=c(0.125,0.5,0.875))
sm.est_out <- apply(bsout2, c(2,3), quantile,probs=c(0.125,0.5,0.875))

lines(ages, sm.est_out[2,,],col=6, lty=3)
library(scales)
par(las=1, mfrow=c(1,1))
plot(ages, ch.est_out['50%',,], col=3, lwd=2, xlab='Approximate age (years)',ylab='Carapace length (mm)',axes=F, type='l', ylim=c(20, 100), xlim=c(2,10))
axis(1)
axis(2)

#polygon(c(ages,rev(ages)), c(ch.est_out[1,,],rev(ch.est_out[3,,])),col=rgb(0,0,1,0.3),border=F)

arrows(ages,ch.est_out[1,,],y1=ch.est_out[3,,],code=3,angle=90,length=0.02, col=rgb(0,1,0,0.3))
lines(ages, sm.est_out['50%',,1], col=6, lwd=2)
#polygon(c(ages,rev(ages)), c(sm.est_out[1,,1],rev(sm.est_out[3,,1])),col=rgb(1,0,0,0.3),border=F)
arrows(ages,sm.est_out[1,,],y1=sm.est_out[3,,],code=3,angle=90,length=0.02, col=scales::alpha('purple',0.3))
lines(ages, ir.est_out['50%',,1], col=2, lwd=2)
#polygon(c(ages,rev(ages)), c(ir.est_out[1,,1],rev(ir.est_out[3,,1])),col=rgb(0,1,0,0.3),border=F)
arrows(ages,ir.est_out[1,,],y1=ir.est_out[3,,],code=3,angle=90,length=0.02, col=rgb(1,0,0,0.3))
legend("bottomright", legend=c("CH", "IR", "SM"), col = c(3, 2, 'purple'), lty=1, box.lty=0, lwd=2)

