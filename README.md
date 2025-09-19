# Titanic Survival Prediction Challenge

![Kaggle](https://www.kaggle.com/competitions/titanic) ![R]

## Overview

This project presents an end-to-end data science pipeline for predicting the survival of passengers aboard the RMS Titanic. Developed for the famous [Kaggle Titanic competition](https://www.kaggle.com/c/titanic), it demonstrates a robust methodology for binary classification problems, encompassing exploratory data analysis (EDA), feature engineering, handling missing data, predictive modeling, and optimal threshold tuning.

The core model is a **logistic regression** with interaction terms, achieving an **AUC of 0.876** and a **predicted accuracy of ~77.8%** on unseen test data, significantly outperforming a naive baseline.

## Key Features

*   **Comprehensive EDA:** Detailed analysis of survival rates based on gender, socio-economic class, family size, and age.
*   **Advanced Feature Engineering:** Creation of new features like `family.cat` (categorized family size) and `has.cabin`.
*   **Sophisticated Missing Data Imputation:** Missing `Age` values are imputed using median values calculated from passenger titles (e.g., Mr., Miss., Master.), a highly effective strategy for this dataset.
*   **Interaction-Based Model:** A logistic regression model that includes interaction terms (e.g., `age:gender`) to capture complex relationships between features.
*   **Optimal Threshold Tuning:** Implementation of **Youden's J statistic** to find the probability threshold that maximizes the difference between true positive and false positive rates, moving beyond the default 0.5 cutoff.
*   **Full Pipeline:** A reproducible R script that processes raw data, trains the model, and generates a submission-ready file for Kaggle.

## Results and Performance

The final model was used to predict survival for 418 passengers in the test set.

*   **Total Test Passengers:** 418
*   **Predicted to Survive:** 193
*   **Predicted to Perish:** 225
*   **Predicted Survival Rate:** 46.17%

**Key Findings from EDA:**
*   **Gender** was the strongest predictor of survival (Cramér's V = 54.1%).
*   **Passenger Class** (Pclass) was highly influential (Cramér's V = 34%).
*   Mid-size families (2-4 people) had the highest survival rate.
*   The relationship between **Age** and survival was more complex and best understood in interaction with other variables like gender and class.

## 🛠️ Installation & Usage

### Prerequisites
*   R (>= 4.0.0)
*   RStudio (recommended)
*   The following R packages: `tidyverse`, `pROC`, `readr`

### Running the Project
1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/The-Titanic-Survival-prediction-challenge.git
    cd The-Titanic-Survival-prediction-challenge
    ```

2.  **Open the R Project** in RStudio or run the script directly.

3.  **Ensure data files are in the correct path:** The script expects the Kaggle `test.csv` file to be in your Downloads folder. Modify the path in the script if necessary.
    ```r
    titanic <- read_csv("~/Downloads/titanic/test.csv")
    ```

4.  **Execute the script:** Run `titanic_model.R` from start to finish. It will:
    *   Load the necessary libraries and data.
    *   Clean the data and perform feature engineering.
    *   Impute missing ages based on passenger titles.
    *   Load the pre-trained model and cutoff value.
    *   Generate predictions for the test set.
    *   Create and save the `submission.csv` file.

##  Reflection and Future Work

A central challenge was determining the optimal probability threshold for classification. While Youden's J statistic provided a data-driven cutoff (~36.3%), manual adjustment to a more pessimistic threshold (~71%) empirically improved accuracy. This highlights the critical impact of **class imbalance**.

**Potential improvements for future exploration:**
*   **Advanced Models:** Experiment with ensemble methods like **Random Forests**, **Gradient Boosting Machines (XGBoost)**, or simple **Neural Networks** to capture non-linear relationships.
*   **Hyperparameter Tuning:** Systematically tune model parameters and probability cutoffs using cross-validation.
*   **Additional Feature Engineering:** Incorporate features like **Deck** from the `Cabin` variable or **Ticket Group** analysis.
*   **More Sophisticated Thresholding:** Explore methods like cost-sensitive learning or maximizing metrics directly relevant to the problem domain.

##  Author

**Christoph Beck**
*   Kaggle: [https://www.kaggle.com/christophbeck]
*   GitHub: [@Nadir-Rath](https://github.com/Nadir-Rath)

---

**Disclaimer:** This project was created for educational purposes as part of a Kaggle competition. The historical data is provided by Kaggle Inc.
