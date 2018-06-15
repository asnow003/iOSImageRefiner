# iOS Image Refiner
Use this utility in your applications so your users can crop a given images or use it so that you can control the size and quality of images that are selected in your application.

 - Pinch, zoom, and pan selected image into crop area.
 - Set the crop area width and height dimensions.
 - Set the quality of image 1x, 2x, 3x (to support retina).
 - Optional creation of thumbnail image.

Crop                       |  Custom crop
:-------------------------:|:-------------------------:
![](https://github.com/asnow003/iOSImageRefiner/blob/master/docs/ImageEdit1.png?raw=true) | ![](https://github.com/asnow003/iOSImageRefiner/blob/master/docs/ImageEdit2.png?raw=true)

Edit Options               |  Sizes
:-------------------------:|:-------------------------:
![](https://github.com/asnow003/iOSImageRefiner/blob/master/docs/ImageEdit3.png?raw=true) | ![](https://github.com/asnow003/iOSImageRefiner/blob/master/docs/ImageEdit4.png?raw=true)

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

Copy all the items in the Image Edit folder in the repo into your project.  The following files should be included in the sample project above:

Folder ImageRefiner:
 - ImageRefiner.xcassets
 - ImageRefiner.storyboard
 - ImageRefinerViewController.swift
 - ImageRefinerOptions.swift
 - ImageRefinerOptionsViewController.swift

## Samples

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
let storyboard = UIStoryboard(name: ImageRefinerViewController.storyboardName, bundle: nil)
            
if let _imageRefiner = storyboard.instantiateViewController(withIdentifier: ImageRefinerViewController.storyboardName) as? ImageRefinerViewController {
                
	_imageRefiner.options = ImageRefinerOptions(
	    cropWidth: 240,
	    cropHeight: 240)

	_imageRefiner.delegate = self
	_imageRefiner.image = {your UIImage to edit}

	self.present(_imageRefiner, animated: true, completion: nil)
}
```
Add the delegates:
```
public func imageUpdated(image: UIImage, thumbnail: UIImage?, scaleFactor: Int) {}
```
