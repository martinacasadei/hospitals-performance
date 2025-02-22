#project script
source("methods_lab_functions.R.txt")
installLibraries(c("Hmisc","ggplot2","RCurl","devtools","gmodels","gridExtra","bootLR",
                   "grid","plyr","geepack","caret","forestplot","Epi","MatchIt","epitools","ROCR","ROCit","pROC","cutpointr"))

library(vctrs)
library(descr)
library(Hmisc)
library(gmodels)
require(ggplot2)
library(gridExtra)
library(plyr)
library(grid)
library(geepack)
library(caret)
library(geepack)
library(forestplot)
library(Epi)
library(MatchIt)
library(epitools)
library(cutpointr)
library(bootLR)
library(ROCR)
library(ROCit)
library(pROC)


#uploading dataset of 2017 ny hospital dataset
dataset<-read.csv("NYSDOH_HospitalInpatientDischarges_SPARCS_De-Identified_2017.csv", stringsAsFactors = F, header = T, sep=",")


#PART 1 
#manipulating 2017 ny dataset
#creating a simpler dataset

#transform some variables in factor and extract the levels
ny_counties<-levels(factor(dataset$Hospital.County))                  
ny_areas<-levels(factor(dataset$Hospital.Service.Area))
ny_age<-levels(factor(dataset$Age.Group))
ny_adm_types<-levels(factor(dataset$Type.of.Admission))
ny_races<-levels(factor(dataset$Race))
ny_ethnicities<-levels(factor(dataset$Ethnicity))
ny_diags<-levels(factor(dataset$CCS.Diagnosis.Description))
ny_procs<-levels(factor(dataset$CCS.Procedure.Description))
ny_dispositions<-levels(factor(dataset$Patient.Disposition))
ny_severities<-levels(factor(dataset$APR.Severity.of.Illness.Description))
ny_risks<-levels(factor(dataset$APR.Risk.of.Mortality)) 

#we assign unique levels to the global environment
assign("ny_counties",ny_counties,envir=.GlobalEnv)     
assign("ny_areas",ny_areas,envir=.GlobalEnv)
assign("ny_age",ny_age,envir=.GlobalEnv)
assign("ny_adm_types",ny_adm_types,envir=.GlobalEnv)
assign("ny_races",ny_races,envir=.GlobalEnv)
assign("ny_ethnicities",ny_ethnicities,envir=.GlobalEnv)
assign("ny_diags",ny_diags,envir=.GlobalEnv)
assign("ny_procs",ny_procs,envir=.GlobalEnv)
assign("ny_dispositions",ny_dispositions,envir=.GlobalEnv)
assign("ny_severities",ny_severities,envir=.GlobalEnv)
assign("ny_risks",ny_risks,envir=.GlobalEnv)

#turn the levels of a variable transformed in a factor variable, in numeric entries,
#assigning the index number
dataset$ny_hosp_id<-as.numeric(as.factor(dataset$Facility.Name))     
dataset$ny_county<-as.numeric(as.factor(dataset$Hospital.County))
dataset$ny_area<-as.numeric(as.factor(dataset$Hospital.Service.Area))
dataset$cl_age<-as.numeric(as.factor(dataset$Age.Group))
dataset$zipcode<-as.numeric(as.factor(dataset$Zip.Code...3.digits))
dataset$adm_type<-as.numeric(as.factor(dataset$Type.of.Admission))
dataset$race<-as.numeric(as.factor(dataset$Race))
dataset$ethnicity<-as.numeric(as.factor(dataset$Ethnicity))
dataset$los<-dataset$Length.of.Stay                                           #generates los variable in hospdata data.frame
dataset$disposition<-as.numeric(as.factor(dataset$Patient.Disposition))
dataset$diagnosis<-as.numeric(as.factor(dataset$CCS.Diagnosis.Description))
dataset$procedure<-as.numeric(as.factor(dataset$CCS.Procedure.Description))
dataset$drg<-as.numeric(as.factor(dataset$APR.DRG.Code))
dataset$mdc<-as.numeric(as.factor(dataset$APR.MDC.Code))
dataset$severity<-as.numeric(as.factor(dataset$APR.Severity.of.Illness.Description))
dataset$risk<-as.numeric(as.factor(dataset$APR.Risk.of.Mortality))
dataset$payment_type<-as.numeric(as.factor(dataset$Payment.Typology.1))
dataset$cost<-dataset$Total.Charges

