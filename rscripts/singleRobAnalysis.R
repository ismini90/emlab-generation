setwd("~/emlab-generation/rscripts")
source("rConfig.R")
source("batchRunAnalysis.R")

#File and folder initiation
nameFile <- "SuperTechSpec"
analysisFolder <- "~/Desktop/emlabGen/output/"
analysisFolder <- paste(analysisFolder, nameFile, "/", sep="")
analysisFolder
setwd(analysisFolder)
analysisFile <- paste(nameFile, ".csv", sep="")
analysisFile
scaleFactor <- 1
filePrefix <- nameFile

#Read csv-file
bigDF <- read.csv(analysisFile)
tickDF <- read.csv("~/Desktop/emlabGen/analysis/39ticks.csv")
# segmentDF <- read.csv("~/Desktop/emlabGen/output/nameFile/nameFile-SegmentClearingPoints.csv")
targetDF <- read.csv("~/Desktop/emlabGen/analysis/R_policyGoalNREAP_NL_DE_2050.csv")

#Initiate
technologyOrder=c("Nuclear","Lignite","CoalPSC","IGCC","CCGT","OCGT","Biomass","Biogas","Wind","WindOffshore","PV")
technologyPalette=c("CoalPSC" = "black", "Biomass" = "darkgreen", "Biogas"="darkolivegreen3", "Nuclear" = "purple", "Lignite" = "saddlebrown",
                    "OCGT" = "darkred", "CCGT" = "blue", "PV" = "yellow", "Wind" = "chartreuse4",
                    "CoalPscCCS" = "darkgray", "IGCC" = "orange", "IgccCCS"="orangered", "CcgtCCS" = "red",
                    "WindOffshore" = "navyblue", "HydroPower" = "skyblue3")
producerPalette=c("A"="black","B"="darkgreen","C"="purple","D"="darkred","E"="blue","F"="yellow","G"="orange","H"="navyblue","I"="darkgrey")

tick <- bigDF$tick
# tick

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

#Melt dataframe
# moltenDF <- melt(bigDF, id.vars = c("runId","tick"))
# moltenDF

library(gridExtra)
library(TeachingDemos)
library(grid)
library(ggplot2)
library(reshape2)

# System costs
meanConsumerCostsA=0
meanProducerCostsA=0
meanGovernmentCostsA=0
meanConsumerCostsB=0
meanProducerCostsB=0
meanGovernmentCostsB=0

for(j in 0:39) {
  meanConsumerCostsA[j] <- mean(subset(bigDF$ConsumerExpenditure_Country_A_electricity_spot_market, tick == j))
  meanProducerCostsA[j] <- mean(subset(bigDF$CountryAProdCosts_Fixed_O_M + 
                                         bigDF$CountryAProdCosts_Loan + 
                                         bigDF$CountryAProdCosts_Commodity + 
                                         bigDF$CountryAProdCosts_Downpayment, tick == j))
  meanGovernmentCostsA[j] <- mean(subset(bigDF$CountryAProdFinances_Tender_Subsidy, tick == j))
  meanConsumerCostsB[j] <- mean(subset(bigDF$ConsumerExpenditure_Country_B_electricity_spot_market, tick == j))
  meanProducerCostsB[j] <- mean(subset(bigDF$CountryBProdCosts_Fixed_O_M + 
                                         bigDF$CountryBProdCosts_Loan + 
                                         bigDF$CountryBProdCosts_Commodity + 
                                         bigDF$CountryBProdCosts_Downpayment, tick == j))
  meanGovernmentCostsB[j] <- mean(subset(bigDF$CountryBProdFinances_Tender_Subsidy, tick == j))
}

meanConsumerCostsA
meanProducerCostsA
meanGovernmentCostsA
meanConsumerCostsB
meanProducerCostsB
meanGovernmentCostsB

meanSystemCostsA <- meanConsumerCostsA + meanProducerCostsA + meanGovernmentCostsA
meanSystemCostsB <- meanConsumerCostsB + meanProducerCostsB + meanGovernmentCostsB
meanSystemCostsOverall <- meanSystemCostsA + meanSystemCostsB

