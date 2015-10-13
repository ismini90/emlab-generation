#install.packages(c("pracma","reshape","ggplot2", "plyr", "triangle"))
library(pracma)
library(reshape)
library(ggplot2)
library(plyr)
library(triangle)

############# Parameter settings & input files #######################
#Number of repitions
rep=120
noTimesteps=50

#Boolean values if output shall be written.
writeFuelPriceOutput=T
writeDemandOutput=T

emlabSvn="~/svn/emlab/"
fuelPriceOutputFolder="~/emlab-generation/emlab-generation/src/main/resources/data/stochasticFuelPrices/"
demandOutputFolder="~/emlab-generation/emlab-generation/src/main/resources/data/stochasticDemandNLandDE/"

#Coal and gas volatility
#Sigma taken from Pyndick1998WP, for period 1920-1996
sigma=c(Coal=0.0833,NaturalGas=0.1193)

# Lignite, uranium and demand trends (Top=To be expected, or top of triangle)
coalTop=1.01
coalMin=0.95
coalMax=1.07

gasTop=1.01
gasMin=0.95
gasMax=1.07

ligniteTop=1.00
ligniteMin=0.99
ligniteMax=1.01

uraniumTop=1.00
uraniumMin=0.99
uraniumMax=1.01

biomassTop=1.01
biomassMin=0.95
biomassMax=1.07


#Change name of demand also below in the write table method.
demandNlTop=1.013
demandNlMax=1.054
demandNlMin=0.961

demandDeTop=1.01
demandDeMax=1.04
demandDeMin=0.98


## Other fuels using
Biomass=numeric()
for(rId in seq(1,rep)){
  biomassGrowthRate=rtriangle(noTimesteps,a=biomassMin,b=biomassMax, c=biomassTop)
  biomassPrice=numeric(noTimesteps)
  biomassPrice[1]=4.5
  for(i in seq(2,noTimesteps)){
    biomassPrice[i]=biomassPrice[i-1]*biomassGrowthRate[i]
  }
  if(rId==1){
    Biomass=biomassPrice
  } else{
    Biomass=c(Biomass,biomassPrice)
  }
}

length(Biomass)
length(fuelPriceScenarios$runId)
fuelPriceScenarios =as.data.frame(Biomass)
fuelPriceScenarios=cbind(fuelPriceScenarios,Biomass)

## Other fuels using
Lignite=numeric()
for(rId in seq(1,rep)){
  LigniteGrowthRate=rtriangle(noTimesteps,a=ligniteMin,b=ligniteMax, c=ligniteTop)
  LignitePrice=numeric(noTimesteps)
  LignitePrice[1]=1.427777777
  for(i in seq(2,noTimesteps)){
    LignitePrice[i]=LignitePrice[i-1]*LigniteGrowthRate[i]
  }
  if(rId==1){
    Lignite=LignitePrice
  } else{
    Lignite=c(Lignite,LignitePrice)
  }
}

fuelPriceScenarios=cbind(fuelPriceScenarios,Lignite)

## Other fuels using
Uranium=numeric()
for(rId in seq(1,rep)){
  UraniumGrowthRate=rtriangle(noTimesteps,a=uraniumMin,b=uraniumMax, c=uraniumTop)
  UraniumPrice=numeric(noTimesteps)
  UraniumPrice[1]=1.286
  for(i in seq(2,noTimesteps)){
    UraniumPrice[i]=UraniumPrice[i-1]*UraniumGrowthRate[i]
  }
  if(rId==1){
    Uranium=UraniumPrice
  } else{
    Uranium=c(Uranium,UraniumPrice)
  }
}

fuelPriceScenarios=cbind(fuelPriceScenarios,Uranium)

## demandNL
demandNL=numeric()
for(rId in seq(1,rep)){
  demandNLGrowthRate=rtriangle(noTimesteps,a=demandNlMin,b=demandNlMax, c=demandNlTop)
  demandNLOneRunId=numeric(noTimesteps)
  demandNLOneRunId[1]=1
  for(i in seq(2,noTimesteps)){
    demandNLOneRunId[i]=demandNLOneRunId[i-1]*demandNLGrowthRate[i]
  }
  if(rId==1){
    demandNL=demandNLOneRunId
  } else{
    demandNL=c(demandNL,demandNLOneRunId)
  }
}

