# The-Titanic-Survival-prediction-challenge
This is my attempt at using logistic regression to create an econometric model, which forecasts and ranks survivability of passengers on the Titanic.

The included script is the distilled, bare-bones workign version for creating my model. I've also included my pdf report with extensive EDA, and step-by-step explanations.

The basic idea is to use logistic regression and feature engineering to create a model, which assigns survival likelihoods to new passengers by using data from the trainign set. By analyzing certain the association of characteristics with survival / death, we can fine-tune the model and get relatively accurate survival chances.

The real issue, which I haven't been able to solve yet, and can mostly be blamed on my lack of knowledge around the subject, is the threshold of survival:

How likely does it need to be for you to survive, so that we can confidently say "you'll survive"? Survival and death are imbalanced, unlike a coin toss. This means we can't just pick 50% and be done with it. This way we'd essentially miss out on potential correct guesses.

I tried solving this by getting an "optimal cutoff" via the Youden's J statistic, but arbitrary changing of the cutoff ended up giving significantly better results, making me doubt it's efficacy.

Tying it all up, I think I'll do more research into cutoffs and also random forrest estimates to get closer to that sweet sweet optimal score.







