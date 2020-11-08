// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let accentColor = ColorAsset(name: "AccentColor")
  internal enum Colors {
    internal static let black1 = ColorAsset(name: "black-1")
    internal static let black2 = ColorAsset(name: "black-2")
    internal static let black3 = ColorAsset(name: "black-3")
    internal static let black4 = ColorAsset(name: "black-4")
    internal static let black5 = ColorAsset(name: "black-5")
    internal static let black6 = ColorAsset(name: "black-6")
    internal static let black7 = ColorAsset(name: "black-7")
    internal static let black8 = ColorAsset(name: "black-8")
    internal static let black9 = ColorAsset(name: "black-9")
    internal static let black = ColorAsset(name: "black")
    internal static let purple1 = ColorAsset(name: "purple-1")
    internal static let purple2 = ColorAsset(name: "purple-2")
    internal static let purple3 = ColorAsset(name: "purple-3")
    internal static let purple4 = ColorAsset(name: "purple-4")
    internal static let purple5 = ColorAsset(name: "purple-5")
    internal static let purple6 = ColorAsset(name: "purple-6")
    internal static let purple7 = ColorAsset(name: "purple-7")
    internal static let purple8 = ColorAsset(name: "purple-8")
    internal static let purple9 = ColorAsset(name: "purple-9")
    internal static let purple = ColorAsset(name: "purple")
    internal static let white = ColorAsset(name: "white")
  }
  internal enum Icons {
    internal static let arrowBack = ImageAsset(name: "arrow_back")
    internal static let arrowForward = ImageAsset(name: "arrow_forward")
    internal static let download = ImageAsset(name: "download")
    internal static let downloadFill = ImageAsset(name: "download_fill")
    internal static let gallery = ImageAsset(name: "gallery")
    internal static let logout = ImageAsset(name: "logout")
    internal static let play = ImageAsset(name: "play")
    internal static let search = ImageAsset(name: "search")
    internal static let video = ImageAsset(name: "video")
  }
  internal enum Images {
    internal static let imagePlaceholder = ImageAsset(name: "imagePlaceholder")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

internal extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
