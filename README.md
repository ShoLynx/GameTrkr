# GameTrkr
**GameTrkr** is designed as a video game software tracking app for video game enthusiasts as a final project for the Udacity iOS Developer program.

## Installation
Clone the GitHub repository and use Xcode to open the xcworkspacefile.  Use Xcode to install to Simulator or your device.

## How to Use
After opening **GameTrkr**, you will be presented with an empty *Platform Table* that will give you instructions on how to add Platforms and Games.  Platforms can be the video game consoles you use to play your games (i.e. Nintendo Switch, PlayStation 4, Xbox One, etc.), handhelds (Game Boy, Game Gear, etc.) or your PC.  Since PC games can be launched from several launchers, like Steam, BattleNet or Epic, it is suggested that you name your PC platforms after these launchers, but this is up to you.

Once you add a Platform, you can add games to said platform.  Follow the instructions to add Games in the same manner as adding platforms.

### Platform/ Game Table Controls
-	Add New Platform/Game button: provides a view for you to add a Platform or Game
-	Edit (with Platforms/Games available): enter the table’s Edit mode, where you have the option to remove Platforms and Games
-	Scroll (with Platforms/Games available): swipe vertically to scroll through the available Platforms and Games
-	Expose item delete function (with Platforms/Games available):  swipe leftward on a Platform/Game item to expose its Delete function

Once you add a Game, you can enter a *customizable page* you can use to track several aspects of your game: like your favorite YouTube video about said game, photos about your game or any descriptive text you want to add.

### Customizable Game Page Controls
-	Load Video button: load a video based on the current Platform and Game
-	Watch Another Video button (while video from Load Video is active): loads YouTube’s next suggested video
-	Add Photo button: opens your device’s photo gallery for you to select a photo to add to the collection view
-	Photo Collection: tap a photo to enter a full-screen view of the selected photo.  Swipe horizontally to scroll through the available photos
-	Remove Photos button: enters the collection view’s edit mode, where you can delete existing photos by tapping them
-	Scroll: swipe vertically to scroll through the page’s contents
-	Edit button: enter the page's *Settings* mode

To customize this page, you can use the *Settings* mode by tapping Edit.  Here, you can toggle the radio buttons that show if a game is digital, if it has its original packaging, or if the game is a special edition.  If you don’t like the videos that appear by selecting Load Video, you can set a default video by adding a YouTube URL.  This video will always appear when the page loads.  Use the Add Description switch to add a description to the custom page.


## Planned Updates
-	The Set Default Video function currently can only use full YouTube URLs.  Update planned for the app to be able to use Share URLs, as well
-	Users will be able to move games from one platform to another with a picker view in Settings
-	If the YouTube view is inactive, instructional text will appear at the view
-	*Ultimate Update*: Web functionality.  User updates are saved to a website, instead of locally.  Users can access their game library and customizations with either the app or the website and share their collections with others.  This will require user authentication on both the app and website.