fracMeanConsumerCostsA <- meanConsumerCostsA*100 / (meanSystemCostsA) 
fracMeanProducerCostsA <- meanProducerCostsA*100 / (meanSystemCostsA) 
fracMeanGovernmentCostsA <- meanGovernmentCostsA*100/ (meanSystemCostsA) 

fracMeanConsumerCostsB <- meanConsumerCostsB*100 / (meanSystemCostsB) 
fracMeanProducerCostsB <- meanProducerCostsB*100 / (meanSystemCostsB) 
fracMeanGovernmentCostsB <- meanGovernmentCostsB*100/ (meanSystemCostsB) 

DataTable <- c(fracMeanConsumerCostsA)
DataTable <- rbind(DataTable, c(fracMeanProducerCostsA))
DataTable <- rbind(DataTable, c(fracMeanGovernmentCostsA))
colnames(DataTable) <- c("Mean fraction")
rownames(DataTable) <- c(" Consumer Costs A"," Producer Costs A",
                         " Government Costs A")
write.csv(DataTable, "DataTableSystemCostsA.csv")
systemCostsDataA <- melt(DataTable)

ggplot(systemCostsDataA, aes(X2, value, fill = X1)) + 
  guides(fill=guide_legend(title=NULL)) +
  # scale_fill_manual(values=c("green", "red", "blue")) +
  geom_bar(stat = "identity") + 
  xlab("Year") + 
  ylab("Fraction") +
ggtitle("System costs breakdown country A")
ggsave(filename = paste(filePrefix, "breakdownSystemCostsAplot.png", sep=""))

DataTable <- c(fracMeanConsumerCostsB)
DataTable <- rbind(DataTable, c(fracMeanProducerCostsB))
DataTable <- rbind(DataTable, c(fracMeanGovernmentCostsB))
colnames(DataTable) <- c("Mean fraction")
rownames(DataTable) <- c(" Consumer Costs B"," Producer Costs B",
                         " Government Costs B")
write.csv(DataTable, "DataTableSystemCostsB.csv")
systemCostsDataB <- melt(DataTable)

ggplot(systemCostsDataB, aes(X2, value, fill = X1)) + 
  guides(fill=guide_legend(title=NULL)) +
  # scale_fill_manual(values=c("green", "red", "blue")) +
  geom_bar(stat = "identity") + 
  xlab("Year") + 
  ylab("Fraction") +
  ggtitle("System costs breakdown country B")
ggsave(filename = paste(filePrefix, "breakdownSystemCostsBplot.png", sep=""))

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
  ggtitle("Relative generation shares Country A")
ggsave(filename = paste(filePrefix, "relativeGenerationShareAplot.png", sep=""))

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
  ggtitle("Relative generation shares Country B")
