//
//  AliasTests.m
//  FMSSwizzler
//
//  Created by Rich Warren on 10/8/12.
//  Copyright (c) 2012 Rich Warren. All rights reserved.
//

#import "AliasInstanceMethodTests.h"
#import "Person.h"
#import "NSObject+FMSSwizzler.h"

@interface NSObject(AliasTests)

@property (strong, nonatomic) NSString *firstNameAlias;

- (void)setFirstNameObserved:(NSString *)name;

- (NSString*)descriptionAlias;

- (NSUInteger)lengthAlias;
- (NSUInteger)lengthAlias2;
- (NSUInteger)lengthAlias3;

- (NSUInteger)countAlias;
- (NSUInteger)countAlias2;

- (NSTimeInterval)timeIntervalSinceDateAlias:(NSDate *)anotherDate;
- (NSTimeInterval)timeIntervalSinceDateAlias2:(NSDate *)anotherDate;
- (NSTimeInterval)timeIntervalSinceDateAlias3:(NSDate *)anotherDate;

+ (id)aliasOfPersonWithFirstName:(NSString *)firstName lastName:(NSString *)lastName age:(NSUInteger)age;

@end


@interface AliasInstanceMethodTests()

@property (strong, nonatomic) Person *p1;
@property (strong, nonatomic) Person *p2;
@property (assign, nonatomic) BOOL b1;
@property (assign, nonatomic) BOOL b2;

@end

@implementation AliasInstanceMethodTests

- (void)setUp
{
    [super setUp];
    
    self.p1 = [Person personWithFirstName:@"John" lastName:@"Smith" age:42];
    self.p2 = [Person personWithFirstName:@"Sara" lastName:@"Jones" age:35];

    self.b1 = NO;
    self.b2 = NO;
    
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
    
    self.p1 = nil;
    self.p2 = nil;

}


- (void)testMethodDefinedInClass {
    
    // Sanity Check
    STAssertNoThrow(self.p1.firstName = @"Tim", @"The setFirstName: method exists and shouldn't throw an exception.");
    STAssertThrows(self.p1.firstNameAlias = @"Jim", @"This method should not be defined yet.");
    STAssertEqualObjects(self.p1.firstName, @"Tim", @"We should get the result that we set.");
    
    STAssertNoThrow([Person FMS_aliasInstanceMethod:@selector(firstName)
                                        newSelector:@selector(firstNameAlias)],
                    @"This should not throw any exceptions");
    
    STAssertNoThrow([Person FMS_aliasInstanceMethod:@selector(setFirstName:)
                                        newSelector:@selector(setFirstNameAlias:)],
                    @"This should not throw any exceptions");
    
    STAssertThrows([Person FMS_aliasInstanceMethod:@selector(firstName)
                                       newSelector:@selector(fullName)],
                   @"This should throw an exception. We're creating an alias that already exists.");
    
    
    STAssertNoThrow(self.p1.firstNameAlias = @"Larry", @"This should change the first name");
    STAssertEqualObjects(self.p1.firstName, @"Larry", @"We should get back the value we set.");
    STAssertEqualObjects(self.p1.firstName, self.p1.firstNameAlias, @"Both accessors should return the same value.");
    STAssertEquals(self.p1.firstName, self.p1.firstNameAlias, @"They should also point to the same instance.");
    
    STAssertNoThrow(self.p1.firstName = @"Jo", @"This should change the first name");
    STAssertEqualObjects(self.p1.firstNameAlias, @"Jo", @"We should get back the value we set.");
    STAssertEqualObjects(self.p1.firstName, self.p1.firstNameAlias, @"Both accessors should return the same value.");
    STAssertEquals(self.p1.firstName, self.p1.firstNameAlias, @"They should also point to the same instance.");
    
    // works on both objects
    STAssertNoThrow(self.p2.firstNameAlias = @"Cathy", @"This method should now exist and shouldn't cause errors.");
    STAssertEqualObjects(self.p2.firstNameAlias, @"Cathy", @"we should get back what we turned in");
    STAssertEqualObjects(self.p2.firstNameAlias, self.p2.firstName, @"Both versions should return the same value");
    
//    STFail(@"Finish writing test cases");
}

- (void)testMethodDefinedInAncestor {
    
    STAssertNoThrow([Person FMS_aliasInstanceMethod:@selector(description)
                                         newSelector:@selector(descriptionAlias)],
                    @"This should not throw any exceptions");
    
    STAssertNotNil([self.p1 descriptionAlias], @"The alias should return a valid number.");
    STAssertEqualObjects([self.p1 description], [self.p1 descriptionAlias],
                         @"Both methods should return the same value");
    
    STAssertNotNil([self.p2 descriptionAlias], @"The alias should return a valid number.");
    STAssertEqualObjects([self.p2 description], [self.p2 descriptionAlias],
                         @"Both methods should return the same value");
    
//    STFail(@"Finish writing test cases");
}

