FolderName <- "TestRuns1504Verification"
setwd("~/emlab-generation/rscripts")
source("rConfig.R")
source("batchRunAnalysis.R")
library(stringr)

setwd(resultFolder)
setwd("~/Desktop/emlabGen/output/TestRuns1504Verification")


bigDFBaseCase<- read.csv("BaseCaseCMtrueTest.csv")
bigDFBaseCaseFinancialReport <- read.csv("BaseCaseCMtrueTest-FinancialReports.csv")
bigDFBaseCaseBaseCostFip <- read.csv("BaseCaseCMtrueTest-BaseCostFip.csv")
bigDFBaseCase <- addSupplyRatios(bigDFBaseCase)
bigDFBaseCase <- addSumOfVariablesByPrefixToDF(bigDFBaseCase, "ProducerCash")
RenewableCapacityBaseCase = c("CapacityinMWinA_Photovoltaic", "CapacityinMWinA_Wind", "CapacityinMWinA_WindOffshore")
bigDFBaseCase <- addSumOfVariablesByVariableListToDF(bigDFBaseCase, RenewableCapacityBaseCase, 'TotalRenewableCapacity')
RenewableGenerationBaseCase = c("GenerationinMWhCountryA_Wind", "GenerationinMWhCountryA_Photovoltaic","GenerationinMWhCountryA_WindOffshore")
bigDFBaseCase <- addSumOfVariablesByVariableListToDF(bigDFBaseCase, RenewableGenerationBaseCase, 'TotalRenewableGeneration')

setwd("~/Desktop/emlabGen/output/TestRuns3105WithoutCoal")

bigDFFipAnte <- read.csv("FipEPfalseCMtrueTest.csv")
bigDFFipAnteFinancialReport <- read.csv("FipEPfalseCMtrueTest-FinancialReports.csv")
bigDFFipAnteBaseCostFip <- read.csv("FipEPfalseCMtrueTest-BaseCostFip.csv")
bigDFFipAnte <- addSupplyRatios(bigDFFipAnte)
bigDFFipAnte <- addSumOfVariablesByPrefixToDF(bigDFFipAnte, "ProducerCash")
RenewableCapacityFipAnte = c("CapacityinMWinA_Photovoltaic", "CapacityinMWinA_Wind", "CapacityinMWinA_WindOffshore")
bigDFFipAnte <- addSumOfVariablesByVariableListToDF(bigDFFipAnte, RenewableCapacityFipAnte, 'TotalRenewableCapacity')
RenewableGenerationFipAnte = c("GenerationinMWhCountryA_Wind", "GenerationinMWhCountryA_Photovoltaic","GenerationinMWhCountryA_WindOffshore")
bigDFFipAnte <- addSumOfVariablesByVariableListToDF(bigDFFipAnte, RenewableGenerationFipAnte, 'TotalRenewableGeneration')


bigDFFipPost <- read.csv("FipEPtrueCMtrueTest.csv")
bigDFFipPostFinancialReport <- read.csv("FipEPtrueCMtrueTest-FinancialReports.csv")
bigDFFipPostBaseCostFip <- read.csv("FipEPtrueCMtrueTest-BaseCostFip.csv")
bigDFFipPost <- addSupplyRatios(bigDFFipPost)
bigDFFipPost <- addSumOfVariablesByPrefixToDF(bigDFFipPost, "ProducerCash")
RenewableCapacityFipPost = c("CapacityinMWinA_Photovoltaic", "CapacityinMWinA_Wind", "CapacityinMWinA_WindOffshore")
bigDFFipPost <- addSumOfVariablesByVariableListToDF(bigDFFipPost, RenewableCapacityFipPost, 'TotalRenewableCapacity')
RenewableGenerationFipPost = c("GenerationinMWhCountryA_Wind", "GenerationinMWhCountryA_Photovoltaic","GenerationinMWhCountryA_WindOffshore")
bigDFFipPost <- addSumOfVariablesByVariableListToDF(bigDFFipPost, RenewableGenerationFipAnte, 'TotalRenewableGeneration')

