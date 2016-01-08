#Placeholders

# Step 1 building the scenarios: insert dataframe and read the scenario file. Name parameters
# that need to be replaced with #
xmlFilePath<-"/Users/kaveri/Desktop/emlabGen/scenario/prelimAnalysis/TenderExAnteTechSpecTemplate.xml"
filestump<-'TenderExAnteTechSpec-'
#filestump<-'TechSpecFullTwoCountriesInfCap-'
# Step 2 building the scenarios: make separate data vectors
noOfRepetitions = 120 
for(runID in seq(1:noOfRepetitions))
  {
  xmlFileContent<-readLines(xmlFilePath, encoding = "UTF-8")
  xmlFileContent<-gsub("#repetitionNumber", runID, xmlFileContent)
  writeLines(xmlFileContent, paste("~/Desktop/emlabGen/scenario/prelimAnalysis/", filestump, runID, ".xml", sep=""))
  }

#TenderExPost
#TenderExAnte
#KBaseCase
#FipExPost
#FipExAnte
#TenderExPostTechSpec
#TenderExAnteTechSpec