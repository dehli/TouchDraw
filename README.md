# TouchDraw


[![](https://travis-ci.org/dehli/TouchDraw.svg?branch=master)](https://travis-ci.org/dehli/TouchDraw) [![Join the chat at https://gitter.im/dehli/TouchDraw](https://badges.gitter.im/dehli/TouchDraw.svg)](https://gitter.im/dehli/TouchDraw?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

The `TouchDraw` module allows you to use the `TouchDrawView` class. This is a subclass of `UIView` which allows you to draw pictures with your finger.

## Installation

The easiest way to include `TouchDraw` is by using `CocoaPods` and adding the following to your `Podfile`.

```
use_frameworks!
pod 'TouchDraw', '~> 2.1'
```

If you're not using CocoaPods, you can add the `TouchDrawView.swift` file to your project.

## Usage

You can either programmatically add the `TouchDrawView` or add it using storyboards.

#### Storyboards

If using storyboards, you must add a `UIView` to your storyboard. Give it the `TouchDrawView` class, and `TouchDraw` module.

![Storyboard class](https://cloud.githubusercontent.com/assets/5856011/14061970/1da011c8-f365-11e5-8362-4bbe956b6152.png)

#### Code

If programmatically adding the view, you can use the `init(frame: CGRect)` method to create a new instance of `TouchDrawView`. You must make sure to write `import TouchDraw` at the top of the class.

#### Customizing

When customizing the `TouchDrawView` you can setting its `delegate`. The container can conform to parts of `TouchDrawViewDelegate`, which has the following functions:

```
func undoEnabled() {
    // triggered when undo is enabled
    // (only if it was previously disabled)
}
```

```
func undoDisabled() {
    // triggered when undo is disabled
    // (only if it previously enabled)
}
```

```
func redoEnabled() {
    // triggered when redo is enabled
    // (only if it was previously disabled)
}
```

```
func redoDisabled() {
    // triggered when redo is disabled
    // (only if it previously enabled)
}
```

```
func clearEnabled() {
    // triggered when clear is enabled
    // (only if it was previously disabled)
}
```

```
func clearDisabled() {
    // triggered when clear is disabled
    // (only if it previously enabled)
}
```

The `TouchDrawView` exposes the following methods:

- `exportDrawing() -> UIImage`
  - Exports a UIImage version of the drawing.
- `clearDrawing()`
  - Clears the TouchDrawView.
- `undo()`
  - Undo the last stroke.
- `redo()`
  - Redo what was undone.
- `setColor(color: UIColor?)`
  - Sets the color of future strokes, if you pass `nil` you will be erasing.
- `setWidth(width: CGFloat)`
  - Sets the width of future strokes.
- `importStack(stack: [Stroke])`
  - Set the `TouchDrawView` to have certain strokes (usually will be used in conjunction with `exportStack()`.
- `exportStack() -> [Stroke]`
  - Exports the strokes from a `TouchDrawView` so they can be imported later.

## Demo

If you'd like to see this library in action, you can download the entire repository and open [Demo/TouchDrawDemo.xcworkspace](Demo/TouchDrawDemo.xcworkspace).

[Demo/TouchDrawDemo/ViewController.swift](Demo/TouchDrawDemo/ViewController.swift) is where most of its functionality is demonstrated.

![Demo Screenshot](https://user-images.githubusercontent.com/5856011/27687865-877fc650-5ca6-11e7-9621-48e2051ff25f.png)

## License

This package has the MIT license, which can be found here: [LICENSE](/LICENSE).

## Code of Conduct

Please make sure to follow the [Code of Conduct](/CODE_OF_CONDUCT.md) when you interact with this project. Thanks!