- (void)testMethodNotDefined {
    
    STAssertThrows([Person FMS_aliasInstanceMethod:@selector(count)
                                       newSelector:@selector(countAlias)],
                   @"This should throw an exception");
    
//    STFail(@"Finish writing test cases");
}

- (void)testAliasingCoreFoundationAndClassClusters {
    
    NSString *staticString = @"Static String";
    NSString *regularString = [NSString stringWithFormat:@"Regular String"];
    NSString *mutableString = [@"Mutable String" mutableCopy];
        
    NSDate *taggedDatePointer = [NSDate dateWithTimeIntervalSince1970:0.0];
    NSDate *regularDate = [NSDate dateWithTimeIntervalSince1970:0.1];
    
    NSArray *array = @[@1, @2, @3, @4];
    
    // *** NSString *** ///
    STAssertNoThrow([NSString FMS_aliasInstanceMethod:@selector(length)
                                          newSelector:@selector(lengthAlias)],
                    @"This should not cause any errors");
    
    STAssertNoThrow([[staticString class] FMS_aliasInstanceMethod:@selector(length)
                                                      newSelector:@selector(lengthAlias2)],
                    @"This should not cause any errors");
    
    // there are some dangers to using FMS_Alias on class clusters...
    STAssertThrows([staticString lengthAlias],
                   @"We created the alias on the abstract super class, not the actual class. "
                   @"lengthAlias is now the alias of an abstract method that throws an exception when called.");
    
    STAssertEquals([staticString length], [staticString lengthAlias2],
                   @"Both alias's should return the same value");
    
    STAssertNoThrow([[regularString class] FMS_aliasInstanceMethod:@selector(length)
                                                       newSelector:@selector(lengthAlias2)],
                    @"This should not cause any errors");
    
    // there are some dangers to using FMS_Alias on class clusters...
    STAssertThrows([regularString lengthAlias],
                   @"We created the alias on the abstract super class, not the actual class. "
                   @"lengthAlias is now the alias of an abstract method that throws an exception when called.");
    
    STAssertNoThrow([[mutableString class] FMS_aliasInstanceMethod:@selector(length)
                                                       newSelector:@selector(lengthAlias3)],
                    @"This should not cause any errors");
    
    // there are some dangers to using FMS_Alias on class clusters...
    STAssertThrows([mutableString lengthAlias],
                   @"We created the alias on the abstract super class, not the actual class. "
                   @"lengthAlias is now the alias of an abstract method that throws an exception when called.");
    
    STAssertEquals([mutableString length], [mutableString lengthAlias3],
                   @"Both alias's should return the same value");
    
    // *** NSDate *** ///
    STAssertNoThrow([NSDate FMS_aliasInstanceMethod:@selector(timeIntervalSinceDate:)
                                        newSelector:@selector(timeIntervalSindeDateAlias:)],
                    @"This should work fine.");
    
    STAssertNoThrow([[taggedDatePointer class] FMS_aliasInstanceMethod:@selector(timeIntervalSinceDate:)
                                                           newSelector:@selector(timeIntervalSinceDateAlias2:)],
                    @"This should work fine.");
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:20.0];
    STAssertEquals([taggedDatePointer timeIntervalSinceDate:date], -20.0, @"This is the hand-calcualted answer");
    
    // again, aliasing the class cluster doesn't work...we end up with an alias of an abstract method.
    STAssertThrows([taggedDatePointer timeIntervalSinceDateAlias:date],
                   @"These should be equal");
    
    // But aliasing the actual class does.
    STAssertEquals([taggedDatePointer timeIntervalSinceDate:date],
                   [taggedDatePointer timeIntervalSinceDateAlias2:date],
                   @"These should also be equal");
    
    STAssertNoThrow([[regularDate class] FMS_aliasInstanceMethod:@selector(timeIntervalSinceDate:)
                                                           newSelector:@selector(timeIntervalSinceDateAlias3:)],
                    @"This should work fine.");
    
    STAssertEqualsWithAccuracy([regularDate timeIntervalSinceDate:date], -19.9, 0.001,
                               @"This is the hand-calcualted answer");
    
    // again, aliasing the class cluster doesn't work...we end up with an alias of an abstract method.
    STAssertThrows([regularDate timeIntervalSinceDateAlias:date],
                   @"This calles an unimplemented method on the abstract NSDate class");
    
    // But aliasing the actual class does.
    STAssertEquals([regularDate timeIntervalSinceDate:date],
                   [regularDate timeIntervalSinceDateAlias3:date],
                   @"These should also be equal");
    
    // *** NSArray *** ///
    STAssertNoThrow([NSArray FMS_aliasInstanceMethod:@selector(count)
                                          newSelector:@selector(countAlias)],
                    @"This should work fine");
    
    STAssertNoThrow([[array class] FMS_aliasInstanceMethod:@selector(count)
                                               newSelector:@selector(countAlias2)],
                    @"This should also work fine");
    
    // Sanity check
    STAssertEquals([array count], (NSUInteger)4, @"This is the hand-calculated answer");
    
    // again, aliasing the class cluster doesn't work...we end up with an alias of an abstract method.
    STAssertThrows([array countAlias], @"This calls an unimplemented method on the abstract NSArray class");
    
    // but aliasing on the actual class does work.
    STAssertEquals([array count], [array countAlias2], @"These should also be equal");
    
