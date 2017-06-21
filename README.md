# FiveYears

"FiveYears" is a small application targeted for iOS 10 and later. I wrote it to celebrate the fifth anniversary with my girlfriend.
It pictures common memories collected during the time we spent together.

This is the first app I designed and developed entirely myself (excluding the listed frameworks below).


## How it works
Memories consist of a short title, a text and some images. All data is fetched from a Firebase database, extracted and displayed by the app.
The Main View of the App is the MemoryVC showing the images on top and the text on the bottom of the screen. The text is embedded in an UITextView. Scrolling down will cause the images to fade out making more space for the text. (see Screenshots)

Tapping the three hearts-button on the left presents a Table View with all memories. Selecting a memory shows it in the MemoryVC.


## Used Frameworks & Libraries
Developing the app I used some Cocoapods frameworks and the Firebase Database for hosting and providing the data.

Despite the awesome [Firebase](https://firebase.google.com) tools it uses the following pods from cocoapods:
- [ImageSlideshow](https://github.com/zvonicek/ImageSlideshow) for the images
- [PopupDialog](https://github.com/orderella/PopupDialog) to display special notifications

## Screenshots
