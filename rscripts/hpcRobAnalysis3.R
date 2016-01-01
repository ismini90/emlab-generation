setwd("~/emlab-generation/rscripts")
source("rConfig.R")
source("batchRunAnalysis.R")

library(gridExtra)
library(TeachingDemos)
library(grid)
library(ggplot2)
library(reshape2)
library(plotrix)

#Axis sizes for plotting
xTitle=16
xAxis=16
yTitle=16
yAxis=16

#Read initial csv files
tickDF <- read.csv("/home/rob/emlabGen/analysis/39ticks.csv")
# segmentDF <- read.csv("/home/rob/emlabGen/output/nameFile/nameFile-SegmentClearingPoints.csv")
targetDF <- read.csv("/home/rob/emlabGen/analysis/R2_policyGoalNREAP_NL_DE_2050.csv")

#File and folder initiation
nameFile <- "TechSpecFullInOneCountry"
analysisFolder <- "/home/rob/emlabGen/output/"
analysisFolder <- paste(analysisFolder, nameFile, "/", sep="")
analysisFolder
setwd(analysisFolder)
analysisFile <- paste(nameFile, ".csv", sep="")
analysisFile
scaleFactor <- 1
filePrefix <- nameFile

#Read scenario output csv-file
bigDF <- read.csv(analysisFile)
tick <- bigDF$tick

#Clean csv-file
library(stringr)
#bigDF$runId <- str_replace(bigDF$runId,"\\..*","")
#bigDF$runNumber <- bigDF$runId
# Some colnames start with "X.", get rid of this 
colnames(bigDF) = gsub("X\\.", "", colnames(bigDF))
# Get rid of periods at the start and end of the names
colnames(bigDF) = gsub("^\\.|\\.$", "", colnames(bigDF))
# Convert all periods into underscores
colnames(bigDF) = gsub("\\.", "_", colnames(bigDF))
#summary(bigDF)

##Costs, Cash, Profits and Welfare
meanConsumerCostsA=0
meanProducerCostsA=0
meanGovernmentCostsA=0
meanProducerProfitsA=0
meanConsumerCostsB=0
meanProducerCostsB=0
meanGovernmentCostsB=0
meanAggProfit=0
meanAggProfitA=0
meanAggProfitB=0
meanProducerCashA=0
meanProducerCashB=0
seAggProfitA=0
seAggProfitB=0
seConsumerCostsA=0
seProducerCostsA=0
seGovernmentCostsA=0
seProducerProfitsA=0
seConsumerCostsB=0
seProducerCostsB=0
seGovernmentCostsB=0


for(j in 0:39) {
  meanAggProfit[j] <- mean(subset(bigDF$CountryAProdFinances_Profit + bigDF$CountryBProdFinances_Profit, tick == j))
  meanAggProfitA[j] <- mean(subset(bigDF$CountryAProdFinances_Profit, tick == j))
  meanAggProfitB[j] <- mean(subset(bigDF$CountryBProdFinances_Profit, tick == j))
  meanConsumerCostsA[j] <- mean(subset(bigDF$ConsumerExpenditure_Country_A_electricity_spot_market, tick == j))
  meanProducerCostsA[j] <- mean(subset(bigDF$CountryAProdCosts_Fixed_O_M + 
                                         bigDF$CountryAProdCosts_Loan + 
                                         bigDF$CountryAProdCosts_Commodity + 
                                         bigDF$CountryAProdCosts_Downpayment, tick == j))
  meanGovernmentCostsA[j] <- mean(subset(bigDF$CountryAProdFinances_Tender_Subsidy, tick == j))
  meanProducerCashA[j] <- mean(subset(bigDF$ProducerCash_Energy_Producer_A +
                                        bigDF$ProducerCash_Energy_Producer_B +
                                        bigDF$ProducerCash_Energy_Producer_C +
                                        bigDF$ProducerCash_Energy_Producer_D, tick == j))
  
  meanConsumerCostsB[j] <- mean(subset(bigDF$ConsumerExpenditure_Country_B_electricity_spot_market, tick == j))
  meanProducerCostsB[j] <- mean(subset(bigDF$CountryBProdCosts_Fixed_O_M + 
                                         bigDF$CountryBProdCosts_Loan + 
                                         bigDF$CountryBProdCosts_Commodity + 
                                         bigDF$CountryBProdCosts_Downpayment, tick == j))
  meanGovernmentCostsB[j] <- mean(subset(bigDF$CountryBProdFinances_Tender_Subsidy, tick == j))
  meanProducerCashB[j] <- mean(subset(bigDF$ProducerCash_Energy_Producer_E +
                                        bigDF$ProducerCash_Energy_Producer_F +
                                        bigDF$ProducerCash_Energy_Producer_G +
                                        bigDF$ProducerCash_Energy_Producer_H +
                                        bigDF$ProducerCash_Energy_Producer_I, tick == j))
  
  seAggProfitA[j] <- std.error(subset(bigDF$CountryAProdFinances_Profit, tick == j))
  seAggProfitB[j] <- std.error(subset(bigDF$CountryBProdFinances_Profit, tick == j))
  seConsumerCostsA[j] <- std.error(subset(bigDF$ConsumerExpenditure_Country_A_electricity_spot_market, tick == j))
  seProducerCostsA[j] <- std.error(subset(bigDF$CountryAProdCosts_Fixed_O_M + 
                                            bigDF$CountryAProdCosts_Loan + 
                                            bigDF$CountryAProdCosts_Commodity + 
                                            bigDF$CountryAProdCosts_Downpayment, tick == j))
  seGovernmentCostsA[j] <- std.error(subset(bigDF$CountryAProdFinances_Tender_Subsidy, tick == j))
  
  seConsumerCostsB[j] <- std.error(subset(bigDF$ConsumerExpenditure_Country_B_electricity_spot_market, tick == j))
  seProducerCostsB[j] <- std.error(subset(bigDF$CountryBProdCosts_Fixed_O_M + 
                                            bigDF$CountryBProdCosts_Loan + 
                                            bigDF$CountryBProdCosts_Commodity + 
                                            bigDF$CountryBProdCosts_Downpayment, tick == j))
  seGovernmentCostsB[j] <- std.error(subset(bigDF$CountryBProdFinances_Tender_Subsidy, tick == j))
  
}

meanConsumerCostsA
meanProducerCostsA
meanGovernmentCostsA
meanConsumerCostsB
meanProducerCostsB
meanGovernmentCostsB
meanProducerCashA
meanProducerCashB
meanAggProfit
meanAggProfitA
meanAggProfitB
seAggProfitA
seAggProfitB
seConsumerCostsA
seProducerCostsA
seGovernmentCostsA
seProducerProfitsA
seConsumerCostsB
seProducerCostsB
seGovernmentCostsB

consCostsAplot = ggplot(data=tickDF, aes(x=X0, y=meanConsumerCostsA)) + 
  # geom_errorbar(aes(ymin=meanAggProfitA-seConsumerCostsA, ymax=meanAggProfitA+seConsumerCostsA, width=1)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Consumer expenditures \n Country A") +  
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis),  
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(consCostsAplot)
ggsave(filename = paste(filePrefix, "consumerCostsAplot", sep=""),scale=1)

consCostsBplot = ggplot(data=tickDF, aes(x=X0, y=meanConsumerCostsB)) + 
  # geom_errorbar(aes(ymin=meanAggProfitA-seConsumerCostsA, ymax=meanAggProfitA+seConsumerCostsA, width=1)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Consumer expenditures \n Country B") +  
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis),
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(consCostsBplot)
ggsave(filename = paste(filePrefix, "consumerCostsBplot", sep=""),scale=1)

