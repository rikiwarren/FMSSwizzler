//
//  OverrideMethodTests.m
//  FMSSwizzler
//
//  Created by Rich Warren on 10/9/12.
//  Copyright (c) 2012 Rich Warren. All rights reserved.
//

#import "OverrideMethodTests.h"
#import "Person.h"
#import "NSObject+FMSSwizzler.h"
#import <objc/runtime.h>

typedef void (^restoreMethodBlock) (void);

@interface NSObject(DynamicMethods)

- (void)oldSetFirstName:(NSString *)name;
- (void)oldSetFirstName2:(NSString *)name;
- (id)oldPersonWithFirstName:(NSString *)firstName lastName:(NSString *)lastName age:(NSUInteger)age;
- (NSUInteger)oldCount;
- (NSUInteger)oldCount2;

@end

@interface OverrideMethodTests()

@property (strong, nonatomic) Person *p1;
@property (strong, nonatomic) Person *p2;

@property (strong, nonatomic) restoreMethodBlock restoreSetFirstNameBlock;

@property (assign, nonatomic) BOOL b1;
@property (assign, nonatomic) BOOL b2;

@end


@implementation OverrideMethodTests

- (restoreMethodBlock)createRestoreBlockForClass:(Class)class selector:(SEL)selector {
    
    Method method = class_getInstanceMethod(class, selector);
    const char *argumentTypeEncoding = method_getTypeEncoding(method);
    IMP oldImp = method_getImplementation(method);
    
    return ^{
        class_replaceMethod(class, selector, oldImp, argumentTypeEncoding);
    };
}

- (void)setUp
{
    [super setUp];
    
    self.p1 = [Person personWithFirstName:@"John" lastName:@"Smith" age:42];
    self.p2 = [Person personWithFirstName:@"Sara" lastName:@"Jones" age:35];
    
    // Save the setFirstName: IMP
    self.restoreSetFirstNameBlock =
    [self createRestoreBlockForClass:[Person class] selector:@selector(setFirstName:)];
}

- (void)tearDown
{
    if (self.restoreSetFirstNameBlock != nil) {
        self.restoreSetFirstNameBlock();
    }
    
    self.p1 = nil;
    self.p2 = nil;
    
    [super tearDown];
}

- (void)testBasicInstanceMethodOverride {
    
    __block BOOL ourMethodCalled = NO;
    STAssertNoThrow([Person FMS_overrideInstanceMethod:@selector(setFirstName:)
                                           oldSelector:@selector(oldSetFirstName:)
                                   implementationBlock:^(Person *_self, NSString *name){
                                       
                                       // Do our custom task.
                                       ourMethodCalled = YES;
                                       
                                       // Then call the original method.
                                       [_self oldSetFirstName: name];
                                       
                                       
                                   }], @"This shouldn't cause any errors");
    
    STAssertNoThrow(self.p1.firstName = @"Batman", @"This shouldn't cause any errors");

    STAssertEquals(ourMethodCalled, YES, @"Our custom method is called.");
    STAssertEqualObjects(self.p1.firstName, @"Batman", @"And the underlying data is still changed.");
    
//    STFail(@"Finish writing test cases");
}

- (void)testBasicClassMethodOverride {
    
    restoreMethodBlock restoreConvenianceMethod =
    [self createRestoreBlockForClass:object_getClass([Person class])
                            selector:@selector(personWithFirstName:lastName:age:)];
    
    __block BOOL ourPersonWithNameCalled = NO;
    [[Person class] FMS_overrideClassMethod:@selector(personWithFirstName:lastName:age:)
                                oldSelector:@selector(oldPersonWithFirstName:lastName:age:)
                        implementationBlock:^(id _self, NSString *firstName, NSString *lastName, NSUInteger age){
                        
                        ourPersonWithNameCalled = YES;
                        return [_self oldPersonWithFirstName:firstName lastName:lastName age:age];
                        
                    }];
    
    Person *p;
    
    STAssertNoThrow(p = [Person personWithFirstName:@"Timmy" lastName:@"Thompson" age:10],
                    @"This should not have any errors");
    
    STAssertEquals(ourPersonWithNameCalled, YES, @"Our custom method was called");
    STAssertEqualObjects(p.firstName, @"Timmy", @"The original class method was also called");

    
    restoreConvenianceMethod();
    ourPersonWithNameCalled = NO;
    p = [Person personWithFirstName:@"Tess" lastName:@"Ty" age:13];
    STAssertEqualObjects(p.firstName, @"Tess", @"The original class method works");
    STAssertFalse(ourPersonWithNameCalled, @"But our custom method was not called");
    
//    STFail(@"Finish writing test cases");
}