dataset$los<-as.numeric(gsub("[^0-9.]","",dataset$los))
dataset$cost<-as.numeric(gsub("[^0-9.]","",dataset$cost))


#long stay variable
dataset$long_stay<-0
dataset$long_stay<-ifelse(dataset$los>6,1,dataset$long_stay)

#gender variable
dataset$males<-0
dataset$males<-ifelse(dataset$Gender=="U",NA,dataset$males)
dataset$males<-ifelse(dataset$Gender=="M" & !is.na((dataset$Gender)),1,dataset$males)


#substance-related disorders
grep("Substance-related disorders",ny_diags)
ny_diags[252]
dataset$sub_dis<-0
dataset$sub_dis<-ifelse(dataset$diagnosis==252,1,dataset$sub_dis)

#new dataset
ny_dataset<-dataset[,c("ny_hosp_id","ny_county","ny_area","cl_age",
                       "males","zipcode","adm_type","race","ethnicity","los",
                       "disposition","diagnosis","procedure","drg","mdc","severity",
                       "risk","payment_type","cost",
                       "dead","sub_dis","long_stay")]

write.table(ny_dataset, file="ny_dataset.csv", row.names = F, sep =",")



#creating a dataset with only those with substance-related disorders
sd_dataset<-ny_dataset[ny_dataset$sub_dis==1,]


#PART 2
#descriptives
#table with personal characteristics
#univariate analysis
CrossTable(sd_dataset$cl_age, format="SPSS")
#cl_age=1 0-17
#cl_age=2 18-29
#cl_age=3 30-49
#cl_age=4 50-69
#cl_age=5 70 or Older

CrossTable(sd_dataset$males,format="SPSS")
#males=1 M
#males=0 F
CrossTable(sd_dataset$males,sd_dataset$cl_age, format="SPSS")

CrossTable(sd_dataset$cl_age)

CrossTable(sd_dataset$race, format="SPSS")
#race=4 white
#race=3 other race
#race=2 multi-racial
#race=1 black/african american

CrossTable(sd_dataset$ethnicity, format="SPSS")
#ethnicity=1 multi-ethnic
#ethnicity=2 not Span/Hispanic
#ethnicity=3 spanish/hispanic
#ethnicity=4 unknown

CrossTable(sd_dataset$ethnicity, sd_dataset$race, format="SPSS")

CrossTable(sd_dataset$payment_type, format="SPSS")
#1 Blue Cross/Blue Shield
#2 Department of Corrections
#3 Federal/State/Local/VA
#4 Managed Care, Unspecified
#5 Medicaid
#6 Medicare
#7 Miscellaneous/Other
#8 Private Health Insurance
#9 Self-Pay
#10 Unknown



CrossTable(sd_dataset$procedure, format="SPSS")



CrossTable(sd_dataset$long_stay, format="SPSS")
#0 short stay
#1 long stay



#PART 3
#(crude and directly std) rates
#long stay rate by each hospital
longstay_sd<-aggregate(sd_dataset$long_stay,by=list(sd_dataset$ny_hosp_id),FUN="mean") 
longstay_sd

#numerosity of long stay by each hospital
longstay_sd_nrow<-aggregate(sd_dataset$long_stay,by=list(sd_dataset$ny_hosp_id),FUN=NROW) 
longstay_sd_nrow