profitsAplot = ggplot(data=tickDF, aes(x=X0, y=meanAggProfitA)) + 
  geom_errorbar(aes(ymin=meanAggProfitA-seAggProfitA, ymax=meanAggProfitA+seAggProfitA, width=1)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Profits \n Country A") +   
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(profitsAplot)
ggsave(filename = paste(filePrefix, "profitsAplot.pdf", sep=""),scale=1)

profitsBplot = ggplot(data=tickDF, aes(x=X0, y=meanAggProfitB)) + 
  geom_errorbar(aes(ymin=meanAggProfitB-seAggProfitB, ymax=meanAggProfitB+seAggProfitB, width=1)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Profits \n Country B") +   
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis),
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(profitsBplot)
ggsave(filename = paste(filePrefix, "profitsBplot.pdf", sep=""),scale=1)

revenuesAplot = ggplot(data=bigDF, aes(x=tick, y=CountryAProdFinances_Total_Revenue)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Revenues \n Country A") +   
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(revenuesAplot)
ggsave(filename = paste(filePrefix, "revenuesAplot.pdf", sep=""),scale=1)

totalAcosts = ggplot(data=bigDF, aes(x=tick, y=TotalCostsA)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Total costs \n Country A") +    
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis),
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(totalAcosts)
ggsave(filename = paste(filePrefix, "totalCostsAplot.pdf", sep=""),scale=1)

revenuesBplot = ggplot(data=bigDF, aes(x=tick, y=CountryBProdFinances_Total_Revenue)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Revenues \n Country B") +  
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(revenuesBplot)
ggsave(filename = paste(filePrefix, "revenuesBplot.pdf", sep=""),scale=1)

totalBcosts = ggplot(data=bigDF, aes(x=tick, y=TotalCostsB)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Total costs \n Country B") +  
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis),   
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(totalBcosts)
ggsave(filename = paste(filePrefix, "totalCostsBplot.pdf", sep=""),scale=1)

## Costs breakdown
meanFixedOMCostsA=0
meanLoanCostsA=0
meanCommodityCostsA=0
meanDownpaymentsCostsA=0
meanFixedOMCostsB=0
meanLoanCostsB=0
meanCommodityCostsB=0
meanDownpaymentsCostsB=0
seFixedOMCostsA=0
seLoanCostsA=0
seCommodityCostsA=0
seDownpaymentsCostsA=0
seFixedOMCostsB=0
seLoanCostsB=0
seCommodityCostsB=0
seDownpaymentsCostsB=0

for(j in 0:39) {
  meanFixedOMCostsA[j] <- mean(subset(bigDF$CountryAProdCosts_Fixed_O_M, tick == j)) 
  meanLoanCostsA[j] <- mean(subset(bigDF$CountryAProdCosts_Loan, tick == j))
  meanCommodityCostsA[j] <- mean(subset(bigDF$CountryAProdCosts_Commodity, tick == j)) 
  meanDownpaymentsCostsA[j] <- mean(subset(bigDF$CountryAProdCosts_Downpayment, tick == j))
  seFixedOMCostsA[j] <- std.error(subset(bigDF$CountryAProdCosts_Fixed_O_M, tick == j))  
  seLoanCostsA[j] <- std.error(subset(bigDF$CountryAProdCosts_Loan, tick == j)) 
  seCommodityCostsA[j] <- std.error(subset(bigDF$CountryAProdCosts_Commodity, tick == j)) 
  seDownpaymentsCostsA[j] <- std.error(subset(bigDF$CountryAProdCosts_Downpayment, tick == j))
  meanFixedOMCostsB[j] <- mean(subset(bigDF$CountryBProdCosts_Fixed_O_M, tick == j)) 
  meanLoanCostsB[j] <- mean(subset(bigDF$CountryBProdCosts_Loan, tick == j))
  meanCommodityCostsB[j] <- mean(subset(bigDF$CountryBProdCosts_Commodity, tick == j)) 
  meanDownpaymentsCostsB[j] <- mean(subset(bigDF$CountryBProdCosts_Downpayment, tick == j))
  seFixedOMCostsB[j] <- std.error(subset(bigDF$CountryBProdCosts_Fixed_O_M, tick == j))  
  seLoanCostsB[j] <- std.error(subset(bigDF$CountryBProdCosts_Loan, tick == j)) 
  seCommodityCostsB[j] <- std.error(subset(bigDF$CountryBProdCosts_Commodity, tick == j)) 
  seDownpaymentsCostsB[j] <- std.error(subset(bigDF$CountryBProdCosts_Downpayment, tick == j))
}

fixedOMcostsAplot = ggplot(data=tickDF, aes(x=X0, y=meanFixedOMCostsA)) + 
  geom_errorbar(aes(ymin=meanFixedOMCostsA-seFixedOMCostsA, ymax=meanFixedOMCostsA+seFixedOMCostsA, width=1)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Fixed O&M Costs \n Country A") +   
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(fixedOMcostsAplot)
ggsave(filename = paste(filePrefix, "fixedOMcostsAplot.pdf", sep=""),scale=1)

loanCostsAplot = ggplot(data=tickDF, aes(x=X0, y=meanLoanCostsA)) + 
  geom_errorbar(aes(ymin=meanLoanCostsA-seLoanCostsA, ymax=meanLoanCostsA+seLoanCostsA, width=1)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Loan Costs \n Country A") +  
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis),  
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(loanCostsAplot)
ggsave(filename = paste(filePrefix, "loanCostsAplot.pdf", sep=""),scale=1)

commodityCostsAplot = ggplot(data=tickDF, aes(x=X0, y= meanCommodityCostsA)) + 
  geom_errorbar(aes(ymin=meanCommodityCostsA-seCommodityCostsA, ymax= meanCommodityCostsA+seCommodityCostsA, width=1)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Commodity Costs \n Country A") +  
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis),   
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(commodityCostsAplot)
ggsave(filename = paste(filePrefix, "commodityCostsAplot.pdf", sep=""),scale=1)

downpaymentsCostsAplot = ggplot(data=tickDF, aes(x=X0, y=meanDownpaymentsCostsA)) + 
  geom_errorbar(aes(ymin=meanDownpaymentsCostsA-seDownpaymentsCostsA, ymax=meanDownpaymentsCostsA+seDownpaymentsCostsA, width=1)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Downpayment Costs \n Country A") + 
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis),  
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(downpaymentsCostsAplot)
ggsave(filename = paste(filePrefix, "downpaymentsCostsAplot.pdf", sep=""),scale=1)

fixedOMcostsBplot = ggplot(data=tickDF, aes(x=X0, y=meanFixedOMCostsB)) + 
  geom_errorbar(aes(ymin=meanFixedOMCostsB-seFixedOMCostsB, ymax=meanFixedOMCostsB+seFixedOMCostsB, width=1)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Fixed O&M Costs \n Country B") +  
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis),  
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(fixedOMcostsBplot)
ggsave(filename = paste(filePrefix, "fixedOMcostsBplot.pdf", sep=""),scale=1)

loanCostsBplot = ggplot(data=tickDF, aes(x=X0, y=meanLoanCostsB)) + 
  geom_errorbar(aes(ymin=meanLoanCostsB-seLoanCostsB, ymax=meanLoanCostsB+seLoanCostsB, width=1)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Loan Costs \n Country B") +  
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis),  
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(loanCostsBplot)
ggsave(filename = paste(filePrefix, "loanCostsBplot.pdf", sep=""),scale=1)

commodityCostsBplot = ggplot(data=tickDF, aes(x=X0, y= meanCommodityCostsB)) + 
  geom_errorbar(aes(ymin=meanCommodityCostsB-seCommodityCostsB, ymax= meanCommodityCostsB+seCommodityCostsB, width=1)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Commodity Costs \n Country B") +    
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis),  
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(commodityCostsBplot)
ggsave(filename = paste(filePrefix, "commodityCostsBplot.pdf", sep=""),scale=1)

downpaymentsCostsBplot = ggplot(data=tickDF, aes(x=X0, y=meanDownpaymentsCostsB)) + 
  geom_errorbar(aes(ymin=meanDownpaymentsCostsB-seDownpaymentsCostsB, ymax=meanDownpaymentsCostsB+seDownpaymentsCostsB, width=1)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Downpayment Costs \n Country B") +   
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(downpaymentsCostsBplot)
ggsave(filename = paste(filePrefix, "downpaymentsCostsBplot.pdf", sep=""),scale=1)


#Initiate
technologyOrder=c("Nuclear","Lignite","CoalPSC","IGCC","CCGT","OCGT","Biomass","Biogas","Wind","WindOffshore","PV")
technologyPalette=c("CoalPSC" = "black", "Biomass" = "darkgreen", "Biogas"="darkolivegreen3", "Nuclear" = "purple", "Lignite" = "saddlebrown",
                    "OCGT" = "darkred", "CCGT" = "blue", "PV" = "yellow", "Wind" = "chartreuse4",
                    "CoalPscCCS" = "darkgray", "IGCC" = "orange", "IgccCCS"="orangered", "CcgtCCS" = "red",
                    "WindOffshore" = "navyblue", "HydroPower" = "skyblue3")
producerPalette=c("A"="black","B"="darkgreen","C"="purple","D"="darkred","E"="blue","F"="yellow","G"="orange","H"="navyblue","I"="darkgrey")

# Generation shares per technology
meanSharePVA=0
meanShareWindA=0
meanShareWindOffshoreA=0
meanShareBiogasA=0
meanShareBiomassA=0
meanShareCoalA=0
meanShareIGCCA=0
meanShareLigniteA=0
meanShareOCGTA=0
meanShareCCGTA=0
meanShareNuclearA=0
meanSharePVB=0
meanShareWindB=0
meanShareWindOffshoreB=0
meanShareBiogasB=0
meanShareBiomassB=0
meanShareCoalB=0
meanShareIGCCB=0
meanShareLigniteB=0
meanShareOCGTB=0
meanShareCCGTB=0
meanShareNuclearB=0

for(j in 0:39) {
  meanSharePVA[j] <- mean(subset(bigDF$GenerationinMWhCountryA_Photovoltaic / bigDF$NationalTotalProductioninMWh_Country_A, tick == j))
  meanShareWindA[j] <- mean(subset(bigDF$GenerationinMWhCountryA_Wind / bigDF$NationalTotalProductioninMWh_Country_A, tick == j))
  meanShareWindOffshoreA[j] <- mean(subset(bigDF$GenerationinMWhCountryA_WindOffshore / bigDF$NationalTotalProductioninMWh_Country_A, tick == j))
  meanShareBiomassA[j] <- mean(subset(bigDF$GenerationinMWhCountryA_Biomass / bigDF$NationalTotalProductioninMWh_Country_A, tick == j))
  meanShareBiogasA[j] <- mean(subset(bigDF$GenerationinMWhCountryA_Biogas / bigDF$NationalTotalProductioninMWh_Country_A, tick == j))
  meanShareCoalA[j] <- mean(subset(bigDF$GenerationinMWhCountryA_CoalPSC / bigDF$NationalTotalProductioninMWh_Country_A, tick == j))
  meanShareIGCCA[j] <- mean(subset(bigDF$GenerationinMWhCountryA_IGCC / bigDF$NationalTotalProductioninMWh_Country_A, tick == j))
  meanShareLigniteA[j] <- mean(subset(bigDF$GenerationinMWhCountryA_Lignite / bigDF$NationalTotalProductioninMWh_Country_A, tick == j))
  meanShareOCGTA[j] <- mean(subset(bigDF$GenerationinMWhCountryA_OCGT / bigDF$NationalTotalProductioninMWh_Country_A, tick == j))
  meanShareCCGTA[j] <- mean(subset(bigDF$GenerationinMWhCountryA_CCGT / bigDF$NationalTotalProductioninMWh_Country_A, tick == j))
  meanShareNuclearA[j] <- mean(subset(bigDF$GenerationinMWhCountryA_Nuclear / bigDF$NationalTotalProductioninMWh_Country_A, tick == j))
  meanSharePVB[j] <- mean(subset(bigDF$GenerationinMWhCountryB_Photovoltaic / bigDF$NationalTotalProductioninMWh_Country_B, tick == j))
  meanShareWindB[j] <- mean(subset(bigDF$GenerationinMWhCountryB_Wind / bigDF$NationalTotalProductioninMWh_Country_B, tick == j))
  meanShareWindOffshoreB[j] <- mean(subset(bigDF$GenerationinMWhCountryB_WindOffshore / bigDF$NationalTotalProductioninMWh_Country_B, tick == j))
  meanShareBiomassB[j] <- mean(subset(bigDF$GenerationinMWhCountryB_Biomass / bigDF$NationalTotalProductioninMWh_Country_B, tick == j))
  meanShareBiogasB[j] <- mean(subset(bigDF$GenerationinMWhCountryB_Biogas / bigDF$NationalTotalProductioninMWh_Country_B, tick == j))
  meanShareIGCCB[j] <- mean(subset(bigDF$GenerationinMWhCountryB_IGCC / bigDF$NationalTotalProductioninMWh_Country_B, tick == j))
  meanShareCoalB[j] <- mean(subset(bigDF$GenerationinMWhCountryB_CoalPSC / bigDF$NationalTotalProductioninMWh_Country_B, tick == j))
  meanShareLigniteB[j] <- mean(subset(bigDF$GenerationinMWhCountryB_Lignite / bigDF$NationalTotalProductioninMWh_Country_B, tick == j))
  meanShareOCGTB[j] <- mean(subset(bigDF$GenerationinMWhCountryB_OCGT / bigDF$NationalTotalProductioninMWh_Country_B, tick == j))
  meanShareCCGTB[j] <- mean(subset(bigDF$GenerationinMWhCountryB_CCGT / bigDF$NationalTotalProductioninMWh_Country_B, tick == j))
  meanShareNuclearB[j] <- mean(subset(bigDF$GenerationinMWhCountryB_Nuclear / bigDF$NationalTotalProductioninMWh_Country_B, tick == j))
}

meanSharePVA
meanShareWindA
meanShareWindOffshoreA
meanShareBiogasA
meanShareBiomassA
meanShareCoalA
meanShareIGCCA
meanShareLigniteA
meanShareOCGTA
meanShareCCGTA
meanShareNuclearA
meanSharePVB
meanShareWindB
meanShareWindOffshoreB
meanShareBiogasB
meanShareBiomassB
meanShareCoalB
meanShareIGCCB
meanShareLigniteB
meanShareOCGTB
meanShareCCGTB
meanShareNuclearB

DataTable <- c(meanShareNuclearA)
DataTable <- rbind(DataTable, c(meanShareLigniteA))
DataTable <- rbind(DataTable, c(meanShareCoalA))
DataTable <- rbind(DataTable, c(meanShareIGCCA))
DataTable <- rbind(DataTable, c(meanShareCCGTA))
DataTable <- rbind(DataTable, c(meanShareOCGTA))
DataTable <- rbind(DataTable, c(meanShareBiomassA))
DataTable <- rbind(DataTable, c(meanShareBiogasA))
DataTable <- rbind(DataTable, c(meanShareWindA))
DataTable <- rbind(DataTable, c(meanShareWindOffshoreA))
DataTable <- rbind(DataTable, c(meanSharePVA))
colnames(DataTable) <- c("share","fraction")
rownames(DataTable) <- c("Nuclear","Lignite","CoalPSC","IGCC", "CCGT","OCGT","Biomass","Biogas","Wind","WindOffshore","PV")
write.csv(DataTable, "DataTableGenerationShareA.csv")
GenerationShareDataA <- melt(DataTable)

ggplot(GenerationShareDataA, aes(X2, value, fill = X1)) + 
  guides(fill=guide_legend(title=NULL)) +
  scale_fill_manual(values=technologyPalette) +
  geom_area(stat = "identity") + 
  xlab("Year") + 
  ylab("Fraction") +
  ggtitle("Relative generation shares Country A") +  
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
ggsave(filename = paste(filePrefix, "relativeGenerationShareAplot.pdf", sep=""))

DataTable <- c(meanShareNuclearB)
DataTable <- rbind(DataTable, c(meanShareLigniteB))
DataTable <- rbind(DataTable, c(meanShareCoalB))
DataTable <- rbind(DataTable, c(meanShareIGCCB))
DataTable <- rbind(DataTable, c(meanShareCCGTB))
DataTable <- rbind(DataTable, c(meanShareOCGTB))
DataTable <- rbind(DataTable, c(meanShareBiomassB))
DataTable <- rbind(DataTable, c(meanShareBiogasB))
DataTable <- rbind(DataTable, c(meanShareWindB))
DataTable <- rbind(DataTable, c(meanShareWindOffshoreB))
DataTable <- rbind(DataTable, c(meanSharePVB))
colnames(DataTable) <- c("share","fraction")
rownames(DataTable) <- c("Nuclear","Lignite","CoalPSC","IGCC", "CCGT","OCGT","Biomass","Biogas","Wind","WindOffshore","PV")
write.csv(DataTable, "DataTableGenerationShareB.csv")
GenerationShareDataB <- melt(DataTable)

ggplot(GenerationShareDataB, aes(X2, value, fill = X1)) + 
  guides(fill=guide_legend(title=NULL)) +
  scale_fill_manual(values=technologyPalette) +
  geom_area(stat = "identity") + 
  xlab("Year") + 
  ylab("Fraction") +
  ggtitle("Relative generation shares Country B") +  
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
ggsave(filename = paste(filePrefix, "relativeGenerationShareBplot.pdf", sep=""))

# Expected Renewable generation check
## means ##
generationPVA=0
generationWindA=0
generationWindOffshoreA=0
generationBiogasA=0
generationBiomassA=0
generationPVB=0
generationWindB=0
generationWindOffshoreB=0
generationBiogasB=0
generationBiomassB=0
expectedRenewableGenerationA=0
expectedRenewableGenerationB=0

for(j in 0:39) {
  generationPVA[j] <- mean(subset(bigDF$GenerationinMWhCountryA_Photovoltaic, tick == j))
  generationWindA[j] <- mean(subset(bigDF$GenerationinMWhCountryA_Wind, tick == j))
  generationWindOffshoreA[j] <- mean(subset(bigDF$GenerationinMWhCountryA_WindOffshore, tick == j))
  generationBiomassA[j] <- mean(subset(bigDF$GenerationinMWhCountryA_Biomass, tick == j))
  generationBiogasA[j] <- mean(subset(bigDF$GenerationinMWhCountryA_Biogas, tick == j))
  generationPVB[j] <- mean(subset(bigDF$GenerationinMWhCountryB_Photovoltaic, tick == j))
  generationWindB[j] <- mean(subset(bigDF$GenerationinMWhCountryB_Wind, tick == j))
  generationWindOffshoreB[j] <- mean(subset(bigDF$GenerationinMWhCountryB_WindOffshore, tick == j))
  generationBiomassB[j] <- mean(subset(bigDF$GenerationinMWhCountryB_Biomass, tick == j))
  generationBiogasB[j] <- mean(subset(bigDF$GenerationinMWhCountryB_Biogas, tick == j))
  expectedRenewableGenerationA[j] <- mean(subset(bigDF$ExpectedRenewableGeneration_RenewableTenderNL, tick == j-1))
  expectedRenewableGenerationB[j] <- mean(subset(bigDF$ExpectedRenewableGeneration_RenewableTenderDE, tick == j-1))
}

seGenerationPVA=0
seGenerationWindA=0
seGenerationWindOffshoreA=0
seGenerationBiogasA=0
seGenerationBiomassA=0
seGenerationPVB=0
seGenerationWindB=0
seGenerationWindOffshoreB=0
seGenerationBiogasB=0
seGenerationBiomassB=0
seExpectedRenewableGenerationA=0
seExpectedRenewableGenerationB=0

for(j in 0:39) {
  seGenerationPVA[j] <- std.error(subset(bigDF$GenerationinMWhCountryA_Photovoltaic, tick == j))
  seGenerationWindA[j] <- std.error(subset(bigDF$GenerationinMWhCountryA_Wind, tick == j))
  seGenerationWindOffshoreA[j] <- std.error(subset(bigDF$GenerationinMWhCountryA_WindOffshore, tick == j))
  seGenerationBiomassA[j] <- std.error(subset(bigDF$GenerationinMWhCountryA_Biomass, tick == j))
  seGenerationBiogasA[j] <- std.error(subset(bigDF$GenerationinMWhCountryA_Biogas, tick == j))
  seGenerationPVB[j] <- std.error(subset(bigDF$GenerationinMWhCountryB_Photovoltaic, tick == j))
  seGenerationWindB[j] <- std.error(subset(bigDF$GenerationinMWhCountryB_Wind, tick == j))
  seGenerationWindOffshoreB[j] <- std.error(subset(bigDF$GenerationinMWhCountryB_WindOffshore, tick == j))
  seGenerationBiomassB[j] <- std.error(subset(bigDF$GenerationinMWhCountryB_Biomass, tick == j))
  seGenerationBiogasB[j] <- std.error(subset(bigDF$GenerationinMWhCountryB_Biogas, tick == j))
  seExpectedRenewableGenerationA[j] <- std.error(subset(bigDF$ExpectedRenewableGeneration_RenewableTenderNL, tick == j-1))
  seExpectedRenewableGenerationB[j] <- std.error(subset(bigDF$ExpectedRenewableGeneration_RenewableTenderDE, tick == j-1))
}

renewableGenerationA <-generationPVA + generationWindA + generationWindOffshoreA + generationBiogasA + generationBiomassA
renewableGenerationB <-generationPVB + generationWindB + generationWindOffshoreB + generationBiogasB + generationBiomassB
seRenewableGenerationA <-seGenerationPVA + seGenerationWindA + seGenerationWindOffshoreA + seGenerationBiogasA + seGenerationBiomassA
seRenewableGenerationB <-seGenerationPVB + seGenerationWindB + seGenerationWindOffshoreB + seGenerationBiogasB + seGenerationBiomassB

expectedRenewableGenerationA
expectedRenewableGenerationB
seExpectedRenewableGenerationA
seExpectedRenewableGenerationB

estimationErrorExpectedGenerationA <- (expectedRenewableGenerationA - renewableGenerationA)*100/expectedRenewableGenerationA 
estimationErrorExpectedGenerationB <- (expectedRenewableGenerationB - renewableGenerationB)*100/expectedRenewableGenerationB 
seEstimationErrorExpectedGenerationA <- (seExpectedRenewableGenerationA - seRenewableGenerationA)/seExpectedRenewableGenerationA 
seEstimationErrorExpectedGenerationB <- (seExpectedRenewableGenerationB - seRenewableGenerationB)/seExpectedRenewableGenerationB 

estimationErrorExpectedGenerationAplot = ggplot(data=tickDF, aes(x=X0, y=estimationErrorExpectedGenerationA )) + 
  geom_errorbar(aes(ymin=estimationErrorExpectedGenerationA-seEstimationErrorExpectedGenerationA, ymax=estimationErrorExpectedGenerationA+seEstimationErrorExpectedGenerationA), width=1) + 
  geom_point() +
  xlab("Year") +  
  ylab("[%]") + 
  ggtitle("Estimation Error \n Expected Generation Country A") +    
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis),
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(estimationErrorExpectedGenerationAplot)
ggsave(filename = paste(filePrefix, "ForecastingErrorExpectedGenA.pdf", sep=""))

estimationErrorExpectedGenerationBplot = ggplot(data=tickDF, aes(x=X0, y=estimationErrorExpectedGenerationB)) + 
  geom_errorbar(aes(ymin=estimationErrorExpectedGenerationB-seEstimationErrorExpectedGenerationB, ymax=estimationErrorExpectedGenerationB+seEstimationErrorExpectedGenerationB), width=1) + 
  geom_point() +
  xlab("Year") +  
  ylab("[%]") + 
  ggtitle("Estimation Error \n Expected Generation Country B") +    
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis),  
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(estimationErrorExpectedGenerationBplot)
ggsave(filename = paste(filePrefix, "ForecastingErrorExpectedGenB.pdf", sep=""))


# Expected Renewable generation check ### Tech Spec Addition ###
## means ##
expectedRenewableGenerationWindA=0
expectedRenewableGenerationBiogasA=0
expectedRenewableGenerationbiomassA=0
expectedRenewableGenerationPVA=0
expectedRenewableGenerationWindOffA=0
expectedRenewableGenerationWindB=0
expectedRenewableGenerationBiogasB=0
expectedRenewableGenerationBiomassB=0
expectedRenewableGenerationPVB=0
expectedRenewableGenerationWindOffB=0

for(j in 0:39) {
  expectedRenewableGenerationWindA[j] <- mean(subset(bigDF$ExpectedRenewableGeneration_RenewableTenderNLwindPGT, tick == j-1))
  expectedRenewableGenerationBiogasA[j] <- mean(subset(bigDF$ExpectedRenewableGeneration_RenewableTenderNLbiogasPGT, tick == j-1))
  expectedRenewableGenerationbiomassA[j] <- mean(subset(bigDF$ExpectedRenewableGeneration_RenewableTenderNLbiomassPGT, tick == j-1))
  expectedRenewableGenerationPVA[j] <- mean(subset(bigDF$ExpectedRenewableGeneration_RenewableTenderNLphotovoltaicPGT, tick == j-1))
  expectedRenewableGenerationWindOffA[j] <- mean(subset(bigDF$ExpectedRenewableGeneration_RenewableTenderNLwindOffshorePGT, tick == j-1))
  expectedRenewableGenerationWindB[j] <- mean(subset(bigDF$ExpectedRenewableGeneration_RenewableTenderDEwindPGT, tick == j-1))
  expectedRenewableGenerationBiogasB[j] <- mean(subset(bigDF$ExpectedRenewableGeneration_RenewableTenderDEbiogasPGT, tick == j-1))
  expectedRenewableGenerationBiomassB[j] <- mean(subset(bigDF$ExpectedRenewableGeneration_RenewableTenderDEbiomassPGT, tick == j-1))
  expectedRenewableGenerationPVB[j] <- mean(subset(bigDF$ExpectedRenewableGeneration_RenewableTenderDEphotovoltaicPGT, tick == j-1))
  expectedRenewableGenerationWindOffB[j] <- mean(subset(bigDF$ExpectedRenewableGeneration_RenewableTenderDEwindOffshorePGT, tick == j-1))
}



expectedTotalRenewableGenerationA <- expectedRenewableGenerationWindA + expectedRenewableGenerationBiogasA + expectedRenewableGenerationBiomassA + expectedRenewableGenerationPVA + expectedRenewableGenerationWindOffA
seExpectedTotalRenewableGenerationA <- seExpectedRenewableGenerationWindA + seExpectedRenewableGenerationBiogasA + seExpectedRenewableGenerationBiomassA + seExpectedRenewableGenerationPVA + seExpectedRenewableGenerationWindOffA
estimationErrorExpectedGenerationA <- (expectedTotalRenewableGenerationA - renewableGenerationA)*100/expectedTotalRenewableGenerationA
seEstimationErrorExpectedGenerationA <- (seExpectedTotalRenewableGenerationA - seRenewableGenerationA)/seExpectedTotalRenewableGenerationA

expectedTotalRenewableGenerationB <- expectedRenewableGenerationWindB + expectedRenewableGenerationBiogasB + expectedRenewableGenerationBiomassB + expectedRenewableGenerationPVB + expectedRenewableGenerationWindOffB
seExpectedTotalRenewableGenerationB <- seExpectedRenewableGenerationWindB + seExpectedRenewableGenerationBiogasB + seExpectedRenewableGenerationBiomassB + seExpectedRenewableGenerationPVB + seExpectedRenewableGenerationWindOffB
estimationErrorExpectedGenerationB <- (expectedTotalRenewableGenerationB - renewableGenerationB)*100/expectedTotalRenewableGenerationB
seEstimationErrorExpectedGenerationB <- (seExpectedTotalRenewableGenerationB - seRenewableGenerationB)/seExpectedTotalRenewableGenerationB

estimationErrorExpectedGenerationAplot = ggplot(data=tickDF, aes(x=X0, y=estimationErrorExpectedGenerationA )) + 
  geom_errorbar(aes(ymin=estimationErrorExpectedGenerationA-seEstimationErrorExpectedGenerationA, ymax=estimationErrorExpectedGenerationA+seEstimationErrorExpectedGenerationA), width=1) + 
  geom_point() +
  xlab("Year") +  
  ylab("[%]") + 
  ggtitle("Estimation Error \n Expected Generation Country A") +    
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis),
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
plot(estimationErrorExpectedGenerationAplot)
ggsave(filename = paste(filePrefix, "TechSpecForecastingErrorExpectedGenA.pdf", sep=""))

estimationErrorExpectedGenerationBplot = ggplot(data=tickDF, aes(x=X0, y=estimationErrorExpectedGenerationB)) + 
  geom_errorbar(aes(ymin=estimationErrorExpectedGenerationB-seEstimationErrorExpectedGenerationB, ymax=estimationErrorExpectedGenerationB+seEstimationErrorExpectedGenerationB), width=1) + 
  geom_point() +
  xlab("Year") +  
  ylab("[%]") + 
  ggtitle("Estimation Error \n Expected Generation Country B") +    
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis),  
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
plot(estimationErrorExpectedGenerationBplot)
ggsave(filename = paste(filePrefix, "TechSpecForecastingErrorExpectedGenB.pdf", sep=""))



# Capacity shares per technology
meanCapSharePVA=0
meanCapShareWindA=0
meanCapShareWindOffshoreA=0
meanCapShareBiogasA=0
meanCapShareBiomassA=0
meanCapShareCoalA=0
meanCapShareIGCCA=0
meanCapShareLigniteA=0
meanCapShareOCGTA=0
meanCapShareCCGTA=0
meanCapShareNuclearA=0
meanCapSharePVB=0
meanCapShareWindB=0
meanCapShareWindOffshoreB=0
meanCapShareBiogasB=0
meanCapShareBiomassB=0
meanCapShareCoalB=0
meanCapShareIGCCB=0
meanCapShareLigniteB=0
meanCapShareOCGTB=0
meanCapShareCCGTB=0
meanCapShareNuclearB=0

for(j in 0:39) {
  meanCapSharePVA[j] <- mean(subset(bigDF$CapacityinMWinA_Photovoltaic / (bigDF$CapacityinMWinA_Photovoltaic + bigDF$CapacityinMWinA_Wind + bigDF$CapacityinMWinA_WindOffshore + bigDF$CapacityinMWinA_Biomass + bigDF$CapacityinMWinA_Biogas + bigDF$CapacityinMWinA_CoalPSC + bigDF$CapacityinMWinA_IGCC + bigDF$CapacityinMWinA_Lignite + bigDF$CapacityinMWinA_OCGT +   bigDF$CapacityinMWinA_CCGT + bigDF$CapacityinMWinA_Nuclear), tick == j))
  meanCapShareWindA[j] <- mean(subset(bigDF$CapacityinMWinA_Wind / (bigDF$CapacityinMWinA_Photovoltaic + bigDF$CapacityinMWinA_Wind + bigDF$CapacityinMWinA_WindOffshore + bigDF$CapacityinMWinA_Biomass + bigDF$CapacityinMWinA_Biogas + bigDF$CapacityinMWinA_CoalPSC + bigDF$CapacityinMWinA_IGCC + bigDF$CapacityinMWinA_Lignite + bigDF$CapacityinMWinA_OCGT +   bigDF$CapacityinMWinA_CCGT + bigDF$CapacityinMWinA_Nuclear), tick == j))
  meanCapShareWindOffshoreA[j] <- mean(subset(bigDF$CapacityinMWinA_WindOffshore / (bigDF$CapacityinMWinA_Photovoltaic + bigDF$CapacityinMWinA_Wind + bigDF$CapacityinMWinA_WindOffshore + bigDF$CapacityinMWinA_Biomass + bigDF$CapacityinMWinA_Biogas + bigDF$CapacityinMWinA_CoalPSC + bigDF$CapacityinMWinA_IGCC + bigDF$CapacityinMWinA_Lignite + bigDF$CapacityinMWinA_OCGT +   bigDF$CapacityinMWinA_CCGT + bigDF$CapacityinMWinA_Nuclear), tick == j))
  meanCapShareBiomassA[j] <- mean(subset(bigDF$CapacityinMWinA_Biomass / (bigDF$CapacityinMWinA_Photovoltaic + bigDF$CapacityinMWinA_Wind + bigDF$CapacityinMWinA_WindOffshore + bigDF$CapacityinMWinA_Biomass + bigDF$CapacityinMWinA_Biogas + bigDF$CapacityinMWinA_CoalPSC + bigDF$CapacityinMWinA_IGCC + bigDF$CapacityinMWinA_Lignite + bigDF$CapacityinMWinA_OCGT +   bigDF$CapacityinMWinA_CCGT + bigDF$CapacityinMWinA_Nuclear), tick == j))
  meanCapShareBiogasA[j] <- mean(subset(bigDF$CapacityinMWinA_Biogas / (bigDF$CapacityinMWinA_Photovoltaic + bigDF$CapacityinMWinA_Wind + bigDF$CapacityinMWinA_WindOffshore + bigDF$CapacityinMWinA_Biomass + bigDF$CapacityinMWinA_Biogas + bigDF$CapacityinMWinA_CoalPSC + bigDF$CapacityinMWinA_IGCC + bigDF$CapacityinMWinA_Lignite + bigDF$CapacityinMWinA_OCGT +   bigDF$CapacityinMWinA_CCGT + bigDF$CapacityinMWinA_Nuclear), tick == j))
  meanCapShareCoalA[j] <- mean(subset(bigDF$CapacityinMWinA_CoalPSC / (bigDF$CapacityinMWinA_Photovoltaic + bigDF$CapacityinMWinA_Wind + bigDF$CapacityinMWinA_WindOffshore + bigDF$CapacityinMWinA_Biomass + bigDF$CapacityinMWinA_Biogas + bigDF$CapacityinMWinA_CoalPSC + bigDF$CapacityinMWinA_IGCC + bigDF$CapacityinMWinA_Lignite + bigDF$CapacityinMWinA_OCGT +   bigDF$CapacityinMWinA_CCGT + bigDF$CapacityinMWinA_Nuclear), tick == j))
  meanCapShareIGCCA[j] <- mean(subset(bigDF$CapacityinMWinA_IGCC / (bigDF$CapacityinMWinA_Photovoltaic + bigDF$CapacityinMWinA_Wind + bigDF$CapacityinMWinA_WindOffshore + bigDF$CapacityinMWinA_Biomass + bigDF$CapacityinMWinA_Biogas + bigDF$CapacityinMWinA_CoalPSC + bigDF$CapacityinMWinA_IGCC + bigDF$CapacityinMWinA_Lignite + bigDF$CapacityinMWinA_OCGT +   bigDF$CapacityinMWinA_CCGT + bigDF$CapacityinMWinA_Nuclear), tick == j))
  meanCapShareLigniteA[j] <- mean(subset(bigDF$CapacityinMWinA_Lignite / (bigDF$CapacityinMWinA_Photovoltaic + bigDF$CapacityinMWinA_Wind + bigDF$CapacityinMWinA_WindOffshore + bigDF$CapacityinMWinA_Biomass + bigDF$CapacityinMWinA_Biogas + bigDF$CapacityinMWinA_CoalPSC + bigDF$CapacityinMWinA_IGCC + bigDF$CapacityinMWinA_Lignite + bigDF$CapacityinMWinA_OCGT +   bigDF$CapacityinMWinA_CCGT + bigDF$CapacityinMWinA_Nuclear), tick == j))
  meanCapShareOCGTA[j] <- mean(subset(bigDF$CapacityinMWinA_OCGT / (bigDF$CapacityinMWinA_Photovoltaic + bigDF$CapacityinMWinA_Wind + bigDF$CapacityinMWinA_WindOffshore + bigDF$CapacityinMWinA_Biomass + bigDF$CapacityinMWinA_Biogas + bigDF$CapacityinMWinA_CoalPSC + bigDF$CapacityinMWinA_IGCC + bigDF$CapacityinMWinA_Lignite + bigDF$CapacityinMWinA_OCGT +   bigDF$CapacityinMWinA_CCGT + bigDF$CapacityinMWinA_Nuclear), tick == j))
  meanCapShareCCGTA[j] <- mean(subset(bigDF$CapacityinMWinA_CCGT / (bigDF$CapacityinMWinA_Photovoltaic + bigDF$CapacityinMWinA_Wind + bigDF$CapacityinMWinA_WindOffshore + bigDF$CapacityinMWinA_Biomass + bigDF$CapacityinMWinA_Biogas + bigDF$CapacityinMWinA_CoalPSC + bigDF$CapacityinMWinA_IGCC + bigDF$CapacityinMWinA_Lignite + bigDF$CapacityinMWinA_OCGT +   bigDF$CapacityinMWinA_CCGT + bigDF$CapacityinMWinA_Nuclear), tick == j))
  meanCapShareNuclearA[j] <- mean(subset(bigDF$CapacityinMWinA_Nuclear / (bigDF$CapacityinMWinA_Photovoltaic + bigDF$CapacityinMWinA_Wind + bigDF$CapacityinMWinA_WindOffshore + bigDF$CapacityinMWinA_Biomass + bigDF$CapacityinMWinA_Biogas + bigDF$CapacityinMWinA_CoalPSC + bigDF$CapacityinMWinA_IGCC + bigDF$CapacityinMWinA_Lignite + bigDF$CapacityinMWinA_OCGT +   bigDF$CapacityinMWinA_CCGT + bigDF$CapacityinMWinA_Nuclear), tick == j))
  meanCapSharePVB[j] <- mean(subset(bigDF$CapacityinMWinB_Photovoltaic / (bigDF$CapacityinMWinB_Photovoltaic + bigDF$CapacityinMWinB_Wind + bigDF$CapacityinMWinB_WindOffshore + bigDF$CapacityinMWinB_Biomass + bigDF$CapacityinMWinB_Biogas + bigDF$CapacityinMWinB_CoalPSC + bigDF$CapacityinMWinB_IGCC + bigDF$CapacityinMWinB_Lignite + bigDF$CapacityinMWinB_OCGT +   bigDF$CapacityinMWinB_CCGT + bigDF$CapacityinMWinB_Nuclear), tick == j))
  meanCapShareWindB[j] <- mean(subset(bigDF$CapacityinMWinB_Wind / (bigDF$CapacityinMWinB_Photovoltaic + bigDF$CapacityinMWinB_Wind + bigDF$CapacityinMWinB_WindOffshore + bigDF$CapacityinMWinB_Biomass + bigDF$CapacityinMWinB_Biogas + bigDF$CapacityinMWinB_CoalPSC + bigDF$CapacityinMWinB_IGCC + bigDF$CapacityinMWinB_Lignite + bigDF$CapacityinMWinB_OCGT +   bigDF$CapacityinMWinB_CCGT + bigDF$CapacityinMWinB_Nuclear), tick == j))
  meanCapShareWindOffshoreB[j] <- mean(subset(bigDF$CapacityinMWinB_WindOffshore / (bigDF$CapacityinMWinB_Photovoltaic + bigDF$CapacityinMWinB_Wind + bigDF$CapacityinMWinB_WindOffshore + bigDF$CapacityinMWinB_Biomass + bigDF$CapacityinMWinB_Biogas + bigDF$CapacityinMWinB_CoalPSC + bigDF$CapacityinMWinB_IGCC + bigDF$CapacityinMWinB_Lignite + bigDF$CapacityinMWinB_OCGT +   bigDF$CapacityinMWinB_CCGT + bigDF$CapacityinMWinB_Nuclear), tick == j))
  meanCapShareBiomassB[j] <- mean(subset(bigDF$CapacityinMWinB_Biomass / (bigDF$CapacityinMWinB_Photovoltaic + bigDF$CapacityinMWinB_Wind + bigDF$CapacityinMWinB_WindOffshore + bigDF$CapacityinMWinB_Biomass + bigDF$CapacityinMWinB_Biogas + bigDF$CapacityinMWinB_CoalPSC + bigDF$CapacityinMWinB_IGCC + bigDF$CapacityinMWinB_Lignite + bigDF$CapacityinMWinB_OCGT +   bigDF$CapacityinMWinB_CCGT + bigDF$CapacityinMWinB_Nuclear), tick == j))
  meanCapShareBiogasB[j] <- mean(subset(bigDF$CapacityinMWinB_Biogas / (bigDF$CapacityinMWinB_Photovoltaic + bigDF$CapacityinMWinB_Wind + bigDF$CapacityinMWinB_WindOffshore + bigDF$CapacityinMWinB_Biomass + bigDF$CapacityinMWinB_Biogas + bigDF$CapacityinMWinB_CoalPSC + bigDF$CapacityinMWinB_IGCC + bigDF$CapacityinMWinB_Lignite + bigDF$CapacityinMWinB_OCGT +   bigDF$CapacityinMWinB_CCGT + bigDF$CapacityinMWinB_Nuclear), tick == j))
  meanCapShareIGCCB[j] <- mean(subset(bigDF$CapacityinMWinB_IGCC / (bigDF$CapacityinMWinB_Photovoltaic + bigDF$CapacityinMWinB_Wind + bigDF$CapacityinMWinB_WindOffshore + bigDF$CapacityinMWinB_Biomass + bigDF$CapacityinMWinB_Biogas + bigDF$CapacityinMWinB_CoalPSC + bigDF$CapacityinMWinB_IGCC + bigDF$CapacityinMWinB_Lignite + bigDF$CapacityinMWinB_OCGT +   bigDF$CapacityinMWinB_CCGT + bigDF$CapacityinMWinB_Nuclear), tick == j))
  meanCapShareCoalB[j] <- mean(subset(bigDF$CapacityinMWinB_CoalPSC / (bigDF$CapacityinMWinB_Photovoltaic + bigDF$CapacityinMWinB_Wind + bigDF$CapacityinMWinB_WindOffshore + bigDF$CapacityinMWinB_Biomass + bigDF$CapacityinMWinB_Biogas + bigDF$CapacityinMWinB_CoalPSC + bigDF$CapacityinMWinB_IGCC + bigDF$CapacityinMWinB_Lignite + bigDF$CapacityinMWinB_OCGT +   bigDF$CapacityinMWinB_CCGT + bigDF$CapacityinMWinB_Nuclear), tick == j))
  meanCapShareLigniteB[j] <- mean(subset(bigDF$CapacityinMWinB_Lignite / (bigDF$CapacityinMWinB_Photovoltaic + bigDF$CapacityinMWinB_Wind + bigDF$CapacityinMWinB_WindOffshore + bigDF$CapacityinMWinB_Biomass + bigDF$CapacityinMWinB_Biogas + bigDF$CapacityinMWinB_CoalPSC + bigDF$CapacityinMWinB_IGCC + bigDF$CapacityinMWinB_Lignite + bigDF$CapacityinMWinB_OCGT +   bigDF$CapacityinMWinB_CCGT + bigDF$CapacityinMWinB_Nuclear), tick == j))
  meanCapShareOCGTB[j] <- mean(subset(bigDF$CapacityinMWinB_OCGT / (bigDF$CapacityinMWinB_Photovoltaic + bigDF$CapacityinMWinB_Wind + bigDF$CapacityinMWinB_WindOffshore + bigDF$CapacityinMWinB_Biomass + bigDF$CapacityinMWinB_Biogas + bigDF$CapacityinMWinB_CoalPSC + bigDF$CapacityinMWinB_IGCC + bigDF$CapacityinMWinB_Lignite + bigDF$CapacityinMWinB_OCGT +   bigDF$CapacityinMWinB_CCGT + bigDF$CapacityinMWinB_Nuclear), tick == j))
  meanCapShareCCGTB[j] <- mean(subset(bigDF$CapacityinMWinB_CCGT / (bigDF$CapacityinMWinB_Photovoltaic + bigDF$CapacityinMWinB_Wind + bigDF$CapacityinMWinB_WindOffshore + bigDF$CapacityinMWinB_Biomass + bigDF$CapacityinMWinB_Biogas + bigDF$CapacityinMWinB_CoalPSC + bigDF$CapacityinMWinB_IGCC + bigDF$CapacityinMWinB_Lignite + bigDF$CapacityinMWinB_OCGT +   bigDF$CapacityinMWinB_CCGT + bigDF$CapacityinMWinB_Nuclear), tick == j))
  meanCapShareNuclearB[j] <- mean(subset(bigDF$CapacityinMWinB_Nuclear / (bigDF$CapacityinMWinB_Photovoltaic + bigDF$CapacityinMWinB_Wind + bigDF$CapacityinMWinB_WindOffshore + bigDF$CapacityinMWinB_Biomass + bigDF$CapacityinMWinB_Biogas + bigDF$CapacityinMWinB_CoalPSC + bigDF$CapacityinMWinB_IGCC + bigDF$CapacityinMWinB_Lignite + bigDF$CapacityinMWinB_OCGT +   bigDF$CapacityinMWinB_CCGT + bigDF$CapacityinMWinB_Nuclear), tick == j))
}



meanCapSharePVA
meanCapShareWindA
meanCapShareWindOffshoreA
meanCapShareBiogasA
meanCapShareBiomassA
meanCapShareCoalA
meanCapShareIGCCA
meanCapShareLigniteA
meanCapShareOCGTA
meanCapShareCCGTA
meanCapShareNuclearA
meanCapSharePVB
meanCapShareWindB
meanCapShareWindOffshoreB
meanCapShareBiogasB
meanCapShareBiomassB
meanCapShareCoalB
meanCapShareIGCCB
meanCapShareLigniteB
meanCapShareOCGTB
meanCapShareCCGTB
meanCapShareNuclearB

DataTable <- c(meanCapShareNuclearA)
DataTable <- rbind(DataTable, c(meanCapShareLigniteA))
DataTable <- rbind(DataTable, c(meanCapShareCoalA))
DataTable <- rbind(DataTable, c(meanCapShareIGCCA))
DataTable <- rbind(DataTable, c(meanCapShareCCGTA))
DataTable <- rbind(DataTable, c(meanCapShareOCGTA))
DataTable <- rbind(DataTable, c(meanCapShareBiomassA))
DataTable <- rbind(DataTable, c(meanCapShareBiogasA))
DataTable <- rbind(DataTable, c(meanCapShareWindA))
DataTable <- rbind(DataTable, c(meanCapShareWindOffshoreA))
DataTable <- rbind(DataTable, c(meanCapSharePVA))
colnames(DataTable) <- c("CapShare","fraction")
rownames(DataTable) <- c("Nuclear","Lignite","CoalPSC","IGCC", "CCGT","OCGT","Biomass","Biogas","Wind","WindOffshore","PV")
write.csv(DataTable, "DataTableGenerationCapShareA.csv")
CapShareDataA <- melt(DataTable)

ggplot(CapShareDataA, aes(X2, value, fill = X1)) + 
  guides(fill=guide_legend(title=NULL)) +
  scale_fill_manual(values=technologyPalette) +
  geom_area(stat = "identity") + 
  xlab("Year") + 
  ylab("Fraction") +
  ggtitle("Relative capacity shares Country A") +  
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
ggsave(filename = paste(filePrefix, "relativeCapacityShareAplot.pdf", sep=""))

DataTable <- c(meanCapShareNuclearB)
DataTable <- rbind(DataTable, c(meanCapShareLigniteB))
DataTable <- rbind(DataTable, c(meanCapShareCoalB))
DataTable <- rbind(DataTable, c(meanCapShareIGCCB))
DataTable <- rbind(DataTable, c(meanCapShareCCGTB))
DataTable <- rbind(DataTable, c(meanCapShareOCGTB))
DataTable <- rbind(DataTable, c(meanCapShareBiomassB))
DataTable <- rbind(DataTable, c(meanCapShareBiogasB))
DataTable <- rbind(DataTable, c(meanCapShareWindB))
DataTable <- rbind(DataTable, c(meanCapShareWindOffshoreB))
DataTable <- rbind(DataTable, c(meanCapSharePVB))
colnames(DataTable) <- c("CapShare","fraction")
rownames(DataTable) <- c("Nuclear","Lignite","CoalPSC","IGCC", "CCGT","OCGT","Biomass","Biogas","Wind","WindOffshore","PV")
write.csv(DataTable, "DataTableGenerationCapShareB.csv")
CapShareDataB <- melt(DataTable)

a = ggplot(CapShareDataB, aes(X2, value, fill = X1)) + 
  guides(fill=guide_legend(title=NULL)) +
  scale_fill_manual(values=technologyPalette) +
  geom_area(stat = "identity") + 
  xlab("Year") + 
  ylab("Fraction") +
  ggtitle("Relative capacity shares Country B") +  
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(a)
ggsave(filename = paste(filePrefix, "relativeCapacityShareBplot.pdf", sep=""))

segmentPricesA = 
  ggplot(data=bigDF, aes(x=tick)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_1)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_2)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_3)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_4)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_5)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_6)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_7)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_8)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_9)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_10)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_11)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_12)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_13)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_14)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_15)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_16)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_17)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_18)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_19)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_20)) + 
  xlab("Tick") +  
  ylab("Price (EUR/MWh)") + 
  ggtitle("Segment Price development - Country A") + 
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
plot(segmentPricesA)
ggsave(filename = paste(filePrefix, "PriceSegmentA.pdf", sep=""))

