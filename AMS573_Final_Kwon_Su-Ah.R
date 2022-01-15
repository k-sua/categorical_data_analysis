# Data 01: Employee Attrition
### Research Problem & Purpose of Analysis

#What are the conditionally dependent explanatory variables for employee attrition adjusted for all other variables that gives a good fit to the model?
#What effects the employee attrition the most and the least among the dependent variables? 
#What is the association between years with current years with manager, performance rating, years in current role?
  
### Explantion of the Data Set
  
or.dat1=read.csv("Employee-Attrition.csv",header=T,stringsAsFactors=T)
str(or.dat1)
summary(or.dat1)
dat1=or.dat1


#I consider that Job Satisfaction, Marital Status, Monthly Income, Relationship Satisfaction, Work life Balance are the dependent variables on the employee attrition.
#To check the goodness of fit test, we will first discretize the continuous variable, Monthly Income.  

dat1$MonthlyIncome=cut(dat1$MonthlyIncome,breaks=5, include.lowest = TRUE,labels = c(1,2,3,4,5))
dat1$Attrition=ifelse(dat1$Attrition=="Yes",1,0)
fit1=glm(Attrition~factor(JobSatisfaction)+MonthlyIncome+MaritalStatus+factor(RelationshipSatisfaction)+factor(WorkLifeBalance),family=binomial,data=dat1)
n=nrow(dat1)
fit.yes=n*fitted(fit1);fit.no=n*(1-fitted(fit1))
sum(fit.yes<5);sum(fit.no<5)

summary(fit1) # Goodness of Fit test --> nonsparse contingency table (large-sample chi-square)
1-pchisq(1173.6,1454)
1-pchisq(1298.6-1173.6,1469-1454)<0.05 #overall test

car::Anova(fit1)[which(car::Anova(fit1)[3]>0.05),3,drop=F]
MASS::stepAIC(fit1) 

fit2=glm(Attrition~factor(JobSatisfaction)+MonthlyIncome+MaritalStatus+factor(WorkLifeBalance),family=binomial,data=dat1)
summary(fit2)
# Original
fit3=glm(Attrition~JobSatisfaction+MonthlyIncome+MaritalStatus+factor(WorkLifeBalance),family=binomial,data=dat1) 
# Check linear trend for Job Satisfaction
fit4=glm(Attrition~factor(JobSatisfaction)+as.numeric(MonthlyIncome)+MaritalStatus+factor(WorkLifeBalance),family=binomial,data=dat1) 
# Check linear trend for Monthly Income
fit5=glm(Attrition~factor(JobSatisfaction)+MonthlyIncome+MaritalStatus+WorkLifeBalance,family=binomial,data=dat1) 
# Check linear trend for Work Life Balance

result=data.frame(fit2=AIC(fit2),fit3=AIC(fit3),fit4=AIC(fit4),fit5=AIC(fit5)) # Job satisfaction have a linear trend with response.
rownames(result)=c("AIC");result
summary(fit3) # There seems to be no complete and quasi-complete separation in the data. 
fit.yes=n*fitted(fit3);fit.no=n*(1-fitted(fit3))
sum(fit.yes<5);sum(fit.no<5)

sum(abs(rstandard(fit2,type="pearson"))>3)/n # about 2% of the data shows lack of fit; however, this is a small number that could occur by chance. 
index=rstandard(fit3,type="pearson")>3

library(pROC)
(rocplot <- roc(dat1$Attrition ~ fitted(fit2), data=dat1)) 
plot.roc(rocplot, legacy.axes=TRUE) 
auc(rocplot) # area under ROC curve
cor(dat1$Attrition,fitted(fit2))


#Let us see the association between current years with manager, performance rating, years in current role?

dat1$YearsInCurrentRole=cut(dat1$YearsInCurrentRole, breaks = 3,labels = c(1,2,3),include.lowest = T)
dat1$YearsWithCurrManager=cut(dat1$YearsWithCurrManager, breaks = 3,labels = c(1,2,3),include.lowest = T)
attach(dat1)
A=as.data.frame(table(YearsInCurrentRole,YearsWithCurrManager,PerformanceRating))

