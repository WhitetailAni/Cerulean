import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
extension ColorResource {

    /// The "AccentColor" asset catalog color resource.
    static let accent = ColorResource(name: "AccentColor", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
extension ImageResource {

    /// The "amtrak" asset catalog image resource.
    static let amtrak = ImageResource(name: "amtrak", bundle: resourceBundle)

    /// The "bnsf" asset catalog image resource.
    static let bnsf = ImageResource(name: "bnsf", bundle: resourceBundle)

    /// The "cerulean" asset catalog image resource.
    static let cerulean = ImageResource(name: "cerulean", bundle: resourceBundle)

    /// The "cta" asset catalog image resource.
    static let cta = ImageResource(name: "cta", bundle: resourceBundle)

    /// The "ctaTrain" asset catalog image resource.
    static let ctaTrain = ImageResource(name: "ctaTrain", bundle: resourceBundle)

    /// The "dataPortal" asset catalog image resource.
    static let dataPortal = ImageResource(name: "dataPortal", bundle: resourceBundle)

    /// The "metra" asset catalog image resource.
    static let metra = ImageResource(name: "metra", bundle: resourceBundle)

    /// The "skokieSwift" asset catalog image resource.
    static let skokieSwift = ImageResource(name: "skokieSwift", bundle: resourceBundle)

    /// The "ssl" asset catalog image resource.
    static let ssl = ImageResource(name: "ssl", bundle: resourceBundle)

    /// The "ssl2" asset catalog image resource.
    static let ssl2 = ImageResource(name: "ssl2", bundle: resourceBundle)

    /// The "trainTracker" asset catalog image resource.
    static let trainTracker = ImageResource(name: "trainTracker", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "AccentColor" asset catalog color.
    static var accent: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .accent)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "AccentColor" asset catalog color.
    static var accent: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .accent)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    /// The "AccentColor" asset catalog color.
    static var accent: SwiftUI.Color { .init(.accent) }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "AccentColor" asset catalog color.
    static var accent: SwiftUI.Color { .init(.accent) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "amtrak" asset catalog image.
    static var amtrak: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .amtrak)
#else
        .init()
#endif
    }

    /// The "bnsf" asset catalog image.
    static var bnsf: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bnsf)
#else
        .init()
#endif
    }

    /// The "cerulean" asset catalog image.
    static var cerulean: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cerulean)
#else
        .init()
#endif
    }

    /// The "cta" asset catalog image.
    static var cta: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .cta)
#else
        .init()
#endif
    }

    /// The "ctaTrain" asset catalog image.
    static var ctaTrain: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ctaTrain)
#else
        .init()
#endif
    }

    /// The "dataPortal" asset catalog image.
    static var dataPortal: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dataPortal)
#else
        .init()
#endif
    }

    /// The "metra" asset catalog image.
    static var metra: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .metra)
#else
        .init()
#endif
    }

    /// The "skokieSwift" asset catalog image.
    static var skokieSwift: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .skokieSwift)
#else
        .init()
#endif
    }

    /// The "ssl" asset catalog image.
    static var ssl: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ssl)
#else
        .init()
#endif
    }

    /// The "ssl2" asset catalog image.
    static var ssl2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ssl2)
#else
        .init()
#endif
    }

    /// The "trainTracker" asset catalog image.
    static var trainTracker: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .trainTracker)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "amtrak" asset catalog image.
    static var amtrak: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .amtrak)
#else
        .init()
#endif
    }

    /// The "bnsf" asset catalog image.
    static var bnsf: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .bnsf)
#else
        .init()
#endif
    }

    /// The "cerulean" asset catalog image.
    static var cerulean: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .cerulean)
#else
        .init()
#endif
    }

    /// The "cta" asset catalog image.
    static var cta: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .cta)
#else
        .init()
#endif
    }

    /// The "ctaTrain" asset catalog image.
    static var ctaTrain: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ctaTrain)
#else
        .init()
#endif
    }

    /// The "dataPortal" asset catalog image.
    static var dataPortal: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dataPortal)
#else
        .init()
#endif
    }

    /// The "metra" asset catalog image.
    static var metra: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .metra)
#else
        .init()
#endif
    }

    /// The "skokieSwift" asset catalog image.
    static var skokieSwift: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .skokieSwift)
#else
        .init()
#endif
    }

    /// The "ssl" asset catalog image.
    static var ssl: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ssl)
#else
        .init()
#endif
    }

    /// The "ssl2" asset catalog image.
    static var ssl2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ssl2)
#else
        .init()
#endif
    }

    /// The "trainTracker" asset catalog image.
    static var trainTracker: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .trainTracker)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)
@available(watchOS, unavailable)
extension ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 11.0, macOS 10.7, tvOS 11.0, *)
@available(watchOS, unavailable)
extension ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

// MARK: - Backwards Deployment Support -

/// A color resource.
struct ColorResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog color resource name.
    fileprivate let name: Swift.String

    /// An asset catalog color resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize a `ColorResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

/// An image resource.
struct ImageResource: Swift.Hashable, Swift.Sendable {

    /// An asset catalog image resource name.
    fileprivate let name: Swift.String

    /// An asset catalog image resource bundle.
    fileprivate let bundle: Foundation.Bundle

    /// Initialize an `ImageResource` with `name` and `bundle`.
    init(name: Swift.String, bundle: Foundation.Bundle) {
        self.name = name
        self.bundle = bundle
    }

}

#if canImport(AppKit)
@available(macOS 10.13, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// Initialize a `NSColor` with a color resource.
    convenience init(resource: ColorResource) {
        self.init(named: NSColor.Name(resource.name), bundle: resource.bundle)!
    }

}

protocol _ACResourceInitProtocol {}
extension AppKit.NSImage: _ACResourceInitProtocol {}

@available(macOS 10.7, *)
@available(macCatalyst, unavailable)
extension _ACResourceInitProtocol {

    /// Initialize a `NSImage` with an image resource.
    init(resource: ImageResource) {
        self = resource.bundle.image(forResource: NSImage.Name(resource.name))! as! Self
    }

}
#endif

#if canImport(UIKit)
@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// Initialize a `UIColor` with a color resource.
    convenience init(resource: ColorResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}

@available(iOS 11.0, tvOS 11.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// Initialize a `UIImage` with an image resource.
    convenience init(resource: ImageResource) {
#if !os(watchOS)
        self.init(named: resource.name, in: resource.bundle, compatibleWith: nil)!
#else
        self.init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Color {

    /// Initialize a `Color` with a color resource.
    init(_ resource: ColorResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension SwiftUI.Image {

    /// Initialize an `Image` with an image resource.
    init(_ resource: ImageResource) {
        self.init(resource.name, bundle: resource.bundle)
    }

}
#endif