//
//  NSObject+FMSSwizzler.m
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

#import "NSObject+FMSSwizzler.h"
#import <objc/runtime.h>

#if __LP64__ || TARGET_OS_EMBEDDED || TARGET_OS_IPHONE || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
#define integerType @"l"
#define unsignedIntegerType @"L"
#else
#define integerType @"i"
#define unsignedIntegerType @"I"
#endif

#if !__has_feature(objc_arc)
#error AFNetworking must be built with ARC.
// You can turn on ARC for only AFNetworking files by adding -fobjc-arc to the build phase for each of its files.
#endif

@implementation NSObject (FMS_Swizzler)

#pragma mark - Pseudo Property Methods

+ (FMSPseudoPropertyAdder)FMS_generatePseudoPropertyAdderForType:(FMSPseudoPropertyType)type {
    
    FMSPseudoPropertyAdder adder;
    
    switch (type) {
        case FMSObjectRetain: {
            
            adder = ^(NSString *propertyName) {
                
                NSString *key = [NSString stringWithFormat:@"FMS%@Key", propertyName];
                
                IMP getterImp = imp_implementationWithBlock(^(id _self){
                    
                    id result = objc_getAssociatedObject(_self, (__bridge const void *)(key));
                    return result;
                    
                });
                
                IMP setterImp = imp_implementationWithBlock(^(id _self, id obj){
                    
                    objc_setAssociatedObject(_self,
                                             (__bridge const void *)(key),
                                             obj,
                                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    
                });
                
                NSString *typeString = @"@";
                [self createPseudoProperties:propertyName typeString:typeString getterImp:getterImp setterImp:setterImp];
            };
            
            break;
            
        }
            
            
            
        case FMSObjectCopy: {
            
            adder = ^(NSString *propertyName) {
                
                NSString *key = [NSString stringWithFormat:@"FMS%@Key", propertyName];
                
                IMP getterImp = imp_implementationWithBlock(^(id _self){
                    
                    return objc_getAssociatedObject(_self, (__bridge const void *)(key));
                    
                });
                
                IMP setterImp = imp_implementationWithBlock(^(id _self, id obj){
                    
                    objc_setAssociatedObject(_self,
                                             (__bridge const void *)(key),
                                             obj,
                                             OBJC_ASSOCIATION_COPY_NONATOMIC);
                    
                });
                
                NSString *typeString = @"@";
                [self createPseudoProperties:propertyName typeString:typeString getterImp:getterImp setterImp:setterImp];
            };
            
            break;
        }
            
            
            
        case FMSObjectAssignUnsafe: {
            
            adder = ^(NSString *propertyName) {
                
                NSString *key = [NSString stringWithFormat:@"FMS%@Key", propertyName];
                
                IMP getterImp = imp_implementationWithBlock(^(id _self){
                    
                    return objc_getAssociatedObject(_self, (__bridge const void *)(key));
                    
                });
                
                IMP setterImp = imp_implementationWithBlock(^(id _self, id obj){
                    
                    objc_setAssociatedObject(_self,
                                             (__bridge const void *)(key),
                                             obj,
                                             OBJC_ASSOCIATION_ASSIGN);
                    
                });
                
                NSString *typeString = @"@";
                [self createPseudoProperties:propertyName typeString:typeString getterImp:getterImp setterImp:setterImp];
            };
            
            break;
        }
            
            
            
        case FMSBool: {
            
            adder = ^(NSString *propertyName) {
                
                NSString *key = [NSString stringWithFormat:@"FMS%@Key", propertyName];
                
                IMP getterImp = imp_implementationWithBlock(^(id _self){
                    
                    return [objc_getAssociatedObject(_self, (__bridge const void *)(key)) boolValue];
                    
                });
                
                IMP setterImp = imp_implementationWithBlock(^(id _self, BOOL value){
                    
                    objc_setAssociatedObject(_self,
                                             (__bridge const void *)(key),
                                             @(value),
                                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    
                });
                
                NSString *typeString = @"c";
                [self createPseudoProperties:propertyName typeString:typeString getterImp:getterImp setterImp:setterImp];
            };
            
            break;
        }
            
            
            
        case FMSInteger: {
            
            adder = ^(NSString *propertyName) {
                
                NSString *key = [NSString stringWithFormat:@"FMS%@Key", propertyName];
                
                IMP getterImp = imp_implementationWithBlock(^(id _self){
                    
                    return [objc_getAssociatedObject(_self, (__bridge const void *)(key)) integerValue];
                    
                });
                
                IMP setterImp = imp_implementationWithBlock(^(id _self, NSInteger value){
                    
                    objc_setAssociatedObject(_self,
                                             (__bridge const void *)(key),
                                             @(value),
                                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    
                });
                
                NSString *typeString = integerType;
                [self createPseudoProperties:propertyName typeString:typeString getterImp:getterImp setterImp:setterImp];
            };
            
            break;
        }
            
            
            
        case FMSUnsignedInteger: {
            
            adder = ^(NSString *propertyName) {
                
                NSString *key = [NSString stringWithFormat:@"FMS%@Key", propertyName];
                
                IMP getterImp = imp_implementationWithBlock(^(id _self){
                    
                    return [objc_getAssociatedObject(_self, (__bridge const void *)(key))
                            unsignedIntegerValue];
                    
                });
                
                IMP setterImp = imp_implementationWithBlock(^(id _self, NSUInteger value){
                    
                    objc_setAssociatedObject(_self,
                                             (__bridge const void *)(key),
                                             @(value),
                                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    
                });
                
                NSString *typeString = unsignedIntegerType;
                [self createPseudoProperties:propertyName typeString:typeString getterImp:getterImp setterImp:setterImp];
            };
            
            break;
        }
            
            
            
        case FMSFloat: {
            
            adder = ^(NSString *propertyName) {
                
                NSString *key = [NSString stringWithFormat:@"FMS%@Key", propertyName];
                
                IMP getterImp = imp_implementationWithBlock(^(id _self){
                    
                    return [objc_getAssociatedObject(_self, (__bridge const void *)(key))
                            floatValue];
                    
                });
                
                IMP setterImp = imp_implementationWithBlock(^(id _self, float value){
                    
                    objc_setAssociatedObject(_self,
                                             (__bridge const void *)(key),
                                             @(value),
                                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    
                });
                
                NSString *typeString = @"f";
                [self createPseudoProperties:propertyName typeString:typeString getterImp:getterImp setterImp:setterImp];
            };
            
            break;
        }
            
            
            
        case FMSDouble: {
            
            adder = ^(NSString *propertyName) {
                
                NSString *key = [NSString stringWithFormat:@"FMS%@Key", propertyName];
                
                IMP getterImp = imp_implementationWithBlock(^(id _self){
                    
                    return [objc_getAssociatedObject(_self, (__bridge const void *)(key))
                            doubleValue];
                    
                });
                
                IMP setterImp = imp_implementationWithBlock(^(id _self, double value){
                    
                    objc_setAssociatedObject(_self,
                                             (__bridge const void *)(key),
                                             @(value),
                                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    
                });
                
                NSString *typeString = @"d";
                [self createPseudoProperties:propertyName typeString:typeString getterImp:getterImp setterImp:setterImp];
            };
            
            break;
        }
            
            
            
        default:
            
            [NSException raise:NSInvalidArgumentException
                        format:@"%d is not a valid FMSPsudoPropertyType", type];
            
    }
    
    return adder;
}

#pragma mark - Instance Method Swizzlers

+ (void)FMS_aliasInstanceMethod:(SEL)originalSelector newSelector:(SEL)newSelector {
    
    if (class_getInstanceMethod(self, newSelector) != NULL) {
        [NSException
         raise:NSInvalidArgumentException
         format:@"The selector %@ is already being used.",
         NSStringFromSelector(newSelector)];
    }
    
    NSUInteger originalArgCount = [[NSStringFromSelector(originalSelector) componentsSeparatedByString:@":"] count];
    NSUInteger newArgCount = [[NSStringFromSelector(newSelector) componentsSeparatedByString:@":"] count];
    
    if ( originalArgCount != newArgCount) {
        
        [NSException
         raise:NSInvalidArgumentException
         format:@"The selectors must have the same number of arguments, had %d and %d",
         (int)originalArgCount, (int)newArgCount];
        
    }
    
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    
    if (originalMethod == NULL) {
        [NSException raise:NSInvalidArgumentException
                    format:@"The original method does not exist"];
    }
    
    IMP implementation = method_getImplementation(originalMethod);
    const char *typeEncoding = method_getTypeEncoding(originalMethod);
    
    if (!class_addMethod(self, newSelector, implementation, typeEncoding)) {
        
        [NSException
         raise:NSGenericException
         format:@"An unknown exception occured while adding the alias method"];
    }
}

+ (void)FMS_replaceInstanceMethod:(SEL)methodSelector withImplementationBlock:(id)block {
    
    // Make sure we have an implementation in the current class (not super class)
    Method originalMethod = class_getInstanceMethod(self, methodSelector);
    
    if (originalMethod == NULL) {
        [NSException raise:NSInvalidArgumentException
                    format:@"The original method does not exist"];
    }
    
    const char *typeEncoding = method_getTypeEncoding(originalMethod);
    IMP newImp = imp_implementationWithBlock(block);
    
    class_replaceMethod(self, methodSelector, newImp, typeEncoding);
}

+ (void)FMS_overrideInstanceMethod:(SEL)selector oldSelector:(SEL)oldSelector implementationBlock:(id)block {
    
    [self FMS_aliasInstanceMethod:selector newSelector:oldSelector];
    [self FMS_replaceInstanceMethod:selector withImplementationBlock:block];
}


#pragma mark - Class Method Swizzlers

+ (void)FMS_aliasClassMethod:(SEL)originalSelector newSelector:(SEL)newSelector {
    
    if (class_getClassMethod(self, newSelector) != NULL) {
        [NSException
         raise:NSInvalidArgumentException
         format:@"The selector %@ is already being used.",
         NSStringFromSelector(newSelector)];
    }
    
    NSUInteger originalArgCount = [[NSStringFromSelector(originalSelector) componentsSeparatedByString:@":"] count];
    NSUInteger newArgCount = [[NSStringFromSelector(newSelector) componentsSeparatedByString:@":"] count];
    
    if ( originalArgCount != newArgCount) {
        
        [NSException
         raise:NSInvalidArgumentException
         format:@"The selectors must have the same number of arguments, had %d and %d",
         (int)originalArgCount, (int)newArgCount];
        
    }
    
    Method originalMethod = class_getClassMethod(self, originalSelector);
    
    if (originalMethod == NULL) {
        [NSException raise:NSInvalidArgumentException
                    format:@"The original method does not exist"];
    }
    
    IMP implementation = method_getImplementation(originalMethod);
    const char *typeEncoding = method_getTypeEncoding(originalMethod);
    
    if (!class_addMethod(object_getClass(self), newSelector, implementation, typeEncoding)) {
        
        [NSException
         raise:NSGenericException
         format:@"An unknown exception occured while adding the alias method"];
    }
}


+ (void)FMS_replaceClassMethod:(SEL)methodSelector withImplementationBlock:(id)block {
    
    // Make sure we have a method implemented.
    Method originalMethod = class_getClassMethod(object_getClass(self), methodSelector);
    
    if (originalMethod == NULL) {
        [NSException raise:NSInvalidArgumentException
                    format:@"The original method does not exist"];
    }
    
    const char *typeEncoding = method_getTypeEncoding(originalMethod);
    IMP newImp = imp_implementationWithBlock(block);
    class_replaceMethod(object_getClass(self), methodSelector, newImp, typeEncoding);
}


+ (void)FMS_overrideClassMethod:(SEL)selector oldSelector:(SEL)oldSelector implementationBlock:(id)block {
    
    [self FMS_aliasClassMethod:selector newSelector:oldSelector];
    [self FMS_replaceClassMethod:selector withImplementationBlock:block];
}


#pragma mark - Private Methods

+ (void)createPseudoProperties:(NSString *)propertyName
                    typeString:(NSString *)typeString
                     getterImp:(IMP)getterImp
                     setterImp:(IMP)setterImp {
    
    // make sure we have a valid property name should be non-nil, one word, lettter for first character,
    // lower case letter for first character, and only numbers, letters or underscores.
    NSError *error;
    NSRegularExpression *regexp =
    [NSRegularExpression regularExpressionWithPattern:@"\\A\\p{Ll}[\\p{Ll}\\p{Lu}\\p{Lo}\\p{Nd}_]*\\z"
                                              options:0
                                                error:&error];
    
    
    if (error != nil) {
        NSString *message = [error localizedDescription];
        NSLog(@"*** An Error Occurred: %@ ***", message);
        
        [NSException
         raise:NSGenericException
         format:@"An error occurred creating the regular expression to validate "
         @"the pseudo property names: %@",
         message];
    }
    
    NSRange range = NSMakeRange(0, [propertyName length]);
    if ([regexp numberOfMatchesInString:propertyName options:NSMatchingReportCompletion range:range] == 0) {
                
        [NSException
         raise:NSInvalidArgumentException
         format:@"%@ is not a valid property name. It must start with a lower case letter and "
         @"have only letters, numbers and underscores.",
         propertyName];
    }
    
    
    SEL getter = NSSelectorFromString(propertyName);
    
    NSString *setterName = [NSString stringWithFormat:@"set%@%@:",
                            [[propertyName substringToIndex: 1] uppercaseString],
                            [propertyName substringFromIndex: 1]];
    
    SEL setter = NSSelectorFromString(setterName);
    
    if ([self instancesRespondToSelector:getter]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"The %@ method already exists", NSStringFromSelector(getter)];
    }
    
    if ([self instancesRespondToSelector:setter]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"The %@ method already exists", NSStringFromSelector(setter)];
    }
    
    NSLog(@"Creating properties: %@ and %@",
          NSStringFromSelector(getter),
          NSStringFromSelector(setter));
    
    
    Class class = [self class];
    
    
    NSString *getterTypeString = [NSString stringWithFormat:@"%@@:", typeString];
    class_addMethod(class, getter, getterImp,
                    [getterTypeString cStringUsingEncoding:NSUTF8StringEncoding]);
    
    NSString *setterTypeString = [NSString stringWithFormat:@"v@:%@", typeString];
    class_addMethod(class, setter, setterImp,
                    [setterTypeString cStringUsingEncoding:NSUTF8StringEncoding]);
    
}

#pragma mark - Dynamic Subclassing

- (void)FMS_dynamiclySubclass {
    
    Class startingClass = [self class];
    NSInteger pointer = (NSInteger)self;
    
    if ((pointer & 1) == 1) {
        
        [NSException raise:NSInternalInconsistencyException
                    format:@"Cannot dynamic subclass a tagged pointer object."];
        
    }
    
    static NSUInteger count = 0;
    count ++;
    
    NSString *className = [NSString stringWithFormat:@"RKW_%@_%@", startingClass, @(count)];
    
    Class cls = objc_allocateClassPair(startingClass,
                                       [className cStringUsingEncoding:NSUTF8StringEncoding],
                                       0);
    
    
    objc_registerClassPair(cls);
    object_setClass(self, cls);
    
    [cls FMS_replaceInstanceMethod:@selector(classForCoder) withImplementationBlock:^(__unused id _self) {
        return startingClass;
    }];
}

@end

