# FiveYears

**FiveYears** is a small app targeted for `iOS 10` and later. I developed it to celebrate the fifth anniversary with my girlfriend and as a small gift for her.
It's picturing common memories collected during the time we spent together.

This is the first app I've designed and developed entirely by myself (excluding the listed frameworks below).


## How it works
Memories consist of a short title, a longer text and some images. All data is fetched from a Firebase database, extracted and displayed in the app.
The Main View of the app is the `MemoryVC` showing the images on top and the text on the bottom of the screen. The text is embedded in a UITextView. Scrolling down will cause the images to fade out making more space for the text. *(see screenshots)*

Tapping the three hearts-button on the top-left presents a `MemoryTableVC` with all available memories. Selecting a memory segues back to the `MemoryVC` and displays that memory in full detail.


## Used Frameworks & Libraries
Developing the app I used some [CocoaPods](https://cocoapods.org) frameworks and the Firebase Database for hosting and providing the data.

Despite the awesome [Firebase](https://firebase.google.com) tools the app integrates these Pods:
- [ImageSlideshow](https://github.com/zvonicek/ImageSlideshow) for the images
- [PopupDialog](https://github.com/orderella/PopupDialog) to display special notifications

## Screenshots
![](http://i.imgur.com/oblv4o0.gif)

## Versions and Changes

- `1.0` initial version used a segment control to switch between image and text
- `1.1` redesign using a TableView: images as header, text in one cell
- `1.1.1` added a parallax header effect and a curved calayer for the headerimages
- `1.2` added core data & caching: downloaded memories are now stored in core data, images are stored in cache directory of the phone (automatically re-downloaded when purged)
