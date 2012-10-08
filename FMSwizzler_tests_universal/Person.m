//
//  Person.m
//  FMSSwizzler
//
//  Created by Rich Warren on 10/7/12.
//  Copyright (c) 2012 Rich Warren. All rights reserved.
//

#import "Person.h"

@implementation Person

+(id)personWithFirstName:(NSString *)firstName lastName:(id)lastName age:(NSUInteger)age {
    
    Person *person = [[self alloc] init];
    
    person.firstName = firstName;
    person.lastName = lastName;
    person.age = age;
    
    return person;
}

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (NSString *)fullNameWithTitle:(NSString *)title {
    
    return [NSString stringWithFormat:@"%@ %@ %@", title, self.firstName, self.lastName];
}

- (BOOL)canLegallyDrink {
    return self.age >= 21;
}

@end