#setwd("~/Desktop/emlabGen/output/TestRuns0604")
bigDFFipAnteTS <- read.csv("FipTechSpecEPfalseCMtrueTest.csv")
bigDFFipAnteTSFinancialReport <- read.csv("FipTechSpecEPfalseCMtrueTest-FinancialReports.csv")
bigDFFipAnteTSBaseCostFip <- read.csv("FipTechSpecEPfalseCMtrueTest-BaseCostFip.csv")
bigDFFipAnteTS <- addSupplyRatios(bigDFFipAnteTS)
bigDFFipAnteTS <- addSumOfVariablesByPrefixToDF(bigDFFipAnteTS, "ProducerCash")
RenewableCapacityFipAnte = c("CapacityinMWinA_Photovoltaic", "CapacityinMWinA_Wind", "CapacityinMWinA_WindOffshore")
bigDFFipAnteTS <- addSumOfVariablesByVariableListToDF(bigDFFipAnteTS, RenewableCapacityFipAnte, 'TotalRenewableCapacity')
RenewableGenerationFipAnte = c("GenerationinMWhCountryA_Wind", "GenerationinMWhCountryA_Photovoltaic","GenerationinMWhCountryA_WindOffshore")
bigDFFipAnteTS <- addSumOfVariablesByVariableListToDF(bigDFFipAnteTS, RenewableGenerationFipAnte, 'TotalRenewableGeneration')

bigDFFipPostTS <- read.csv("FipTechSpecEPtrueCMtrueTest.csv")
bigDFFipPostTSFinancialReport <- read.csv("FipTechSpecEPtrueCMtrueTest-FinancialReports.csv")
bigDFFipPostTSBaseCostFip <- read.csv("FipTechSpecEPtrueCMtrueTest-BaseCostFip.csv")
bigDFFipPostTS <- addSupplyRatios(bigDFFipPostTS)
bigDFFipPostTS <- addSumOfVariablesByPrefixToDF(bigDFFipPostTS, "ProducerCash")
RenewableCapacityFipPost = c("CapacityinMWinA_Photovoltaic", "CapacityinMWinA_Wind", "CapacityinMWinA_WindOffshore")
bigDFFipPostTS <- addSumOfVariablesByVariableListToDF(bigDFFipPostTS, RenewableCapacityFipPost, 'TotalRenewableCapacity')
RenewableGenerationFipPost = c("GenerationinMWhCountryA_Wind", "GenerationinMWhCountryA_Photovoltaic","GenerationinMWhCountryA_WindOffshore")
bigDFFipPostTS <- addSumOfVariablesByVariableListToDF(bigDFFipPostTS, RenewableGenerationFipAnte, 'TotalRenewableGeneration')


bigDFTenderAnte <- read.csv("TenderEPfalseCMtrueTest.csv")
bigDFTenderAnteFinancialReport <- read.csv("TenderEPfalseCMtrueTest-FinancialReports.csv")
bigDFTenderAnteClearingPoints <- read.csv("TenderEPfalseCMtrueTest-TenderClearingPoints.csv")
bigDFTenderAnte <- addSupplyRatios(bigDFTenderAnte)
bigDFTenderAnte <- addSumOfVariablesByPrefixToDF(bigDFTenderAnte, "ProducerCash")
RenewableCapacityTender = c("CapacityinMWinA_Photovoltaic", "CapacityinMWinA_Wind", "CapacityinMWinA_WindOffshore")
bigDFTenderAnte <- addSumOfVariablesByVariableListToDF(bigDFTenderAnte, RenewableCapacityTender, 'TotalRenewableCapacity')
RenewableGenerationTenderAnte = c("GenerationinMWhCountryA_Wind", "GenerationinMWhCountryA_Photovoltaic","GenerationinMWhCountryA_WindOffshore")
bigDFTenderAnte <- addSumOfVariablesByVariableListToDF(bigDFTenderAnte, RenewableGenerationTenderAnte, 'TotalRenewableGeneration')

