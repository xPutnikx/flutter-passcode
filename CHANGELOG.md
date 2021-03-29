## [0.0.1] - TODO: Add release date.

## [1.0.0+1] - 22 Jan 2019 
Basic implementation of a widget.
- You could show a widget, enter passcode and validate it.

## [1.0.1] - 12 May 2019
- Added `isValidCallback` to help you handle success scenario. `isValidCallback` will be invoked after passcode screen will pop.

## [1.0.2] - 28 June 2019
- Added configurable background and title color.
- Added `cancelCallback` to react when user cancelled widget

## [1.1.0] - 11 May 2020
- Provide widget instead of string for title
- Fixed digits layout
- Added flexibility to configure 'Cancel' and 'Delete' buttons as widgets
- Added flexibility to provide digits as list of strings for better customisation
- Removed navigation as default action when cancel pressed

## [1.1.1] - 6 June 2020
- Add landscape view for the passcode screen

## [1.2.0] - 7 June 2020
- Add dynamic size for landscape view.
- Moved 'Cancel' button to the bottom of the screen to align with iOS Native Passcode Screen style.

## [1.2.1] - 25 October 2020
- Example updated to target Android 11
- Fixed [Issue#23](https://github.com/xPutnikx/flutter-passcode/issues/23)

## [1.2.2] - 25 October 2020
- Fixed an issue with example build
- Example updated to show how to implement 'Reset passcode' feature

## [1.2.2+1] - 28 October 2020
- Fix antialiasing issue for keyboard https://github.com/xPutnikx/flutter-passcode/issues/26

## [2.0.0] - 29 March 2021
- Null safety