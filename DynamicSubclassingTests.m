//
//  DynamicSubclassingTests.m
//  FMSSwizzler
//
//  Created by Rich Warren on 10/9/12.
//  Copyright (c) 2012 Rich Warren. All rights reserved.
//

#import "DynamicSubclassingTests.h"
#import "Person.h"
#import "NSObject+FMSSwizzler.h"

@interface NSObject(DynamicSubclassing)

- (void)oldSetFirstName:(NSString *)name;
- (void)anotherOldSetFirstName:(NSString *)name;
- (NSUInteger)oldCount;
- (NSUInteger)oldLength;
- (NSTimeInterval)oldTimeIntervalSinceDate:(NSDate *)date;

@end



@interface DynamicSubclassingTests()

@property (strong, nonatomic) Person *p1;
@property (strong, nonatomic) Person *p2;

@property (assign, nonatomic) BOOL b1;
@property (assign, nonatomic) BOOL b2;


@end



@implementation DynamicSubclassingTests


- (void)setUp
{
    [super setUp];
    
    self.p1 = [Person personWithFirstName:@"John" lastName:@"Smith" age:42];
    self.p2 = [Person personWithFirstName:@"Sara" lastName:@"Jones" age:35];

}

- (void)tearDown
{
    self.p1 = nil;
    self.p2 = nil;
    
    [super tearDown];
}

- (void)testBasicDynamicSubclassing {
    
    STAssertEqualObjects([self.p1 class], [self.p2 class], @"The classes should be equal");
    [self.p1 FMS_dynamiclySubclass];
    
    // p1 and p2 should now have different subclasses.
    STAssertFalse([[self.p1 class] isEqual:[self.p2 class]], @"The classes should now be not equal");
    
    // if we override a method, it should only affect p1.
    
    __block BOOL ourMethodCalled = NO;
    [[self.p1 class]
     FMS_overrideInstanceMethod:@selector(setFirstName:)
     oldSelector:@selector(oldSetFirstName:)
     implementationBlock:^(Person *_self, NSString *name){
         
         ourMethodCalled = YES;
         [_self oldSetFirstName:name];
         
     }];
    
    self.p1.firstName = @"Tom";
    
    STAssertTrue(ourMethodCalled, @"Our method should be called");
    STAssertEqualObjects(self.p1.firstName, @"Tom", @"The accessor should return the name we set.");
    
    ourMethodCalled = NO;
    
    self.p2.firstName = @"Jane";
   
    STAssertFalse(ourMethodCalled, @"Our method should not be called");
    STAssertEqualObjects(self.p2.firstName, @"Jane", @"However, the accessor should return the name we set.");
    
//    STFail(@"Finish writing test cases");
}

- (void)testDynamicSubclassingClassClusters {
    
    NSArray *array = @[@1, @2, @3, @4, @5, @6];
    
    STAssertNoThrow([array FMS_dynamiclySubclass], @"This should not throw an exception");
    __block BOOL ourMethodCalled = NO;
    
    [[array class]
     FMS_overrideInstanceMethod:@selector(count)
     oldSelector:@selector(oldCount)
     implementationBlock:^(NSArray *_self){
     
         ourMethodCalled = YES;
         return [_self oldCount];
     }];
    
    NSUInteger count = 0;
    STAssertNoThrow(count = [array count], @"This should not throw an exception");
    STAssertTrue(ourMethodCalled, @"Our count method should be called");
    STAssertEquals(count, (NSUInteger)6, @"Should still get the correct count value");
    
    NSString *staticString = @"Static String";
    STAssertNoThrow([staticString FMS_dynamiclySubclass], @"This should not throw an exception");
    ourMethodCalled = NO;
    
    [[staticString class]
     FMS_overrideInstanceMethod:@selector(length)
     oldSelector:@selector(oldLength)
     implementationBlock:^(NSArray *_self){
         
         ourMethodCalled = YES;
         return [_self oldLength];
     }];
    
    STAssertNoThrow(count = [staticString length], @"This should not throw an exception");
    STAssertTrue(ourMethodCalled, @"Our count method should be called");
    STAssertEquals(count, (NSUInteger)13, @"Should still get the correct count value");
    
    NSDate *regularDate = [NSDate dateWithTimeIntervalSince1970:0.1];
    STAssertNoThrow([regularDate FMS_dynamiclySubclass], @"This should not throw an exception");
    ourMethodCalled = NO;
    
    [[regularDate class]
     FMS_overrideInstanceMethod:@selector(timeIntervalSinceDate:)
     oldSelector:@selector(oldTimeIntervalSinceDate:)
     implementationBlock:^(NSDate *_self, NSDate *date){
         
         ourMethodCalled = YES;
         return [_self oldTimeIntervalSinceDate:date];
     }];
    
    NSTimeInterval interval;
    STAssertNoThrow(interval = [regularDate timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:100.0]],
                    @"This should not throw an exception");
    
    STAssertTrue(ourMethodCalled, @"Our method should be called");
    
    STAssertEqualsWithAccuracy(interval, (NSTimeInterval)-99.9, 0.001,
                               @"Should return the correct interval between dates");
    
    // Does not work with tagged pointers
    // This will produce a tagged pointer on OSX, but not on iOS
    NSDate *taggedDate = [NSDate dateWithTimeIntervalSince1970:0.0];
    NSUInteger pointer = taggedDate;
    
    if ((pointer & 1) == 1) {
        NSLog(@"*** Testing a tagged date ***");
        STAssertThrows([taggedDate FMS_dynamiclySubclass], @"This should throw an exception");
    }
    
