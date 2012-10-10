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
 *
 * Note: I've tried to test and identify most of the obvious gotchas. However, by it's nature
 * class and method swizzling is inherently unsafe. There may be additional edge cases that
 * will cause errors. Please use these methods with care, and test your code thoroughly.
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
 * the subclass, you must call `FMS_aliasInstanceMethod` on the subclass itself (e.g. 
 * `[[myString class] FMS_aliasInstanceMethod...). To make things even more difficult, different instances
 * from the same class cluster may have different concrete subclasses. Bottom line, it's probably best to avoid
 * aliasing methods on class clusters. Alternatively, dynamically subclass the instance before creating the 
 * alias to limit the change to just that instance.
 *
 * Note: Aliasing can also interfere with KVO (though, in potentially useful ways). If you are observing a keypath
 * that corresponds to an accessor method, and you alias that accessor method, then calling the original method will
 * still generate KVO notifications--but calling the alias will not. This, potentially, lets you sidestep around 
 * KVO notification when done deliberately, but can also cause odd bugs when you are not paying attention.
 *
 * Note: There may be a few odd edge cases where methods check the _cmd hidden before determining their
 * behavior. In these cases, the aliased methods will use the new selector for their _cmd value. So, they 
 * may no longer function properly. This should be rare, however.
 */

+ (void)FMS_aliasInstanceMethod:(SEL)originalSelector newSelector:(SEL)newSelector;

/**
 * @brief Replaces the specified method with the given block.
 *
 * @param methodSelector The selector for the method we wish to replace.
 * @param block A block containing our new implementation. This block must start with an argument for the current object (the equivilant of the `self` argument--note that we do not need to include the `_cmd` argument). Next, we  need to match all the method's arguments exactly. If you do not, it could cause the applicaiton to crash at runtime. Finally, the block needs to return the same type of data as the original method.
 *
 * This method replaces the specified method's current `IMP` with a new `IMP` created from the provided block. 
 * Our block must return the same data type as the original implementation. It must also take a number of 
 * arguments equal to the original + 1 (for `_self`). 
 *
 * Examples:
 * Method with no arguments:
 * `[[Person class] FMS_replaceInstanceMethod:@selector(firstName) withImplementationBlock:^(Person *_self){return @"Bob";}];`
 * 
 * Method with one argument:
 * `[[Person class] FMS_replaceInstanceMethod:@selector(setFirstName:) withImplementationBlock:^(Person *_self, NSString *name){ // do something with the name here -- no need to return anything.}];`
 
 *
 * Note: replacing a method that the class relies on internally may cause unexpected results. Strongly consider
 * using `FMS_OverrideInsanceMethod:oldSelector:implementationBlock: and calling the original method either before
 * or after your modified code.
 *
 * Note: You must take care when replacing methods from class clusters. Classes like NSString, NSArray or NSDate
 * declare a public, abstract class--but then provide private subclasses when instantiated. If you replace the
 * abstract class (e.g. `[NSString FMS_replaceInstanceMethod:...`) your new method will probably be overridden
 * by the concrete subclass, and will never be called. You must call `FMS_replaceInstanceMethod` on the subclass
 * itself (e.g. `[[myString class] FMS_aliasInstanceMethod...). To make things even more difficult, different
 * instances from the same class cluster may have different concrete subclasses. Bottom line, it's probably best 
 * to avoid replacing methods on class clusters. Alternatively, dynamically subclass the instance before creating the
 * alias to limit the change to just that instance.
 *
 * Note: Replacing methods may also cause unexpected results with KVO. Remember, if you are observing a keypath
 * that corresponds to the method you have replaced, your new method will still trigger KVO notifications--even 
 * if you end up not changing the underlying values.
 */

+ (void)FMS_replaceInstanceMethod:(SEL)methodSelector withImplementationBlock:(id)block;

/**
 * @brief Allows you to replace the implementation of an existing method, while still providing access to the original implementation.
 *
 * @param selector This is the selector for the method you wish to override.
 * @param oldSelector This is the selector that will be used for accessing the old implementation. This must have the same number of arguments as the original `selector`.
 * @param block A block containing our new implementation. This block must start with an argument for the current object (the equivilant of the `self` argument--note that we do not need to include the `_cmd` argument). Next, we  need to match all the method's arguments exactly. If you do not, it could cause the applicaiton to crash at runtime. Finally, the block needs to return the same type of data as the original method.
 *
 * This method starts by creating an alias of the specified method using the `oldSelector` argument. Then it 
 * replaces the method's current `IMP` with a new `IMP` created from the provided block. This leaves us with
 * two, unique methods: `selector` points to our new implementation while `oldSelector` points to the old.
 *
 * Our implementation block must return the same data type as the original implementation. It must also take a 
 * number of arguments equal to the original + 1 (for `_self`).
 *
 * Examples:
 * Method with no arguments:
 * `[[Person class] FMS_overrideInstanceMethod:@selector(firstName) oldSelector:@selector(oldFirstName) implementationBlock:^(Person *_self){return [[_self oldFirstName] lowercaseString];}];`
 *
 * Method with one argument:
 * `[[Person class] FMS_overrideInstanceMethod:@selector(setFirstName:) oldSelector:@selector(oldSetFirstName:) implementationBlock:^(Person *_self, NSString *name){ [_self oldSetFirstName:[name lowercaseString]];}];`
 
 *
 * Note: You must take care when replacing methods from class clusters. Classes like NSString, NSArray or NSDate
 * declare a public, abstract class--but then provide private subclasses when instantiated. If you replace the
 * abstract class (e.g. `[NSString FMS_replaceInstanceMethod:...`) your new method will probably be overridden
 * by the concrete subclass, and will never be called. You must call `FMS_replaceInstanceMethod` on the subclass
 * itself (e.g. `[[myString class] FMS_aliasInstanceMethod...). To make things even more difficult, different
 * instances from the same class cluster may have different concrete subclasses. Bottom line, it's probably best
 * to avoid replacing methods on class clusters. Alternatively, dynamically subclass the instance before creating the
 * alias to limit the change to just that instance.
 *
 * Note: Replacing methods may also cause unexpected results with KVO. Remember, if you are observing a keypath
 * that corresponds to the method you have replaced, your new method will still trigger KVO notifications--even
 * if you end up not changing the underlying values.
 *
 * Note: There may be a few odd edge cases where the original method checks the _cmd hidden before determining its
 * behavior. In these cases, the old implementation will use `oldSelector` for their _cmd value. So, they
 * may no longer function properly. This should be rare, however.
 */

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
 *
 * Note: There may be a few odd edge cases where methods check the _cmd hidden before determining their
 * behavior. In these cases, the aliased methods will use the new selector for their _cmd value. So, they
 * may no longer function properly. This should be rare, however.
 */

+ (void)FMS_aliasClassMethod:(SEL)originalSelector newSelector:(SEL)newSelector;

/**
 * @brief Replaces the specified class method with the given block.
 *
 * @param methodSelector The selector for the class method we wish to replace.
 * @param block A block containing our new implementation. This block must start with an argument for the current class (the equivilant of the `self` argument in other class methods--note that we do not need to include the `_cmd` argument). Next, we  need to match all the class method's arguments exactly. If you do not, it could cause the applicaiton to crash at runtime. Finally, the block needs to return the same type of data as the original method.
 *
 * This method replaces the specified class method's current `IMP` with a new `IMP` created from the provided block.
 * Our block must return the same data type as the original implementation. It must also take a number of
 * arguments equal to the original + 1 (for `_self`).
 *
 * Examples:
 * Method with 3 arguments:
 * `[[Person class] FMS_replaceClassMethod:@selector(personWithFirstName:lastName:age:) withImplementationBlock:^(id _self, NSString *firstName, NSString *lastName, NSUInteger age){return nil;}];`
 *
 */

+ (void)FMS_replaceClassMethod:(SEL)methodSelector withImplementationBlock:(id)block;

/**
 * @brief Allows you to replace the implementation of an existing class method, while still providing access to the original implementation.
 *
 * @param selector This is the selector for the class method you wish to override.
 * @param oldSelector This is the selector that will be used for accessing the old implementation. This must have the same number of arguments as the original `selector`.
 * @param block A block containing our new implementation. This block must start with an argument for the current object (the equivilant of the `self` argument--note that we do not need to include the `_cmd` argument). Next, we  need to match all the method's arguments exactly. If you do not, it could cause the applicaiton to crash at runtime. Finally, the block needs to return the same type of data as the original method.
 *
 * This method starts by creating an alias of the specified class method using the `oldSelector` argument. Then it
 * replaces the method's current `IMP` with a new `IMP` created from the provided block. This leaves us with
 * two, unique methods: `selector` points to our new implementation while `oldSelector` points to the old.
 *
 * Our implementation block must return the same data type as the original implementation. It must also take a
 * number of arguments equal to the original + 1 (for `_self`).
 *
 * Example:
 * Method with 3 arguments:
 * `[[Person class] FMS_overrideClassMethod:@selector(personWithFirstName:lastName:age:) oldSelector:@selector(oldPersonWithFirstName:lastName:age:) implementationBlock:^(id _self, NSString *firstName, NSString *lastName, NSUInteger age){return [_self oldPersonWithFirstName:[firstName lowercaseString] lastName:[lastName lowercaseString] age:age;}];`
 
 *
 * Note: replacing a method that the class relies on internally may cause unexpected results. Strongly consider
 * using `FMS_OverrideInsanceMethod:oldSelector:implementationBlock: and calling the original method either before
 * or after your modified code.
 *
 * Note: There may be a few odd edge cases where the original method checks the _cmd hidden before determining its
 * behavior. In these cases, the old implementation will use `oldSelector` for their _cmd value. So, they
 * may no longer function properly. This should be rare, however.
 */

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


/**
 * @brief Make the instance a subclass of its current class. This lets you override methods on the new subclass without affecting any other objects in your project.
 *
 * Calling this method dynamically creates a subclass of the object's current class, then changes the object's class 
 * to the newly created subclass. This lets us sandbox any changes we make to the class. It is most often paired
 * with calls to `FMS_overrideInstanceMethod:oldSelector:implementationBlock:`, letting us override the instances
 * method without modifying any other instances of the class.
 *
 * Dynamic subclassing avoids many of the problems associated with class clusters.
 *
 * Note: Any further FMSSwizzling methods must be called on the new class. For example, if I dynamically subclass
 * my `self.person` instance, I can then override its methods by calling 
 * `[[self.person class] FMS_overrideInstanceMethod...`.
 *
 * Note: Care must be taken when mixing dynamic subclassing and KVO. KVO uses a version of dynamic subclassing 
 * to provide its notifications. Importantly, KVO notifications will only work if the KVO subclass is the last 
 * one. Therefore, calling `FMS_dynamiclySubclass` before calling `addObserver:forKeyPath:options:context:` works
 * fine. Calling `addObserver:forKeyPath:options:context:` and then calling `FMS_dynamiclySubclass` will prevent
 * the notifications from being sent.
 *
 * Note: Dynamic subclassing cannot be used with tagged pointers. Some NSNumber and NSDate (and possibly other)
 * objects use pointer tagging to improve efficiency. `FMS_dynamiclySubclass` will check the object's class
 * before trying to dynamically subclass the class. If it finds a tagged pointer (any pointer with a 1 in the
 * lowest bit), it throws an exception.
 */
 
- (void)FMS_dynamiclySubclass;

@end