---
title: Extract Reusable Views into Separate XIB Files
impact: MEDIUM
impactDescription: eliminates view duplication across storyboards
tags: arch, xib, reusable-views, IBDesignable
---

## Extract Reusable Views into Separate XIB Files

When the same custom view (a rating bar, a user avatar card, a branded input field) is copy-pasted into multiple storyboard scenes, every design change must be applied N times. Extracting the view into a standalone XIB with an `@IBDesignable` wrapper creates a single source of truth that renders live in every storyboard that uses it.

**Incorrect (same view layout duplicated in every storyboard scene):**

```xml
<!-- Checkout.storyboard — PaymentSummaryView layout inlined -->
<scene sceneID="checkout-confirm">
    <objects>
        <viewController id="OrderConfirmVC" sceneMemberID="viewController">
            <view key="view">
                <subviews>
                    <!-- Payment summary card — duplicated from Profile.storyboard -->
                    <view contentMode="scaleToFill" userLabel="PaymentSummaryView">
                        <subviews>
                            <label text="Total" />
                            <label text="$0.00" />
                            <imageView image="credit-card-icon" />
                            <label text="**** 4242" />
                        </subviews>
                        <color key="backgroundColor" red="0.96" green="0.96"
                               blue="0.97" alpha="1"/>
                    </view>
                </subviews>
            </view>
        </viewController>
    </objects>
</scene>
```

```xml
<!-- Profile.storyboard — identical PaymentSummaryView layout copied here -->
<scene sceneID="profile-billing">
    <objects>
        <viewController id="BillingInfoVC" sceneMemberID="viewController">
            <view key="view">
                <subviews>
                    <!-- Same layout, same constraints — must update both -->
                    <view contentMode="scaleToFill" userLabel="PaymentSummaryView">
                        <subviews>
                            <label text="Total" />
                            <label text="$0.00" />
                            <imageView image="credit-card-icon" />
                            <label text="**** 4242" />
                        </subviews>
                        <color key="backgroundColor" red="0.96" green="0.96"
                               blue="0.97" alpha="1"/>
                    </view>
                </subviews>
            </view>
        </viewController>
    </objects>
</scene>
```

**Correct (single XIB loaded via @IBDesignable):**

```swift
@IBDesignable
final class PaymentSummaryView: UIView {
    @IBOutlet private weak var totalLabel: UILabel!
    @IBOutlet private weak var cardNumberLabel: UILabel!
    @IBOutlet private weak var cardIconImageView: UIImageView!

    @IBInspectable var totalAmount: String = "$0.00" {
        didSet { totalLabel?.text = totalAmount }
    }

    @IBInspectable var maskedCardNumber: String = "**** 0000" {
        didSet { cardNumberLabel?.text = maskedCardNumber }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }

    private func loadNib() {
        let nib = UINib(nibName: "PaymentSummaryView", bundle: .init(for: Self.self))
        guard let contentView = nib.instantiate(withOwner: self).first as? UIView else {
            return
        }
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }
}
```

```xml
<!-- Any storyboard — just drop in the custom class, renders live in IB -->
<scene sceneID="checkout-confirm">
    <objects>
        <viewController id="OrderConfirmVC" sceneMemberID="viewController">
            <view key="view">
                <subviews>
                    <view customClass="PaymentSummaryView"
                          customModule="ShopApp"
                          customModuleProvider="target"
                          contentMode="scaleToFill"
                          userLabel="Payment Summary">
                        <userDefinedRuntimeAttributes>
                            <userDefinedRuntimeAttribute type="string"
                                keyPath="totalAmount" value="$129.99"/>
                            <userDefinedRuntimeAttribute type="string"
                                keyPath="maskedCardNumber" value="**** 4242"/>
                        </userDefinedRuntimeAttributes>
                    </view>
                </subviews>
            </view>
        </viewController>
    </objects>
</scene>
```

**When NOT to use:**
- One-off views that appear in a single scene do not need XIB extraction. The overhead of a separate file and `@IBDesignable` class only pays off when the view appears in 2+ locations.

**Benefits:**
- Design changes propagate instantly to every storyboard scene
- XIB files are small and rarely cause merge conflicts
- `@IBDesignable` renders the view live in Interface Builder, so designers see real output
