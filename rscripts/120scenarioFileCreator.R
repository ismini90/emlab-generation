#Placeholders

# Step 1 building the scenarios: insert dataframe and read the scenario file. Name parameters
# that need to be replaced with #
xmlFilePath<-"/Users/kaveri/Desktop/emlabGen/scenario/prelimAnalysis/FipTechSpecTemplate.xml"
#scenarioTemplateNames <- c("FipTemplate.xml","FipTechSpecTemplate.xml", "TenderTemplate.xml","TenderTechSpecTemplate.xml")
scenarioTemplateNames <- c("TenderTemplate.xml","TenderTechSpecTemplate.xml")
filestump<-'FipTechSpec'
exPostExAnteVariable <- c("true","false")
#filestump<-'TechSpecFullTwoCountriesInfCap-'
# Step 2 building the scenarios: make separate data vectors
noOfRepetitions = 120
supportSchemeDuration = 10
futureSchemeStartTime = 0
feedInPremiumBiasFactor =1.001
degressionEnabled = "false"
degressionFactor =0.06
avgElectricityPriceBasedPremiumEnabled = "false"
co2MarketParameters <- c("true","false")
exPostExAnteVariable <- c("true", "false")

counter =0;
xmlFilePath<-"/Users/kaveri/Desktop/emlabGen/scenario/prelimAnalysis/"
#scenarioTemplateNames <- c("FipTemplate.xml","FipTechSpecTemplate.xml","TenderTemplate.xml","TenderTechSpecTemplate.xml")
scenarioTemplateNames <- c("FipTemplate.xml","FipTechSpecTemplate.xml","TenderTemplate.xml","TenderTechSpecTemplate.xml")
nameList<-character()
exPostExAnteVariable <- c("true", "false")
for(scenario in scenarioTemplateNames){
  filePathAndName <- paste(xmlFilePath,scenario,sep="")
  filestump<-gsub("Template.xml","",scenario)
for(exPostBoolean in exPostExAnteVariable)
  {
  for(co2Var in co2MarketParameters)
  {
    counter = counter +1
    for(runID in seq(1:noOfRepetitions))
    {
      xmlFileContent<-readLines(filePathAndName, encoding = "UTF-8")
      xmlFileContent<-gsub("#supportSchemeDuration", supportSchemeDuration, xmlFileContent)
      xmlFileContent<-gsub("#degressionEnabled", degressionEnabled, xmlFileContent)
      xmlFileContent<-gsub("#degressionFactor", degressionFactor, xmlFileContent)
      xmlFileContent<-gsub("#feedInPremiumBiasFactor", feedInPremiumBiasFactor, xmlFileContent)
      xmlFileContent<-gsub("#avgElectricityPriceBasedPremiumEnabled", "false", xmlFileContent)
      xmlFileContent<-gsub("#exPostEnabled", exPostBoolean, xmlFileContent) 
      xmlFileContent<-gsub("#futureSchemeStartTime", futureSchemeStartTime, xmlFileContent) 
      xmlFileContent<-gsub("#co2TradingAndBankingImplemented", co2Var, xmlFileContent)
      xmlFileContent<-gsub("#repetitionNumber", runID, xmlFileContent)
      writeLines(xmlFileContent, paste("~/Desktop/emlabGen/scenario/prelimAnalysis/", filestump,"EP",exPostBoolean, "CM", co2Var, "-", runID, ".xml", sep=""))
    }
    nameList<- cbind(nameList, paste(filestump,"EP",exPostBoolean, "CM", co2Var, sep=""))
  }
}
}
nameList


