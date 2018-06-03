# iOS Image Refiner
Use this utility in your applications so your users can crop a given images or use it so that you can control the size and quality of images that are selected in your application.

 - Pinch, zoom, and pan selected image into crop area.
 - Set the crop area width and height dimensions.
 - Set the quality of image 1x, 2x, 3x (to support retina).
 - Optional creation of thumbnail image.

![enter image description here](https://github.com/asnow003/iOSImageRefiner/docs/ImageEdit1.png)

![enter image description here](https://github.com/asnow003/iOSImageRefiner/docs/ImageEdit2.png)
## Installation

### Cocopods
Add reference of the pod to your [Podfile](https://cocoapods.org/pods/iOSImageRefiner):
```
target 'MyApp' do
  pod 'iOSImageRefiner'
end
```
Run the pod installation:
```
$ pod install
```
Open your project iOS project workspace (.xcworkspace)

### Manually
You can manually add the files to your Xcode project by copying the following items from this repo.

Copy all the items in the Image Edit folder in the repo into your project.  The following files should be included:

 - ImageEdit.xcassets
 - ImageEdit.storyboard
 - ImageEdit.swift

## Samples

### Cocoapods Usage
When including the cocoapods in your project use the following code snippets.

Add the following to your calling ViewController:
```
import iOSImageRefiner
```
Add the delegate reference:
```
class ViewController: UIViewController,ImageEditDelegate {}
```
Display the image editor ViewController:
```
let bundle = Bundle(for: ImageEdit.self)
let storyboard = UIStoryboard(name: "ImageEdit", bundle: bundle)

if let _imageEdit = storyboard.instantiateViewController(withIdentifier: "ImageEdit") as? ImageEdit {
	_imageEdit.image = imageToEdit
	_imageEdit.imageCropWidth = 240
	_imageEdit.imageCropHeight = 240
	_imageEdit.delegate = self
	self.present(_imageEdit, animated: true, completion: nil)
}
```

Add the delegates:
```
public func imageEdited(image: UIImage, thumbnail: UIImage?, scaleFactor: Int) {}
```
### Copy Usage
When copying from this repo and placing in your own project.

Add the delegate reference:
```
class ViewController: UIViewController,ImageEditDelegate {}
```

Display the image editor ViewController:
```
let storyboard = UIStoryboard(name: "ImageEdit", bundle: nil)

if let _imageEdit = storyboard.instantiateViewController(withIdentifier: "ImageEdit") as? ImageEdit {
	_imageEdit.image = imageToEdit
	_imageEdit.imageCropWidth = 240
	_imageEdit.imageCropHeight = 240
	_imageEdit.delegate = self
	self.present(_imageEdit, animated: true, completion: nil)
}
```
Add the delegates:
```
public func imageEdited(image: UIImage, thumbnail: UIImage?, scaleFactor: Int) {}
```