bigDFTenderAnteTS <- read.csv("TenderTechSpecEPfalseCMtrueTest.csv")
bigDFTenderAnteTSFinancialReport <- read.csv("TenderTechSpecEPfalseCMtrueTest-FinancialReports.csv")
bigDFTenderAnteTSClearingPoints <- read.csv("TenderTechSpecEPfalseCMtrueTest-TenderClearingPoints.csv")
bigDFTenderAnteTS <- addSupplyRatios(bigDFTenderAnteTS)
bigDFTenderAnteTS <- addSumOfVariablesByPrefixToDF(bigDFTenderAnteTS, "ProducerCash")
RenewableCapacityTender = c("CapacityinMWinA_Photovoltaic", "CapacityinMWinA_Wind", "CapacityinMWinA_WindOffshore")
bigDFTenderAnteTS <- addSumOfVariablesByVariableListToDF(bigDFTenderAnteTS, RenewableCapacityTender, 'TotalRenewableCapacity')
RenewableGenerationTenderAnte = c("GenerationinMWhCountryA_Wind", "GenerationinMWhCountryA_Photovoltaic","GenerationinMWhCountryA_WindOffshore")
bigDFTenderAnteTS <- addSumOfVariablesByVariableListToDF(bigDFTenderAnteTS, RenewableGenerationTenderAnte, 'TotalRenewableGeneration')

bigDFTenderPostTS <- read.csv("TenderTechSpecEPtrueCMtrueTest.csv")
bigDFTenderPostTSFinancialReport <- read.csv("TenderTechSpecEPtrueCMtrueTest-FinancialReports.csv")
bigDFTenderPostTSClearingPoints <- read.csv("TenderTechSpecEPtrueCMtrueTest-TenderClearingPoints.csv")
bigDFTenderPostTS <- addSupplyRatios(bigDFTenderPostTS)
bigDFTenderPostTS <- addSumOfVariablesByPrefixToDF(bigDFTenderPostTS, "ProducerCash")
RenewableCapacityTender = c("CapacityinMWinA_Photovoltaic", "CapacityinMWinA_Wind", "CapacityinMWinA_WindOffshore")
bigDFTenderPostTS <- addSumOfVariablesByVariableListToDF(bigDFTenderPostTS, RenewableCapacityTender, 'TotalRenewableCapacity')
RenewableGenerationTenderAnte = c("GenerationinMWhCountryA_Wind", "GenerationinMWhCountryA_Photovoltaic","GenerationinMWhCountryA_WindOffshore")
bigDFTenderPostTS <- addSumOfVariablesByVariableListToDF(bigDFTenderPostTS, RenewableGenerationTenderAnte, 'TotalRenewableGeneration')

bigDFBaseCase$modelRun <- 'NoPolicy'
bigDFFipAnte$modelRun <- 'P_ExAnte'
bigDFFipPost$modelRun <- 'P_ExPost'
bigDFFipAnteTS$modelRun <- 'P_ExAnteTS'
bigDFFipPostTS$modelRun <- 'P_ExPostTS'
bigDFTenderAnte$modelRun <- 'Q_ExAnte'
bigDFTenderPost$modelRun <- 'Q_ExPost'
bigDFTenderAnteTS$modelRun <- 'Q_ExAnteTS'
bigDFTenderPostTS$modelRun <- 'Q_ExPostTS'

bigDFBaseCaseFinancialReport$runId <- 'NoPolicy'
bigDFFipAnteFinancialReport$runId <- 'P_ExAnte'
bigDFFipPostFinancialReport$runId <- 'P_ExPost'
bigDFFipAnteTSFinancialReport$runId <- 'P_ExAnteTS'
bigDFFipPostTSFinancialReport$runId <- 'P_ExPostTS'
bigDFTenderAnteFinancialReport$runId <- 'Q_ExAnte'
bigDFTenderPostFinancialReport$runId <- 'Q_ExPost'
bigDFTenderAnteTSFinancialReport$runId <-'Q_ExAnteTS'
bigDFTenderPostTSFinancialReport$runId <-'Q_ExPostTS'