fit1=glm(Freq~ YearsInCurrentRole+YearsWithCurrManager+PerformanceRating,family=poisson,data=A) # Independence Model
sum(fitted(fit1)*n<5)
summary(fit1)
1-pchisq(760.64,12) <0.05 # Goodness of Fit Test --> They are not mutually independent
fit2=glm(Freq~YearsInCurrentRole+YearsWithCurrManager+PerformanceRating+YearsInCurrentRole:YearsWithCurrManager+YearsInCurrentRole:PerformanceRating+PerformanceRating:YearsWithCurrManager ,family=poisson,data=A) # homogeneous association model
summary(fit2)
1-pchisq(2.0587,4)>0.05 # Goodness of Fit Test--> well fitted
fit3=glm(Freq~YearsInCurrentRole+YearsWithCurrManager+PerformanceRating+YearsInCurrentRole:YearsWithCurrManager ,family=poisson,data=A)
summary(fit3)
result=data.frame(A[,-4],fit=fitted(fit3))
1-pchisq(5.8915,8) # Goodness of Fit Test --> well fitted



# Data 02: Happiness 1972-2006
### Research Problem & Purpose of Analysis

#(1) Under the condition of independent observations and given categorical variables, can we fit the given data using only finrela(relative financial status),year, or health?
#(2) What is the association between health,and finrela?
  
  
### Explantion of the Data Set
  
library(productplots)
library(VGAM)
dat2.ori=happy
str(dat2.ori)
summary(dat2.ori)

### Cleaning Data and Discretize the Data

dat2=na.omit(dat2.ori)[,-c(1,10)]
summary
str(dat2)
dat2$year=cut(dat2$year,breaks=4, include.lowest = TRUE,labels = c("earlier","early","mid","late"))


### Model Selection 

# I considered that finrela,health, year are the dependent variables for happiness degree. 

attach(dat2)
B=as.data.frame(table(finrela,happy,year,health))
BB=reshape(B,idvar=c("year","finrela","health"),timevar="happy",direction="wide")
colnames(BB)=c("fin","year","health","not","pretty","very")

fit1=vglm(as.matrix(BB[,-c(1,2,3)])~year+fin+health,family=cumulative(parallel =T),data=BB)
n=nrow(dat2)
sum(n*fitted(fit1)<5)

fit.nominal=vglm(as.matrix(BB[,-c(1,2,3)])~year+fin+health,family=multinomial,data=BB)
summary(fit1)
1-pchisq(527.9542,148)
summary(fit.nominal) 
1-pchisq(207.0248,138)


fit.nom2=vglm(as.matrix(BB[,-c(1,2,3)])~1,family=multinomial,data=BB)
fit.nominal=vglm(as.matrix(BB[,-c(1,2,3)])~year+fin+health,family=multinomial,data=BB)
fit3=vglm(as.matrix(BB[,-c(1,2,3)])~year+fin,family=multinomial,data=BB)
fit4=vglm(as.matrix(BB[,-c(1,2,3)])~year+health,family=multinomial,data=BB)
fit5=vglm(as.matrix(BB[,-c(1,2,3)])~health+fin,family=multinomial,data=BB)
lrtest(fit.nominal,fit.nom2) # P-value < 0.05     
lrtest(fit.nominal,fit3) # P-value < 0.05
lrtest(fit.nominal,fit4) # P-value < 0.05
lrtest(fit.nominal,fit5) # P-value < 0.05


BB$fin=as.numeric(BB$fin)
BB$health=as.numeric(BB$health)
fit6=vglm(as.matrix(BB[,-c(1,2,3)])~year+fin+health,family=multinomial,data=BB) # we treat finrela and health as ordinal variables 
fit7=vglm(as.matrix(BB[,-c(1,2,3)])~year+fin+health,family=cumulative(parallel=T),data=BB)
summary(fit6)
summary(fit7)
1-pchisq(539.5048,148) 
1-pchisq(647.8967,153)

