//
//  MonitorableObject.m
//  FMSSwizzler
//
//  Created by Rich Warren on 10/7/12.
//  Copyright (c) 2012 Rich Warren. All rights reserved.
//

#import "MonitorableObject.h"

@implementation MonitorableObject

- (id)initWithValue:(NSUInteger)value {
    
    self = [super init];
    if (self != nil) {
        _value = value;
        _copy = NO;
    }
    
    return self;
}

-(void)dealloc {
    
    if (self.deallocBlock != nil) {
        self.deallocBlock(self);
    }
}

- (id)copyWithZone:(NSZone *)zone {

    MonitorableObject *copy = [[MonitorableObject alloc] initWithValue:self.value];
    copy.copy = YES;
    
    return copy;
}

- (BOOL)isEqual:(id)object {
    
    if (![object isKindOfClass:[MonitorableObject class]]) return NO;
    
    MonitorableObject *test = object;
    return test.value == self.value;
}

- (NSUInteger)hash {
    return self.value;
}

@end