//    STFail(@"Finish writing test cases");
}

- (void)testDynamicSubclassingAndKVO {
    
    // KVO before subclassing
    self.b1 = NO;
    [self.p1 addObserver:self
              forKeyPath:@"firstName"
                 options:NSKeyValueObservingOptionNew
                 context:NULL];
    
    self.p1.firstName = @"Sam";
    STAssertTrue(self.b1, @"The KVO notificaiton was fired");
    STAssertEqualObjects(self.p1.firstName, @"Sam", @"The accessor should return the value we just assigned.");
    
    [self.p1 FMS_dynamiclySubclass];
    __block BOOL ourMethodCalled = NO;
    self.b1 = NO;
    
    [[self.p1 class]
     FMS_overrideInstanceMethod:@selector(setFirstName:)
     oldSelector:@selector(oldSetFirstName:)
     implementationBlock:^(Person *_self, NSString *name) {
         
         ourMethodCalled = YES;
         [_self oldSetFirstName:name];
     }];
    
    STAssertNoThrow(self.p1.firstName = @"Robert", @"This should not cause any errors");
    STAssertTrue(ourMethodCalled, @"Our method was called");
    STAssertFalse(self.b1, @"The KVO notificaiton was NOT fired");
    STAssertEqualObjects(self.p1.firstName, @"Robert", @"The accessor should return the value we just assigned.");
    
    // subclassing before KVO
    
    [self.p2 FMS_dynamiclySubclass];
    
    [self.p2 addObserver:self
              forKeyPath:@"firstName"
                 options:NSKeyValueObservingOptionNew
                 context:NULL];
    
    
    ourMethodCalled = NO;
    self.b2 = NO;
    
    [[self.p2 class]
     FMS_overrideInstanceMethod:@selector(setFirstName:)
     oldSelector:@selector(oldSetFirstName:)
     implementationBlock:^(Person *_self, NSString *name) {
         
         ourMethodCalled = YES;
         [_self oldSetFirstName:name];
     }];
    
    STAssertNoThrow(self.p2.firstName = @"Robert", @"This should not cause any errors");
    STAssertTrue(ourMethodCalled, @"Our method was called");
    STAssertTrue(self.b2, @"The KVO notificaiton was fired");
    STAssertEqualObjects(self.p2.firstName, @"Robert", @"The accessor should return the value we just assigned.");
    
//    STFail(@"Finish writing test cases");
}

- (void)testNestedDynamicSubclasses {
    
    STAssertNoThrow([self.p1 FMS_dynamiclySubclass], @"This should not throw an exception.");
    
    __block BOOL oldestMethodFired = NO;
    
    [[self.p1 class]
     FMS_overrideInstanceMethod:@selector(setFirstName:)
     oldSelector:@selector(oldSetFirstName:)
     implementationBlock:^(Person *_self, NSString *name) {
     
         oldestMethodFired = YES;
         [_self oldSetFirstName:name];
     }];
    
    STAssertNoThrow([self.p1 FMS_dynamiclySubclass], @"This still should not throw an exception");
    
    __block BOOL oldMethodFired = NO;
    
    STAssertThrows(
                   [[self.p1 class]
                    FMS_overrideInstanceMethod:@selector(setFirstName:)
                    oldSelector:@selector(oldSetFirstName:)
                    implementationBlock:^(Person *_self, NSString *name) {
                        
                        oldMethodFired = YES;
                        [_self oldSetFirstName:name];
                    }],
                   @"Cannot reuse the same oldSelector");
    
    [[self.p1 class]
     FMS_overrideInstanceMethod:@selector(setFirstName:)
     oldSelector:@selector(anotherOldSetFirstName:)
     implementationBlock:^(Person *_self, NSString *name) {
         
         oldMethodFired = YES;
         [_self anotherOldSetFirstName:name];
     }];
    
    STAssertNoThrow(self.p1.firstName = @"Bill", @"This should not throw an exception");
    
    STAssertTrue(oldMethodFired, @"Our old method fired");
    STAssertTrue(oldestMethodFired, @"Our oldest method also fired");
    STAssertEqualObjects(self.p1.firstName, @"Bill", @"And the method is set as expected");
    
//    STFail(@"Finish writing test cases");

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