ggsave(filename = paste(filePrefix, "relativeGenerationShareBplot.png", sep=""))


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
  meanCapSharePVA[j] <- mean(subset(bigDF$CapacityinMWinA_Photovoltaic / bigDF$TotalOperationalCapacityPerZoneInMW_Country_A, tick == j))
  meanCapShareWindA[j] <- mean(subset(bigDF$CapacityinMWinA_Wind / bigDF$TotalOperationalCapacityPerZoneInMW_Country_A, tick == j))
  meanCapShareWindOffshoreA[j] <- mean(subset(bigDF$CapacityinMWinA_WindOffshore / bigDF$TotalOperationalCapacityPerZoneInMW_Country_A, tick == j))
  meanCapShareBiomassA[j] <- mean(subset(bigDF$CapacityinMWinA_Biomass / bigDF$TotalOperationalCapacityPerZoneInMW_Country_A, tick == j))
  meanCapShareBiogasA[j] <- mean(subset(bigDF$CapacityinMWinA_Biogas / bigDF$TotalOperationalCapacityPerZoneInMW_Country_A, tick == j))
  meanCapShareCoalA[j] <- mean(subset(bigDF$CapacityinMWinA_CoalPSC / bigDF$TotalOperationalCapacityPerZoneInMW_Country_A, tick == j))
  meanCapShareIGCCA[j] <- mean(subset(bigDF$CapacityinMWinA_IGCC / bigDF$TotalOperationalCapacityPerZoneInMW_Country_A, tick == j))
  meanCapShareLigniteA[j] <- mean(subset(bigDF$CapacityinMWinA_Lignite / bigDF$TotalOperationalCapacityPerZoneInMW_Country_A, tick == j))
  meanCapShareOCGTA[j] <- mean(subset(bigDF$CapacityinMWinA_OCGT / bigDF$TotalOperationalCapacityPerZoneInMW_Country_A, tick == j))
  meanCapShareCCGTA[j] <- mean(subset(bigDF$CapacityinMWinA_CCGT / bigDF$TotalOperationalCapacityPerZoneInMW_Country_A, tick == j))
  meanCapShareNuclearA[j] <- mean(subset(bigDF$CapacityinMWinA_Nuclear / bigDF$TotalOperationalCapacityPerZoneInMW_Country_A, tick == j))
  meanCapSharePVB[j] <- mean(subset(bigDF$CapacityinMWinB_Photovoltaic / bigDF$TotalOperationalCapacityPerZoneInMW_Country_B, tick == j))
  meanCapShareWindB[j] <- mean(subset(bigDF$CapacityinMWinB_Wind / bigDF$TotalOperationalCapacityPerZoneInMW_Country_B, tick == j))
  meanCapShareWindOffshoreB[j] <- mean(subset(bigDF$CapacityinMWinB_WindOffshore / bigDF$TotalOperationalCapacityPerZoneInMW_Country_B, tick == j))
  meanCapShareBiomassB[j] <- mean(subset(bigDF$CapacityinMWinB_Biomass / bigDF$TotalOperationalCapacityPerZoneInMW_Country_B, tick == j))
  meanCapShareBiogasB[j] <- mean(subset(bigDF$CapacityinMWinB_Biogas / bigDF$TotalOperationalCapacityPerZoneInMW_Country_B, tick == j))
  meanCapShareIGCCB[j] <- mean(subset(bigDF$CapacityinMWinB_IGCC / bigDF$TotalOperationalCapacityPerZoneInMW_Country_B, tick == j))
  meanCapShareCoalB[j] <- mean(subset(bigDF$CapacityinMWinB_CoalPSC / bigDF$TotalOperationalCapacityPerZoneInMW_Country_B, tick == j))
  meanCapShareLigniteB[j] <- mean(subset(bigDF$CapacityinMWinB_Lignite / bigDF$TotalOperationalCapacityPerZoneInMW_Country_B, tick == j))
  meanCapShareOCGTB[j] <- mean(subset(bigDF$CapacityinMWinB_OCGT / bigDF$TotalOperationalCapacityPerZoneInMW_Country_B, tick == j))
  meanCapShareCCGTB[j] <- mean(subset(bigDF$CapacityinMWinB_CCGT / bigDF$TotalOperationalCapacityPerZoneInMW_Country_B, tick == j))
  meanCapShareNuclearB[j] <- mean(subset(bigDF$CapacityinMWinB_Nuclear / bigDF$TotalOperationalCapacityPerZoneInMW_Country_B, tick == j))
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
  ggtitle("Relative capacity shares Country A")
ggsave(filename = paste(filePrefix, "relativeGenerationCapShareAplot.png", sep=""))

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

ggplot(CapShareDataB, aes(X2, value, fill = X1)) + 
  guides(fill=guide_legend(title=NULL)) +
  scale_fill_manual(values=technologyPalette) +
  geom_area(stat = "identity") + 
  xlab("Year") + 
  ylab("Fraction") +
  ggtitle("Relative capacity shares Country B")
ggsave(filename = paste(filePrefix, "relativeGenerationCapShareBplot.png", sep=""))