#bigDFFinancialReport <- rbind(bigDFFipAnteFinancialReport,bigDFFipPostFinancialReport,bigDFTenderAnteFinancialReport,bigDFTenderPostFinancialReport, bigDFTenderAnteTSFinancialReport, bigDFTenderPostTSFinancialReport)
bigDFFinancialReport <- rbind(bigDFFipAnteFinancialReport,bigDFFipPostFinancialReport,bigDFFipAnteTSFinancialReport,bigDFFipPostTSFinancialReport, bigDFTenderAnteFinancialReport,bigDFTenderPostFinancialReport, bigDFTenderAnteTSFinancialReport, bigDFTenderPostTSFinancialReport)
bigDFwithBCFinancialReport <- rbind(bigDFBaseCaseFinancialReport, bigDFFipAnteFinancialReport,bigDFFipPostFinancialReport,bigDFFipAnteTSFinancialReport,bigDFFipPostTSFinancialReport, bigDFTenderAnteFinancialReport,bigDFTenderPostFinancialReport, bigDFTenderAnteTSFinancialReport, bigDFTenderPostTSFinancialReport)


Intersect0 <- bigDFBaseCase[,intersect(colnames(bigDFBaseCase), colnames(bigDFTenderAnte))]
Intersect5 <- bigDFTenderAnte[, intersect(colnames(bigDFTenderAnte), colnames(Intersect0))] #, colnames(Intersect1))]
Intersect6 <- bigDFTenderPost[, intersect(colnames(bigDFTenderPost), colnames(Intersect5))]
Intersect7 <- bigDFTenderAnteTS[,intersect(colnames(bigDFTenderPost), colnames(Intersect6))]
Intersect8 <- bigDFTenderPostTS[,intersect(colnames(bigDFTenderAnteTS), colnames(Intersect6))]
Intersect1 <- bigDFFipAnte[,intersect(colnames(Intersect8), colnames(bigDFFipAnte))]
Intersect2 <- bigDFFipPost[,intersect(colnames(bigDFFipPost), colnames(Intersect1))]
Intersect3 <- bigDFFipAnteTS[,intersect(colnames(bigDFFipAnteTS), colnames(Intersect2))]
Intersect4 <- bigDFFipPostTS[,intersect(colnames(Intersect3), colnames(bigDFFipPostTS))]


bigDF <- rbind(Intersect1,Intersect2,Intersect3,Intersect4, Intersect5,Intersect6,Intersect7,Intersect8)
bigDFwithBC <- rbind(Intersect0, Intersect1,Intersect2,Intersect3,Intersect4, Intersect5,Intersect6,Intersect7,Intersect8)

bigDF$modelRun <- factor(bigDF$modelRun, levels = c("P_ExAnte","P_ExPost","P_ExAnteTS","P_ExPostTS","Q_ExAnte", "Q_ExPost","Q_ExAnteTS", "Q_ExPostTS"))
oldNames<-names(bigDF)
bigDF <- cbind(bigDF, numeric(nrow(bigDF)))
names(bigDF)<-c(oldNames,"renTarget")

graphics.off()
library(gridExtra)
library(TeachingDemos)  
analysisFolder <- "~/Desktop/emlabGen/analysis/TestRuns3105WithoutCoalETS"
setwd(analysisFolder)


# 1) EFFECTIVENESS OF POLICY

#TARGETS - Add overall target to BigDF
targets <- read.csv("/Users/kaveri/emlab-generation/emlab-generation/src/main/resources/data/nodeAndTechSpecificPotentials.csv")
columnNames <- targets$realtime
targets <- targets[,2:ncol(targets)]
targets<-as.data.frame(t(targets))
colnames(targets)<-columnNames
bigDF$renTarget<- bigDF$Total_DemandinMWh_Country.A*targets$nl_target[match(bigDF$tick, targets$timestep)]
bigDF <- addNewVariableBasedOnTwoExistingVarsToDF(bigDF, 'targetOffset', 'TotalRenewableGeneration', 'renTarget', '-')

demandAvgDF <- ddply(bigDF, ~tick, summarise, demandAvg = mean(Total_DemandinMWh_Country.A))


targetOffset <- ddply(bigDF, ~modelRun, summarise, meanTargetAchieved = mean(targetOffset))
meanTargetOffsetPercentage <- ddply(bigDF, ~modelRun, summarise, meanTargetAchieved = mean(targetOffset)*100/mean(renTarget))
sdTargetOffsetPercentage <- ddply(bigDF, ~modelRun, summarise, sdTargetAchieved = sd(targetOffset/renTarget))

