

Hitters<-read.csv("data/Hitters.csv")
#The following two commands list the names of variables in the data file
#and the dimension of the data
names(Hitters)
dim(Hitters)

# The following command finds the number of time the Salary field is empty,
# given as na, then the following line removes those entries from the working
# data set.  Note:  this is a common practice but one must be aware of
# the fact of throwing away some amount of otherwise good data
# This is OK if one is aware of this fact and the number of entries removed
# is low, aroung 5% is a good rule of thumb.
# Alternatives exist if this condition is not met
# These techniques are referred to by the name "imputation"
# Several methods of imputing missing data,which means making an educated
# guess on the value of missing data based on "similar" data in the data set
# R has several nice packages that do imputation

sum(is.na(Hitters$Salary))
Hitters=na.omit(Hitters)

# Now check if the missing data has been removed
dim(Hitters)
sum(is.na(Hitters))

nvmax<-3

# This library, "leaps" performs subset selection
# Adding or removing variables and checking to see
# if the model performance increase
# This starts by using all variable available
# In R's "formula" language this is done via "Salary~."
# Which means create a model, linear regression in this case,
# that defines the output, "Salary", using all other variable
# in the data set.  Several methods exist:  use all subsets of a
# given size ( choosing among all possible subset), or to select
# variables that produce the best improvement starting either
# from one variable, then adding other in (forward selection),
# or start with all variables and
# remove one at a time ( backward selection)
# The "all subset of size k" becomes computationally too demanding
# once k > 30 or 40, so the latter techniques are used most often
# for datasets contain potentially large number of predicter
# variables.

# This starts by using all variables available
library(leaps)
#regfit.full=regsubsets(Salary~.,Hitters, really.big=T)
#summary(regfit.full)


# This repeats the regression but limits the maximum number
# of variables used to nvmax, via "nvmax"
regfit.full=regsubsets(Salary~.,data=Hitters,3)
reg.summary=summary(regfit.full)


# There are several standard ways of calculating a "measure of fit"
# or how well the model predicts the response, or dependent variable
# based on the generated model.  These include "R-Squared",
# "Adjusted R-Squared", "Mallow's Cp", and "Bayesian Information Criteris (BIC)"
#  No one measure is always better than the others, so it is wise to look
# at all of the.


names(reg.summary)
reg.summary$rsq

# This is basic plotting of the "measure of fit" as the number of variables
# used in the model increases
par(mfrow=c(2,2))
plot(reg.summary$rss,xlab="Number of Variables",ylab="RSS",type="l")
plot(reg.summary$adjr2,xlab="Number of Variables",ylab="Adjusted RSq",type="l")
which.max(reg.summary$adjr2)
points(11,reg.summary$adjr2[11], col="red",cex=2,pch=20)
plot(reg.summary$cp,xlab="Number of Variables",ylab="Cp",type='l')
which.min(reg.summary$cp)
points(10,reg.summary$cp[10],col="red",cex=2,pch=20)
which.min(reg.summary$bic)
plot(reg.summary$bic,xlab="Number of Variables",ylab="BIC",type='l')
points(6,reg.summary$bic[6],col="red",cex=2,pch=20)
plot(regfit.full,scale="r2")
plot(regfit.full,scale="adjr2")
plot(regfit.full,scale="Cp")
plot(regfit.full,scale="bic")
coef(regfit.full,6)

# Forward and Backward Stepwise Selection

regfit.fwd=regsubsets(Salary~.,data=Hitters,nvmax,method="forward")
summary(regfit.fwd)
regfit.bwd=regsubsets(Salary~.,data=Hitters,nvmax,method="backward")
summary(regfit.bwd)
coef(regfit.full,7)
coef(regfit.fwd,7)
coef(regfit.bwd,7)

# Choosing Among Models

set.seed(1)
train=sample(c(TRUE,FALSE), nrow(Hitters),rep=TRUE)
test=(!train)
regfit.best=regsubsets(Salary~.,data=Hitters[train,],nvmax)
test.mat=model.matrix(Salary~.,data=Hitters[test,])
val.errors=rep(NA,nvmax)
for(i in 1:nvmax){
   coefi=coef(regfit.best,id=i)
   pred=test.mat[,names(coefi)]%*%coefi
   val.errors[i]=mean((Hitters$Salary[test]-pred)^2)
}
val.errors
which.min(val.errors)
coef(regfit.best,10)
predict.regsubsets=function(object,newdata,id,...){
  form=as.formula(object$call[[2]])
  mat=model.matrix(form,newdata)
  coefi=coef(object,id=id)
  xvars=names(coefi)
  mat[,xvars]%*%coefi
  }
regfit.best=regsubsets(Salary~.,data=Hitters,nvmax)
coef(regfit.best,10)
k=10
set.seed(1)
folds=sample(1:k,nrow(Hitters),replace=TRUE)
cv.errors=matrix(NA,k,nvmax, dimnames=list(NULL, paste(1:nvmax)))
for(j in 1:k){
  best.fit=regsubsets(Salary~.,data=Hitters[folds!=j,],nvmax)
  for(i in 1:nvmax){
    pred=predict(best.fit,Hitters[folds==j,],id=i)
    cv.errors[j,i]=mean( (Hitters$Salary[folds==j]-pred)^2)
    }
  }
mean.cv.errors=apply(cv.errors,2,mean)
mean.cv.errors
par(mfrow=c(1,1))
plot(mean.cv.errors,type='b')
reg.best=regsubsets(Salary~.,data=Hitters, nvmax)
coef(reg.best,11)
