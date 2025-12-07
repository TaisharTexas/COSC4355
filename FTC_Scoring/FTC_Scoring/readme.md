no matter how many times I set the launchscreen file in the settings it always forgets it and apple documentation is no help so I give up


### Change Notes
Currently the match records generated and stored by the app (which are used on the analysis screen) are seperate from the matches viewable on on the Search Teams screen. I tried to last minute cram in a converter implementation with Claude that imported the alliance score block from the API and converted it to my MatchRecord type but it wasnt working and obviously I need to put some more thought into how I am going to merge api data with data generated with the scoring functionality in the app itself. 
The goal is to be able to batch import your own matches and seamlessly use them as part of your self analysis (using the analysis screen) but that'll have to happen later as I continue to work on this for my sister's team. 

(the issue im having is I have to use three different api endpoints in conjuction to extract a single alliance score block for one match from a specific event and its turning into a mess...I see now why theres only like 2 websites that do this sort of full match viewing from the api)

### Current Functions:
1) Score own matches with score screen and save them to persistent internal storage
2) Selectively analyze stored matches to extract performance metrics (currently the team is doing this with pen and paper so having it all coded will be very nice)
3) View own or other teams' performance at events in the current season (pulls data from the FTC Event API..updated semi-live so will also be able to use at competitions)

### Future Functions:
1) Save own matches from API to internal storage
2) Save other teams' matches from API to internal storage and have seperate analysis screen for analyzing their performance (focusing on metrics that help determine their quality as an alliance partner)