#RenewableCostsRevenuesAndProfits
renFinancialReport <-  subset(bigDFFinancialReport, grepl('WindOffshore', technology))
renFinancialReport <-  rbind(renFinancialReport, subset(bigDFFinancialReport, grepl('Wind', technology)))
renFinancialReport <-  rbind(renFinancialReport, subset(bigDFFinancialReport, grepl('Photovoltaic', technology)))


TotalCostsRen = c("commodityCosts", "variableCosts", "fixedCosts")
renFinancialReport <- addSumOfVariablesByVariableListToDF(renFinancialReport, TotalCostsRen, 'TotalCostsRenewable')
renFinancialReport <- addNewVariableBasedOnTwoExistingVarsToDF(renFinancialReport,'totalProdSurplusRen', 'overallRevenue', 'TotalCostsRenewable', '-')
renFinancialReport <- addNewVariableBasedOnTwoExistingVarsToDF(renFinancialReport,'subsidyRevenue', 'fipRevenue', 'tenderRevenue', '+')
renFinancialReport <- addNewVariableBasedOnTwoExistingVarsToDF(renFinancialReport,'subsidyPerUnit', 'subsidyRevenue', 'production', '/')
renFinancialReport <- addNewVariableBasedOnTwoExistingVarsToDF(renFinancialReport,'spotMarketRevenuePerUnit', 'spotMarketRevenue', 'production', '/')
renFinancialReport <- addNewVariableBasedOnTwoExistingVarsToDF(renFinancialReport,'fixedCostsPerUnit', 'fixedCosts', 'production', '/')
na.omit(renFinancialReport)
renFinancialReport$runId <- factor(renFinancialReport$runId, levels = c("P_ExAnte","P_ExPost","P_ExAnteTS","P_ExPostTS","Q_ExAnte",  "Q_ExPost", "Q_ExAnteTS", "Q_ExPostTS"))

meanSubsidyPerUnitDF <- ddply(renFinancialReport, ~runId, summarise, meanSubsidyPerUnit = mean(sum(subsidyRevenue)/sum(production)))
pertUnitData<- ddply(renFinancialReport, .(runId,tick,technology), summarise, meanSubsidyPerUnit = mean(sum(subsidyRevenue)/sum(production)))



meanSubsidyPerUnitDF["targetOffset"] <- NA 
meanSubsidyPerUnitDF["sdTargetOffset"] <- NA
meanSubsidyPerUnitDF$targetOffset <- meanTargetOffsetPercentage$meanTargetAchieved
meanSubsidyPerUnitDF$sdTargetOffset <- sdTargetOffsetPercentage$sdTargetAchieved

meanSubsidyPerUnitDFTable<- meanSubsidyPerUnitDF
colnames(meanSubsidyPerUnitDFTable) <- c("Scenario", "Avg Subsidy/Unit", "Target Offset (%)")
write.csv(meanSubsidyPerUnitDFTable[,1:3], "policyEffectiveness.csv")

# subsidyCost - targetAchievement Graph
plotTargetOffsetSubsidy <- ggplot(meanSubsidyPerUnitDF, aes(targetOffset, meanSubsidyPerUnit)) +
  geom_point(aes(size = 4,colour = factor(runId))) +
  guides(size=FALSE)+
  xlim(-72, 20) +
  ylim(0,50) +
  geom_vline(xintercept = 0) +
  geom_hline(yintercept = 0) +
  xlab("Target Offset in %") +
  ylab("Subsidy Cost in Eur/MWh")+
#theme( legend.position="bottom")
#geom_errorbarh(aes(xmax = targetOffset + sdTargetOffset, xmin = targetOffset - sdTargetOffset, height = 1))+
  scale_colour_brewer(palette = "Set1")
plotTargetOffsetSubsidy
ggsave(filename="TargetOffsetSubsidy.pdf",plot=plotTargetOffsetSubsidy, width=10, height=10, units="cm")

#plotting mean subsidy per policy
plotMeanSubsidy <- ggplot(meanSubsidyPerUnitDF, aes(runId, meanSubsidyPerUnit)) +
  geom_bar(stat = "identity") 
plotMeanSubsidy
ggsave(filename="plotMeanSubsidy.pdf",plot=plotMeanSubsidy, width=20, height=10, units="cm")



