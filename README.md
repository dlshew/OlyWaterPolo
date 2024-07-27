# OlyWaterPolo
Attempting to predict olympics water polo scores. Were only going to look at the women's but the appraoch is simple so I used a version of it for the men too. I'm going to show it with a normal distribution, I'll let you decide if you think that's correct or not, this is the team scores I have in the csv file above. 

![WomenScores](https://github.com/user-attachments/assets/b08a71ab-a759-44ad-a668-5e3f06ab5dce)

There isn't that much data here I only used games against other olympic teams going back like a year and a half. I don't kkow if that's enough and I only have scores since I don't know how to get get metrics for handball. The scores were hand typed so there could be errors. I'm just going to walk through some of the code here the rest is in the files. 

'''


Score = Figure(size=(720,600))
ax = Axis(Score[1,1],
    title = "Actual Scores of Womens Games",
    xticks=0:1:25,
    xlabel = "Scores",
)
hist!(Scores.Team1Score,  color=:blue)
save("WomenScores.png", Score)

'''

This is the code that plots the histogram of the actual scores. I only used Team1Score column becasue I have every teams score in that column at some point.



