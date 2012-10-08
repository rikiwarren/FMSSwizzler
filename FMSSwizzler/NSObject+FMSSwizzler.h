//
//  NSObject+FMSSwizzler.h
//  FMSSwizzler
//
//    Copyright (c) 2012, Richard Warren
//    All rights reserved.
//
//    Redistribution and use in source and binary forms, with or without modification,
//    are permitted provided that the following conditions are met:
//
//        * Redistributions of source code must retain the above copyright notice, this
//          list of conditions and the following disclaimer.
//
//        * Redistributions in binary form must reproduce the above copyright notice,
//          this list of conditions and the following disclaimer in the documentation
//          and/or other materials provided with the distribution.
//
//        * Neither the name of the <ORGANIZATION> nor the names of its contributors may
//          be used to endorse or promote products derived from this software without
//            specific prior written permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//    EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//    SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//    STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
//    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

/**
 * @file NSObject+FMSSwizzler.h
 * The public interface for FMSSwizzler.
 */

#import <Foundation/Foundation.h>

/**
 * Used to set the property type for dynamicly added pseudo-properties. All properties are nonatomic.
 */

enum pseudoPropertyType {
    
    FMSObjectRetain,        /**< Used for objects that should be retained. */
    FMSObjectCopy,          /**< Used for objects that should be copied. */
    FMSObjectAssignUnsafe,  /**< Used for objects that should be assigned unsafely (NOT a zeroing weak reference). */
    FMSBool,                /**< Used for scalar `BOOL` values */
    FMSInteger,             /**< Used for scalar `NSInteger` values */
    FMSUnsignedInteger,     /**< Used for scalar `NSUInteger` values */
    FMSFloat,               /**< Used for scalar `float` values */
    FMSDouble               /**< Used for scalar `double` values */
};

/** 
 * Used to identify the property type for dynamically added pseudo-properties 
 */
typedef enum pseudoPropertyType FMSPseudoPropertyType;

/**
 * A block that can add a property of the given property name to its class.
 * You should generate an FMSPseudoPropertyAdder block for each class, and for each
 * property type.
 */
typedef void (^FMSPseudoPropertyAdder) (NSString *propertyName);


/**
 * @brief FMSSwizzler's public methods.
 *
 * Public methods added to the NSObject (and it's decendents) to simplify method and class swizzling, as
 * well as providing support for dynamically adding pseudo properties at runtime.
 */
@interface NSObject (FMS_Swizzler)

/**
 * @brief adds a new instance method using the same implementation as the original selector
 *
 * @param originalSelector This is the original selector whose implementation we wish to alias. This must be an instance method that is currently defined either by the current class or by one of its ancestors.
 *
 * @param newSelector This is the selector for the new method we will create. This instance method must not yet exist either in the current class or in any of its ancestors. Additionally, this must have the same number of arguments as `originalSelector`.
 *
 * This method creates a new method using the `newSelector` and the implementation from the `originalSelector`. 
 * We then have two methods that both use the same implementation. This is particularly useful if you wish to replace
 * an existing method, but still want access to it.
 *
 * Note: You must take care when aliasing methods from class clusters. Classes like NSString, NSArray or NSDate 
 * declare a public, abstract class--but then provide private subclasses when instantiated. If you alias the 
 * abstract class (e.g. `[NSString FMS_aliasInstanceMethod:...`) your new method will point to the version of the
 * method defined in the abstract class, not the version provided in the concrete subclass. To correctly alias
 * the subclass, you must call FMS_aliasInstanceMethod on the subclass itself (e.g. 
 * `[[myString class] FMS_aliasInstanceMethod...). To make things even more difficult, different instances
 * from the same class cluster may have different concrete subclasses. Bottom line, it's probably best to avoid
 * aliasing subclasses.
 *
 * Note: Aliasing can also interfere with KVO (though, in potentially useful ways). If you are observing a keypath
 * that corresponds to an accessor method, and you alias that accessor method, then calling the original method will
 * still generate KVO notifications--but calling the alias will not. This, potentially, lets you sidestep around 
 * KVO notification when done deliberately, but can also cause odd bugs when you are not paying attention.
 */

+ (void)FMS_aliasInstanceMethod:(SEL)originalSelector newSelector:(SEL)newSelector;

+ (void)FMS_replaceInstanceMethod:(SEL)methodSelector withImplementationBlock:(id)block;

+ (void)FMS_overrideInstanceMethod:(SEL)selector oldSelector:(SEL)oldSelector implementationBlock:(id)block;

/**
 * @brief adds a new class method using the same implementation as the original selector
 *
 * @param originalSelector This is the original selector whose implementation we wish to alias. This must be a class method that is currently defined either by the current class or by one of its ancestors.
 *
 * @param newSelector This is the selector for the new class method we will create. This method must not yet exist either in the current class or in any of its ancestors. Additionally, this must have the same number of arguments as `originalSelector`.
 *
 * This method creates a new class method using the `newSelector` and the implementation from the `originalSelector`.
 * We then have two methods that both use the same implementation. This is particularly useful if you wish to replace
 * an existing method, but still want to be able to access it in your code.
 */

+ (void)FMS_aliasClassMethod:(SEL)originalSelector newSelector:(SEL)newSelector;

+ (void)FMS_replaceClassMethod:(SEL)methodSelector withImplementationBlock:(id)block;

+ (void)FMS_overrideClassMethod:(SEL)selector oldSelector:(SEL)oldSelector implementationBlock:(id)block;

/**
 * @brief Generates a `FMSPseudoPropertyAdder` block for the specified class and property type.
 *
 * @param type A `FMSPseudoPropertyType` indicating the type of properties the returned adder should create.
 * @return The `FMSPseudoPropertyAdder` for the calling class that creates pseudo properties of the type specified in the `type` parameter.
 *
 * This method generates a block that can be used to create pseudo properties. Simply call the block and pass in 
 * a single `NSString` argument. The adder will dynamically create getter and setter methods using the string as
 * the property name. The adder will use `objc_getAssociatedObject()` and `objc_setAssociatedObject()` as the data
 * storage for the property.
 */

+ (FMSPseudoPropertyAdder)FMS_generatePseudoPropertyAdderForType:(FMSPseudoPropertyType)type;

- (void)FMS_dynamiclySubclass;




@end