#BASE CASE 
xmlFilePath<-"/Users/kaveri/Desktop/emlabGen/scenario/prelimAnalysis/"
filePathAndName <- paste(xmlFilePath,"BaseCase.xml",sep="")
filestump<-"BaseCase"
for(co2Var in co2MarketParameters)
{
  counter = counter +1
  for(runID in seq(1:noOfRepetitions))
  {
    xmlFileContent<-readLines(filePathAndName, encoding = "UTF-8")
    xmlFileContent<-gsub("#supportSchemeDuration", supportSchemeDuration, xmlFileContent)
    xmlFileContent<-gsub("#degressionEnabled", degressionEnabled, xmlFileContent)
    xmlFileContent<-gsub("#degressionFactor", degressionFactor, xmlFileContent)
    xmlFileContent<-gsub("#feedInPremiumBiasFactor", feedInPremiumBiasFactor, xmlFileContent)
    xmlFileContent<-gsub("#avgElectricityPriceBasedPremiumEnabled", "false", xmlFileContent)
    xmlFileContent<-gsub("#exPostEnabled", exPostBoolean, xmlFileContent) 
    xmlFileContent<-gsub("#futureSchemeStartTime", futureSchemeStartTime, xmlFileContent) 
    xmlFileContent<-gsub("#co2TradingAndBankingImplemented", co2Var, xmlFileContent)
    xmlFileContent<-gsub("#repetitionNumber", runID, xmlFileContent)
    writeLines(xmlFileContent, paste("~/Desktop/emlabGen/scenario/prelimAnalysis/", filestump,"CM", co2Var, "-", runID, ".xml", sep=""))
  }
  nameList<- cbind(nameList, paste(filestump, "CM", co2Var, sep=""))
}

nameList



#SENSITIVITY ANALYSIS

xmlFilePath<-"/Users/kaveri/Desktop/emlabGen/scenario/prelimAnalysis/"
scenarioTemplateNames <- c("FipTemplate.xml","FipTechSpecTemplate.xml", "TenderTemplate.xml","TenderTechSpecTemplate.xml")

#Sensitivity to FIP BIAS FACTOR 

#nameList<-character()
xmlFilePath<-"/Users/kaveri/Desktop/emlabGen/scenario/prelimAnalysis/"
feedInPremiumBiasFactorArray <- c(1.05,1.1,1.15,1.2)
scenarioTemplateNames <- c("FipTemplate.xml","FipTechSpecTemplate.xml", "TenderTemplate.xml","TenderTechSpecTemplate.xml")

exPostExAnteVariable <- c("false")
noOfRepetitions = 120

  filestump<-gsub("Template.xml","","FipTechSpecTemplate.xml")
  for(exPostBoolean in exPostExAnteVariable){
    
    filePathAndName <- paste(xmlFilePath,"FipTechSpecTemplate.xml",sep="")
    xmlFileContent<-readLines(filePathAndName, encoding = "UTF-8")
    xmlFileContent<-gsub("#supportSchemeDuration", 10, xmlFileContent)
    xmlFileContent<-gsub("#degressionEnabled", "false", xmlFileContent)
    xmlFileContent<-gsub("#degressionFactor", 0.06, xmlFileContent)
    xmlFileContent<-gsub("#avgElectricityPriceBasedPremiumEnabled", "false", xmlFileContent)
    xmlFileContent<-gsub("#exPostEnabled", exPostBoolean, xmlFileContent) 
    xmlFileContent<-gsub("#futureSchemeStartTime", 0, xmlFileContent) 
    xmlFileContent<-gsub("#co2TradingAndBankingImplemented", "false", xmlFileContent)
    
    for(fipBiasFactor in feedInPremiumBiasFactorArray){
      xmlFileContent<-gsub("#feedInPremiumBiasFactor", fipBiasFactor, xmlFileContent) 
      
      for(runIterator in 1:noOfRepetitions){
        xmlFileContent<-gsub("#repetitionNumber", runID, xmlFileContent)
        writeLines(xmlFileContent, paste("~/Desktop/emlabGen/scenario/sensitivityAnalysis/", filestump,"BF",fipBiasFactor*100, "-", runIterator, ".xml", sep=""))
      }
      nameList<- cbind(nameList, paste(filestump,"BF",fipBiasFactor*100,sep=""))
    }
  }