//    STFail(@"Finish writing test cases");
}

- (void)testAliasAndKVO {
    
    // Start observing p1
    [self.p1 addObserver:self forKeyPath:@"firstName" options:NSKeyValueObservingOptionNew context:NULL];
    
    // Alias Method
    STAssertNoThrow([Person FMS_aliasInstanceMethod:@selector(setFirstName:)
                                        newSelector:@selector(setFirstNameObserved:)],
                    @"This should not have any errors");
    
    // Alias can be used to bypass KVO
    STAssertNoThrow([self.p1 setFirstNameObserved:@"Pinkey"],
                    @"This also should not have any errors");
    
    STAssertNoThrow([self.p2 setFirstNameObserved:@"The Brain"],
                    @"This also should not have any errors");
    
    STAssertEqualObjects(self.p1.firstName, @"Pinkey", @"The alias should still work");
    STAssertEqualObjects(self.p2.firstName, @"The Brain", @"The alias should still work");
    
    STAssertEquals(self.b1, NO, @"We didn't use the KVO method, so we shouldn't detect the change.");
    STAssertEquals(self.b2, NO, @"We aren't observing p2 yet, so this shouldn't change");
    
    STAssertNoThrow([self.p1 setFirstName:@"Ernie"],
                    @"This also should not have any errors");
    
    STAssertNoThrow([self.p2 setFirstName:@"Bert"],
                    @"This also should not have any errors");
    
    STAssertEquals(self.b1, YES, @"We should trigger the change in p1's name");
    STAssertEquals(self.b2, NO, @"We aren't observing p2 yet, so this shouldn't change");
    
    // Add Observer for p2
    [self.p2 addObserver:self forKeyPath:@"firstName" options:NSKeyValueObservingOptionNew context:NULL];
    
    self.b1 = NO;
    self.b2 = NO;

    STAssertNoThrow([self.p1 setFirstNameObserved:@"Butch"],
                    @"This also should not have any errors");
    
    STAssertNoThrow([self.p2 setFirstNameObserved:@"Sundance"],
                    @"This also should not have any errors");
    
    STAssertEquals(self.b1, NO, @"We didn't use the KVO method, so we shouldn't detect the change.");
    STAssertEquals(self.b2, NO, @"We aren't observing p2 yet, so this shouldn't change");
    
    STAssertNoThrow([self.p1 setFirstName:@"Batman"],
                    @"This also should not have any errors");
    
    STAssertNoThrow([self.p2 setFirstName:@"Robin"],
                    @"This also should not have any errors");
    
    STAssertEquals(self.b1, YES, @"We should trigger the change in p1's name");
    STAssertEquals(self.b2, YES, @"We should trigger the change in p2's name");
    
    
//    STFail(@"Finish writing test cases");
}

- (void)testMethodsHaveDifferentNumbersOfArguments {
    
    STAssertThrows([Person FMS_aliasInstanceMethod:@selector(setFirstName:)
                                       newSelector:@selector(set:first:name:)],
                   @"The selectors must have the same number of arguments");
    
    
//    STFail(@"Finish writing test cases");
}

- (void)testAliasClassMethods {
    
    // Different number of arguments
    STAssertThrows([Person FMS_aliasClassMethod:@selector(personWithFirstName:lastName:age:)
                                    newSelector:@selector(personWithFirstName:lastName:)],
                   @"Should throw an exception; the selectors have a different number of arguments.");
    
    // Method doesn't exist
    STAssertThrows([Person FMS_aliasClassMethod:@selector(setFirstName:)
                                    newSelector:@selector(classAliasSetFirstName:)],
                   @"Should throw an exception; setFirstName: isn't a valid class method");
    
    
    // Alias already exists
    STAssertThrows([Person FMS_aliasClassMethod:@selector(class)
                                    newSelector:@selector(description)],
                   @"Should throw an exception; description already exists");
    
    STAssertNoThrow([Person FMS_aliasClassMethod:@selector(personWithFirstName:lastName:age:)
                                     newSelector:@selector(aliasOfPersonWithFirstName:lastName:age:)],
                    @"This should work fine");
    
    Person *p;
    STAssertNoThrow(p = [Person aliasOfPersonWithFirstName:@"Samantha"
                                                  lastName:@"Emmerson"
                                                       age:45],
                    @"This should also work fine");
    
    STAssertEqualObjects(p.firstName, @"Samantha", @"We should get the name we specified in the conveniance alias");
    STAssertEqualObjects(p.lastName, @"Emmerson", @"We should get the name we specified in the conveniance alias");
    STAssertEquals(p.age, (NSUInteger)45, @"We should get the age we specified in the conveniance alias");
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([object isEqual:self.p1]) {
        self.b1 = YES;
    }
    
    if ([object isEqual:self.p2]) {
        self.b2 = YES;
    }
    
}

@end
