#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.whitetailani.Cerulean";

/// The "AccentColor" asset catalog color resource.
static NSString * const ACColorNameAccentColor AC_SWIFT_PRIVATE = @"AccentColor";

/// The "amtrak" asset catalog image resource.
static NSString * const ACImageNameAmtrak AC_SWIFT_PRIVATE = @"amtrak";

/// The "bnsf" asset catalog image resource.
static NSString * const ACImageNameBnsf AC_SWIFT_PRIVATE = @"bnsf";

/// The "cerulean" asset catalog image resource.
static NSString * const ACImageNameCerulean AC_SWIFT_PRIVATE = @"cerulean";

/// The "cta" asset catalog image resource.
static NSString * const ACImageNameCta AC_SWIFT_PRIVATE = @"cta";

/// The "ctaTrain" asset catalog image resource.
static NSString * const ACImageNameCtaTrain AC_SWIFT_PRIVATE = @"ctaTrain";

/// The "dataPortal" asset catalog image resource.
static NSString * const ACImageNameDataPortal AC_SWIFT_PRIVATE = @"dataPortal";

/// The "metra" asset catalog image resource.
static NSString * const ACImageNameMetra AC_SWIFT_PRIVATE = @"metra";

/// The "skokieSwift" asset catalog image resource.
static NSString * const ACImageNameSkokieSwift AC_SWIFT_PRIVATE = @"skokieSwift";

/// The "ssl" asset catalog image resource.
static NSString * const ACImageNameSsl AC_SWIFT_PRIVATE = @"ssl";

/// The "ssl2" asset catalog image resource.
static NSString * const ACImageNameSsl2 AC_SWIFT_PRIVATE = @"ssl2";

/// The "trainTracker" asset catalog image resource.
static NSString * const ACImageNameTrainTracker AC_SWIFT_PRIVATE = @"trainTracker";

#undef AC_SWIFT_PRIVATE
