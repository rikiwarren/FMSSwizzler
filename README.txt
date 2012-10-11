FMSSwizzler is a static library that simplifies some common method- and class-swizzling tasks. Unlike traditional Objective-C method swizzling, this library uses a block-based API for replacing the implementation of existing classes.

Note: I've tried to test and identify most of the obvious gotchas. However, by it's nature class and method swizzling is inherently unsafe. There may be additional edge cases that will cause errors. Please use these methods with care, and test your code thoroughly.

Note: to add the library to a project, first add the library to the target project, then set the project's Other Linker Flags build setting to -ObjC. This will force the compiler to include the NSObject+FMSSwizzler code.

You can either copy NSObject+FMSSwizzler.h and the appropriate libFMSSwizzler_*.a file into the target project, or you can place both projects in a workspace. If the destination project and library share a workspace, make sure to add the following paths to the destination project's build settings.

For iOS: User Header Search Paths: "$OBJROOT/UninstalledProducts/include/"

For OSX: Header Search Paths: "$TARGET_BUILD_DIR/usr/local/include"

Then import the header as "FMSSwizzler/NSObject+FMSSwizzler.h"

The complete documentation can be found in FMSSwizzler/FMSSwizzler.docset. Copy this file into ~/Library/Developer/Shared/Documentation/DocSets/ and restart Xcode to add this docset to Xcode's documentation.

You can also follow me at the following:

Blog: http://www.freelancemadscience.com
G+: Rich Warren (https://plus.google.com/114311896476820866022/posts)
Twitter: @rikiwarren