#(crude) rates of long stay by hospital
names(longstay_sd)<-c("ny_hosp_id","rate")
names(longstay_sd_nrow)<-c("ny_hosp_id","n")
longstay_sd<-merge(longstay_sd,longstay_sd_nrow,by=c("ny_hosp_id"))
longstay_sd$rate<-longstay_sd$rate*100
longstay_sd$rate

#turning unique hospital id and county number
hosp_county<-aggregate(ny_county ~ ny_hosp_id,ny_dataset,FUN="unique")    
names(hosp_county)<-c("ny_hosp_id","ny_county") 
hosp_county  

#merging the data by my_hosp_id
z_sd<-merge(longstay_sd,hosp_county,by=c("ny_hosp_id"),all.x=TRUE)
z_sd$county_up<-ifelse(z_sd$ny_county>20,2,1) #if county >20 assign 2 otherwise 1
z_sd #new clearer dataset


#aggregating the long stays by ny area
longstay_sd_area<-aggregate(sd_dataset$long_stay,by=list(sd_dataset$ny_area),FUN="mean")
names(longstay_sd_area)<-c("ny_area","long_stay")
longstay_sd_area$long_stay<-round(longstay_sd_area$long_stay*1000,2)
longstay_sd_area #mean number of observations with long stay by each ny area

#creating a subset with only the hospitals with n>1000
hospitals<-subset(z_sd, z_sd$n>1000)
#Mount Sinai Beth Israel = 100                   New York City
#Nassau University Medical Center = 107          Long Island
#SJRH - Park Care Pavilion = 159                 Hudson Valley
#St Charles Hospital = 166                       Long Island
#Staten Island University Hosp-South = 183       New York City



#direct standardization for major hospitals
#population table for the whole population
#reclassification of age (1-2 classes together)
sd_dataset$recl_age<-ifelse(sd_dataset$cl_age %in% c(1,2),1,sd_dataset$cl_age)
pop_ij<-table(sd_dataset[,c("recl_age")],sd_dataset[,c("males")]) #contingency table for ageclass and gender
pop_ij
totpop<-sum(pop_ij)       #N=number of total population (sum of all counts)


#crude and direct standardized rate
table(sd_dataset$ny_hosp_id)
target_group<-subset(sd_dataset,sd_dataset$ny_hosp_id=="100") 
target_group
outcome_intarget<-subset(target_group,target_group$long_stay==1)     
outcome_intarget

label_target_group<-"Hospital 100"  


num_data<-table(outcome_intarget[,c("recl_age")],outcome_intarget[,c("males")])  #age/gender table of dead patients of hosp_id 19. Cells contain dij
num_data
den_data<-table(target_group[,c("recl_age")],target_group[,c("males")])          #age/gender table of patients of hosp_id 10. Cells contain nij
#note: tables have different dimension

#in direct standardization we compare the outcome of the numerator
#with denominator 
num_data
den_data
as.data.frame.matrix(num_data)
as.data.frame.matrix(den_data*0)  #just to make the two matrices comparable as they have diff dimension
#we create a 0 matrix and then we fill it

#make the numerator uniform with denominator
res<-merge(as.data.frame.matrix(num_data),as.data.frame.matrix(den_data*0),all=TRUE,sort=FALSE)
res
res<-as.matrix(res[,order(as.numeric(colnames(res)))])
rownames(res)<-c(rownames(num_data),rownames(den_data))
res<-rowsum(res,row.names(res))
res

#res and num_data have the same length now 4x2
res
den_data