fuelPriceScenarios=cbind(fuelPriceScenarios,demandNL)

## demandDE
demandDE=numeric()
for(rId in seq(1,rep)){
  demandDEGrowthRate=rtriangle(noTimesteps,a=demandDeMin,b=demandDeMax, c=demandDeTop)
  demandDEOneRunId=numeric(noTimesteps)
  demandDEOneRunId[1]=1
  for(i in seq(2,noTimesteps)){
    demandDEOneRunId[i]=demandDEOneRunId[i-1]*demandDEGrowthRate[i]
  }
  if(rId==1){
    demandDE=demandDEOneRunId
  } else{
    demandDE=c(demandDE,demandDEOneRunId)
  }
}

fuelPriceScenarios=cbind(fuelPriceScenarios,DemandDE)

fuelPriceScenarios$runId<-as.factor(fuelPriceScenarios$runId)
fuelPriceLong<-melt(fuelPriceScenarios,id=c("YEAR","runId"))

plotSpaghettiTimeSeries <- function(df, ylabel, xlabel="Time [a]", ylim=NULL, basesize=8){
  p<- ggplot(df, aes(x=YEAR, y=value))+
    geom_line(aes(group=runId, colour=runId), alpha=I(0.8))+
    #stat_summary(aes_string(fill="variable"), fun.data="median_hilow", conf.int=.5, geom="smooth") +
    facet_wrap(~ variable,ncol=4)+
    ylab(ylabel)+
    xlab(xlabel)+
    scale_color_discrete()+
    theme_grey(base_size=15)+
    theme(legend.position="none")
  if(!is.null(ylim))
    p<- p + ylim(ylim)
  return(p)
}
a<-plotSpaghettiTimeSeries(fuelPriceLong, "Price [EUR/GJ]")
a

corlist<-dlply(fuelPriceScenarios[-2], .(runId), function(m){return(data.frame(cov(colwise(diff)(m[-1]))))})
corlsqrt(Reduce('+',corlist)/length(corlist))
cor(colwise(diff)(log(ukFuelPrice[4:22,-1])))

cor(log(ukFuelPrice[4:22,-1]))

names(fuelPriceScenarios)

for(runId in seq(1,rep)){
  if(writeFuelPriceOutput){write.table(t(fuelPriceScenarios[fuelPriceScenarios$runId==runId,c(2,3,4,5,6,7,8,9,10,11)]), file=paste(fuelPriceOutputFolder,"fuelPrices-",runId,".csv",sep=""),sep=",",row.names=T, col.names=F, quote=F)}
  if(writeDemandOutput){write.table(t(fuelPriceScenarios[fuelPriceScenarios$runId==runId,c(2,12,13)]), file=paste(demandOutputFolder,"demand-",runId,".csv",sep=""),sep=",",row.names=T, col.names=F, quote=F)}
}


#Joern's Stuff



fuelPriceTrendsLong<-melt(fuelPriceTrends,id=c("Time"))
fuelPriceTrendsLong$Fuel<-rep("",dim(fuelPriceTrendsLong)[1])
fuelPriceTrendsLong$Scenario<-rep("",dim(fuelPriceTrendsLong)[1])
fuelPriceTrendsLong[grepl("Coal",fuelPriceTrendsLong$variable),]$Fuel<-"Coal"
fuelPriceTrendsLong[grepl("Gas",fuelPriceTrendsLong$variable),]$Fuel<-"Gas"
fuelPriceTrendsLong[grepl("Low",fuelPriceTrendsLong$variable),]$Scenario<-"Low"
fuelPriceTrendsLong[grepl("Medium",fuelPriceTrendsLong$variable),]$Scenario<-"Medium"
fuelPriceTrendsLong[grepl("High",fuelPriceTrendsLong$variable),]$Scenario<-"High"
fuelPriceTrendsLong$Scenario<-factor(fuelPriceTrendsLong$Scenario,c("Medium","Low","High"))
fuelPriceTrendPlot<-ggplot(fuelPriceTrendsLong, aes(x=Time, y=value, group=variable))+
  geom_line(data=fuelPriceTrendsLong,aes(linetype=Scenario))+
  geom_point(data=fuelPriceTrendsLong[fuelPriceTrendsLong$Time%%5==0,],aes(shape=Fuel))+
  #stat_summary(aes_string(fill="variable"), fun.data="median_hilow", conf.int=.5, geom="smooth") +
  ylab("Price [EUR/GJ]")+
  xlab("Time [a]")+
  theme_publication(base_size=9)+
  xlim(2011,2050)+
  #scale_linetype_discrete(name="Fuel Price Scenario")+
  scale_linetype_discrete(name="Price Level")+
  scale_shape_discrete(name="Fuel")+
  guides(linetype=guide_legend())+
  ylim(0,13)+
  theme(legend.position="right",legend.margin=unit(-5,"mm"),legend.key.height=unit(2,"mm"),plot.margin=unit(x=c(1,1,1,1),units="mm"))
