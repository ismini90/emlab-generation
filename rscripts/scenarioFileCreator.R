#Placeholders

# Step 1 building the scenarios: insert dataframe and read the scenario file. Name parameters
# that need to be replaced with #

xmlFilePath<-templateFolder

xmlFilePath<-"/Users/kaveri/Desktop/emlabGen/scenario/TestRuns1104Verification/"
scenarioFolder <- xmlFilePath
#scenarioTemplateNames <- c("FipTemplate.xml","FipTechSpecTemplate.xml","TenderTemplate.xml","TenderTechSpecTemplate.xml")
scenarioTemplateNames <- c("FipTemplate.xml","FipTechSpecTemplate.xml","TenderTemplate.xml","TenderTechSpecTemplate.xml")


#Initialization

supportSchemeDuration = 20
futureSchemeStartTime = 2
feedInPremiumBiasFactor =1.01
degressionEnabled = "false"
degressionFactor =0.06
avgElectricityPriceBasedPremiumEnabled = "false"
co2MarketParameters <- c("true","false")
exPostExAnteVariable <- c("true", "false")
co2MarketParameter <- c("false")

#filestump<-'TechSpecFullTwoCountriesInfCap-'
# Step 2 building the scenarios: make separate data vectors


counter =0;
nameList<-character()


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
        #writeLines(xmlFileContent, paste(scenarioFolder, filestump,"EP",exPostBoolean, "CM", co2Var, "-", runID, ".xml", sep=""))
      }
      nameList<- cbind(nameList, paste(filestump,"EP",exPostBoolean, "CM", co2Var, sep=""))
    }
  }
}
nameList


#BASE CASE 
xmlFilePath<-scenarioFolder
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
    xmlFileContent<-gsub("#avgElectricityPriceBasedPremiumEnabled", avgElectricityPriceBasedPremiumEnabled, xmlFileContent)
    xmlFileContent<-gsub("#exPostEnabled", exPostBoolean, xmlFileContent) 
    xmlFileContent<-gsub("#futureSchemeStartTime", futureSchemeStartTime, xmlFileContent) 
    xmlFileContent<-gsub("#co2TradingAndBankingImplemented", co2Var, xmlFileContent)
    xmlFileContent<-gsub("#repetitionNumber", runID, xmlFileContent)
    writeLines(xmlFileContent, paste(scenarioFolder, filestump,"VerifyCM", co2Var, "-", runID, ".xml", sep=""))
  }
  nameList<- cbind(nameList, paste(filestump, "VerifyCM", co2Var, sep=""))
}
nameList



#SENSITIVITY ANALYSIS



#Sensitivity to FIP BIAS FACTOR 

scenarioFolder <- "/Users/kaveri/Desktop/emlabGen/scenario/TestRuns1104Verification/"
nameList<-character()
feedInPremiumBiasFactorArray <- c(1.0,5, 1.1,1.15,2)
scenarioTemplateNames <- c("FipTemplate.xml","FipTechSpecTemplate.xml")
exPostExAnteVariable <- c("false","true")

for(scenario in scenarioTemplateNames){
  filePathAndName <- paste(xmlFilePath,scenario,sep="")
  filestump<-gsub("Template.xml","",scenario)
for(exPostBoolean in exPostExAnteVariable){
  
  filePathAndName <- paste(xmlFilePath,scenario,sep="")
  xmlFileContent<-readLines(filePathAndName, encoding = "UTF-8")
  xmlFileContent<-gsub("#supportSchemeDuration", supportSchemeDuration, xmlFileContent)
  xmlFileContent<-gsub("#degressionEnabled", degressionEnabled, xmlFileContent)
  xmlFileContent<-gsub("#degressionFactor", degressionFactor, xmlFileContent)
  xmlFileContent<-gsub("#avgElectricityPriceBasedPremiumEnabled", avgElectricityPriceBasedPremiumEnabled, xmlFileContent)
  xmlFileContent<-gsub("#exPostEnabled", exPostBoolean, xmlFileContent) 
  xmlFileContent<-gsub("#futureSchemeStartTime", futureSchemeStartTime, xmlFileContent) 
  xmlFileContent<-gsub("#co2TradingAndBankingImplemented", co2MarketParameter, xmlFileContent)
  
  for(fipBiasFactor in feedInPremiumBiasFactorArray){
    print(fipBiasFactor)
    xmlFileContent<-gsub("#feedInPremiumBiasFactor", fipBiasFactor, xmlFileContent) 
    
    for(runIterator in 1:noOfRepetitions){
      xmlFileContent<-gsub("#repetitionNumber", runIterator, xmlFileContent)
     writeLines(xmlFileContent, paste("/Users/kaveri/Desktop/emlabGen/scenario/TestRuns1104Sensitivity/", filestump,"EP",exPostBoolean,"BF",fipBiasFactor*100, "-", runIterator, ".xml", sep=""))
    }
    #nameList<- cbind(nameList, paste(filestump,"EP",exPostBoolean,"BF",fipBiasFactor*100,sep=""))
  }
}
}
nameList




