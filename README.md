# Paint

An iOS painting framework base on CoreGraphics (UIBezierPath).

## Demo Screen Shot

<img src="https://github.com/kukushi/Paint/blob/master/ScreenShoot/Screen%20shot%201.png?raw=true" alt="Drawing" style="width: 300px; height: 568px;"/>

## Install

1. Simply drag the `KKSPainting` folder into your project. 
2. Add a `KKSPaintingScrollView` subview  of the mainview.

> Note: If you want to run the demo project, you should install the pod first ( by `pod install`).

## Features

### Basic Drawings

You can draw the following items:

* Smooth Signatures
* Line
* Segments
* Bezier
* Polygon
* Rectangle
* Ellipse

Redo, undo, clear  action also supported.

### Editing Support

You can do the following editing actions to paintings:

* Move
* Rotate & Zoom
* Remove
* Copy & Paste
* Fill (Closed Painting only)

### Save & Restore

You can save the `KKSPaintingModel` to persistent all the data and reload it using `- (void)reloadManagerWithModel:(KKSPaintingModel *)paintingModel;` of `KKSPaintingManager`. All the paintings can be edited.

## License

This project is is available under the MIT license. See the LICENSE file for more info. Attribution by linking to the [project page](https://github.com/kukushi/Paint) is appreciated.
