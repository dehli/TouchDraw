# TouchDraw

The `TouchDraw` module allows you to use the `TouchDrawView` class. This is a subclass of `UIView` which allows you to draw pictures with your finger.

The easiest way to include `TouchDraw` is by using `CocoaPods`.

```
use_frameworks!
pod 'TouchDraw', '~> 1.2'
```

To use `TouchDrawView` you must first write `import TouchDraw` in whichever classes will use `TouchDrawView`. `TouchDrawView` exposes the following functions:

- `exportDrawing() -> UIImage`
- `clearDrawing()`
- `undo()`
- `redo()`
- `setColor(color: UIColor)`
- `setWidth(width: CGFloat)`

You must make whichever view contains `TouchDrawView` conform to `TouchDrawViewDelegate` protocol. This includes the following functions:

- `undoEnabled()`
- `undoDisabled()`
- `redoEnabled()`
- `redoDisabled()`
- `clearEnabled()`
- `clearDisabled()`

These functions are triggered whenever the various functionalities become enabled or disabled.

## Demo

If you'd like to see this library in action, you can download the entire repository and open [Demo/TouchDrawDemo.xcworkspace](Demo/TouchDrawDemo.xcworkspace).

![Demo Screenshot](https://cloud.githubusercontent.com/assets/5856011/13918081/4b2fae7e-ef3b-11e5-96bd-978b62895aa7.png)