nameList


#Sensitivity to FutureTimePoint

scenarioTemplateNames <- c("FipTemplate.xml","FipTechSpecTemplate.xml", "TenderTemplate.xml","TenderTechSpecTemplate.xml")
futureTimePointArray <- c(1,5)
exPostExAnteVariable <- c("true","false")
noOfRepetitions = 120

for(scenario in scenarioTemplateNames){
  filestump<-gsub("Template.xml","",scenario)
  for(exPostBoolean in exPostExAnteVariable){
    
    filePathAndName <- paste(xmlFilePath,scenario,sep="")
    xmlFileContent<-readLines(filePathAndName, encoding = "UTF-8")
    xmlFileContent<-gsub("#supportSchemeDuration", 10, xmlFileContent)
    xmlFileContent<-gsub("#degressionEnabled", "false", xmlFileContent)
    xmlFileContent<-gsub("#degressionFactor", 0.06, xmlFileContent)
    xmlFileContent<-gsub("#feedInPremiumBiasFactor", 1, xmlFileContent)
    xmlFileContent<-gsub("#avgElectricityPriceBasedPremiumEnabled", "false", xmlFileContent)
    xmlFileContent<-gsub("#exPostEnabled", exPostBoolean, xmlFileContent) 
    xmlFileContent<-gsub("#co2TradingAndBankingImplemented", "false", xmlFileContent)
    
    for(futureTimePoint in futureTimePointArray){
      xmlFileContent<-gsub("#futureSchemeStartTime", futureSchemeStartTime, xmlFileContent) 
    
      for(runIterator in 1:noOfRepetitions){
        xmlFileContent<-gsub("#repetitionNumber", runID, xmlFileContent)
        writeLines(xmlFileContent, paste("~/Desktop/emlabGen/scenario/sensitivityAnalysis/", filestump,"FTP",futureTimePoint, "-", runIterator, ".xml", sep=""))
      }
      
    }
  }
}

#Sensitivity to supportSchemeDuration

scenarioTemplateNames <- c("FipTechSpecTemplate.xml","TenderTechSpecTemplate.xml")
nameList<-character()
supportSchemeDurationArray <- c(10,15,20)
exPostExAnteVariable <- c("true")
for(scenario in scenarioTemplateNames){
  filestump<-gsub("Template.xml","",scenario)
  for(exPostBoolean in exPostExAnteVariable){
    
    filePathAndName <- paste(xmlFilePath,scenario,sep="")
    xmlFileContent<-readLines(filePathAndName, encoding = "UTF-8")
    xmlFileContent<-gsub("#degressionEnabled", "false", xmlFileContent)
    xmlFileContent<-gsub("#degressionFactor", 0.06, xmlFileContent)
    xmlFileContent<-gsub("#feedInPremiumBiasFactor", 1, xmlFileContent)
    xmlFileContent<-gsub("#avgElectricityPriceBasedPremiumEnabled", "false", xmlFileContent)
    xmlFileContent<-gsub("#exPostEnabled", exPostBoolean, xmlFileContent) 
    xmlFileContent<-gsub("#futureSchemeStartTime", 0, xmlFileContent) 
    xmlFileContent<-gsub("#co2TradingAndBankingImplemented", "false", xmlFileContent)
    
    for(supportSchemeDuration in supportSchemeDurationArray){
      xmlFileContent<-gsub("#supportSchemeDuration", supportSchemeDuration, xmlFileContent)
      
      for(runID in 1:noOfRepetitions){
        xmlFileContent<-gsub("#repetitionNumber", runID, xmlFileContent)
        writeLines(xmlFileContent, paste("~/Desktop/emlabGen/scenario/sensitivityAnalysis/", filestump,"SD",supportSchemeDuration, "-", runID, ".xml", sep=""))
      }
      nameList<- cbind(nameList, paste(filestump,"SD",supportSchemeDuration,sep=""))
    }
  }
}
nameList

