import Foundation
import GoogleMobileAds
import google_mobile_ads

/// iOS counterpart to the Android `HomeBottomNativeAdFactory`.
///
/// Builds the native ad view programmatically (no .xib needed) so the
/// file only needs to be added to the Runner target in Xcode — no asset
/// catalog or Interface Builder step.
class HomeBottomNativeAdFactory: NSObject, FLTNativeAdFactory {

    func createNativeAd(
        _ nativeAd: GADNativeAd,
        customOptions: [AnyHashable : Any]? = nil
    ) -> GADNativeAdView? {
        let adView = GADNativeAdView()
        adView.translatesAutoresizingMaskIntoConstraints = false

        // Root vertical stack
        let root = UIStackView()
        root.axis = .vertical
        root.spacing = 8
        root.alignment = .fill
        root.distribution = .fill
        root.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: adView.topAnchor),
            root.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            root.bottomAnchor.constraint(equalTo: adView.bottomAnchor),
        ])

        // --- Ad Info row: Icon + (Headline / Body / Stars) ---
        let infoRow = UIStackView()
        infoRow.axis = .horizontal
        infoRow.spacing = 8
        infoRow.alignment = .center

        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 48),
            iconView.heightAnchor.constraint(equalToConstant: 48),
        ])

        let textColumn = UIStackView()
        textColumn.axis = .vertical
        textColumn.spacing = 2
        textColumn.alignment = .leading

        let headlineLabel = UILabel()
        headlineLabel.font = UIFont.boldSystemFont(ofSize: 14)
        headlineLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        headlineLabel.numberOfLines = 1

        let bodyLabel = UILabel()
        bodyLabel.font = UIFont.systemFont(ofSize: 12)
        bodyLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        bodyLabel.numberOfLines = 1

        let starsView = UIImageView()
        starsView.contentMode = .scaleAspectFit
        starsView.translatesAutoresizingMaskIntoConstraints = false
        starsView.heightAnchor.constraint(equalToConstant: 14).isActive = true

        textColumn.addArrangedSubview(headlineLabel)
        textColumn.addArrangedSubview(bodyLabel)
        textColumn.addArrangedSubview(starsView)

        infoRow.addArrangedSubview(iconView)
        infoRow.addArrangedSubview(textColumn)
        root.addArrangedSubview(infoRow)

        // --- Ad Media (fills remaining space; Flutter side reserves 16:9) ---
        let mediaView = GADMediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        mediaView.setContentHuggingPriority(.defaultLow, for: .vertical)
        mediaView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        root.addArrangedSubview(mediaView)

        // --- CTA Button ---
        let ctaButton = UIButton(type: .system)
        ctaButton.backgroundColor = UIColor(
            red: 0xDF / 255.0,
            green: 0xFF / 255.0,
            blue: 0x4F / 255.0,
            alpha: 1.0
        )
        ctaButton.setTitleColor(.black, for: .normal)
        ctaButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        ctaButton.isUserInteractionEnabled = false // NativeAdView handles taps
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        root.addArrangedSubview(ctaButton)

        // --- Ad Badge (absolute, top-left overlay) ---
        let badgeLabel = PaddedLabel()
        badgeLabel.text = "Ad"
        badgeLabel.textColor = .black
        badgeLabel.font = UIFont.boldSystemFont(ofSize: 9)
        badgeLabel.backgroundColor = UIColor(
            red: 0xFD / 255.0,
            green: 0xC7 / 255.0,
            blue: 0x00 / 255.0,
            alpha: 1.0
        )
        badgeLabel.textInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(badgeLabel)
        NSLayoutConstraint.activate([
            badgeLabel.topAnchor.constraint(equalTo: adView.topAnchor),
            badgeLabel.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            badgeLabel.heightAnchor.constraint(equalToConstant: 14),
        ])

        // Bind asset views
        adView.iconView = iconView
        adView.headlineView = headlineLabel
        adView.bodyView = bodyLabel
        adView.starRatingView = starsView
        adView.mediaView = mediaView
        adView.callToActionView = ctaButton

        // Populate
        (adView.headlineView as? UILabel)?.text = nativeAd.headline
        (adView.bodyView as? UILabel)?.text = nativeAd.body
        (adView.bodyView as? UILabel)?.isHidden = (nativeAd.body == nil)

        if let image = nativeAd.icon?.image {
            (adView.iconView as? UIImageView)?.image = image
            adView.iconView?.isHidden = false
        } else {
            adView.iconView?.isHidden = true
        }

        if let rating = nativeAd.starRating {
            (adView.starRatingView as? UIImageView)?.image = imageForStars(rating.doubleValue)
            adView.starRatingView?.isHidden = false
        } else {
            adView.starRatingView?.isHidden = true
        }

        if let cta = nativeAd.callToAction {
            (adView.callToActionView as? UIButton)?.setTitle(cta, for: .normal)
            adView.callToActionView?.isHidden = false
        } else {
            adView.callToActionView?.isHidden = true
        }

        adView.nativeAd = nativeAd
        return adView
    }

    private func imageForStars(_ rating: Double) -> UIImage? {
        // Simple text-based star image since there's no native star widget on iOS.
        let full = Int(rating.rounded())
        let text = String(repeating: "★", count: full) + String(repeating: "☆", count: max(0, 5 - full))
        let label = UILabel()
        label.text = text
        label.textColor = UIColor(red: 1.0, green: 0.78, blue: 0.0, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 12)
        label.sizeToFit()
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        label.layer.render(in: ctx)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

/// UILabel that supports content insets (used for the badge).
private class PaddedLabel: UILabel {
    var textInsets: UIEdgeInsets = .zero

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }
}
