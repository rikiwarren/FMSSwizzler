//
//  FMSwizzler_osxTests.m
//  FMSwizzler_osxTests
//
//  Created by Rich Warren on 10/7/12.
//  Copyright (c) 2012 Rich Warren. All rights reserved.
//

#import "PseudoPropertyTests.h"
#import "Person.h"
#import "MonitorableObject.h"
#import "NSObject+FMSSwizzler.h"


// This prevents compiler errors for non-declared methods
@interface NSObject(pseudoProperties)

@property (strong, nonatomic) id pseudoRetain;
@property (copy, nonatomic)  id pseudoCopy;
@property (assign, nonatomic) id pseudoAssign;
@property (assign, nonatomic) BOOL pseudoBool;
@property (assign, nonatomic) NSUInteger pseudoUInteger;
@property (assign, nonatomic) NSInteger pseudoInteger;
@property (assign, nonatomic) float pseudoFloat;
@property (assign, nonatomic) double pseudoDouble;

@property (strong, nonatomic) id first;
@property (strong, nonatomic) id second;
@property (strong, nonatomic) id third;
@property (strong, nonatomic) id fourth;

@end

@interface PseudoPropertyTests()

@property (strong, nonatomic) Person *p1;
@property (strong, nonatomic) Person *p2;

@end


// Unit Tests
@implementation PseudoPropertyTests

- (void)setUp
{
    [super setUp];
    
    self.p1 = [Person personWithFirstName:@"John" lastName:@"Smith" age:42];
    self.p2 = [Person personWithFirstName:@"Sara" lastName:@"Jones" age:35];
    
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
    
    self.p1 = nil;
    self.p2 = nil;
}


