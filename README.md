# PicShowTeam
SWIFT Test Task project.

Application performs image search on Flicker by text and shows result as a grid (CollectionView) with SearchBar that showed/hide on swipe (NavigationBar default feature). Architecture is the mix between MVC and React. Views updating on data changes (used default didSet instead of 3rd parties).

Universal App can be run on iPad and iPhone. Supports rotations.

### Features:
* Search images by text on Flicker service
* Loading results page-by-page
* View fullscreen images + slider (3rd party library)
* Auto request when typing is finished (timeout 1s)
* Example unit test to check ImageModel
* Show/Hide search bar on swipe
* Encoding search string to support different symbols and languages
* Background fetching and parsing. Main Thread is only for UI.
* For class `ImageProvider` added Swift Documentation

### TODO List:
* Localisation (Currently there only one string)
* Show image title in fullscreen mode
* Add internal error type and make user-friendly error handling
* Add settings screen for appearance (per page, number of columns)
* Add filter controls (upload dates, license, sorting, geodata...)
* Cover all logic with unit tests
* Add dynamic and flexible theme (colors, fonts, insets)
* Cache results of latest search between app sessions
* Build two way pagination to support "infinite scroll"

### Installation:
1. checkout project to your folder
2. run `pod install`
3. build and run project on simulator

To run project on device you'll need to get key to sign the build.
