#tThis file can generate n number of trends in the form of a triangular distribution, whose mode follows the 
#sequence 

library(reshape)
library(ggplot2)
library(plyr)
library(triangle)


noOfTicks = 50 
noOfRepetitions = 120 
columnNames = as.character(seq.int(2011,2060)) 

#For NL
start = 1 
top = 1.02
max = 1.05
min = 0.99
rowNames = c()
modeSeq = seq(start, top, length.out = noOfTicks)
demandNL<- matrix(nrow = noOfRepetitions, ncol = noOfTicks )
for(j in 1:noOfRepetitions){
for(i in 1:noOfTicks){demandNL[j,i] <- rtriangle(1, min, max, modeSeq[i])}
  rowNames <- c(rowNames, paste('demandNL-',j,sep = ""))
}
colnames(demandNL) <- columnNames
write.csv(demandNL, file =paste('demandGrowthNL.csv'), quote = F, row.names = rowNames)

#For DE
start = 1 
top = 1.02
max = 1.05
min = 0.99
noOfTicks = 50 
rowNames = c()
modeSeq = seq(start, top, length.out = noOfTicks)
demandDE<- matrix(nrow = noOfRepetitions , ncol = noOfTicks )
for(j in 1:noOfRepetitions){
  for(i in 1:noOfTicks){demandDE[j,i] <- rtriangle(1, min, max, modeSeq[i])}
  rowNames <- c(rowNames, paste('demandDE-',j,sep = ""))
}
colnames(demandDE) <- columnNames
write.csv(demandDE, file =paste('demandGrowthDE.csv'), quote = F, row.names = rowNames)

#For Coal Price
start = 1 
top = 1.02
max = 1.05
min = 0.99
noOfTicks = 50 
rowNames = c()
modeSeq = seq(start, top, length.out = noOfTicks)
coalPrice<- matrix(nrow = noOfRepetitions , ncol = noOfTicks )
for(j in 1:noOfRepetitions){
  for(i in 1:noOfTicks){coalPrice[j,i] <- rtriangle(1, min, max, modeSeq[i])}
  rowNames <- c(rowNames, paste('coalPrice-',j,sep = ""))
}
colnames(coalPrice) <- columnNames
write.csv(coalPrice, file =paste('coalPrice.csv'), quote = F, row.names = rowNames)


#For gas Price
start = 1 
top = 1.02
max = 1.05
min = 0.99
noOfTicks = 50 
rowNames = c()
modeSeq = seq(start, top, length.out = noOfTicks)
gasPrice<- matrix(nrow = noOfRepetitions , ncol = noOfTicks )
for(j in 1:noOfRepetitions){
  for(i in 1:noOfTicks){gasPrice[j,i] <- rtriangle(1, min, max, modeSeq[i])}
  rowNames <- c(rowNames, paste('gasPrice-',j,sep = ""))
}
colnames(gasPrice) <- columnNames
write.csv(gasPrice, file =paste('gasPrice.csv'), quote = F, row.names = rowNames)

#For biomass Price
start = 1 
top = 1.02
max = 1.05
min = 0.99
noOfTicks = 50 
rowNames = c()
modeSeq = seq(start, top, length.out = noOfTicks)
biomassPrice<- matrix(nrow = noOfRepetitions , ncol = noOfTicks )
for(j in 1:noOfRepetitions){
  for(i in 1:noOfTicks){biomassPrice[j,i] <- rtriangle(1, min, max, modeSeq[i])}
  rowNames <- c(rowNames, paste('biomassPrice-',j,sep = ""))
}
colnames(biomassPrice) <- columnNames
write.csv(biomassPrice, file =paste('biomassPrice.csv'), quote = F, row.names = rowNames)

#For uranium Price
start = 1 
top = 1.02
max = 1.05
min = 0.99
noOfTicks = 50 
rowNames = c()
modeSeq = seq(start, top, length.out = noOfTicks)
uraniumPrice<- matrix(nrow = noOfRepetitions , ncol = noOfTicks )
for(j in 1:noOfRepetitions){
  for(i in 1:noOfTicks){uraniumPrice[j,i] <- rtriangle(1, min, max, modeSeq[i])}
  rowNames <- c(rowNames, paste('uraniumPrice-',j,sep = ""))
}
colnames(uraniumPrice) <- columnNames
write.csv(uraniumPrice, file =paste('uraniumPrice.csv'), quote = F, row.names = rowNames)

#For lignite Price
start = 1 
top = 1.02
max = 1.05
min = 0.99
noOfTicks = 50 
rowNames = c()
modeSeq = seq(start, top, length.out = noOfTicks)
lignitePrice<- matrix(nrow = noOfRepetitions , ncol = noOfTicks )
for(j in 1:noOfRepetitions){
  for(i in 1:noOfTicks){lignitePrice[j,i] <- rtriangle(1, min, max, modeSeq[i])}
  rowNames <- c(rowNames, paste('lignitePrice-',j,sep = ""))
}
colnames(lignitePrice) <- columnNames
write.csv(lignitePrice, file =paste('lignitePrice.csv'), quote = F, row.names = rowNames)


