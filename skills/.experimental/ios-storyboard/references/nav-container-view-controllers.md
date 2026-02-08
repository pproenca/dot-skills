---
title: Use Container Views for Embedded Child View Controllers
impact: MEDIUM
impactDescription: reduces view controller bloat by 40-60%
tags: nav, container-view, embed, child-vc, composition
---

## Use Container Views for Embedded Child View Controllers

A single view controller that manages a complex screen with multiple independent sections (e.g., a header, a map, and a feed) accumulates hundreds of lines of unrelated logic. Dragging Container Views from the Object Library in Interface Builder creates embed segues that instantiate child view controllers automatically, splitting responsibilities along clear boundaries.

**Incorrect (one massive view controller managing all sections):**

```swift
// PropertyDetailViewController.swift — 600+ lines managing everything
class PropertyDetailViewController: UIViewController,
    MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var amenitiesStackView: UIStackView!
    @IBOutlet weak var agentNameLabel: UILabel!
    @IBOutlet weak var agentPhoneLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHeader()
        configureMap()
        configurePhotosCarousel()
        configureDescription()
        configureAmenities()
        configureAgentContact()
    }

    // ... 400+ more lines of mixed concerns
}
```

**Correct (split into child view controllers via container views in IB):**

```swift
// PropertyDetailViewController.swift — orchestrator only
class PropertyDetailViewController: UIViewController {
    var property: Property!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "EmbedMap":
            let mapVC = segue.destination as! PropertyMapViewController
            mapVC.coordinate = property.coordinate
        case "EmbedPhotos":
            let photosVC = segue.destination as! PropertyPhotosViewController
            photosVC.photoURLs = property.photoURLs
        case "EmbedAgentContact":
            let agentVC = segue.destination as! AgentContactViewController
            agentVC.agent = property.agent
        default:
            break
        }
    }
}
```

```xml
<!-- PropertyDetail.storyboard — container views create embed segues automatically -->
<scene sceneID="propertyDetail">
    <viewController id="PropertyDetailVC" sceneMemberID="viewController">
        <view key="view">
            <subviews>
                <containerView id="mapContainer" translatesAutoresizingMaskIntoConstraints="NO">
                    <connections>
                        <segue destination="PropertyMapVC" kind="embed"
                               identifier="EmbedMap" id="seg-embed-map"/>
                    </connections>
                </containerView>
                <containerView id="photosContainer" translatesAutoresizingMaskIntoConstraints="NO">
                    <connections>
                        <segue destination="PropertyPhotosVC" kind="embed"
                               identifier="EmbedPhotos" id="seg-embed-photos"/>
                    </connections>
                </containerView>
                <containerView id="agentContainer" translatesAutoresizingMaskIntoConstraints="NO">
                    <connections>
                        <segue destination="AgentContactVC" kind="embed"
                               identifier="EmbedAgentContact" id="seg-embed-agent"/>
                    </connections>
                </containerView>
            </subviews>
        </view>
    </viewController>
</scene>
```

**Benefits:**
- Each child view controller is independently testable and reusable across screens
- The parent controller shrinks to a thin orchestrator that passes data via embed segues
- Adding or removing a section is a single drag operation in Interface Builder