#matrix contains all death rates age/sex specific
asr_ijt<-as.matrix(res/den_data)   #age gender table with dij/nij cells
asr_ijt
asr_ijt[4,1]<-0
pop_ij
cr_t<-((sum(num_data)/sum(den_data)))*100 #creating rate=sum(dij)/sum(nij) *100
cr_t
sr_t<-sum(unclass(asr_ijt)*unclass(pop_ij))/totpop*100 #std rate rate=sum(dij/nij *Nij)/N *100
sr_t   #???
sr_t.se<- sqrt((sr_t/100*(1-sr_t/100))/(sum(den_data))) #std error
sr_t.ll95  <- sr_t - 1.96 * sr_t.se    #lower 95% c.i.
sr_t.ul95  <- sr_t + 1.96 * sr_t.se    #upper 95% c.i.

#creating the final dataset
output1<-data.frame(label_target_group,round(cr_t,2),round(sr_t,2),round(sum(den_data),2),round(sr_t.ll95,2),round(sr_t.ul95,2))
names(output1)<-c("Unit","CR","SR","N","Lower95","Upper95")
output1


#PART 4
#multivariate analysis
str(sd_dataset)
sd_dataset$ethnicity<-as.factor(sd_dataset$ethnicity)
sd_dataset$cl_age<-as.factor(sd_dataset$cl_age)
sd_dataset$race<-as.factor(sd_dataset$race)
sd_dataset$males<-as.factor(sd_dataset$males)
sd_dataset$payment_type<-as.factor(sd_dataset$payment_type)
sd_dataset$procedure<-as.factor(sd_dataset$procedure)

#recodification of procedure variable
sd_dataset$proc[sd_dataset$procedure=="114"]<-0 #no proc
sd_dataset$proc[sd_dataset$procedure=="3"]<-1 #detox/rehab
sd_dataset$proc[sd_dataset$procedure=="194"]<-2 #psych
sd_dataset$proc[sd_dataset$procedure=="200"]<-3 #intubation
sd_dataset$proc[is.na(sd_dataset$proc)]<-4 #others

sd_dataset$proc<-as.factor(sd_dataset$proc)

#recodification of payment_type variable
sd_dataset$pay<-NA
sd_dataset$pay[sd_dataset$payment_type=="5"]<-0 #medicaid
sd_dataset$pay[sd_dataset$payment_type=="6"]<-1 #medicare
sd_dataset$pay[sd_dataset$payment_type=="1"]<-2 #blue
sd_dataset$pay[sd_dataset$payment_type=="8"]<-3 #private insurance/
sd_dataset$pay[sd_dataset$payment_type=="9"]<-3 #self pay
sd_dataset$pay[is.na(sd_dataset$pay)]<-4 #others

sd_dataset$pay<-as.factor(sd_dataset$pay)

#recodification of ethnicity
sd_dataset$ethnic<-NA
sd_dataset$ethnic[sd_dataset$ethnicity=="1"]<-0
sd_dataset$ethnic[sd_dataset$ethnicity=="2"]<-0
sd_dataset$ethnic[sd_dataset$ethnicity=="4"]<-0
sd_dataset$ethnic[sd_dataset$ethnicity=="3"]<-1

sd_dataset$ethnic<-as.factor(sd_dataset$ethnic)

#recodification of race
sd_dataset$race_new<-NA
sd_dataset$race_new[sd_dataset$race=="1"]<-0
sd_dataset$race_new[sd_dataset$race=="2"]<-0
sd_dataset$race_new[sd_dataset$race=="4"]<-0
sd_dataset$race_new[sd_dataset$race=="3"]<-1

sd_dataset$race_new<-as.factor(sd_dataset$race_new)

#recodification of class age
sd_dataset$recl_age<-0
sd_dataset$recl_age[sd_dataset$cl_age=="1"]<-0
sd_dataset$recl_age[sd_dataset$cl_age=="2"]<-0
sd_dataset$recl_age[sd_dataset$cl_age=="3"]<-1
sd_dataset$recl_age[sd_dataset$cl_age=="4"]<-2
sd_dataset$recl_age[sd_dataset$cl_age=="5"]<-2

sd_dataset$recl_age<-as.factor(sd_dataset$recl_age)


