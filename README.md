# RTvsEccentricity
All codes and data for the Reaction Time dependence on eccentricity paper from Elegant Mind Club. 

Store data for each protocol in a seperate folder and and store all protocol folders in a master folder. The code reads the data in an ascending order so ensure the names go from Protocol 1 onwards. Also, ensure that the position of a particular subject's data is the same in all protocol folder. 

Master Code- AggregateAnalysis_version3.mat
I suggest running the code section by section. Most of the sections use functions that are also in this GitHub. 

FolderNameGenerator-
This is a fairly simple function that creates a folder on the directory based on experimenter and experiment name that you would need to input in the dialogue box that appears. This is the folder where some of the data such as Slope/Intercept/Chi-squared values for individual subject and aggregated is stored as well as the percentage correct bar charts. 

experimentInformation- 
This function takes all stylistic information from the experimenter for plots. This is optimized for 4-protocol experiment, but can be easily editted to add more. The dialogue box also allows the experimenter to change any stylistic options, but that can be tedious to do if you are repeating the process. 

aggregatePlotting-
This function plots the aggregate graphs

chiSquareFunction-
This function calculates the slope and intercept, standard error and reduced chisquare values. 

hypothesisTesting-
This function tests if a subject is guessing the answer based on their percentage error. 

plotSubjectData_v3-
Plots individual subject's data

plotProtocolData_v3-
Plots all subject's data for a particular protocol in one graph as well as the aggregated plot for that protocol. i.e. stacked plots

