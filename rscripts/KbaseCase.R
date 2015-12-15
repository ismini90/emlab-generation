setwd("~/emlab-generation/rscripts")
source("rConfig.R")
source("batchRunAnalysis.R")
library(stringr)

setwd(resultFolder)

bigDF <- read.csv("KBaseCase.csv")
bigDFFinancialReport <- read.csv("KBaseCase-FinancialReports.csv")
bigDF <- addSupplyRatios(bigDF)
bigDF <- addSumOfVariablesByPrefixToDF(bigDF, "ProducerCash")
RenewableCapacity = c("CapacityinMWinA_Photovoltaic", "CapacityinMWinA_Wind", "CapacityinMWinA_Biomass", "CapacityinMWinA_WindOffshore")
bigDF <- addSumOfVariablesByVariableListToDF(bigDF, RenewableCapacity, 'TotalRenewableCapacity')

#bigDF$WelfareLossThroughENS_Country.A <- NULL 

setwd(analysisFolder)
bigDF$runId <- gsub("KBaseCase-","BaseCase",bigDF$runId)
bigDF$modelRun <- 'BaseCase'

graphics.off()
library(gridExtra)
library(TeachingDemos)  
setwd("~/Desktop/emlabGen/analysis/prelimAnalysis/BaseCase")

#Average Price
avgPricePlotinB_CI<-plotTimeSeriesWithConfidenceIntervalGroupedInOnePlot(bigDF, "Avg_El_PricesinEURpMWh_Country.B", "Avg. Electricity Price in DE [EUR/MW]")
avgPricePlotinB_CI
ggsave(filename="AveragePricePlotinGermany.pdf",plot=avgPricePlotinB_CI, width=20, height=10, units="cm")

avgPricePlotinB_CI<-plotTimeSeriesWithConfidenceIntervalByFacettedGroup(bigDF, "Avg_El_PricesinEURpMWh_Country.A", "Avg. Electricity Price in NL [EUR/MW]")
avgPricePlotinB_CI
ggsave(filename="AveragePricePlotinNetherlands.pdf",plot=avgPricePlotinB_CI, width=20, height=10, units="cm")

#totalRenewableCapacity
renCapacityTotal<-plotTimeSeriesWithConfidenceIntervalByFacettedGroup(bigDF, "TotalRenewableCapacity", "Renewable Capacity [MW]")
renCapacityTotal
ggsave(filename="TotalRenCapacityinNetherlands.pdf",plot=avgPricePlotinB_CI, width=20, height=10, units="cm")

#RenewableCostsRevenuesAndProfits
renFinancialReport <-  subset(bigDFFinancialReport, grepl('WindOffshore', technology))
renFinancialReport <-  rbind(renFinancialReport, subset(bigDFFinancialReport, grepl('Wind', technology)))
renFinancialReport <-  rbind(renFinancialReport, subset(bigDFFinancialReport, grepl('Biomass', technology)))
renFinancialReport <-  rbind(renFinancialReport, subset(bigDFFinancialReport, grepl('Photovoltaic', technology)))

TotalCostsRen = c("commodityCosts", "variableCosts", "fixedCosts")
renFinancialReport <- addSumOfVariablesByVariableListToDF(renFinancialReport, TotalCostsRen, 'TotalCostsRenewable')

totalProdSurplusRen <- renFinancialReport$overallRevenue - renFinancialReport$TotalCostsRenewable
oldNames<-names(renFinancialReport)
renFinancialReport<-cbind(renFinancialReport, totalProdSurplusRen)
names(renFinancialReport)<-c(oldNames,"totalProdSurplusRen")

renFinancialReport$runId <- 'BaseCase'
totalProdSurplusRenNL<-plotTimeSeriesWithConfidenceIntervalByFacettedByRunIdGroup(renFinancialReport, "totalProdSurplusRen", "Renewable Producer Surplus NL")
totalProdSurplusRenNL
ggsave(filename="totalProdSurplusRen.pdf",plot=supplyRatioNL, width=20, height=9, units="cm")

#MOLTEN BY RENEWABLES

#SupplyRatio
supplyRatioNL<-plotTimeSeriesWithConfidenceIntervalByFacettedGroup(bigDF, "SupplyRatio_Country.A", "Peak Capacity Supply Ratio NL")
supplyRatioNL
ggsave(filename="SupplyRatioNL.pdf",plot=supplyRatioNL, width=20, height=9, units="cm")

supplyRatioDE<-plotTimeSeriesWithConfidenceIntervalByFacettedGroup(bigDF, "SupplyRatio_Country.B", "Peak Capacity Supply Ratio DE")
supplyRatioDE
ggsave(filename="SupplyRatioDE.pdf",plot=supplyRatioNL, width=20, height=9, units="cm")#ESM-Graph-Spaghetti

