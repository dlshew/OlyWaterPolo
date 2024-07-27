using CSV, DataFrames, StatsBase, Distributions, CairoMakie
#Reads CSV Files
Scores = CSV.read("WomensWPolo.csv", DataFrame)
Adj = CSV.read("WAdjs.csv", DataFrame)

#Prints a fit of a normal dist to all scores
println(fit(Normal, Scores.Team1Score))
#Plots all scores
Score = Figure(size=(720,600))
ax = Axis(Score[1,1],
    title = "Actual Scores of Womens Games",
    xticks=0:1:25,
    xlabel = "Scores",
)
hist!(Scores.Team1Score,  color=:blue)
save("WomenScores.png", Score)

#Creates a ome summary stats then stores them in a dataframe
Scores.Total .= Scores.Team1Score .+ Scores.Team2Score
Scores.TeamTotal .= Scores.Team1Score
Scores.OppTotal .= Scores.Team2Score
Scores.Diff .= abs.(Scores.Team1Score .- Scores.Team2Score)
MeanTotal = mean(Scores.Total)
MeanTeamTotal = mean(Scores.TeamTotal)
MeanOppTotal = mean(Scores.OppTotal)
MedianTotal = median(Scores.Total)
ModeTotal = mode(Scores.Total)
MeanDiff = mean(Scores.Diff)
MedianDiff = median(Scores.Diff)
ModeDiff = mode(Scores.Diff)

BasicStats = DataFrame(Name="All", TeamTotal=MeanTeamTotal, OppTotal=MeanOppTotal, MeanTotal=MeanTotal, MedianTotal=MedianTotal, ModeTotal=ModeTotal,
Margin=MeanDiff, MedianMargin=MedianDiff, ModeMargin=ModeDiff)
println("")


#Gets country specific data stores in dataframe
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

Spain = GetCountry("Spain")
Italy = GetCountry("Italy")
Greece = GetCountry("Greece")
USA = GetCountry("USA")
France = GetCountry("France")
Hungary = GetCountry("Hungary")
China = GetCountry("China")
Australia = GetCountry("Australia")
Netherlands = GetCountry("Netherlands")
Canada = GetCountry("Canada")

#Vcats all countries into one dataframe
Countries = vcat(BasicStats, Spain, Italy, Greece, USA, France, Hungary, Australia, Netherlands, Canada, China)
sort!(Countries, :Margin)
show(Countries)

CSV.write("WomensBasicStats.csv", Countries)

#Plots the countires and parameters given in the fucntion call
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

ScorePlot("Netherlands", 11.916, 3.569, 1.00, 9.833, 3.157, 1.02, "Hungary", 11.454, 2.016, 1.02, 10.818, 3.270, .98)