segmentPricesB = 
  ggplot(data=bigDF, aes(x=tick)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_1)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_2)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_3)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_4)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_5)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_6)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_7)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_8)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_9)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_10)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_11)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_12)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_13)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_14)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_15)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_16)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_17)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_18)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_19)) + 
  geom_point(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_20)) + 
  xlab("Tick") +  
  ylab("Price (EUR/MWh)") + 
  ggtitle("Segment Price development - Country B") +   
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(segmentPricesB)
ggsave(filename = paste(filePrefix, "PriceSegmentB.pdf", sep=""))


# Renewable generation in terms of demand (compare this with NREAP targets)
meanRealizedTargetA=0
meanRealizedTargetB=0
seRealizedTargetA=0
seRealizedTargetB=0

for(j in 0:39) {
  meanRealizedTargetA[j] <- mean(subset( 
    ((bigDF$GenerationinMWhCountryA_Photovoltaic + bigDF$GenerationinMWhCountryA_Wind + bigDF$GenerationinMWhCountryA_Biomass + 
        bigDF$GenerationinMWhCountryA_HydroPower + bigDF$GenerationinMWhCountryA_Biogas + bigDF$GenerationinMWhCountryA_WindOffshore)/ bigDF$Total_DemandinMWh_Country_A) 
    , tick == j))
  
  meanRealizedTargetB[j] <- mean(subset( 
    ((bigDF$GenerationinMWhCountryB_Photovoltaic + bigDF$GenerationinMWhCountryB_Wind + bigDF$GenerationinMWhCountryB_Biomass + 
        bigDF$GenerationinMWhCountryB_HydroPower + bigDF$GenerationinMWhCountryB_Biogas + bigDF$GenerationinMWhCountryB_WindOffshore) / bigDF$Total_DemandinMWh_Country_B) 
    , tick == j))
  
  seRealizedTargetA[j] <- std.error(subset( 
    ((bigDF$GenerationinMWhCountryA_Photovoltaic + bigDF$GenerationinMWhCountryA_Wind + bigDF$GenerationinMWhCountryA_Biomass + 
        bigDF$GenerationinMWhCountryA_HydroPower + bigDF$GenerationinMWhCountryA_Biogas + bigDF$GenerationinMWhCountryA_WindOffshore) / bigDF$Total_DemandinMWh_Country_A) 
    , tick == j))
  
  seRealizedTargetB[j] <- std.error(subset( 
    ((bigDF$GenerationinMWhCountryB_Photovoltaic + bigDF$GenerationinMWhCountryB_Wind + bigDF$GenerationinMWhCountryB_Biomass + 
        bigDF$GenerationinMWhCountryB_HydroPower + bigDF$GenerationinMWhCountryB_Biogas + bigDF$GenerationinMWhCountryB_WindOffshore) / bigDF$Total_DemandinMWh_Country_B) 
    , tick == j))
}