#glm models
#first logit model
longstay_logit1<-glm(long_stay~recl_age+males+race_new+ethnic+proc+pay,family = binomial("logit"),data=sd_dataset)
summary(longstay_logit1)

#second logit model
longstay_logit2<-glm(long_stay~recl_age+males+ethnic+proc+pay,family = binomial("logit"),data=sd_dataset)
summary(longstay_logit2)

#third logistic model
longstay_logit3<-glm(long_stay~males+ethnic+proc+pay,family = binomial("logit"),data=sd_dataset)
summary(longstay_logit3)

#odds ratios
library(oddsratio)
oddsratio(sd_dataset$recl_age, sd_dataset$long_stay)
oddsratio(sd_dataset$males, sd_dataset$long_stay)
oddsratio(sd_dataset$proc, sd_dataset$long_stay)
oddsratio(sd_dataset$pay, sd_dataset$long_stay)
oddsratio(sd_dataset$ethnic, sd_dataset$long_stay)


#LRT
#likelihood ratio test between the full model (logit 3) and the reduced one (logit 4)
ndiffpars<-length(longstay_logit2$coefficients)-length(longstay_logit3$coefficients)     #dof=difference of n* of variables, useful for chisqaure test
LL1<-(-2*as.numeric(logLik(longstay_logit2)))     #-2*loglik of full model
LL2<-(-2*as.numeric(logLik(longstay_logit3)))  #-2*loglik of reduced model
LR<-pchisq(LL2-LL1,ndiffpars,lower.tail=FALSE)  #chisquare test
#we only test if in the reduced model the loglik dicreases significally
LR
message(paste("-2 LogLik FULL:",LL1))    
message(paste("-2 LogLik REDUCED:",LL2))
message(paste("Likelihood Ratio:",LL2-LL1,"; P(chi-square)=",LR,"; df=",ndiffpars))
#shows likelihood ratio, p value of chi square test and dof
#p-value=0,000 we prefer the full model as the difference in the loglikelihoods is stat significant (p<0.05)

#roc curve for the full model
sd_dataset$p<- predict(longstay_logit2,newdata=sd_dataset,type="response")
optimal_cut_full<-cutpointr(data=sd_dataset,x=p,class=long_stay,na.rm=TRUE,method=maximize_metric,metric=youden,use_midpoint=TRUE)
summary(optimal_cut_full)
plot_metric(optimal_cut_full) # Youden Index: Sensitivity + Specificity -1
sd_dataset$predicted.value <- ifelse(sd_dataset$p >optimal_cut_full$optimal_cutpoint,1,0)
discordant<-mean(sd_dataset$predicted.value != sd_dataset$long_stay,na.rm=TRUE) #discordant proportion
message(paste('Accuracy of the FULL model (logit 3):',1-discordant))   #accuracy-concordance


pROC_full<- pROC::plot.roc(sd_dataset$long_stay,sd_dataset$p,
                           main="Confidence interval of a threshold", percent=TRUE,
                           ci=TRUE, of="thresholds", # compute AUC (of threshold)
                           thresholds="best", # select the (best) threshold
                           print.thres=optimal_cut_full$optimal_cutpoint,
                           print.thres.col="red")
ci_auc_2<-ciAUC(rocit(score=sd_dataset$p,sd_dataset$long_stay)) #confidence intervals

#roc curve reduced model
sd_dataset$p_r<- predict(longstay_logit3,newdata=sd_dataset,type="response") #create a variable with predicted probabilities
optimal_cut_reduced<-cutpointr(data=sd_dataset,x=p_r,class=long_stay,na.rm=TRUE,method=maximize_metric,metric=youden,use_midpoint=TRUE)
summary(optimal_cut_reduced)
plot_metric(optimal_cut_reduced) # Youden Index: Sensitivity + Specificity -1
sd_dataset$predicted.value<-ifelse(sd_dataset$p_r>optimal_cut_reduced$optimal_cutpoint,1,0)
confusionMatrix(as.factor(sd_dataset$predicted.value),as.factor(sd_dataset$long_stay))
discordant<-mean(sd_dataset$predicted.value != sd_dataset$long_stay,na.rm=TRUE)
message(paste('Accuracy of the REDUCED model (logit 4):',1-discordant))

