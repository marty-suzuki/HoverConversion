Part of [Fabric](https://www.fabric.io/), Twitter Kit is easiest way to bring real-time conversational content to your apps. Growing an app’s user base and retaining end users can be a challenge for any developer. To keep users engaged, you need rich, unique content that feels natural to your app’s experience.

To install, follow the instructions [here](https://fabric.io/kits/ios/twitterkit/install).

### Show a Single Tweet

To show a single Tweet, you first need to load that Tweet from the network and then create and configure a `TWTRTweetView` with that `TWTRTweet` model object. Then it may be added to the view hierarchy:

```swift
    import TwitterKit

    TWTRAPIClient().loadTweetWithID("20") { tweet, error in
      if let t = tweet {
        let tweetView = TWTRTweetView(tweet: t)
        tweetView.center = view.center
        view.addSubview(tweetView)
      } else {
        print("Failed to load Tweet: \(error)")
      }
    }
```

<img src="https://docs.fabric.io/apple/_images/show_tweet_compact.png" width="250"/>


#### Configuring Tweet View Colors & Themes
To change the colors of a Tweet view you can either set properties directly on the `TWTRTweetView` instances or on the `UIAppearanceProxy` of the `TWTRTweetView`.

```swift
  // Set the theme directly
  tweetView.theme = .Dark

  // Use custom colors
  tweetView.primaryTextColor = .yellowColor()
  tweetView.backgroundColor = .blueColor()
```

<img src="https://docs.fabric.io/apple/_images/show_tweet_themed.png" width="250"/>



Set visual properties using the `UIAppearanceProxy` for `TWTRTweetView`.

```
  // Set all future tweet views to use dark theme using UIAppearanceProxy
  TWTRTweetView.appearance().theme = .Dark
```

### Show a TableView of Tweets

```swift
import TwitterKit

class UserTimelineViewController: TWTRTimelineViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let client = TWTRAPIClient.clientWithCurrentUser()
        self.dataSource = TWTRUserTimelineDataSource(screenName: "jack", APIClient: client)
        self.showTweetActions = true
    }

}
```

<img src="https://docs.fabric.io/apple/_images/list_timeline.png" width="250"/>


## Resources		
		
 * [Documentation](https://docs.fabric.io/apple/twitter/overview.html)		
 * [Forums](https://twittercommunity.com/c/fabric/twitter)		
 * [Website](https://docs.fabric.io/apple/twitter/overview.html)		
 * Follow us on Twitter: [@fabric](https://twitter.com/fabric)		
 * Follow us on Periscope: [Fabric](https://periscope.tv/fabric) and [TwitterDev](https://periscope.tv/twitterdev)