- (void)testAddPropertyTypes
{
    __block BOOL originalDeallocated = NO;
    __block BOOL copyDeallocated = NO;
    
    MonitorableObjectDeallocBlock deallocBlock = ^(id _self) {
        MonitorableObject *obj = _self;

        if (obj.copy) {
            copyDeallocated = YES;
        } else {
            originalDeallocated = YES;
        }
    };
    
    // use mutalbe strings to make sure copying is working.
    MonitorableObject *o1 = [[MonitorableObject alloc] initWithValue:0];
    o1.deallocBlock = deallocBlock;
    
    MonitorableObject *o2 = [[MonitorableObject alloc] initWithValue:1];
    o2.deallocBlock = deallocBlock;
    
    MonitorableObject *o3 = [[MonitorableObject alloc] initWithValue:2];
    o3.deallocBlock = deallocBlock;
    
    // Sanity Check
    STAssertNoThrow(self.p1.firstName = @"Bob", @"The setFirstName method should exist");
    STAssertNoThrow(self.p1.lastName = @"Davis", @"The setLastName method should exist");
    STAssertNoThrow(self.p1.age = 25, @"The setAge method should exist");
    
    STAssertFalse([o1 isEqual:o2], @"These should not be equal.");
    STAssertFalse([o1 isEqual:o3], @"These should not be equal.");
    STAssertFalse([o2 isEqual:o3], @"These should not be equal.");
        
    // Make sure the pseudo methods don't exist yet.
    STAssertThrows(self.p1.pseudoRetain = o1, @"We have not yet defined the setPseudoRetain method.");
    STAssertThrows(self.p1.pseudoCopy = o2, @"We have not yet defined the setPseudoCopy method.");
    STAssertThrows(self.p1.pseudoAssign = o3, @"We have not yet defined the setPseudoAssign method.");
    STAssertThrows(self.p1.pseudoBool = YES, @"We have not yet defined the setPseudoBool method.");
    STAssertThrows(self.p1.pseudoInteger = -52, @"We have not yet defined the setPseudoInteger method.");
    STAssertThrows(self.p1.pseudoUInteger = 23, @"We have not yet defined the setPseudoUInteger method.");
    STAssertThrows(self.p1.pseudoFloat = 0.25f, @"We have not yet defined the setPseudoFloat method.");
    STAssertThrows(self.p1.pseudoDouble = 0.52, @"We have not yet defined the setPseudoDouble method.");
    
    // Create pseudo properties
    FMSPseudoPropertyAdder addRetainedProperty = [Person FMS_generatePseudoPropertyAdderForType:FMSObjectRetain];
    addRetainedProperty(@"pseudoRetain");
    
    FMSPseudoPropertyAdder addCopyProperty = [Person FMS_generatePseudoPropertyAdderForType:FMSObjectCopy];
    addCopyProperty(@"pseudoCopy");
    
    FMSPseudoPropertyAdder addAssignedProperty = [Person FMS_generatePseudoPropertyAdderForType:FMSObjectAssignUnsafe];
    addAssignedProperty(@"pseudoAssign");
    
    FMSPseudoPropertyAdder addBoolProperty = [Person FMS_generatePseudoPropertyAdderForType:FMSBool];
    addBoolProperty(@"pseudoBool");
    
    FMSPseudoPropertyAdder addIntegerProperty = [Person FMS_generatePseudoPropertyAdderForType:FMSInteger];
    addIntegerProperty(@"pseudoInteger");
    
    FMSPseudoPropertyAdder addUIntegerProperty = [Person FMS_generatePseudoPropertyAdderForType:FMSUnsignedInteger];
    addUIntegerProperty(@"pseudoUInteger");
    
    FMSPseudoPropertyAdder addFloatProperty = [Person FMS_generatePseudoPropertyAdderForType:FMSFloat];
    addFloatProperty(@"pseudoFloat");
    
    FMSPseudoPropertyAdder addDoubleProperty = [Person FMS_generatePseudoPropertyAdderForType:FMSDouble];
    addDoubleProperty(@"pseudoDouble");
    
    
    // test the properties
    STAssertNoThrow(self.p1.pseudoRetain = o1, @"We've dynamically added the setPseudoRetain: method.");
    STAssertNoThrow(self.p1.pseudoCopy = o2, @"We've dynamically added the setPseudoCopy: method.");
    STAssertNoThrow(self.p1.pseudoAssign = o3, @"We've dynamically added the setPseudoAssign: method.");
    STAssertNoThrow(self.p1.pseudoBool = YES, @"We've dynamically added the setPseudoBool: method.");
    STAssertNoThrow(self.p1.pseudoInteger = -156, @"We've dynamically added the setPseudoInteger: method.");
    STAssertNoThrow(self.p1.pseudoUInteger = 345, @"We've dynamically added the setPseudoUInteger: method.");
    STAssertNoThrow(self.p1.pseudoFloat = -3.45, @"We've dynamically added the setPseudoFloat: method.");
    STAssertNoThrow(self.p1.pseudoDouble = 23.532, @"We've dynamically added the pseudoDouble: method.");

    // Old properties continue to work
    STAssertEqualObjects(self.p1.firstName, @"Bob", @"firstName should continue to work");
    STAssertEqualObjects(self.p1.lastName, @"Davis", @"Last name should continue to work");
    STAssertEquals(self.p1.age, 25ul, @"Age should continue to work");
    
    STAssertEqualObjects(self.p2.firstName, @"Sara", @"firstName should continue to work");
    STAssertEqualObjects(self.p2.lastName, @"Jones", @"Last name should continue to work");
    STAssertEquals(self.p2.age, 35ul, @"Age should continue to work");
    
    

    // Check the new properties that we've set
    
    @autoreleasepool {
        
        STAssertEqualObjects(self.p1.pseudoRetain, o1, @"pseudoRetaion should return the value we assigned");
        STAssertEquals(self.p1.pseudoRetain, o1 , @"We should store the same instance that we passed in");
        STAssertFalse([self.p1.pseudoRetain isCopy], @"We shouldn't have copied the o1 property");
    
    }

    originalDeallocated = NO;
    copyDeallocated = NO;
    o1 = nil;
    STAssertFalse(originalDeallocated, @"We shouldn't have deallocated the o1 property");
    STAssertFalse(copyDeallocated, @"We shouldn't have deallocated a copy of o1 property");

    @autoreleasepool {
        
        STAssertEqualObjects(self.p1.pseudoCopy, o2, @"pseudoCopy should return the value we assigned");
        STAssertFalse(self.p2.pseudoCopy == o2, @"The stored object and the original should be different instances");
        STAssertTrue([self.p1.pseudoCopy isCopy], @"We should have copied the o2 property");
        
    }
    
    originalDeallocated = NO;
    copyDeallocated = NO;
    o2 = nil;
    STAssertTrue(originalDeallocated, @"We should have deallocated the o2 property");
    STAssertFalse(copyDeallocated, @"We shouldn't have deallocated a copy of o2 property");
    
    @autoreleasepool {
        
        STAssertEqualObjects(self.p1.pseudoAssign, o3, @"pseudoAssign should return the value we assigned");
        STAssertEquals(self.p1.pseudoAssign, o3, @"PseudoAssign should store the same instance we passed in");
        STAssertFalse([self.p1.pseudoAssign isCopy], @"We shouldn't have copied the o3 property");
    
    }

    originalDeallocated = NO;
    copyDeallocated = NO;
    o3 = nil;
    STAssertTrue(originalDeallocated, @"We should have deallocated the o3 property");
    STAssertFalse(copyDeallocated, @"We shouldn't have deallocated a copy of o3 property");
    
    STAssertEquals(self.p1.pseudoBool, YES, @"pseduoBool should return the value we set");
    STAssertEquals(self.p1.pseudoInteger, -156l, @"pseudoInteger should return the value we set");
    STAssertEquals(self.p1.pseudoUInteger, 345ul, @"pseudoUInteger should return the value we set");
    STAssertEquals(self.p1.pseudoFloat, -3.45f, @"pseudoFloat should return the value we set");
    STAssertEquals(self.p1.pseudoDouble, 23.532, @"pseudoDouble should return the value we set");
    

    // Check the new properties that we haven't set
    STAssertEqualObjects(self.p2.pseudoRetain, nil, @"Should return nil by default");
    STAssertEqualObjects(self.p2.pseudoCopy, nil, @"Should return nil by default");
    STAssertEqualObjects(self.p2.pseudoAssign, nil, @"Should return nil by default");
    STAssertEquals(self.p2.pseudoBool, NO, @"should return NO by default");
    STAssertEquals(self.p2.pseudoInteger, 0l, @"Should return 0 by default");
    STAssertEquals(self.p2.pseudoUInteger, 0ul, @"should return 0 by default");
    STAssertEquals(self.p2.pseudoFloat, 0.0f, @"should return 0.0 by default");
    STAssertEquals(self.p2.pseudoDouble, 0.0, @"should return 0.0 by default");
    
    // Set property to nil
    
    originalDeallocated = NO;
    copyDeallocated = NO;
    
    @autoreleasepool {
        STAssertNoThrow(self.p1.pseudoRetain = nil, @"setting the value to nil should clear it and release it.");
    }
    
    STAssertEqualObjects(self.p1.pseudoRetain, nil, @"the property should now be equal to nil");
    STAssertTrue(originalDeallocated, @"We should have deallocated the o1 property");
    STAssertFalse(copyDeallocated, @"We shouldn't have deallocated a copy of o1 property");
    
//    STFail(@"Boo");
}