meanRealizedTargetA
meanRealizedTargetB
seRealizedTargetA
seRealizedTargetB


mean((meanRealizedTargetA-targetDF$nl_target)*100)

renewableTargetDeviationAplot = ggplot(data=targetDF, aes(x=tick, y=(meanRealizedTargetA-nl_target)*100)) + 
  geom_point() + 
  xlab("Year") +  
  ylab("[%]") + 
  ggtitle("Difference Realized Renewable Target and \n NREAP target (Country A)") +  
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
plot(renewableTargetDeviationAplot)
ggsave(filename = paste(filePrefix, "renewableTargetDeviationA.pdf", sep=""),scale=1)

renewableTargetDeviationBplot = ggplot(data=targetDF, aes(x=tick, y=(meanRealizedTargetB-de_target)*100)) + 
  geom_point() + 
  xlab("Year") +  
  ylab("[%]") + 
  ggtitle("Difference Realized Renewable Target and \n NREAP target (Country B)") + 
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
plot(renewableTargetDeviationBplot)
ggsave(filename = paste(filePrefix, "renewableTargetDeviationB.pdf", sep=""),scale=1)



realizedTargetAplot = ggplot(data=tickDF, aes(x=X0, y=meanRealizedTargetA*100)) + 
  geom_errorbar(aes(ymin=(meanRealizedTargetA-seRealizedTargetA)*100, ymax=(meanRealizedTargetA+seRealizedTargetA)*100), width=1) + 
  geom_point() +
  xlab("Year") +  
  ylab("[%]") + 
  ggtitle("RES-E generation in terms of demand \n Country A") + 
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(realizedTargetAplot)
ggsave(filename = paste(filePrefix, "realizedTargetAplot.pdf", sep=""),scale=1)