# Renewable generation in terms of demand (compare this with NREAP targets)
meanRealizedTargetA=0
meanRealizedTargetB=0
for(j in 0:39) {
  meanRealizedTargetA[j] <- mean(subset( 
    ((bigDF$GenerationinMWhCountryA_Photovoltaic + bigDF$GenerationinMWhCountryA_Wind + bigDF$GenerationinMWhCountryA_Biomass + 
      bigDF$GenerationinMWhCountryA_HydroPower + bigDF$GenerationinMWhCountryA_Biogas + bigDF$GenerationinMWhCountryA_WindOffshore) / bigDF$Total_DemandinMWh_Country_A) 
    , tick == j))
   meanRealizedTargetB[j] <- mean(subset( 
    ((bigDF$GenerationinMWhCountryB_Photovoltaic + bigDF$GenerationinMWhCountryB_Wind + bigDF$GenerationinMWhCountryB_Biomass + 
        bigDF$GenerationinMWhCountryB_HydroPower + bigDF$GenerationinMWhCountryB_Biogas + bigDF$GenerationinMWhCountryB_WindOffshore) / bigDF$Total_DemandinMWh_Country_B) 
    , tick == j))
}
plot(meanRealizedTargetA)


realizedTargetAplot = ggplot(data=tickDF, aes(x=X0, y=meanRealizedTargetA*100)) + 
  geom_point() +
  xlab("Year") +  
  ylab("[%]") + 
  ggtitle("RES-E generation in terms of demand \n Country A") #give the plot a title
plot(realizedTargetAplot)
ggsave(filename = paste(filePrefix, "realizedTargetAplot.png", sep=""),scale=1)

nreapAplot = ggplot(data=targetDF, aes(x=tick, y=nl_target*100)) + 
  geom_point() + 
  xlab("Year") +  
  ylab("[%]") + 
  ggtitle("NREAP Target \n Country A") #give the plot a title
plot(nreapAplot)
ggsave(filename = paste(filePrefix, "NREAP_target_nl.png", sep=""),scale=1)

realizedTargetBplot = ggplot(data=tickDF, aes(x=X0, y=meanRealizedTargetB*100)) + 
  geom_point() +
  xlab("Year") +  
  ylab("[%]") + 
  ggtitle("RES-E generation in terms of demand \n Country B") #give the plot a title
plot(realizedTargetBplot)
ggsave(filename = paste(filePrefix, "realizedTargetBplot.png", sep=""),scale=1)

nreapBplot = ggplot(data=targetDF, aes(x=tick, y=de_target*100)) + 
  geom_point() + 
  xlab("Year") +  
  ylab("[%]") + 
  ggtitle("NREAP Target \n Country B") #give the plot a title
plot(nreapBplot)
ggsave(filename = paste(filePrefix, "NREAP_target_de.png", sep=""),scale=1)


# Average electricity wholesale price in country
meanElectricityPriceA=0
meanElectricityPriceB=0

for(j in 0:39) {
  meanElectricityPriceA[j] <- mean(subset(bigDF$Avg_El_PricesinEURpMWh_Country_A, tick == j))
  meanElectricityPriceB[j] <- mean(subset(bigDF$Avg_El_PricesinEURpMWh_Country_B, tick == j))
}
meanElectricityPriceA
meanElectricityPriceB

meanElectricityPriceAplot = ggplot(data=tickDF, aes(x=X0, y=meanElectricityPriceA)) + 
  geom_line() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Mean electricity price \n Country A") #give the plot a title
plot(meanElectricityPriceAplot)
ggsave(filename = paste(filePrefix, "meanElectricityPriceA.png", sep=""),scale=1)

meanElectricityPriceBplot = ggplot(data=tickDF, aes(x=X0, y=meanElectricityPriceB)) + 
  geom_line() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Mean electricity price \n Country B") #give the plot a title
plot(meanElectricityPriceBplot)
ggsave(filename = paste(filePrefix, "meanElectricityPriceB.png", sep=""),scale=1)

