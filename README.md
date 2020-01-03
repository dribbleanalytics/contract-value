# METHODOLOGY: Using machine learning to find the best and worst value contracts

[Link to blog post.](https://dribbleanalytics.blog/2020/01/contract-value)

## Data collection

We collected salary data from two places. For historical data dating back to 1990, we used [this Kaggle data set](https://www.kaggle.com/whitefero/nba-player-salary-19902017). For 2018-19 salary data, we used Basketball-Reference's player contract page from April 1, 2019 ([link](https://web.archive.org/web/20190401162630/https://www.basketball-reference.com/contracts/players.html)).

We collected all counting and advanced stats for every player from Basketball-Reference.

Using the data, we created models to predict salary given a player's performance in that year. So, this is not a predictive metric; it's a retrospective look at value.

We used the following stats as features:

1. Age
2. Points per game
3. Rebounds per game
4. Assists per game
5. Steals per game
6. Blocks per game
7. True shooting %
8. Win shares

These factors predicted a player's percent of cap, not their raw salary. This is because the cap rose and there was inflation, so raw salary numbers are inconsistent.

Note that players who have a contract but did not play are not considered, as they have no stats to predict. So, for example, Chris Bosh was on the Heat's payroll last year, but is not in our data set.

Also note that in cases where a player had multiple contracts (mostly happens if they were released), we removed their duplicate values. We kept the value with the higher salary number.

## Contract value analysis

With this data, we created four models:

1. K-nearest neighbors regressor
2. Random forest regressor
3. Gradient boosting regressor
4. Extreme gradient boosting regressor

After evaluating these models, we compared each player's average predicted salary from these four models to his actual salary. We also created a team-by-team analysis by looking at the sum of predicted salary relative to the sum of real salary.

The full player results are available in the "results" folder and also in a Google sheet [here](https://docs.google.com/spreadsheets/d/19_g58Nzb9qv0HqmUuUqH5YSfk9Ys25E5q_e4qJIB1UI/edit?usp=sharing).

## R Shiny app

To help visualize each contract value we created an R Shiny app. The app can be accessed [here](https://dribbleanalytics.shinyapps.io/contract-value/).

The app lets you compare players within a team, compare players across the league, and compare teams.

The R code for the Shiny app is in the folder called "r-shiny-app." The code is contained in the "app" file. The .csv file provides the data used in the app. The "publish" file simply publishes the app to shinyapps.io.
