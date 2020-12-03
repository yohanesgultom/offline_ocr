# offline_ocr

![icon](assets/images/icon.png)

Simple offline OCR **Android** app build on top the awesome [Tesseract OCR](https://tesseract-ocr.github.io/)

Features:
* Detect text from camera capture
* Detect text from image picker/browser
* Detect text from shared image (intent)

## Build

Make sure to use `--no-shrink` option when building apks as currently it causes the app crashes (not sure why)

## References

* Extracts text using Tesseract OCR https://pub.dev/packages/tesseract_ocr/example
* Receives sharing intent https://pub.dev/packages/receive_sharing_intent

## Demo

![demo](offline_ocr_demo.gif)