diff_el_price_AB = ggplot(data=tickDF , aes(x=X0, y=(meanElectricityPriceA-meanElectricityPriceB))) + 
  geom_line() +  #(aes(colour = runNumber))
  xlab("Year") +  
  ylab("Eur/MWh") + 
  ggtitle("Difference Electricity Price \n Country A - Country B") #give the plot a title
plot(diff_el_price_AB)
ggsave(filename = paste(filePrefix, "Diff_ElectricityPriceAverageAB.png", sep=""))

#Tender Clearing Prices, subsidies
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
  ylab("Eur") + 
  ggtitle("Mean tender clearing price \n Country A") #give the plot a title
plot(tenderClearingPriceCountryAplot)
ggsave(filename = paste(filePrefix, "meanTenderClearingPriceA.png", sep=""),scale=1)

tenderClearingPriceCountryBplot = ggplot(data=tickDF, aes(x=X0, y=meanTenderClearingPriceB)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Mean tender clearing price \n Country B") #give the plot a title
plot(tenderClearingPriceCountryBplot)
ggsave(filename = paste(filePrefix, "meanTenderClearingPriceB.png", sep=""),scale=1)


# Tender subsidies
meanTotalTenderSubsidyA=0
meanTotalTenderSubsidyB=0

for(j in 0:39) {
  meanTotalTenderSubsidyA[j] <- mean(subset(bigDF$yearlyTotalTenderSubsidyCountryA_Tender_Subsidy_Yearly_Country_A, tick == j))
  meanTotalTenderSubsidyB[j] <- mean(subset(bigDF$yearlyTotalTenderSubsidyCountryB_Tender_Subsidy_Yearly_Country_B, tick == j))
}
meanTotalTenderSubsidyA
meanTotalTenderSubsidyB

TotalTenderSubsidyCountryAplot = ggplot(data=tickDF, aes(x=X0, y=meanTotalTenderSubsidyA)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Mean total tender subsidies \n Country A") #give the plot a title
plot(TotalTenderSubsidyCountryAplot)
ggsave(filename = paste(filePrefix, "meanTotalTenderSubsidyA.png", sep=""),scale=1)

TotalTenderSubsidyCountryBplot = ggplot(data=tickDF, aes(x=X0, y=meanTotalTenderSubsidyB)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Mean total tender subsidies \n Country B") #give the plot a title
plot(TotalTenderSubsidyCountryBplot)
ggsave(filename = paste(filePrefix, "meanTotalTenderSubsidyB.png", sep=""),scale=1)


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
  ggtitle("Mean supply ratio \n Country A") #give the plot a title
plot(meanSupplyRatioAplot)
ggsave(filename = paste(filePrefix, "meanSupplyRatioA.png", sep=""),scale=1)

meanSupplyRatioBplot = ggplot(data=tickDF, aes(x=X0, y=meanSupplyRatioB)) + 
  geom_point() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Mean supply ratio \n Country B") #give the plot a title
plot(meanSupplyRatioBplot)
ggsave(filename = paste(filePrefix, "meanSupplyRatioB.png", sep=""),scale=1)


#Demand
demandCountryAplot = ggplot(data=bigDF, aes(x=tick, y=Total_DemandinMWh_Country_A, group=runId)) + 
  geom_smooth() + #(aes(colour = runNumber))
  xlab("Year") +  
  ylab("Demand (MWh)") + 
  ggtitle("Demand \n Country A") #give the plot a title
plot(demandCountryAplot)
ggsave(filename = paste(filePrefix, "demand_A.png", sep=""))

demandCountryBplot = ggplot(data=bigDF, aes(x=tick, y=Total_DemandinMWh_Country_B, group=runId)) + 
  geom_smooth() + #(aes(colour = runNumber))
  xlab("Year") +  
  ylab("Demand (MWh)") + 
  ggtitle("Demand \n Country B") #give the plot a title
plot(demandCountryBplot)
ggsave(filename = paste(filePrefix, "demand_B.png", sep=""))


#Segment prices
pSA_1 = 
  ggplot(data=bigDF, aes(x=tick)) + 
  geom_smooth(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_1), method= "loess") + #(aes(colour = runId)) +
  xlab("Tick") +  
  ylab("Price (EUR/MWh)") + 
  ggtitle("Segment 1 - Country A") #give the plot a title
plot(pSA_1)

pSA_2 = 
  ggplot(data=bigDF, aes(x=tick)) + 
  geom_smooth(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_2), method= "loess") + #(aes(colour = runId)) +
  xlab("Tick") +  
  ylab("Price (EUR/MWh)") + 
  ggtitle("Segment 2 - Country A") #give the plot a title
plot(pSA_2)

pSA_3 = 
  ggplot(data=bigDF, aes(x=tick)) + 
  geom_smooth(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_3), method= "loess") + #(aes(colour = runId)) +
  xlab("Tick") +  
  ylab("Price (EUR/MWh)") + 
  ggtitle("Segment 3 - Country A") #give the plot a title