fuelPriceTrendPlot

## Uhlstein-Uhlenbeck
#Cholesky decomposition of log-returns
#C=chol(cor(colwise(diff)(log(ukFuelPrice[4:22,-1]))))
#sigma=sapply(colwise(diff)(log(ukFuelPrice[4:22,-1])),sd)
C=chol(cor(colwise(diff)(log(ukFuelPrice[4:22,c(2,4)]))))
#sigma=sapply(colwise(diff)(log(ukFuelPrice[4:22,c(2,4)])),sd)
#sigma=sapply(log(ukFuelPrice[4:22,-1]),sd)
#sigma=apply(ukFuelPriceDetrended[,-1],2,sd)

nvars = dim(C)[1]
numobs = 40000
set.seed(1)
random.normal = matrix(rnorm(nvars*numobs,0,1), nrow=nvars, ncol=numobs);
dW = t(C %*% random.normal)
fuelPriceTrend<-data.frame()

for(scenario in c("Medium", "Low", "High")){
  x0=log(ukFuelPrice[22,c(1,2,4)])
  names(x0)<-c("YEAR", paste("Coal.",scenario,sep=""), paste("NaturalGas.",scenario,sep=""))
  x0$YEAR<-ukFuelPrice[22,]$YEAR
  
  if(scenario=="Medium"){fuelPriceTrend<-mediumTrend}
  if(scenario=="Low"){fuelPriceTrend<-lowTrend}
  if(scenario=="High"){fuelPriceTrend<-highTrend}
  
  fuelPriceTrend[1,]
  dt=1
  gamma=1/5
  
  for(rId in seq(0,rep-1)){
    timeSeriesRealization=as.data.frame(x0)
    X=x0
    for(y in seq(1,noTimesteps-1)){
      #dX = gamma*(log(fuelPriceTrend[(y+1),-1])-X[,-1]) + sigma*dW[(rId*40)+y,]
      #X=cbind(fuelPriceTrend[y+1,1],X[,-1]+dX)
      #After Gillespie:
      newX = exp(-gamma*dt)*X[,-1]+(1-exp(-gamma*dt))*log(fuelPriceTrend[(y+1),-1])+sigma*sqrt((1-exp(-2*gamma*dt))/(2*gamma))*dW[(rId*40)+y,]
      X=cbind(fuelPriceTrend[y+1,1],newX)
      names(X)<-c("YEAR",names(X)[-1])
      timeSeriesRealization <- rbind(timeSeriesRealization,X)
    }
    runId=rId
    timeSeriesRealization[,-1]<-exp(timeSeriesRealization[,-1])
    if(rId==0){
      multipleTimeSeriesRealization<-cbind(runId,timeSeriesRealization)
    } else{
      multipleTimeSeriesRealization<-rbind(multipleTimeSeriesRealization,cbind(runId,timeSeriesRealization))
    }     
  }
  if(scenario=="Medium"){
    fuelPriceScenarios<-multipleTimeSeriesRealization
  } else{
    fuelPriceScenarios<-cbind(fuelPriceScenarios,multipleTimeSeriesRealization[,c(3,4)])
  }
}