pROC_reduced<- pROC::plot.roc(sd_dataset$long_stay,sd_dataset$p_r,
                              main="Confidence interval of a threshold", percent=TRUE,
                              ci=TRUE, of="thresholds", # compute AUC (of threshold)
                              thresholds="best", # select the (best) threshold
                              print.thres=optimal_cut_reduced$optimal_cutpoint,
                              print.thres.col="red")
ci_auc_1<-ciAUC(rocit(score=sd_dataset$p_r,sd_dataset$long_stay)) #confidence intervals

#plot curves together
plot(pROC_reduced,col="red",lty=2)
text(round(optimal_cut_reduced$specificity*100,1)-9,round(optimal_cut_reduced$sensitivity*100,1)-3,paste(round(optimal_cut_reduced$optimal_cutpoint,4)," (",round(optimal_cut_reduced$specificity*100,1),",",round(optimal_cut_reduced$sensitivity*100,1),")",sep=""),cex=0.65,col="red")
plot(pROC_full,type="shape",col="blue",lty=3,add=TRUE)
text(round(optimal_cut_full$specificity*100,1)+10,round(optimal_cut_full$sensitivity*100,1)+3,paste(round(optimal_cut_full$optimal_cutpoint,4)," (",round(optimal_cut_full$specificity*100,1),",",round(optimal_cut_full$sensitivity*100,1),")",sep=""),cex=0.65,col="blue")

#adding legend to the plot
legend("bottomright", 
       legend = c(
         paste("Score REDUCED AUC: ",format(round(ci_auc_1$AUC*100,1),nsmall=1)," (",round(ci_auc_1$lower*100,1),"-",round(ci_auc_1$upper*100,1),")",sep=""),
         paste("Score FULL AUC: ",format(round(ci_auc_2$AUC*100,1),nsmall=1)," (",round(ci_auc_2$lower*100,1),"-",round(ci_auc_2$upper*100,1),")",sep="")
       ),
       inset=c(.0001,.0001),col = c("red","blue"),lty=c(2,3),lwd=c(2,2)) 



#gee model
g_longstay_logit<-geeglm(long_stay~recl_age+males+ethnic+proc+pay, data=sd_dataset,id=as.factor(ny_hosp_id),family=gaussian,corstr="exchangeable")
summary(g_longstay_logit)
P=coef(summary(g_longstay_logit))[,4]
P
OR<-exp(cbind(OR=g_longstay_logit$coefficients))
OR

#PART 5
#indirectly std rate
#Linear combination of the predictors: p(outcome), p=exp(xiB)/[1+exp(xijB)]
sd_dataset$p<- predict(longstay_logit2,newdata=sd_dataset,type="response")   #it creates a variable p with predicted probabilities
#from fitted logistic model (expected prob of long stay from the fitted model)

#average outcome in the entire sample: reference population rate
Ybar<-sum(sd_dataset$long_stay,na.rm=TRUE)/dim(sd_dataset)[1] #divided by the number of observations
Ybar   #tot long stay rate for the entire sample
Ybar*100

#Average predicted probabilities for ALL dataset
mean(sd_dataset$p) # with missing values
mean(sd_dataset$p,na.rm=TRUE) # without missing values
sum(sd_dataset$p,na.rm=TRUE)/dim(sd_dataset)[1] # divided by the number of observations
sum(sd_dataset$p,na.rm=TRUE)/sum(!is.na(sd_dataset$p))  # divided by the number of observations WITHOUT missing values