#Sensitivity to Degression

scenarioTemplateNames <- c("FipTechSpecTemplate.xml")
#nameList<-character()
futureTimePointArray <- c(0)
exPostExAnteVariable <- c("true")
degressionFactorArray<-c(0.015, 0.05, 0.15, 0.25)
filestump<-gsub("Template.xml","","FipTechSpecTemplate.xml")

  for(exPostBoolean in exPostExAnteVariable){
    filePathAndName <- paste(xmlFilePath,"FipTechSpecTemplate.xml",sep="")
    xmlFileContent<-readLines(filePathAndName, encoding = "UTF-8")
    xmlFileContent<-gsub("#degressionEnabled", "false", xmlFileContent)
    xmlFileContent<-gsub("#feedInPremiumBiasFactor", 1, xmlFileContent)
    xmlFileContent<-gsub("#supportSchemeDuration", 10, xmlFileContent)
    xmlFileContent<-gsub("#avgElectricityPriceBasedPremiumEnabled", "false", xmlFileContent)
    xmlFileContent<-gsub("#exPostEnabled", exPostBoolean, xmlFileContent) 
    xmlFileContent<-gsub("#co2TradingAndBankingImplemented", "false", xmlFileContent)
    
    for(futureTimePoint in futureTimePointArray){
      xmlFileContent<-gsub("#futureSchemeStartTime", futureSchemeStartTime, xmlFileContent) 
      print(futureTimePoint)
      
      for(degressionFactorValue in degressionFactorArray){
        xmlFileContent<-gsub("#degressionFactor", degressionFactorValue, xmlFileContent) 
        print(degressionFactorValue)
        for(runIDiterator in 1:noOfRepetitions){
          xmlFileContent<-gsub("#repetitionNumber", runID, xmlFileContent)

            writeLines(xmlFileContent, paste("~/Desktop/emlabGen/scenario/sensitivityAnalysis/", filestump,"DF",degressionFactorValue*1000, "-", runIDiterator, ".xml", sep=""))
          
        }
        nameList<- cbind(nameList, paste(filestump,"DF",degressionFactorValue*1000, sep=""))
        
      }
    }
  }
nameList

#Sensitivity to Average Electricity Price Remuneration

scenarioTemplateNames <- c("FipTemplate.xml","FipTechSpecTemplate.xml")
exPostExAnteVariable <- c("true")
for(scenario in scenarioTemplateNames){
  filestump<-gsub("Template.xml","",scenario)
  for(exPostBoolean in exPostExAnteVariable){
    
    filePathAndName <- paste(xmlFilePath,scenario,sep="")
    xmlFileContent<-readLines(filePathAndName, encoding = "UTF-8")
    xmlFileContent<-gsub("#supportSchemeDuration", 10, xmlFileContent)
    xmlFileContent<-gsub("#degressionEnabled", "false", xmlFileContent)
    xmlFileContent<-gsub("#degressionFactor", 0.06, xmlFileContent)
    xmlFileContent<-gsub("#feedInPremiumBiasFactor", 1, xmlFileContent)
    xmlFileContent<-gsub("#avgElectricityPriceBasedPremiumEnabled", "true", xmlFileContent)
    xmlFileContent<-gsub("#exPostEnabled", exPostBoolean, xmlFileContent) 
    xmlFileContent<-gsub("#co2TradingAndBankingImplemented", "false", xmlFileContent)
        for(runID in 1:noOfRepetitions){
          xmlFileContent<-gsub("#repetitionNumber", runID, xmlFileContent)
          writeLines(xmlFileContent, paste("~/Desktop/emlabGen/scenario/sensitivityAnalysis/", filestump, "APtrue","-", runID, ".xml", sep=""))
        }
    }
  }




#TenderExPost
#TenderExAnte
#KBaseCase
#FipExPost
#FipExAnte
#TenderExPostTechSpec
#TenderExAnteTechSpec