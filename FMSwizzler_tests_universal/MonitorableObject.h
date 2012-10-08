//
//  MonitorableObject.h
//  FMSSwizzler
//
//  Created by Rich Warren on 10/7/12.
//  Copyright (c) 2012 Rich Warren. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MonitorableObjectDeallocBlock) (id _self);

@interface MonitorableObject : NSObject <NSCopying>

@property (assign, nonatomic, getter = isCopy) BOOL copy;
@property (strong, nonatomic) MonitorableObjectDeallocBlock deallocBlock;
@property (assign, nonatomic, readonly) NSUInteger value;

- (id)initWithValue:(NSUInteger)value;

@end