#plotting standard deviation of targetAchievementOffset per policy
plotTargetOffsetVariance <- ggplot(meanSubsidyPerUnitDF, aes(runId, sdTargetOffset)) +
  geom_bar(stat = "identity") +
  #theme(text = element_text(size=20)) +
  ylab("Std Dev Target Offset") +
  xlab("Policy Scenario")
#theme(text = element_text(size=20))
plotTargetOffsetVariance
ggsave(filename="plotTargetOffsetVariance.pdf",plot=plotTargetOffsetVariance, width=20, height=10, units="cm")

# 2) SOCIAL WELFARE AND DISTRIBUTIONAL IMPLICATIONS

#MEANS | Distributional Implications
welfareLossDF <- ddply(bigDFwithBC, ~modelRun, summarise, welfareLoss =  mean(WelfareLossThroughENS_Country.A))
spotMarketRevenueDF <- ddply(bigDFwithBCFinancialReport, ~runId, summarise, consumerExpenditure = mean(spotMarketRevenue))

#Producer Surplus
#overallCostsDF <- ddply(bigDFwithBC, ~modelRun, summarise, totalCosts =  mean(CountryAProdFinances_Total.Costs) )
overallCostsDF <- ddply(bigDFwithBCFinancialReport, ~runId, summarise, totalCosts =  mean(fixedCosts +variableCosts) )
overallRevenueDF <- ddply(bigDFwithBCFinancialReport, ~runId, summarise, totalRevenue = mean(overallRevenue))
welfareLossDF <- ddply(bigDFwithBC, ~modelRun, summarise, welfareLoss =  mean(WelfareLossThroughENS_Country.A))

#Government Surplus 
GovtExpenditureDF <- ddply(bigDFwithBCFinancialReport, ~runId, summarise, govtExpenditure =  mean(tenderRevenue + fipRevenue))

distributionalImplicationDF <- ddply(spotMarketRevenueDF, ~runId, mutate, 
                                     consumerExpenditureWithoutENS = consumerExpenditure - welfareLossDF$welfareLoss[match(runId, welfareLossDF$modelRun)])

distributionalImplicationDF <- ddply(distributionalImplicationDF, ~runId, mutate, 
                                     changeInConsumerWelfare = distributionalImplicationDF$consumerExpenditure[[1]] - consumerExpenditure)
#changeInConsumerWelfare = distributionalImplicationDF$consumerExpenditureWithoutENS[[1]] - consumerExpenditureWithoutENS)

distributionalImplicationDF <- ddply(distributionalImplicationDF, ~runId, mutate,                                     
                                     producerSurplus = overallRevenueDF$totalRevenue[match(runId, overallRevenueDF$runId)] -overallCostsDF$totalCosts[match(runId, overallCostsDF$runId)])# -welfareLossDF$welfareLoss[match(runId, welfareLossDF$modelRun)])
didfCheck <- ddply(distributionalImplicationDF, ~runId, mutate,                                     
                   producerRevenue = overallRevenueDF$totalRevenue[match(runId, overallRevenueDF$runId)], producerCost =overallCostsDF$totalCosts[match(runId, overallCostsDF$runId)])# -welfareLossDF$welfareLoss[match(runId, welfareLossDF$modelRun)])

distributionalImplicationDF <- ddply(distributionalImplicationDF, ~runId, mutate, 
                                     changeInProducerSurplus = distributionalImplicationDF$producerSurplus[[1]]-producerSurplus)
distributionalImplicationDF <- ddply(distributionalImplicationDF, ~runId, mutate, 
                                     govtExpenditure = GovtExpenditureDF$govtExpenditure[match(runId, GovtExpenditureDF$runId)])
distributionalImplicationDF <- ddply(distributionalImplicationDF, ~runId, mutate, 
                                     changeInGovtSurplus = distributionalImplicationDF$govtExpenditure[[1]]- govtExpenditure)
distributionalImplicationDF <- ddply(distributionalImplicationDF, ~runId, mutate, 
                                     changeInSocialSurplus = changeInConsumerWelfare + changeInProducerSurplus +changeInGovtSurplus)