plot(pSA_3)

pSA_4 = 
  ggplot(data=bigDF, aes(x=tick)) + 
  geom_smooth(aes(y=bigDF$PriceInEURperMWh_Segment_Country_A_4), method= "loess") + #(aes(colour = runId)) +
  xlab("Tick") +  
  ylab("Price (EUR/MWh)") + 
  ggtitle("Segment 4 - Country A") #give the plot a title
plot(pSA_4)

pSB_1 = 
  ggplot(data=bigDF, aes(x=tick)) + 
  geom_smooth(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_1), method= "loess") + #(aes(colour = runId)) +
  xlab("Tick") +  
  ylab("Price (EUR/MWh)") + 
  ggtitle("Segment 1 - Country B") #give the plot a title
plot(pSB_1)

pSB_2 = 
  ggplot(data=bigDF, aes(x=tick)) + 
  geom_smooth(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_2), method= "loess") + #(aes(colour = runId)) +
  xlab("Tick") +  
  ylab("Price (EUR/MWh)") + 
  ggtitle("Segment 2 - Country B") #give the plot a title
plot(pSB_2)

pSB_3 = 
  ggplot(data=bigDF, aes(x=tick)) + 
  geom_smooth(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_3), method= "loess") + #(aes(colour = runId)) +
  xlab("Tick") +  
  ylab("Price (EUR/MWh)") + 
  ggtitle("Segment 3 - Country B") #give the plot a title
plot(pSB_3)

pSB_4 = 
  ggplot(data=bigDF, aes(x=tick)) + 
  geom_smooth(aes(y=bigDF$PriceInEURperMWh_Segment_Country_B_4), method= "loess") + #(aes(colour = runId)) +
  xlab("Tick") +  
  ylab("Price (EUR/MWh)") + 
  ggtitle("Segment 4 - Country B") #give the plot a title
plot(pSB_4)

noInitialShortagesPlot <-multiplot(pSA_1,pSA_2,pSA_3,pSA_4, pSB_1,pSB_2,pSB_3,pSB_4, cols=4)
plot(noInitialShortagesPlot)
ggsave(filename = paste(filePrefix, "noInitialShortages.png", sep=""))



# Overall welfare
meanConsumerWelfare=0
meanProducerWelfare=0
meanWelfareLossENS=0

for(j in 0:39) {
  meanConsumerWelfare[j] <- mean(subset(bigDF$ConsumerExpenditure_Country_A_electricity_spot_market + bigDF$ConsumerExpenditure_Country_B_electricity_spot_market, tick == j))
  meanProducerWelfare[j] <- mean(subset(bigDF$AggregateFinances_Profit, tick == j))
  meanWelfareLossENS[j] <- mean(subset(bigDF$WelfareLossThroughENS_Country_A + bigDF$WelfareLossThroughENS_Country_B, tick == j))
}

meanConsumerWelfare
meanProducerWelfare
meanWelfareLossENS

