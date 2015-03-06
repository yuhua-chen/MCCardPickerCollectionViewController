# MCCardPickerCollectionViewController

A card collection view controller inspired by Facebook People you may know.

Take a while for screenshot :p   
![screen-shot](https://raw.githubusercontent.com/yuhua-chen/MCCardPickerCollectionViewController/master/demo.gif)

# Compatibility

Required on iOS 7.

# Usage

Simply drag and drop the classes under `/src` folder and use it like normal collection view controller.

To initialize the `MCCardPickerCollectionViewController`

```objc
MCCardPickerCollectionViewController *cardViewController = [[MCCardPickerCollectionViewController alloc] init];
	cardViewController.delegate = self;
	//Don't forget to register cell like usual collection view.
	[cardViewController.collectionView registerClass:[MCSampleCardCollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
```

and implement the delegate:

```objc
- (void)cardPickerCollectionViewController:(MCCardPickerCollectionViewController *)cardPickerCollectionViewController preparePresentingView:(UIView *)presentingView fromSelectedCell:(UICollectionViewCell *)cell
{
    //Do whatever you want to prepare for the presenting view.
}

// and collection view delegate and data source
```

To present view controler, we use our own method to present instead of `presentViewController:animated:completion:` in order to keep the transparent background. 

```objc
- (void)presentInViewController:(UIViewController *)viewController;
```

To dismiss view controller, likewise we use our own method:

```objc
- (void)dismissFromParentViewController;
```

Moreover there are some properties of `MCCardPickerCollectionViewFlowLayout` you can adjust. If you want to change the padding of cards, you can just set `minimumLineSpacing`:

```objc
cardViewController.layout.minimumLineSpacing = 40;
```

and the bouncing velocity of centering card by setting `flickVelocity`:

```objc
cardViewController.layout.flickVelocity = 0.5;
```

The current index means the card number user picked:

```objc
NSInteger currentIndex = cardViewController.layout.currentIndex;
```

License
============================
This project is under MIT License. Please feel free to use.  
Michael Chen [@yuhua_twit](https://twitter.com/yuhua_twit)
