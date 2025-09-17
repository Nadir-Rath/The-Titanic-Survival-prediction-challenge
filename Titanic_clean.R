# Titanic survivor analysis 

rm(list = ls())
library(readr)
titanic <- read_csv("~/Downloads/titanic/train.csv")


# assigning variables ####

age = titanic$Age
id = titanic$PassengerId
parch = titanic$Parch
sibsp = titanic$SibSp
sex = titanic$Sex
fare = titanic$Fare
pclass = titanic$Pclass
survived = titanic$Survived

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

base.data = data.frame(survived, age, gender, family.cat, pclass, title, has.cabin) 

# creating a function for estimation of contingency correlations - "Cramér's V" ####

cat.test = function(x, y) {
  # contingency table
  table.xy = table( x, y)
  
  # chisquare test
  chi.test = chisq.test(table.xy)
  
  # Cramér's V
  n = sum(table.xy)
  k = min(dim(table.xy))
  V = sqrt (chi.test$statistic / (n * (k - 1)) )
  
  # Return the results
  list(
    table = table.xy,
    chi.squared = chi.test,
    cramers.v = V,
    std.residuals = chi.test$stdres
  )
}

family.test = cat.test(survived, family.cat)

family.chi.squ = family.test$chi.squared$statistic 
print(family.chi.squ); print(family.test$cramers.v); print(family.test$std.residuals)

# this demonstrates the significance of family size on survival, 
# apllies with other variables.

# setting up the model ####

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

median.by.group = aggregate(age ~ young.woman + older.woman + young.man + old.man + specialist + noble + other,
                            data = title.class,
                            FUN = median,
                            na.rm = T)

group.names = c("Young Woman", "Older Woman", "Young Man", "Old Man", "Specialist", "Noble", "Other")
median.age = c(median.by.group$age, sum(other))
print(median.age)
median.age = data.frame(group.names , median.age)
print(median.age)

# proper medians have been distilled and labeled. Moving on to NA replacement

median.age.by.group = median.age$median.age

base.data$age[is.na(base.data$age) & title.class$young.woman == 1] = median.age.by.group[1]
base.data$age[is.na(base.data$age) & title.class$older.woman == 1] = median.age.by.group[2]
base.data$age[is.na(base.data$age) & title.class$young.man == 1] = median.age.by.group[3]
base.data$age[is.na(base.data$age) & title.class$old.man == 1] = median.age.by.group[4]
base.data$age[is.na(base.data$age) & title.class$specialist == 1] = median.age.by.group[5]
base.data$age[is.na(base.data$age) & title.class$noble == 1] = median.age.by.group[6]
base.data$age[is.na(base.data$age) & title.class$other == 1] = median.age.by.group[7]

# new ages successfully imputed, 


# creating an interaction based model ####

library(pROC)

survival.est = glm(formula = survived ~ age + gender + family.cat + socio.class + has.cabin +
                   age:gender + age:family.cat + age:socio.class, 
                   family = "binomial",
                   data = base.data)
probs = predict(object = survival.est, type = "response")
roc.curve = roc(base.data$survived, probs)
survival.est$aic
# ROC plot ####

survival.roc = roc(base.data$survived, probs)
plot(survival.roc,
     main = "ROC Curve for survival model",
     print.auc = T,
     auc.polygon = T,
     auc.polygon.col = "cadetblue2",
     max.auc.polygon = T,
     grid = T,
     legacy.axes = T)

best.cutoff <- coords(survival.roc, "best", ret = "threshold", best.method = "youden") # basically the p which minimizes false pos / neg rate


summary(survival.est)
coefficients(survival.est)

# anyways, this delivers a maximum AUC of 0.876.
# this means I can have 87.6% maximum accuracy, should I desire so.


# this is essentially done. Everything left now is maybe modulating the relationship between age and death
# otherwise we're now doing and submitting our first prognosis. 

# running the model on the test data
save(median.age.by.group,  file = "./titanic_median.RData") #dataexport for predictions
save(best.cutoff, file = "./titanic_cutoff.RData") # survival cutoff
save(survival.est,  file = "./titanic_model.RData") #dataexport for predictions


