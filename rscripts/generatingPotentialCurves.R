# -4 -->2010, 25 --> 2040

#WIND OFFSHORE


#Get data input from page 19, https://www.ecn.nl/docs/library/report/2010/e10034.pdf 
# year 2010 is represented as timestep -4, year 2040 as timestep 25. 
# 58756 GWh at 2040, corresponds to 837.273 GWh at 228 MW, at 58756 GWh/16000MW = 3672.25 flh (page 18, para 3)

#NOTE: Limits are in GWh!!
potentialInputW <- data.frame(timestep= c(-5,25), potential=c(837.273,58756)) 

# fit data into model@ potential = a*timestep + b
f= lm(potential~timestep, data=potentialInputW)
coef(f)
timestep = -4:50
limitWindOff <- timestep*coef(f)[2] + coef(f)[1]
#limitWindOff <- data.frame(timestep, limit)

#WIND ONSHORE
potentialInputWOnshore <- data.frame(timestep= c(-5,25), potential=c(2151.62311111,9032)) 

# fit data into model@ potential = a*timestep + b
f= lm(potential~timestep, data=potentialInputWOnshore)
coef(f)
timestep = -4:50
limitWindOn <- timestep*coef(f)[2] + coef(f)[1]
#limitWindOn <- data.frame(timestep, limit)

#SOLAR PHOTOVOLTAIC
# 10839.8 GWh is from Green-X model (total generation for 2020). COmpressed _....xlsx
# 1123 MW = 1065.197 GWh is from IEA report http://www.iea-pvps.org/fileadmin/dam/public/report/national/IEA-PVPS_-_Trends_2015_-_MedRes.pdf
#crosschecked with: Defaix, 2012 (http://www.sciencedirect.com/science/article/pii/S0038092X12002186)
# which says, total potential is 31887+25677+6210 GWh = 63774, which is higher than what I have calculated.
potentialInputPV <- data.frame(timestep= c(-1,10), potential=c(1065.197 ,10839.8)) 

# fit data into model@ potential = a*timestep + b
f= lm(potential~timestep, data=potentialInputPV)
coef(f)
timestep = -4:50
limitPV <- timestep*coef(f)[2] + coef(f)[1]
limit <- data.frame(timestep, limitWindOff, limitWindOn, limitPV)

#Convert to MWh: 

limit$limitWindOff <- limit$limitWindOff*1000
limit$limitWindOn <- limit$limitWindOn*1000
limit$limitPV <- limit$limitPV*1000
limit <-t(limit)
write.csv(limit, '~/emlab-generation/emlab-generation/src/main/resources/data/potentialLimits.csv', row.names = TRUE)
