# Seattle Schools
This application helps parents to see the schools around Seattle. The app features filtering to cut down the schools to display of only their interest.

## Screenshots
![screenshot](https://raw.githubusercontent.com/naterhat/seattleschools/master/screenshots/screenshot1.PNG)

## Notes
For Core Data, the code is there, but it's not being used yet. The app manage the data in memory, for now.

## Todos
x Dependencies injection for local storage
x Retrieve image from url
x Create actions links to phone, web, and address
x For group of annotations, show number count
x Filter Grades
x add copyright
x animate a wave for the flag
x Change Color of Annotation by Public or Private
x BUG - fixed current location annotation
x BUG - when pull down flag to the further point, able to see beyond the wood texture.

- If its group of annotations, disable call out.
- Fix annotation refresh
- Deal with address nil
- Deal with website nil
- Disable call button if no phone
- Disable web if no website.
- When tap current, check if out of area and display error.
- Tap on Seattle Title - Go Center of Seattle
- Scale to fit for annotation call out image view.
- animate annotations when seperate and when pull back together.
- add UIMotionEffect
- create pressure point when drag the flag
- iPhone 6 and greater, the pole texture image is not shown because the height is smaller.
- add credits
- add cut off above the flag
- separate HomeViewController with MapViewController
- check internet connection
- check if already  downloaded schools 


- BUG - some annotation are not being removed, Stuck at a location. It has no interaction.
- BUG - call for image from google wit NTJSONNetworkCollector
- CRASH - when add new annotation. To get there, by zooming out and in.