- (void)testAddExistingProperty
{
    FMSPseudoPropertyAdder addRetainedProperty = [Person FMS_generatePseudoPropertyAdderForType:FMSObjectRetain];
    STAssertThrows(addRetainedProperty(@"firstName"), @"The firstName and setFirstName methods already exist");
    STAssertThrows(addRetainedProperty(@"fullName"), @"The fullName method exists, setFullName does not");
    
//    STFail(@"Boo");

}

- (void)testAddingPropertiesToClassClusters
{
    
    STAssertNoThrow([NSString FMS_generatePseudoPropertyAdderForType:FMSObjectRetain](@"pseudoRetain"),
                    @"This should not throw any exceptions");

    STAssertNoThrow([NSDate FMS_generatePseudoPropertyAdderForType:FMSObjectRetain](@"pseudoRetain"),
                    @"This should not throw any exceptions");
    
    STAssertNoThrow([NSArray FMS_generatePseudoPropertyAdderForType:FMSObjectRetain](@"pseudoRetain"),
                    @"This should not throw any exceptions");

    
    // 3 x string, 2 x date, Array
    [self setObject:@"Static String" value:@1];
    [self setObject:[NSString stringWithFormat:@"Non Static String"] value:@2];
    [self setObject:[@"Mutable String" mutableCopy] value:@3];
    [self setObject:[NSDate dateWithTimeIntervalSince1970:0.0f] value:@4];
    [self setObject:[NSDate dateWithTimeIntervalSince1970:0.1f] value:@5];
    [self setObject:@[@"First", @"Second", @"Third"] value:@6];
    
//    STFail(@"Boo");
}

- (void)setObject:(id)obj value:(id)value {
    
    STAssertNoThrow([obj setPseudoRetain:value], @"This should not throw any exceptions");
    
    STAssertEqualObjects([obj pseudoRetain],
                         value,
                         @"pseudoRetain on %@ should return the value we set.",
                         [obj class]);
//    STFail(@"Ha!");
}

- (void)testAddingMultiplePropertiesWithOneAdder
{
    
    FMSPseudoPropertyAdder addRetainedProperty = [Person FMS_generatePseudoPropertyAdderForType:FMSObjectAssignUnsafe];
    addRetainedProperty(@"first");
    addRetainedProperty(@"second");
    addRetainedProperty(@"third");
    addRetainedProperty(@"fourth");
    
    self.p1.first = @"Hello";
    self.p1.second = @"How";
    self.p1.third = @"Are";
    self.p1.fourth = @"You";
    
    STAssertEqualObjects(self.p1.first, @"Hello", @"Should return the value we set");
    STAssertEqualObjects(self.p1.second, @"How", @"Should return the value we set");
    STAssertEqualObjects(self.p1.third, @"Are", @"Should return the value we set");
    STAssertEqualObjects(self.p1.fourth, @"You", @"Should return the value we set");


//    STFail(@"Boo");

}
                    
- (void)testAddingPropertyToRootClass
{
    [NSObject FMS_generatePseudoPropertyAdderForType:FMSObjectRetain](@"pseudoRetain");
    [self setObject:@"static string" value:@[@1, @2, @3]];
}

- (void)testPropertyNames
{
    FMSPseudoPropertyAdder adder = [NSString FMS_generatePseudoPropertyAdderForType:FMSObjectRetain];
    STAssertThrows(adder(@""), @"This should throw and exception");
    STAssertThrows(adder(nil), @"This should throw an exception");
    STAssertThrows(adder(@"CapitalFirstLetter"), @"This should throw an exception");
    STAssertThrows(adder(@"property with spaces"), @"This should throw an exception");
    STAssertThrows(adder(@"propertyWith#InvalidCharacters"), @"This should throw an exception");
    
    STAssertNoThrow(adder(@"aNameCanHave123numbers_and_underscores"), @"This should not throw an exception");
    
}


@end
