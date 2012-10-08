//
//  Person.h
//  FMSSwizzler
//
//  Created by Rich Warren on 10/7/12.
//  Copyright (c) 2012 Rich Warren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (assign, nonatomic) NSUInteger age;

+ (id)personWithFirstName:(NSString *)firstName lastName:(NSString *)lastName age:(NSUInteger)age;

- (NSString *)fullName;
- (NSString *)fullNameWithTitle:(NSString *)title;
- (BOOL)canLegallyDrink;

@end