distributionalImplicationDFTable <- distributionalImplicationDF[, c(1,4,6,8,9)]
colnames(distributionalImplicationDFTable) <- c("Scenario", "Change Consumer Surplus", "Change Producer Surplus", "Change in Govt Surplus","Change Social Surplus")
write.csv(distributionalImplicationDFTable, "distributionalImplicationTable.csv")
dIDF <- melt(distributionalImplicationDF[, c(1,4,6,8,9)]) 
names(dIDF)[2] <-"swVariable"

#Plotting Change in Social Welfare
plotChangeInSw <-ggplot(dIDF, aes(x = runId, y= value, fill = swVariable), xlab="Age Group") +
  geom_bar(stat="identity", width=.5, position = "dodge")  +
  ylab("Welfare in Euros") +
  xlab("Policy Scenario")+
 theme(legend.position="bottom")+
  theme(legend.title=element_blank())+
  theme(axis.text.x = element_text(angle=90)) +
  guides(fill = guide_legend(nrow = 4))

#theme(text = element_text(size=15))
ggsave(filename="plotChangeInSw.pdf",plot=plotChangeInSw, width=10, height=10, units="cm")
plotChangeInSw

#TO BE DONE
subsidyPerTechnologyDF <- ddply(renFinancialReport, ~runId, mutate, subsidyPerTechnology = sum(subsidyRevenue))

plotMeanSubsidyPerTechnology <- ggplot(subsidyPerTechnologyDF, aes(runId, subsidyPerTechnology)) +
  geom_bar(stat = "identity") 
plotMeanSubsidyPerTechnology

# 3) GENERATION PORTFOLIO AND ELECTRICITY MARKET PERFORMANCE

#ren Gen in the netherlands
bigDF <- addNewVariableBasedOnTwoExistingVarsToDF(bigDF,'fractionRenewableGeneration3', 'TotalRenewableGeneration', 'TotalConsumptioninMWh', '/')
plotRenGenerationTotal<-plotTimeSeriesWithConfidenceIntervalByFacettedGroup(bigDF, "TotalRenewableGeneration","Renewable Generation [MWh]", nrow=2) 
plotRenGenerationTotal
ggsave(filename="plotRenGenerationTotal.pdf",plot=plotRenGenerationTotal, width=20, height=10, units="cm")

#Capacities
moltenCapacities<-meltTechnologyVariable(bigDF,"CapacityinMW_")
moltenCapacities$value<-moltenCapacities$value/1000
stackedCapacities<-plotStackedTechnologyDiagram(moltenVariable=moltenCapacities,ylabel="Capacity [GW]", nrow=2)
stackedCapacities
ggsave(filename="StackedCapacityDiagramCMfalse.pdf",plot=stackedCapacities, width=10, height=15, units="cm")

#total subsidy per technology, stacked. 


#ren Gen in the netherlands
avgPricePlot<-plotTimeSeriesWithConfidenceIntervalByFacettedGroupWithSuperImposition(bigDF, "Avg_El_PricesinEURpMWh_Country.A","fractionRenewableGeneration3","Avg Elec Price [eur/MWh]", nrow=2) 
avgPricePlot
ggsave(filename="avgPricePlot.pdf",plot=avgPricePlot, width=20, height=10, units="cm")

plotSubsidyPerUnit <- plotTimeSeriesWithConfidenceIntervalByFacettedByRunIdGroup(renFinancialReport, "subsidyPerUnit","Subsidy Per Unit [eur/MWh]", nrow=2)
plotSubsidyPerUnit
ggsave(filename="plotSubsidyPerUnit.pdf",plot=plotSubsidyPerUnit, width=20, height=10, units="cm")

plotSubsidyPerUnit <- plotTimeSeriesWithConfidenceIntervalByFacettedByRunIdGroup(renFinancialReport, "fixedCostsPerUnit","Fixed Costs Per Unit [eur/MWh]", nrow=2)
plotSubsidyPerUnit
ggsave(filename="plotSubsidyPerUnit.pdf",plot=plotSubsidyPerUnit, width=20, height=10, units="cm")