meanOverallWelfare <- meanConsumerWelfare + meanProducerWelfare + meanWelfareLossENS
sd(meanOverallWelfare )
meanOverallWelfareplot = ggplot(data=tickDF, aes(x=X0, y=meanOverallWelfare)) + 
  geom_line() +
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Mean overall welfare") #give the plot a title
plot(meanOverallWelfareplot)
ggsave(filename = paste(filePrefix, "meanOverallWelfareplot.png", sep=""),scale=1)

meanConsumerWelfareStart <- mean(subset(bigDF$ConsumerExpenditure_Country_A_electricity_spot_market + bigDF$ConsumerExpenditure_Country_B_electricity_spot_market, tick == 0))
meanProducerWelfareStart <- mean(subset(bigDF$AggregateFinances_Profit, tick == 0))
meanWelfareLossENSStart <- mean(subset(bigDF$WelfareLossThroughENS_Country_A + bigDF$WelfareLossThroughENS_Country_B, tick == 0))

meanConsumerWelfareEnd <- mean(subset(bigDF$ConsumerExpenditure_Country_A_electricity_spot_market + bigDF$ConsumerExpenditure_Country_B_electricity_spot_market, tick == 39))
meanProducerWelfareEnd <- mean(subset(bigDF$AggregateFinances_Profit, tick == 39))
meanWelfareLossENSEnd <- mean(subset(bigDF$WelfareLossThroughENS_Country_A + bigDF$WelfareLossThroughENS_Country_B, tick == 39))

meanStartOverallWelfare <- meanConsumerWelfareStart + meanProducerWelfareStart + meanWelfareLossENSStart
meanEndOverallWelfare <- meanConsumerWelfareEnd + meanProducerWelfareEnd + meanWelfareLossENSEnd

meanChangeOverallWelfare <- meanEndOverallWelfare - meanStartOverallWelfare
meanChangeOverallWelfare

write.table(meanChangeOverallWelfare , file = "meanChangeOverallWelfare.csv",row.names=FALSE, na="",col.names=FALSE, sep=",")

## Producer welfare changes / Income distrubition changes

meanProfitA=0 
meanProfitB=0
meanProfitC=0 
meanProfitD=0 
meanProfitE=0
meanProfitF=0
meanProfitG=0
meanProfitH=0
meanProfitI=0

for(j in 0:39) {
  meanProfitA[j] <- mean(subset(bigDF$ProfitProducersYearlyIncludingTenderSubsidy_ProfitProdA, tick == j))
  meanProfitB[j] <- mean(subset(bigDF$ProfitProducersYearlyIncludingTenderSubsidy_ProfitProdB, tick == j))
  meanProfitC[j] <- mean(subset(bigDF$ProfitProducersYearlyIncludingTenderSubsidy_ProfitProdC, tick == j))
  meanProfitD[j] <- mean(subset(bigDF$ProfitProducersYearlyIncludingTenderSubsidy_ProfitProdD, tick == j))
  meanProfitE[j] <- mean(subset(bigDF$ProfitProducersYearlyIncludingTenderSubsidy_ProfitProdE, tick == j))
  meanProfitF[j] <- mean(subset(bigDF$ProfitProducersYearlyIncludingTenderSubsidy_ProfitProdF, tick == j))
  meanProfitG[j] <- mean(subset(bigDF$ProfitProducersYearlyIncludingTenderSubsidy_ProfitProdG, tick == j))
  meanProfitH[j] <- mean(subset(bigDF$ProfitProducersYearlyIncludingTenderSubsidy_ProfitProdH, tick == j))
  meanProfitI[j] <- mean(subset(bigDF$ProfitProducersYearlyIncludingTenderSubsidy_ProfitProdI, tick == j))
}

meanProfitA
meanProfitB
meanProfitC
meanProfitD 
meanProfitE
meanProfitF
meanProfitG
meanProfitH
meanProfitI

