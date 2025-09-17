# Titanic survivor analysis 

rm(list = ls())
library(readr)
titanic <- read_csv("~/Downloads/titanic/test.csv")
load("~/Documents/R_Projects/titanic_median.RData") # loading median estimates,
load("~/Documents/titanic_model.RData") # and model.
load("~/Documents/titanic_cutoff.RData")


# assigning variables ####

age = titanic$Age
id = titanic$PassengerId
parch = titanic$Parch
sibsp = titanic$SibSp
sex = titanic$Sex
fare = titanic$Fare
pclass = titanic$Pclass


# data cleaning ####

gender = (sex == "female") * 1 # converting to binary variable, female = 1
gender = as.factor(gender)
socio.class = as.factor(pclass) # factorization
has.cabin = as.factor(as.numeric(! is.na(titanic$Cabin)))

# analyzing family size's impact, creating a size variable

family.size = parch + sibsp + 1 # +1 for self
family.cat = cut(family.size,
                 breaks = c(0, 1, 4, Inf),
                 labels = c("alone", "small (2-4)", "large (5+)"))

library(tidyverse) # string extraction with tidyverse

name = titanic$Name
title = str_extract(name, "\\b[A-Za-z]+\\.")

# dataframing ####

base.data = data.frame(age, gender, family.cat, pclass, title, has.cabin) 
# age imputation ####

young.woman = as.numeric( base.data$title == "Lady." | 
                            base.data$title == "Miss." |
                            base.data$title == "Mlle." |
                            base.data$title == "Ms." )

older.woman = as.numeric( base.data$title == "Mme."|
                            base.data$title == "Mrs.")
young.man =   as.numeric(base.data$title == "Master.")

old.man =     as.numeric(base.data$title == "Mr.")

specialist =  as.numeric(base.data$title == "Capt."|
                           base.data$title == "Col."|
                           base.data$title == "Dr."|
                           base.data$title == "Major."|
                           base.data$title == "Rev.")

noble =       as.numeric(base.data$title == "Countess."|
                           base.data$title == "Count."| # same logic as 'Dona.'
                           base.data$title == "Don."|
                           base.data$title == "Jonkheer."|
                           base.data$title == "Sir."|
                           base.data$title == "Dame.")

other = as.numeric (!(noble | specialist | old.man | young.man | older.woman | young.woman))

title.class = data.frame(titanic$Age, young.woman, older.woman, young.man, old.man, specialist, noble, other )

# proper medians have been distilled and labeled. Moving on to NA replacement


base.data$age[is.na(base.data$age) & title.class$young.woman == 1] = median.age.by.group[1]
base.data$age[is.na(base.data$age) & title.class$older.woman == 1] = median.age.by.group[2]
base.data$age[is.na(base.data$age) & title.class$young.man == 1] = median.age.by.group[3]
base.data$age[is.na(base.data$age) & title.class$old.man == 1] = median.age.by.group[4]
base.data$age[is.na(base.data$age) & title.class$specialist == 1] = median.age.by.group[5]
base.data$age[is.na(base.data$age) & title.class$noble == 1] = median.age.by.group[6]
base.data$age[is.na(base.data$age) & title.class$other == 1] = median.age.by.group[7]

# new ages successfully imputed.

# running the model on the test data:
probs = predict(survival.est, newdata = base.data, type = "response")

best.cutoff = as.numeric(best.cutoff)
# trying a new cut-off

best.cutoff = 0.88

predicted.class = ifelse(probs >= best.cutoff, 1, 0)
PassengerId = id
Survived = predicted.class

submission = data.frame(PassengerId, Survived)
write_csv(submission, file = "~/Documents/submission_88.csv")
