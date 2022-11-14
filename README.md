# Categorical Data Analysis

Performed categorical data analysis on employee attrition and happiness data 1972-2006 with R to answer the following research questions. The code, `AMS573_Final_Kwon_Su-Ah.R`, and pdf file, *statistical_analysis_detailed_process.pdf*, show detailed description of the analysis.  

---
### Employee Attrition
- What are the conditionally dependent explanatory variables for the probability of employee attrition adjusted for all other variables that gives a good fit to the model?
- What affects the probability of employee attrition the most and the least among the dependent variables? 
- Which dependent variable has a linear trend against employee attrition?
- What is the association between years with current manager, performance rating, and years in current role?

---
### Happiness 1972-2006

- Can we fit the given data using only finrela (relative financial status),year,or health? 
- What is the association between health, and relative financial status?

---
The statistical models and tools are used in the analysis. 

- Logistic regression: Baseline-Category Logit Model and Cumulative Logit Model
- Loglinear regression: Linear-by-Linear model
- Chi-Square Goodness of fit test
- Backward stepwise Algorithm: AIC
- ROC curve

## Description

The employee attrition dataset is a fictional data set created by IBM data scientists to find components that impact employee attrition. There are 1470 employees (or observations) and 25 variables with ordinal variables are already coded with numeric values.The happiness 1972-2006 data is a small sample of variables related to happiness from the general social survey (GSS). The GSS is a yearly cross-sectional survey of Americans, run from 1972 to 2006. There are 51,020 observations, and of the over 5,000 variables, nine were selected related to happiness. The detailed description for both dataset can be found from the links.

## Links
- https://www.kaggle.com/pavansubhasht/ibm-hr-analytics-attrition-dataset
- https://www.rdocumentation.org/packages/GGally/versions/1.5.0/topics/happy 

## Executing Program
Download R version (>=4.1.0)

Imports:
* pROC (>=1.18.0)
* productplots (>=0.1.1)
* VGAM (>=1.1-7)