DataTable <- c(meanProfitA)
DataTable <- rbind(DataTable, c(meanProfitB))
DataTable <- rbind(DataTable, c(meanProfitC))
DataTable <- rbind(DataTable, c(meanProfitD))
DataTable <- rbind(DataTable, c(meanProfitE))
DataTable <- rbind(DataTable, c(meanProfitF))
DataTable <- rbind(DataTable, c(meanProfitG))
DataTable <- rbind(DataTable, c(meanProfitH))
DataTable <- rbind(DataTable, c(meanProfitI))
colnames(DataTable) <- c(nameFile)
rownames(DataTable) <- c("A","B","C","D","E","F","G","H","I")
write.csv(DataTable, "DataTableIncomeDistribution.csv")
meanIncomeDistribution <- melt(DataTable)

ggplot(meanIncomeDistribution, aes(X2, value, fill = X1)) + 
  guides(fill=guide_legend(title=NULL)) +
  scale_fill_manual(values=producerPalette) +
  geom_area(stat = "identity") + 
  xlab("Year") + 
  ylab("Eur") +
  ggtitle("Income distribution")
ggsave(filename = paste(filePrefix, "incomeDistributionplot.png", sep=""))


consumerExpenditureAplot = ggplot(data=moltenDFconsumerExpenditureA, aes(x=tick)) + 
  geom_smooth(aes(y=value), colour="red", method = "loess") + 
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Consumer expenditure \n Country A") #give the plot a title
plot(consumerExpenditureAplot)

CapShareDataB <- melt(DataTable)





#Consumer Welfare = Difference in consumer expenditure at the beginning and end of simulation
moltenDFconsumerExpenditureA <- melt(bigDF, id.vars = "tick", "ConsumerExpenditure_Country_A_electricity_spot_market")
moltenDFconsumerExpenditureB <- melt(bigDF, id.vars = "tick", "ConsumerExpenditure_Country_B_electricity_spot_market")

s1 <- subset(moltenDFconsumerExpenditureA , tick==0)
s2 <- subset(moltenDFconsumerExpenditureA , tick==39)
changeConsumerExpenditureA <- (s2$value - s1$value)
pcChangeConsumerExpenditureA <- changeConsumerExpenditureA*100/s1$value
meanPcChangeConsumerExpenditureA <- mean(pcChangeConsumerExpenditureA)

s1 <- subset(moltenDFconsumerExpenditureB , tick==0)
s2 <- subset(moltenDFconsumerExpenditureB , tick==39)
changeConsumerExpenditureB <- (s2$value - s1$value)
pcChangeConsumerExpenditureB <- changeConsumerExpenditureB*100/s1$value
meanPcChangeConsumerExpenditureB <- mean(pcChangeConsumerExpenditureB)

DataTable <- c(meanPcChangeConsumerExpenditureA)
DataTable <- rbind(DataTable, c(meanPcChangeConsumerExpenditureB))
colnames(DataTable) <- c(nameFile)
rownames(DataTable) <- c("Change Welfare Consumer Country A","Change Welfare Consumer Country B")
write.csv(DataTable, "DataTableConsumerWelfareChange.csv")
DataTable

consumerExpenditureAplot = ggplot(data=moltenDFconsumerExpenditureA, aes(x=tick)) + 
  geom_smooth(aes(y=value), colour="red", method = "loess") + 
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Consumer expenditure \n Country A") #give the plot a title
plot(consumerExpenditureAplot)

consumerExpenditureBplot = ggplot(data=moltenDFconsumerExpenditureB, aes(x=tick)) + 
  geom_smooth(aes(y=value), colour="red", method = "loess") + 
  xlab("Year") +  
  ylab("Eur") + 
  ggtitle("Consumer expenditure \n Country B") #give the plot a title
plot(consumerExpenditureBplot)



#Market Value of RES-E (PV, Wind, WindOfshore)
# market value = Volume PV per segment * Sgement Clearing Price / generation in MWh in tick
# system base price = Average electricity price in tick
# value factor = market value / system base price