fractionRenewableGeneration <- plotTimeSeriesWithConfidenceIntervalByFacettedGroup(bigDF, "fractionRenewableGeneration3","Ratio Renewable - Total Generation ", nrow=2)
fractionRenewableGeneration
ggsave(filename="plotFractionRenewableGeneration.pdf",plot=fractionRenewableGeneration, width=20, height=10, units="cm")

#Generation per Renewable Technology 
plotGenerationPerRenewableTechnology <- ggplot(renFinancialReport) + 
  geom_smooth(aes(x=tick,y=production,colour=technology))+
  facet_wrap(~runId, nrow=2)+
  ylab("Production per Technology [MWh]") +
  xlab("Year")+
  theme(legend.position="bottom")
plotGenerationPerRenewableTechnology
ggsave(filename="plotGenerationPerRenewableTechnology.pdf",plot=plotGenerationPerRenewableTechnology, width=20, height=10, units="cm")

#Generation per Technology 
plotGenerationPerTechnology <- ggplot(bigDFFinancialReport) + 
  geom_smooth(aes(x=tick,y=production,colour=technology))+
  facet_wrap(~runId, nrow=2)+
  ylab("Production per Technology [MWh]") +
  xlab("Year")+
  theme(legend.position="bottom")
plotGenerationPerTechnology
ggsave(filename="plotGenerationPerTechnology.pdf",plot=plotGenerationPerTechnology, width=20, height=10, units="cm")

# VERIFICATION. 

# 1. create subset for fixed anual cost, variable cost, subsidy

renFinancialReport2 <- renFinancialReport[which(renFinancialReport$production > 0), ]
pertUnitData<- ddply(renFinancialReport2, .(runId,tick,technology), summarise, 
                     fixedCostPerUnit = mean(sum(fixedCosts)/sum(production)), 
                     meanSubsidyPerUnit = mean(sum(subsidyRevenue)/sum(production)),
                     spotMarketRevenuePerUnit = mean(sum(spotMarketRevenue)/sum(production)),
                     profitPerUnit = mean(sum(totalProdSurplusRen)/sum(production))
)

# 2. melt by technology, tick and runId, so that each perUnit cost becomes a variable too. 
perUnitDataMelted <- melt(pertUnitData, id.vars = c("runId", "tick", "technology"), na.rm = TRUE)
head(perUnitDataMelted)

# 3. subset by technology so that for each technology, perunit costs may be compared differently
perUnitDataPV <- subset(perUnitDataMelted, technology == 'Photovoltaic')
perUnitDataWindOn <- subset(perUnitDataMelted, technology == 'Wind')
perUnitDataWindOff <- subset(perUnitDataMelted, technology == 'WindOffshore')

# 3. plot the data
p.perUnit <- ggplot(perUnitDataMelted) + 
  geom_smooth(aes(x=tick,y=value,colour=variable))+
  facet_wrap(~runId, nrow=2)


pPV.perUnit <- ggplot(perUnitDataPV) + 
  geom_smooth(aes(x=tick,y=value,colour=variable))+
  facet_wrap(~runId, nrow=2) +
  ylab("Finances Photovoltaic [Eur/MWh]") +
  xlab("Year")+
  theme(legend.position="bottom")
pPV.perUnit
ggsave(filename="plotFinancesPV.pdf",plot=pPV.perUnit, width=20, height=10, units="cm")

pWindOn.perUnit <- ggplot(perUnitDataWindOn) + 
  geom_smooth(aes(x=tick,y=value,colour=variable))+
  facet_wrap(~runId, nrow=2) +
  ylab("Finances Wind Onshore [Eur/MWh]") +
  xlab("Year")+
  theme(legend.position="bottom")
pWindOn.perUnit
ggsave(filename="plotFinancesWindOn.pdf",plot=pWindOn.perUnit, width=20, height=10, units="cm")

pWindOff.perUnit <- ggplot(perUnitDataWindOff) + 
  geom_smooth(aes(x=tick,y=value,colour=variable))+
  facet_wrap(~runId, nrow=2) +
  ylab("Finances Wind OffShore [Eur/MWh]") +
  xlab("Year")+
  theme(legend.position="bottom")
pWindOff.perUnit
ggsave(filename="plotFinancesWindOff.pdf",plot=pWindOff.perUnit, width=20, height=10, units="cm")



