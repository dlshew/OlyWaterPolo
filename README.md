# OlyWaterPolo
Attempting to predict olympics water polo scores. Were only going to look at the women but the appraoch is simple so I used a version of it for the men too. I'm going to show it with a normal distribution, I'll let you decide if you think that's correct or not, this is the team scores I have in the csv file above. 

![WomenScores](https://github.com/user-attachments/assets/b08a71ab-a759-44ad-a668-5e3f06ab5dce)

There isn't that much data here I only used games against other olympic teams going back like a year and a half. I don't know if that's enough and I only have scores since I don't know how to get get metrics for handball. The scores were hand typed so there could be errors. I'm just going to walk through some of the code here the rest is in the files. 


```
Score = Figure(size=(720,600))
ax = Axis(Score[1,1],
    title = "Actual Scores of Womens Games",
    xticks=0:1:25,
    xlabel = "Scores",
)
hist!(Scores.Team1Score,  color=:blue)
save("WomenScores.png", Score)
```
This is the code that plots the histogram of the actual scores. I only used Team1Score column becasue I have every teams score in that column at some point.


This code prints the fit of the normal distribution for each country and makes a dataframe of some basic stats for the countries.

```
function GetCountry(Country::String)
    CountryDF = subset(Scores, :Team1 => team -> team .== Country)
    println(Country, " Off Score ",  fit(Normal, CountryDF.Team1Score))
    println(Country, " Def Score ",  fit(Normal, CountryDF.Team2Score))
    CountryDF.Total .= CountryDF.Team1Score .+ CountryDF.Team2Score
    CountryDF.TeamTotal .= CountryDF.Team1Score
    CountryDF.OppTotal .= CountryDF.Team2Score
    CountryDF.Diff .= CountryDF.Team1Score .- CountryDF.Team2Score
    TeamTotal = mean(CountryDF.TeamTotal)
    MeanTotal = mean(CountryDF.Total)
    MeanOppTotal = mean(CountryDF.OppTotal)
    MedianTotal = median(CountryDF.Total)
    ModeTotal = mode(CountryDF.Total)
    MeanDiff = mean(CountryDF.Diff)
    MedianDiff = median(CountryDF.Diff)
    ModeDiff = mode(CountryDF.Diff)
    DF = DataFrame(Name=Country, TeamTotal=TeamTotal,  OppTotal=MeanOppTotal, MeanTotal=MeanTotal, MedianTotal=MedianTotal, ModeTotal=ModeTotal,
    Margin=MeanDiff, MedianMargin=MedianDiff, ModeMargin=ModeDiff)
    return DF
end
```

This is the printing of the normal fit: Spain Def Score Normal{Float64}(μ=8.785714285714286, σ=2.782048870592921) when you call GetCountry("Spain").



The table turns out like are you vcat all the countries. 
 Row │ Name         TeamTotal  OppTotal  MeanTotal  MedianTotal  ModeTotal  Margin     MedianMargin  ModeMargin 
     │ String       Float64    Float64   Float64    Float64      Int64      Float64    Float64       Int64      
─────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ France         7.36364  13.3636     20.7273         21.0         21  -6.0               -7.0          -7
   2 │ China          9.0      14.3846     23.3846         23.0         23  -5.38462           -5.0         -13
   3 │ Canada         8.9      12.9        21.8            20.5         20  -4.0               -3.5          -3
   4 │ Australia      9.5      10.1        19.6            18.0         18  -0.6               -1.5          -2



```
function ScorePlot(TeamOne::String, OneOMean::Float64, OneOSTtd::Float64, OneOAdj::Float64, OneDMean::Float64, OneDStd::Float64, OneDAdj::Float64,
    TeamTwo::String, TwoOMean::Float64, TwoOStd::Float64, TwoOAdj::Float64, TwoDMean::Float64, TwoDStd::Float64, TwoDAdj::Float64)
    NorOne = round.(rand(Truncated(Normal(((OneOMean * OneOAdj) * .5) + ((TwoDMean * TwoDAdj) * .5),  (OneOSTtd * .5) + (TwoDStd * .5)), 0,25), 50_000))
    NorTwo = round.(rand(Truncated(Normal(((TwoOMean * TwoOAdj) * .5) + ((OneDMean * OneDAdj) * .5),  (TwoOStd * .5) + (OneDStd * .5)), 0,25), 50_000))

    Nor = Figure(size=(720,600))
    ax = Axis(Nor[1,1],
        title = "$TeamOne Vs $TeamTwo Mens 50,000 Samples",
        xticks=0:1:25,
        xlabel = "Scores",
        ylabel = "Probablity of Score"
)

    density!(NorOne,  color=:blue, label = "$TeamOne")
    density!(NorTwo,  color=(:yellow, 0.8), label = "$TeamTwo")
    axislegend()
    save("NormalWomen$TeamOne" * "Vs" * "$TeamTwo" * ".png", Nor)
    println("")

    println("$TeamOne")
    println("Mode: ", mode(NorOne))
    display(summarystats(NorOne))
    println("")
    println("$TeamTwo")
    println("Mode: ", mode(NorTwo))
    display(summarystats(NorTwo))
end

```

When you call ScorePlot("Netherlands", 11.916, 3.569, 1.00, 9.833, 3.157, 1.02, "Hungary", 11.454, 2.016, 1.02, 10.818, 3.270, .98) you get some descriptive stats and a density plot of 50,000 sample from a normal distribution with those parameters.

![NormalWomenNetherlandsVsHungary](https://github.com/user-attachments/assets/1f251d27-1864-4117-8b49-79d1bb36add8)

Netherlands
Mode: 11.0
Summary Stats:
Length:         50000
Missing Count:  0
Mean:           11.235440
Std. Deviation: 3.424395
Minimum:        0.000000
1st Quartile:   9.000000
Median:         11.000000
3rd Quartile:   14.000000
Maximum:        25.000000

You can code it to get the values in there but I chose not to so I can mess around with the values since the model is so simple. I want to be able to pass in different parameters to see on my own without going into the funtion and messing stuff up. Since there's only a few games every couple days its not a big time killer to type them in I think freedom > speed for this. Adjustments were art more than science but I tried to factor in some strenght of schedule feel free to really adjust those I didn't end up using those exaxtly. The function basically takes: offense mean score times an adjustment then takes a weighted average of that and the opponents defense of the same thing.  I'll admit I did not use a normal disttribution but I thought it was the best way to be able to share something. I specifiaclly don't expect this version to win and don't fully expect mine to either.
