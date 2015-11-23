# TouchDraw

The `TouchDraw` module allows you to use the `TouchDrawView` class. This is a subclass of `UIView` which allows you to draw pictures with your finger.

The easiest way to include `TouchDraw` is by using `CocoaPods`.

```
use_frameworks!
pod 'TouchDraw', '~> 1.0'
```

To use `TouchDrawView` you must first write `import TouchDraw` in whichever classes will use `TouchDrawView`. `TouchDrawView` exposes the following functions:

- `exportDrawing() -> UIImage`
- `clearDrawing()`
- `setColor(color: UIColor)`
- `setWidth(width: CGFloat)`

You must make whichever view contains `TouchDrawView` conform to `TouchDrawViewDelegate` protocol. This includes the following functions:

- `undoEnabled()`
- `undoDisabled()`
- `redoEnabled()`
- `redoDisabled()`

These functions are triggered whenever the undo/redo functionality becomes enabled.

**TODO:**
- Make undo/redo work with various colors or widths (right now it uses the most recent values for all the strokes).