- (void)testWithClassClusters {
    
    NSArray *array = @[@1, @2, @3, @4, @5];
    
    restoreMethodBlock restoreCount = [self createRestoreBlockForClass:[NSArray class] selector:@selector(count)];
    
    __block BOOL ourCountCalled = NO;
    STAssertNoThrow([NSArray FMS_overrideInstanceMethod:@selector(count)
                                            oldSelector:@selector(oldCount)
                                    implementationBlock:^(NSArray *_self){
                                    
                                        ourCountCalled = YES;
                                        return [_self oldCount];
                                    
                                    }],
                    @"This shouldn't have any errors");
    
    NSUInteger count;
    STAssertNoThrow(count = [array count], @"This should not cause any errors");
    STAssertFalse(ourCountCalled, @"Our count method is not called.");
    STAssertEquals(count, (NSUInteger)5, @"But the original count implementation is still called");
    
    
    restoreCount();
    ourCountCalled = NO;
    
    restoreCount = [self createRestoreBlockForClass:[array class] selector:@selector(count)];
    
    STAssertNoThrow([[array class] FMS_overrideInstanceMethod:@selector(count)
                                            oldSelector:@selector(oldCount2)
                                    implementationBlock:^(NSArray *_self){
                                        
                                        ourCountCalled = YES;
                                        return [_self oldCount2];
                                        
                                    }],
                    @"This shouldn't have any errors");
    
    STAssertNoThrow(count = [array count], @"This should not cause any errors");
    STAssertTrue(ourCountCalled, @"Our count method is also called.");
    STAssertEquals(count, (NSUInteger)5, @"But the original count implementation is still called");
    
    restoreCount();
    ourCountCalled = NO;
    
    // Everything's back to normal
    STAssertNoThrow(count = [array count], @"This should not cause any errors");
    STAssertFalse(ourCountCalled, @"Our count method is not called.");
    STAssertEquals(count, (NSUInteger)5, @"And the original count implementation is still called");
    
//    STFail(@"Finish writing test cases");
}

- (void)testWithKVO {
    
    // Start observing p1
    [self.p1 addObserver:self forKeyPath:@"firstName" options:NSKeyValueObservingOptionNew context:NULL];
    
    // Replace Method
    __block BOOL ourMethodCalled = NO;
    self.b1 = NO;
    self.b2 = NO;
    
    STAssertNoThrow([Person FMS_overrideInstanceMethod:@selector(setFirstName:)
                                           oldSelector:@selector(oldSetFirstName2:)
                                   implementationBlock:^(Person *_self, NSString *name){
                                   
                                       ourMethodCalled = YES;
                                       return [_self oldSetFirstName2:name];
                                       
                                   }],
                    @"This should not have any errors");
    
    // Alias can be used to bypass KVO
    STAssertNoThrow([self.p1 setFirstName:@"Pinkey"],
                    @"This also should not have any errors");
    
    STAssertEquals(ourMethodCalled, YES, @"We've called our version of the method.");
    STAssertEqualObjects(self.p1.firstName, @"Pinkey", @"The first name variable was changed");
    STAssertEquals(self.b1, YES, @"And the KVO notification is still called");
    
    ourMethodCalled = NO;
    STAssertNoThrow([self.p2 setFirstName:@"The Brain"],
                    @"This also should not have any errors");
    
    STAssertEquals(ourMethodCalled, YES, @"We've called our version of the method.");
    STAssertEqualObjects(self.p2.firstName, @"The Brain", @"The first name variable also changed.");
    STAssertEquals(self.b2, NO, @"However, we are not listening to p2 yet.");
    
    // Add Observer for p2
    [self.p2 addObserver:self forKeyPath:@"firstName" options:NSKeyValueObservingOptionNew context:NULL];
    
    ourMethodCalled = NO;
    self.b1 = NO;
    self.b2 = NO;
    
    STAssertNoThrow([self.p1 setFirstName:@"Ernie"],
                    @"This also should not have any errors");
    
    STAssertEquals(ourMethodCalled, YES, @"We've called our version of the method.");
    STAssertEqualObjects(self.p1.firstName, @"Ernie", @"The first name variable also changed");
    STAssertEquals(self.b1, YES, @"And the KVO notification is still called");
    
    STAssertNoThrow([self.p2 setFirstName:@"Bert"],
                    @"This also should not have any errors");
    
    STAssertEquals(ourMethodCalled, YES, @"We've called our version of the method.");
    STAssertEqualObjects(self.p2.firstName, @"Bert", @"The first name variable also changed");
    STAssertEquals(self.b2, YES, @"And the KVO notification is still called.");
    
//    STFail(@"Finish writing test cases");
}

- (void)testSelectorsHaveDifferentArgumentCounts {
    
    STAssertThrows([Person FMS_overrideInstanceMethod:@selector(setFirstName:)
                                          oldSelector:@selector(oldsetFirstName)
                                  implementationBlock:^(Person *_self, NSString *name){
                                  
                                      return [_self oldSetFirstName:name];
                                  
                                  }],
                   @"This should throw an exception");
    
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