nreapAplot = ggplot(data=targetDF, aes(x=tick, y=nl_target*100)) + 
  geom_point() + 
  xlab("Year") +  
  ylab("[%]") + 
  ggtitle("NREAP Target \n Country A") +  
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(nreapAplot)
ggsave(filename = paste(filePrefix, "NREAP_target_nl.pdf", sep=""),scale=1)




realizedTargetBplot = ggplot(data=tickDF, aes(x=X0, y=meanRealizedTargetB*100)) + 
  geom_errorbar(aes(ymin=(meanRealizedTargetB-seRealizedTargetB)*100, ymax=(meanRealizedTargetB+seRealizedTargetB)*100), width=1) + 
  geom_point() +
  xlab("Year") +  
  ylab("[%]") + 
  ggtitle("RES-E generation in terms of demand \n Country B") +  
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis),   
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(realizedTargetBplot)
ggsave(filename = paste(filePrefix, "realizedTargetBplot.pdf", sep=""),scale=1)



nreapBplot = ggplot(data=targetDF, aes(x=tick, y=de_target*100)) + 
  geom_point() + 
  xlab("Year") +  
  ylab("[%]") + 
  ggtitle("NREAP Target \n Country B") +   
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis),
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(nreapBplot)
ggsave(filename = paste(filePrefix, "NREAP_target_de.pdf", sep=""),scale=1)


