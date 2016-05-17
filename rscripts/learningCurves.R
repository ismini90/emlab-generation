install.packages("mosaicData")
install.packages('mosaic')
install.packages('car')
library(car)
library(mosaic)


potentialW <- data.frame(year= c(2010,2040), potential=c(704.4339,58756)) 
plotPoints(potential~year, data=potentialW)
# fit data into model@ y = a ln(t) + b
f= fitModel(PVUtilityAvg_Inv~A*log(tick)+B, data=u)
coef(f)
t[1]= 0.0001
t[2:112]=(1:111)
o1 = f(t)
o1
f2= fitModel(PVUtilityAvg_Inv~A*log(tick)+B, data=u)
f3= fitModel(formula = PVUtilityAvg_Inv~PVUtilityAvg_Inv[1]*exp(-tick/Tau), data=u)
plotFun(f(tick)~tick, temp.lim=range(0,50), add=FALSE)

uWind = fetchData('WindData.csv')
plotPoints(WindOnshoreAvg~tick, data=uWind)
# fit data into model@ y = a ln(t) + b
fWind <- nls(formula = WindOffshoreAvg~A*log(tick, base = 10)+B, data=uWind, trace=T,
                 start = list(A=-200, B=1000), algorithm = "port" )
coef(fWind)
t=(0:50)
o1 = f(t)

uPV2 = fetchData('PVOMData.csv')
f4 = fitModel(OM~A*tick+B, data = uPV2)
yOM = -0.28*t+21.1
yOM
yEff = 0.0025*t +0.14
yEff
rowNames = c('tick','Inv','OM', 'Eff')
tick=c(0:111)
PVData = rbind(tick,o1, yOM, yEff)
write.csv(PVData, file = 'PvData.csv', row.names = rowNames)


require(graphics)

## Annette Dobson (1990) "An Introduction to Generalized Linear Models".
## Page 9: Plant Weight Data.
ctl <- c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)
trt <- c(4.81,4.17,4.41,3.59,5.87,3.83,6.03,4.89,4.32,4.69)
group <- gl(2, 10, 20, labels = c("Ctl","Trt"))
weight <- c(ctl, trt)
lm.D9 <- lm(weight ~ group)
lm.D90 <- lm(weight ~ group - 1) # omitting intercept

anova(lm.D9)
summary(lm.D90)

opar <- par(mfrow = c(2,2), oma = c(0, 0, 1.1, 0))
plot(lm.D9, las = 1)      # Residuals, Fitted, ...
par(opar)