#Calculate Standardized Rates for Type 1
O1<-mean(sd_dataset[sd_dataset$ny_hosp_id=="100",c("long_stay")],na.rm=TRUE)   #observed rate at hosp_id 100
O1
E1<-mean(sd_dataset[sd_dataset$ny_hosp_id=="100",c("p")],na.rm=TRUE)      #expected rate at hosp_id 100
E1*100
N1<-dim(sd_dataset[sd_dataset$ny_hosp_id=="100",])[1]                     #number of patients at hosp_id 100
P1j<-sd_dataset[sd_dataset$ny_hosp_id=="100",c("p")]                      #predicted probability from logit of Y on X for all patients in hosp_id 1


rar1<-Ybar*(O1/E1)   #risk adjusted rate (indirect std rate)    
rar1

rar1.se<-sqrt( (Ybar/E1)^2 *(1/N1)^2 * sum(P1j*(1-P1j),na.rm=TRUE))   #std error of risk adj rate
rar1.ll95  <- rar1 - 1.96 * rar1.se     #lower ci
rar1.ul95  <- rar1 + 1.96 * rar1.se     #upper ci

#final output with all the indicators
output3<-data.frame("HOSPITAL 100",round(O1*100,2),round(rar1*100,2),N1,round(rar1.ll95*100,2),round(rar1.ul95*100,2))
names(output3)<-c("Unit","CR","SR","N","Lower95","Upper95")
output3

#funnel plot
funnel_plot(title="Long stay rate for SRD in New York State hospitals (2017)", # Graph Title
            names=z_sd$ny_hosp_id,                # variable for group names
            names_outliers=1,                      # differently plot outliers by names (0=No;1=Yes)
            plot_names=1,                          # plot names instead of dots
            in_colour=1,                           # colour points within boundaries (0=No;1=Yes)
            colour_var=z_sd$county_up,            # variable for colouring groups (numeric)
            colour_values=c("blue", "red"),  # list of colours for all levels of colour_var
            rate=z_sd$rate,                         # value of standardized rates
            unit=100,                              # denominator of rates
            population=z_sd$n,                    # total number of subjects for each rate
            binary=1,                              # binary variable (0=No;1=Yes)
            p_mean="weighted",                     # Unweighted, Weighted or specified value
            filename="funnel_plot",                           # output graph filename 
            graph="sd_longstay",                 # name of graph object
            pdf_height=3.5,                        # height pdf output
            pdf_width=6,                           # width pdf output
            ylab="Indicator per 100",              # y axis label
            xlab="Total N",                        # x axis label
            selectlab="County",                    # Label for group legend
            selectlev=c("1","2"),                  # Values of group legend
            dot_size=1.5,                          # Scaling factor for dots in the funnel plot
            dfout="dfout")

print(sd_longstay)

#PART 6
#comparison between years (2013-2017)
dataset2<-read.csv("NYSDOH_HospitalInpatientDischarges_SPARCS_De-Identified_2016.csv", stringsAsFactors = F, header = T, sep=",")
sd_dataset2<-subset(dataset2, dataset2$CCS.Diagnosis.Code=="661")

dataset3<-read.csv("NYSDOH_HospitalInpatientDischarges_SPARCS_De-Identified_2015.csv", stringsAsFactors = F, header = T, sep=",")
sd_dataset3<-subset(dataset3, dataset3$CCS.Diagnosis.Code=="661")

dataset4<-read.csv("NYSDOH_HospitalInpatientDischarges_SPARCS_De-Identified_2014.csv", stringsAsFactors = F, header = T, sep=",")
sd_dataset4<-subset(dataset4, dataset4$CCS.Diagnosis.Code=="661")

dataset5<-read.csv("NYSDOH_HospitalInpatientDischarges_SPARCS_De-Identified_2013.csv", stringsAsFactors = F, header = T, sep=",")
sd_dataset5<-subset(dataset4, dataset5$CCS.Diagnosis.Code=="661")