# Average electricity wholesale price in country
meanElectricityPriceA=0
meanElectricityPriceB=0

for(j in 0:39) {
  meanElectricityPriceA[j] <- mean(subset(bigDF$Avg_El_PricesinEURpMWh_Country_A, tick == j))
  meanElectricityPriceB[j] <- mean(subset(bigDF$Avg_El_PricesinEURpMWh_Country_B, tick == j))
}


meanElectricityPriceAplot = ggplot(data=tickDF, aes(x=X0, y=meanElectricityPriceA)) + 
  geom_line() +
  xlab("Year") +  
  ylab("Eur/MWh") + 
  ggtitle("Mean electricity price \n Country A") + 
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(meanElectricityPriceAplot)
ggsave(filename = paste(filePrefix, "meanElectricityPriceA.pdf", sep=""),scale=1)

meanElectricityPriceBplot = ggplot(data=tickDF, aes(x=X0, y=meanElectricityPriceB)) + 
  geom_line() +
  xlab("Year") +  
  ylab("Eur/MWh") + 
  ggtitle("Mean electricity price \n Country B") +   
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis),
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(meanElectricityPriceBplot)
ggsave(filename = paste(filePrefix, "meanElectricityPriceB.pdf", sep=""),scale=1)

diff_el_price_AB = ggplot(data=tickDF , aes(x=X0, y=(meanElectricityPriceA-meanElectricityPriceB))) + 
  geom_line() +  #(aes(colour = runNumber))
  xlab("Year") +  
  ylab("Eur/MWh") + 
  ggtitle("Difference Electricity Price \n Country A - Country B") +   
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(diff_el_price_AB)
ggsave(filename = paste(filePrefix, "Diff_ElectricityPriceAverageAB.pdf", sep=""))


