# 2.0.0

- Upgraded project to Swift 3.0.1 (thanks to @sirnacnud!)
- Set correct content scale on image contexts (also thanks to @sirnacnud!)
- Added some comments

# 1.3.1

- Refactored project into 3 separate files (for each class)
- Fixed `exportStack` so it follows `NSCoding`
- Added deployment target `8.0`

# 1.3.0

- Added the ability to import and export the stack.
- Made the protocol methods optional.
- Made the code more Swifty.

# 1.2.4

- Added a few more tests
- Updated `README.md`

# 1.2.3

- Added a handful of tests
- Updated `README.md`

# 1.2.2

- Switched project settings to recommended settings
- Added documentation

# 1.2.1

- Fixed a bug where pressing clear wouldn't trigger `redoDisabled()`
- Updated deprecated code
- Added documentation

# 1.2.0

- Fixed `redo()` and `undo()` so they work with various brush sizes and colors
- Implemented `clearEnabled()` to the protocol
- Implemented `clearDisabled()` to the protocol
- Fixed a bug where `TouchDrawView` only worked when it took up the entire `ViewController`'s screen

# 1.1.0

- Implemented `undo()` (using last selected brush settings)
- Implemented `redo()` (using last selected brush settings)
- Implemented `redoEnabled()` and `redoDisabled()` protocol methods
- Implemented `undoEnabled()` and `undoDisabled()` protocol methods

# 1.0.0

- Initial release
- Implemented `TouchDrawView` which is a subclass of `UIView` that you can draw on
- Implemented `clear()`
- Implemented `exportDrawing()`
- Implemented `setColor(color: UIColor)`
- Implemented `setWidth(width: CGFloat)`