PriceSeg1PlotinBSpaghetti<-plotSpaghettiTimeSeries(bigDF, "PriceInEURperMWh_Segment.Country.A.1","Segment 1","Time [a]", NULL, 8)
PriceSeg1PlotinBSpaghetti

PriceSeg2PlotinBSpaghetti<-plotSpaghettiTimeSeries(bigDF, "PriceInEURperMWh_Segment.Country.A.2","Segment 2","Time [a]", NULL, 8)
PriceSeg2PlotinBSpaghetti

PriceSeg3PlotinBSpaghetti<-plotSpaghettiTimeSeries(bigDF, "PriceInEURperMWh_Segment.Country.A.3","Segment 3","Time [a]", NULL, 8)
PriceSeg3PlotinBSpaghetti

PriceSeg4PlotinBSpaghetti<-plotSpaghettiTimeSeries(bigDF, "PriceInEURperMWh_Segment.Country.A.4","Segment 4","Time [a]", NULL, 8)
PriceSeg4PlotinBSpaghetti

PricePlotB<- arrangeGrob(PriceSeg1PlotinBSpaghetti, PriceSeg2PlotinBSpaghetti, PriceSeg3PlotinBSpaghetti, PriceSeg4PlotinBSpaghetti, nrow = 4, ncol = 1)
ggsave(filename="PricePlotNL.pdf",plot=PricePlotB, width=18, height=23, units="cm")

PriceSeg1PlotinBSpaghetti<-plotSpaghettiTimeSeries(bigDF, "PriceInEURperMWh_Segment.Country.B.1","Segment 1","Time [a]", NULL, 8)
PriceSeg1PlotinBSpaghetti

PriceSeg2PlotinBSpaghetti<-plotSpaghettiTimeSeries(bigDF, "PriceInEURperMWh_Segment.Country.B.2","Segment 2","Time [a]", NULL, 8)
PriceSeg2PlotinBSpaghetti

PriceSeg3PlotinBSpaghetti<-plotSpaghettiTimeSeries(bigDF, "PriceInEURperMWh_Segment.Country.B.3","Segment 3","Time [a]", NULL, 8)
PriceSeg3PlotinBSpaghetti

PriceSeg4PlotinBSpaghetti<-plotSpaghettiTimeSeries(bigDF, "PriceInEURperMWh_Segment.Country.B.4","Segment 4","Time [a]", NULL, 8)
PriceSeg4PlotinBSpaghetti

PricePlotB<- arrangeGrob(PriceSeg1PlotinBSpaghetti, PriceSeg2PlotinBSpaghetti, PriceSeg3PlotinBSpaghetti, PriceSeg4PlotinBSpaghetti, nrow = 4, ncol = 1)
ggsave(filename="PricePlotDE.pdf",plot=PricePlotB, width=18, height=23, units="cm")

#ProducerCash
aggregateProducerCash<-plotTimeSeriesWithConfidenceIntervalGroupedInOnePlot(bigDF, "ProducerCashSum", "Aggregated Producer Cash")
aggregateProducerCash
ggsave(filename="ProducerCashSum.pdf",plot=aggregateProducerCash, width=20, height=9, units="cm")

aggregateProfit <- plotTimeSeriesWithConfidenceIntervalGroupedInOnePlot(bigDF, "AggregateFinances_Profit", "Aggregated Profit")
aggregateProfit
ggsave(filename="AggregateProfit.pdf",plot=aggregateProfit, width=20, height=9, units="cm")

#Consumer Expenditure
ConsumerExpA<-plotTimeSeriesWithConfidenceIntervalByFacettedGroup(bigDF, "ConsumerExpenditure_Country.A.electricity.spot.market", "Consumer Expenditure")
ConsumerExpA
ggsave(filename="ConsumerExpNL.pdf",plot=ConsumerExpA, width=20, height=9, units="cm")

ConsumerExpB<-plotTimeSeriesWithConfidenceIntervalByFacettedGroup(bigDF, "ConsumerExpenditure_Country.B.electricity.spot.market", "Consumer Expenditure")
ConsumerExpB
ggsave(filename="ConsumerExpDE.pdf",plot=ConsumerExpB, width=20, height=9, units="cm")

#Capacities
moltenCapacities<-meltTechnologyVariable(bigDF,"CapacityinMWinA_")
moltenCapacities$value<-moltenCapacities$value/1000
stackedCapacitiesNL<-plotStackedTechnologyDiagram(moltenVariable=moltenCapacities,ylabel="Capacity in NL [GW]")
stackedCapacitiesNL
ggsave(filename="StackedCapacityDiagramNL.pdf",plot=stackedCapacitiesDE, width=20, height=15, units="cm")


RenewableCapacity = bigDF$CapacityinMWinB_Photovoltaic + bigDF$CapacityinMWinB_Wind + bigDF$CapacityinMWinB_Biomass + bigDF$CapacityinMWinB_WindOffshore
TotalCapacity = bigDF$TotalOperationalCapacityPerZoneInMW_Country.B