#Tender Clearing Prices
meanTenderClearingPriceA=0
meanTenderClearingPriceB=0


for(j in 0:39) {
  meanTenderClearingPriceA[j] <- mean(subset(bigDF$tenderClearingPrice_Country_A, tick == j))
  meanTenderClearingPriceB[j] <- mean(subset(bigDF$tenderClearingPrice_Country_B, tick == j))

}
meanTenderClearingPriceA
meanTenderClearingPriceB


tenderClearingPriceCountryAplot = ggplot(data=tickDF, aes(x=X0, y=meanTenderClearingPriceA)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur/MWh") + 
  ggtitle("Mean tender clearing price \n Country A") + 
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(tenderClearingPriceCountryAplot)
ggsave(filename = paste(filePrefix, "meanTenderClearingPriceA.pdf", sep=""),scale=1)

tenderClearingPriceCountryBplot = ggplot(data=tickDF, aes(x=X0, y=meanTenderClearingPriceB)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur/MWh") + 
  ggtitle("Mean tender clearing price \n Country B") +   
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(tenderClearingPriceCountryBplot)
ggsave(filename = paste(filePrefix, "meanTenderClearingPriceB.pdf", sep=""),scale=1)



## Tender clearing prices Tech Spec edition
meanTenderClearingPricePVA=0
meanTenderClearingPriceWindOffshoreA=0
meanTenderClearingPriceWindA=0
meanTenderClearingPriceBiomassA=0
meanTenderClearingPriceBiogasA=0
meanTenderClearingPricePVB=0
meanTenderClearingPriceWindOffshoreB=0
meanTenderClearingPriceWindB=0
meanTenderClearingPriceBiomassB=0
meanTenderClearingPriceBiogasB=0


for(j in 0:39) {
  meanTenderClearingPriceA[j] <- mean(subset(bigDF$tenderClearingPrice_Country_A, tick == j))
  meanTenderClearingPriceB[j] <- mean(subset(bigDF$tenderClearingPrice_Country_B, tick == j))
  
}
meanTenderClearingPriceA
meanTenderClearingPriceB


tenderClearingPriceCountryAplot = ggplot(data=tickDF, aes(x=X0, y=meanTenderClearingPriceA)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur/MWh") + 
  ggtitle("Mean tender clearing price \n Country A") + 
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(tenderClearingPriceCountryAplot)
ggsave(filename = paste(filePrefix, "meanTenderClearingPriceA.pdf", sep=""),scale=1)

tenderClearingPriceCountryBplot = ggplot(data=tickDF, aes(x=X0, y=meanTenderClearingPriceB)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur/MWh") + 
  ggtitle("Mean tender clearing price \n Country B") +   
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(tenderClearingPriceCountryBplot)
ggsave(filename = paste(filePrefix, "meanTenderClearingPriceB.pdf", sep=""),scale=1)



# Tender subsidies

meanTotalTenderSubsidyA=0
meanTotalTenderSubsidyB=0

for(j in 0:39) {
  meanTotalTenderSubsidyA[j] <- mean(subset(bigDF$CountryAProdFinances_Tender_Subsidy , tick == j))
  meanTotalTenderSubsidyB[j] <- mean(subset(bigDF$CountryBProdFinances_Tender_Subsidy, tick == j))
}
meanTotalTenderSubsidyA
meanTotalTenderSubsidyB

TotalTenderSubsidyCountryAplot = ggplot(data=tickDF, aes(x=X0, y=meanTotalTenderSubsidyA)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Mean total tender subsidies \n Country A") +   
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(TotalTenderSubsidyCountryAplot)
ggsave(filename = paste(filePrefix, "meanTotalTenderSubsidyA.pdf", sep=""),scale=1)

TotalTenderSubsidyCountryBplot = ggplot(data=tickDF, aes(x=X0, y=meanTotalTenderSubsidyB)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Mean total tender subsidies \n Country B") +    
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(TotalTenderSubsidyCountryBplot)
ggsave(filename = paste(filePrefix, "meanTotalTenderSubsidyB.pdf", sep=""),scale=1)



#supply ratio
meanSupplyRatioA=0
meanSupplyRatioB=0

for(j in 0:39) {
  meanSupplyRatioA[j] <- mean(subset(bigDF$TotalOperationalCapacityPerZoneInMW_Country_A/bigDF$PeakDemandPerZoneInMW_Country_A, tick == j))
  meanSupplyRatioB[j] <- mean(subset(bigDF$TotalOperationalCapacityPerZoneInMW_Country_B/bigDF$PeakDemandPerZoneInMW_Country_B, tick == j))
}
meanSupplyRatioA
meanSupplyRatioB

meanSupplyRatioAplot = ggplot(data=tickDF, aes(x=X0, y=meanSupplyRatioA)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Mean supply ratio \n Country A") +    
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(meanSupplyRatioAplot)
ggsave(filename = paste(filePrefix, "meanSupplyRatioA.pdf", sep=""),scale=1)

meanSupplyRatioBplot = ggplot(data=tickDF, aes(x=X0, y=meanSupplyRatioB)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Mean supply ratio \n Country B") +    
  theme(axis.title.x = element_text(face="bold", size=xTitle), axis.text.x=element_text(size = xAxis), 
        axis.title.y = element_text(face="bold", size=yTitle), axis.text.y=element_text(size = yAxis))
#plot(meanSupplyRatioBplot)
ggsave(filename = paste(filePrefix, "meanSupplyRatioB.pdf", sep=""),scale=1)

DataTable <- c(format(mean(meanConsumerCostsA), scientific=TRUE))
DataTable <- rbind(DataTable, c(format(mean(meanProducerCostsA), scientific=TRUE)))
DataTable <- rbind(DataTable, c(format(mean(meanGovernmentCostsA), scientific=TRUE)))
DataTable <- rbind(DataTable, c(format(mean(meanConsumerCostsB), scientific=TRUE)))
DataTable <- rbind(DataTable, c(format(mean(meanProducerCostsB), scientific=TRUE)))
DataTable <- rbind(DataTable, c(format(mean(meanGovernmentCostsB), scientific=TRUE)))
DataTable <- rbind(DataTable, c(format(mean(meanAggProfitA), scientific=TRUE)))
DataTable <- rbind(DataTable, c(format(mean(meanAggProfitB), scientific=TRUE)))
DataTable <- rbind(DataTable, c(format(mean(meanProducerCashA), scientific=TRUE)))
DataTable <- rbind(DataTable, c(format(mean(meanProducerCashB), scientific=TRUE)))
DataTable <- rbind(DataTable, c(format(sd(meanConsumerCostsA), scientific=TRUE)))
DataTable <- rbind(DataTable, c(format(sd(meanProducerCostsA), scientific=TRUE)))
DataTable <- rbind(DataTable, c(format(sd(meanGovernmentCostsA), scientific=TRUE)))
DataTable <- rbind(DataTable, c(format(sd(meanConsumerCostsB), scientific=TRUE)))
DataTable <- rbind(DataTable, c(format(sd(meanProducerCostsB), scientific=TRUE)))
DataTable <- rbind(DataTable, c(format(sd(meanGovernmentCostsB), scientific=TRUE)))
DataTable <- rbind(DataTable, c(format(sd(meanAggProfitA), scientific=TRUE)))
DataTable <- rbind(DataTable, c(format(sd(meanAggProfitB), scientific=TRUE)))
DataTable <- rbind(DataTable, c(format(sd(meanProducerCashA), scientific=TRUE)))
DataTable <- rbind(DataTable, c(format(sd(meanProducerCashB), scientific=TRUE)))
colnames(DataTable) <- c("Value")
rownames(DataTable) <- c("Mean Consumer welfare A","Mean Producer costs A", "Government Costs A", "Mean Consumer welfare B","Mean Producer costs B", "Government Costs B", "Mean Aggregate profit A", "Mean Aggregate profit B", "Prod Cash A", "Prod Cash B","sd Consumer welfare A","sd Producer costs A", "sd Government Costs A", "sd Consumer welfare B","sd Producer costs B", "sd Government Costs B", " sd Aggregate profit A", "sd Aggregate profit B", "sd Prod Cash A", "sd Prod Cash B")
write.csv(DataTable, "DataTableMeanAndSDCostsWelfare.csv")

DataTable <- c(mean(meanFixedOMCostsA))
DataTable <- rbind(DataTable, c(mean(meanLoanCostsA)))
DataTable <- rbind(DataTable, c(mean(meanCommodityCostsA)))
DataTable <- rbind(DataTable, c(mean(meanDownpaymentsCostsA)))
DataTable <- rbind(DataTable, c(mean(meanFixedOMCostsB)))
DataTable <- rbind(DataTable, c(mean(meanLoanCostsB)))
DataTable <- rbind(DataTable, c(mean(meanCommodityCostsB)))
DataTable <- rbind(DataTable, c(mean(meanDownpaymentsCostsB)))
rownames(DataTable) <- c("Mean Fixed costs OM A","Mean Loan costs A", "Mean Commodity costs A", "Mean downpayments A","Mean Fixed costs OM B","Mean Loan costs B", "Mean Commodity costs B", "Mean downpayments B") 
write.csv(DataTable, "DataTableBreakdownCosts.csv")

DataTable <- c(mean(meanTenderClearingPriceA))
DataTable <- rbind(DataTable, c(mean(meanTenderClearingPriceB)))
DataTable <- rbind(DataTable, c(sd(meanTenderClearingPriceA)))
DataTable <- rbind(DataTable, c(sd(meanTenderClearingPriceB)))
DataTable <- rbind(DataTable, c(mean(meanElectricityPriceA)))
DataTable <- rbind(DataTable, c(mean(meanElectricityPriceB)))
DataTable <- rbind(DataTable, c(sd(meanElectricityPriceA)))
DataTable <- rbind(DataTable, c(sd(meanElectricityPriceB)))
DataTable <- rbind(DataTable, c(mean(meanElectricityPriceA-meanElectricityPriceB)))
DataTable <- rbind(DataTable, c(mean(meanSupplyRatioA)))
DataTable <- rbind(DataTable, c(mean(meanSupplyRatioB)))
DataTable <- rbind(DataTable, c(sd(meanSupplyRatioA)))
DataTable <- rbind(DataTable, c(sd(meanSupplyRatioB)))
rownames(DataTable) <- c("Mean Tender Price A", "Mean Tender Price B","SD Tender Price A", "SD Tender Price B","Mean El Price A", "Mean El Price B","SD El Price A", "SD El Price B","Mean Diff El Price AB"  ,"Mean SR A", "Mean SR B", "SD SR A", "SD SR B")
write.csv(DataTable, "DataTablePricesSupplyRatios.csv")