#Sensitivity to supportSchemeDuration

scenarioTemplateNames <- c("FipTechSpecTemplate.xml","TenderTechSpecTemplate.xml")
supportSchemeDurationArray <- c(10,15,20)
exPostExAnteVariable <- c("true")

for(scenario in scenarioTemplateNames){
  filestump<-gsub("Template.xml","",scenario)
  for(exPostBoolean in exPostExAnteVariable){
    
    filePathAndName <- paste(xmlFilePath,scenario,sep="")
    xmlFileContent<-readLines(filePathAndName, encoding = "UTF-8")
    xmlFileContent<-gsub("#degressionEnabled", degressionEnabled, xmlFileContent)
    xmlFileContent<-gsub("#degressionFactor", degressionFactor, xmlFileContent)
    xmlFileContent<-gsub("#feedInPremiumBiasFactor", feedInPremiumBiasFactor, xmlFileContent)
    xmlFileContent<-gsub("#avgElectricityPriceBasedPremiumEnabled", "false", xmlFileContent)
    xmlFileContent<-gsub("#exPostEnabled", exPostBoolean, xmlFileContent) 
    xmlFileContent<-gsub("#futureSchemeStartTime", futureSchemeStartTime, xmlFileContent) 
    xmlFileContent<-gsub("#co2TradingAndBankingImplemented", co2MarketParameter, xmlFileContent)
    
    for(supportSchemeDuration in supportSchemeDurationArray){
      xmlFileContent<-gsub("#supportSchemeDuration", supportSchemeDuration, xmlFileContent)
      
      for(runID in 1:noOfRepetitions){
        xmlFileContent<-gsub("#repetitionNumber", runID, xmlFileContent)
        writeLines(xmlFileContent, paste(scenarioFolder, filestump,"SD",supportSchemeDuration, "-", runID, ".xml", sep=""))
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
degressionEnabled = "true"
degressionFactorArray<-c(0.015, 0.05, 0.15, 0.25)
filestump<-gsub("Template.xml","","FipTechSpecTemplate.xml")

for(exPostBoolean in exPostExAnteVariable){
  filePathAndName <- paste(xmlFilePath,"FipTechSpecTemplate.xml",sep="")
  xmlFileContent<-readLines(filePathAndName, encoding = "UTF-8")
  xmlFileContent<-gsub("#degressionEnabled", degressionEnabled, xmlFileContent)
  xmlFileContent<-gsub("#feedInPremiumBiasFactor", feedInPremiumBiasFactor, xmlFileContent)
  xmlFileContent<-gsub("#supportSchemeDuration", supportSchemeDuration, xmlFileContent)
  xmlFileContent<-gsub("#avgElectricityPriceBasedPremiumEnabled", avgElectricityPriceBasedPremiumEnabled, xmlFileContent)
  xmlFileContent<-gsub("#exPostEnabled", exPostBoolean, xmlFileContent) 
  xmlFileContent<-gsub("#co2TradingAndBankingImplemented",co2MarketParameter, xmlFileContent)
  
  for(futureTimePoint in futureTimePointArray){
    xmlFileContent<-gsub("#futureSchemeStartTime", futureSchemeStartTime, xmlFileContent) 
    print(futureTimePoint)
    
    for(degressionFactorValue in degressionFactorArray){
      xmlFileContent<-gsub("#degressionFactor", degressionFactorValue, xmlFileContent) 
      print(degressionFactorValue)
      for(runIDiterator in 1:noOfRepetitions){
        xmlFileContent<-gsub("#repetitionNumber", runID, xmlFileContent)
        
        writeLines(xmlFileContent, paste(scenarioFolder, filestump,"DF",degressionFactorValue*1000, "-", runIDiterator, ".xml", sep=""))
        
      }
      nameList<- cbind(nameList, paste(filestump,"DF",degressionFactorValue*1000, sep=""))
      
    }
  }
}
nameList

#Sensitivity to Average Electricity Price Remuneration

scenarioTemplateNames <- c("FipTemplate.xml","FipTechSpecTemplate.xml")
exPostExAnteVariable <- c("true")
avgElectricityPriceBasedPremiumEnabled <- c("true")

for(scenario in scenarioTemplateNames){
  filestump<-gsub("Template.xml","",scenario)
  for(exPostBoolean in exPostExAnteVariable){
    
    filePathAndName <- paste(xmlFilePath,scenario,sep="")
    xmlFileContent<-readLines(filePathAndName, encoding = "UTF-8")
    xmlFileContent<-gsub("#supportSchemeDuration", supportSchemeDuration, xmlFileContent)
    xmlFileContent<-gsub("#degressionEnabled", degressionEnabled, xmlFileContent)
    xmlFileContent<-gsub("#degressionFactor", degressionFactor, xmlFileContent)
    xmlFileContent<-gsub("#feedInPremiumBiasFactor", feedInPremiumBiasFactor, xmlFileContent)
    xmlFileContent<-gsub("#avgElectricityPriceBasedPremiumEnabled", avgElectricityPriceBasedPremiumEnabled, xmlFileContent)
    xmlFileContent<-gsub("#exPostEnabled", exPostBoolean, xmlFileContent) 
    xmlFileContent<-gsub("#co2TradingAndBankingImplemented", co2MarketParameter, xmlFileContent)
    for(runID in 1:noOfRepetitions){
      xmlFileContent<-gsub("#repetitionNumber", runID, xmlFileContent)
      writeLines(xmlFileContent, paste(scenarioFolder, filestump, "APtrue","-", runID, ".xml", sep=""))
    }
  }
}

#Sensitivity to FutureTimePoint

scenarioTemplateNames <- c("FipTemplate.xml","FipTechSpecTemplate.xml", "TenderTemplate.xml","TenderTechSpecTemplate.xml")
futureTimePointArray <- c(1,5)
exPostExAnteVariable <- c("true","false")


for(scenario in scenarioTemplateNames){
  filestump<-gsub("Template.xml","",scenario)
  for(exPostBoolean in exPostExAnteVariable){
    
    filePathAndName <- paste(xmlFilePath,scenario,sep="")
    xmlFileContent<-readLines(filePathAndName, encoding = "UTF-8")
    xmlFileContent<-gsub("#supportSchemeDuration", supportSchemeDuration, xmlFileContent)
    xmlFileContent<-gsub("#degressionEnabled", degressionEnabled, xmlFileContent)
    xmlFileContent<-gsub("#degressionFactor",degressionFactor, xmlFileContent)
    xmlFileContent<-gsub("#feedInPremiumBiasFactor", feedInPremiumBiasFactor, xmlFileContent)
    xmlFileContent<-gsub("#avgElectricityPriceBasedPremiumEnabled", avgElectricityPriceBasedPremiumEnabled, xmlFileContent)
    xmlFileContent<-gsub("#exPostEnabled", exPostBoolean, xmlFileContent) 
    xmlFileContent<-gsub("#co2TradingAndBankingImplemented", co2MarketParameter, xmlFileContent)
    
    for(futureTimePoint in futureTimePointArray){
      xmlFileContent<-gsub("#futureSchemeStartTime", futureSchemeStartTime, xmlFileContent) 
      
      for(runIterator in 1:noOfRepetitions){
        xmlFileContent<-gsub("#repetitionNumber", runID, xmlFileContent)
        writeLines(xmlFileContent, paste(scenarioFolder, filestump,"FTP",futureTimePoint, "-", runIterator, ".xml", sep=""))
      }
      
    }
  }
}

