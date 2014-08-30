# Paint
=====

A iOS painting framework base on CoreGraphics.

## Features 

### Basic Drawings

You can draw the follwing items:

* Smooth Signatures
* Line
* Segments
* Bezier
* Polygon
* Rectangle
* Ellipse

Redo, undo, clear are also supported.

### Editing Support

You can do the following editing actions to paintings:

* Move
* Rotate & Zoom
* Remove
* Copy & Paste
* Fill (Closed Painting only)

### Save & Restore

You can save the `KKSPaintingModel` to persistent all the data and reload it using `- (void)reloadManagerWithModel:(KKSPaintingModel *)paintingModel;` of `KKSPaintingManager`. All the paintings can be edited.


## Demo Screen Shot

<img src="https://github.com/kukushi/Paint/blob/master/ScreenShoot/Screen%20shot%201.png?raw=true" alt="Drawing" style="width: 300px; height: 568px;"/>

## License

This project is is available under the MIT license. See the LICENSE file for more info. Attribution by linking to the [project page](https://github.com/kukushi/Paint) is appreciated.