fit8=vglm(as.matrix(BB[,-c(1,2,3)])~year+factor(fin)+health,family=multinomial,data=BB)  # We assume that year has no linear trend to the probability of the degree of happiness. 
fit9=vglm(as.matrix(BB[,-c(1,2,3)])~year+fin+factor(health),family=multinomial,data=BB)
summary(fit8)
summary(fit9)
1-pchisq(408.0058,142)
1-pchisq(334.5304,144)
deviance(fit8) # 408.0048 > 207.0248 
deviance(fit9) # 334.5304 > 207.0248


fit1.int01=vglm(as.matrix(BB[,-c(1,2,3)])~year+factor(fin)+factor(health)+factor(fin):factor(health),family=multinomial,data=BB)
fit1.int02=vglm(as.matrix(BB[,-c(1,2,3)])~year+factor(fin)+factor(health)+factor(fin):year,family=multinomial,data=BB)
summary(fit1.int01)
summary(fit1.int02)
1-pchisq(169.5027,114)
1-pchisq(159.9879,114) # Correlated vs. 0.0001302404


## Fit with finrela, and health
C=as.data.frame(table(finrela,happy,health))
CC=reshape(C,idvar=c("finrela","health"),timevar="happy",direction="wide")
colnames(CC)=c("fin","health","not","pretty","very")

fit.or=vglm(as.matrix(CC[,-c(1,2)])~fin+health,family=cumulative(parallel =T),data=CC)
summary(fit.or)
fit.nominal=vglm(as.matrix(CC[,-c(1,2)])~fin+health,family=multinomial,data=CC)
summary(fit.nominal)
1-pchisq(325.1225,31)
1-pchisq(46.8493,24)


fit.or2=vglm(as.matrix(CC[,-c(1,2)])~as.numeric(fin)+as.numeric(health),family=cumulative(parallel =T),data=CC) # No Linear Trend
fit.nominal2=vglm(as.matrix(CC[,-c(1,2)])~as.numeric(fin)+as.numeric(health),family=multinomial,data=CC) 
summary(fit.or2);summary(fit.nominal2)
1-pchisq(450.2304,36)
1-pchisq(386.4982,34)

fit.or3=vglm(as.matrix(CC[,-c(1,2)])~health+fin+health:fin,family=cumulative(parallel =T),data=CC)
fit.nominal3=vglm(as.matrix(CC[,-c(1,2)])~fin+health+fin:health,family=multinomial,data=CC) 
summary(fit.or3);summary(fit.nominal3)
1-pchisq(289.6491,19)
# Inaccurate residual deviance due to convergence at a half-step

fit.or4=vglm(as.matrix(CC[,-c(1,2)])~as.numeric(fin)+health,family=cumulative(parallel =T),data=CC)
fit.nominal4=vglm(as.matrix(CC[,-c(1,2)])~fin+as.numeric(health),family=multinomial,data=CC) 
summary(fit.or4);summary(fit.nominal4)
1-pchisq(434.0577,34)
1-pchisq(256.4947,28)

fit10=vglm(as.matrix(CC[,-c(1,2)])~fin,family=multinomial,data=CC)
fit11=vglm(as.matrix(CC[,-c(1,2)])~health,family=multinomial,data=CC)
summary(fit10);summary(fit11)
1-pchisq(1041.41,32)
1-pchisq(1986.135,30)


# What is the association between health and finrela?

E=as.data.frame(table(dat2$health,dat2$finrela))
colnames(E)=c("health","finrela","Freq")
fit=glm(Freq~health+finrela,family=poisson,data=E) 
summary(fit)
1-pchisq(2007.6,12) #Goodness of Fit Test --> They are not mutually independent
fit2=glm(Freq~health+finrela+as.numeric(health):as.numeric(finrela),family=poisson,data=E) # Linear by Linear association model
fit3=glm(Freq~health*finrela,family=poisson,data=E) # The Saturated model
summary(fit2)
summary(fit3)
1-pchisq(170.73,11) # Goodness of Fit test --> They have no linear trend



















