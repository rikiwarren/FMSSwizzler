//
//  ReplaceMethodTests.m
//  FMSSwizzler
//
//  Created by Rich Warren on 10/8/12.
//  Copyright (c) 2012 Rich Warren. All rights reserved.
//

#import "ReplaceMethodTests.h"
#import "Person.h"
#import "NSObject+FMSSwizzler.h"
#import <objc/runtime.h>

typedef void (^restoreMethodBlock) (void);

@interface ReplaceMethodTests ()

@property (strong, nonatomic) Person *p1;
@property (strong, nonatomic) Person *p2;

@property (strong, nonatomic) restoreMethodBlock restoreSetFirstNameBlock;

@property (assign, nonatomic) BOOL b1;
@property (assign, nonatomic) BOOL b2;

@end



@implementation ReplaceMethodTests

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
        self.restoreSetFirstNameBlock = nil;
    }
    
    self.p1 = nil;
    self.p2 = nil;
    
    [super tearDown];
}

- (void)restoreImplementionForSelector:(SEL)selector {
}

- (void)testReplaceMethodBasics {
    
    // Sanity Checks
    STAssertEqualObjects(self.p1.firstName, @"John", @"This is the value at startup");
    STAssertNoThrow(self.p1.firstName = @"Bob", @"This should work fine");
    STAssertEqualObjects(self.p1.firstName, @"Bob", @"Returns the value we assigned");

    
    __block BOOL setFirstNameCalled = NO;
    
    STAssertNoThrow([Person FMS_replaceInstanceMethod:@selector(setFirstName:)
                              withImplementationBlock:^(Person  *_self, NSString *name){
                              
                                  setFirstNameCalled = YES;
                                  
                              }],
                    @"This shouldn't cause any errors.");
    
    STAssertEquals(setFirstNameCalled, NO, @"Our block has not run yet.");
    STAssertNoThrow([self.p1 setFirstName:@"Timmy"], @"This should work fine.");
    STAssertEquals(setFirstNameCalled, YES, @"Our block should have run.");
    STAssertEqualObjects(self.p1.firstName, @"Bob", @"And the name has not changed.");
    
//    STFail(@"Finish writing test cases");

}

- (void)testWrongNumberOfArguments {
    
    // Sanity Checks
    STAssertEqualObjects(self.p1.firstName, @"John", @"This is the value at startup");
    STAssertNoThrow(self.p1.firstName = @"Bob", @"This should work fine");
    STAssertEqualObjects(self.p1.firstName, @"Bob", @"Returns the value we assigned");
    
    __block BOOL setFirstNameCalled = NO;
    
    STAssertNoThrow([Person FMS_replaceInstanceMethod:@selector(setFirstName:)
                              withImplementationBlock:^(Person *_self){
                                  
                                  setFirstNameCalled = YES;
                                  
                              }],
                    
                    @"Our block does not have enough arguments.");
    
    
    STAssertEquals(setFirstNameCalled, NO, @"Our block has not run yet.");
    STAssertNoThrow([self.p1 setFirstName:@"Timmy"], @"Our block doesn't have enough arguments, yet doesn't crash.");
    STAssertEquals(setFirstNameCalled, YES, @"However our block still runs fine.");
    
    
    // These tests cause an EXC_BAD_ACCESS when trying to replace the method. No exception thrown, just crashes.
    
//    setFirstNameCalled = NO;
//    STAssertThrows([Person FMS_replaceInstanceMethod:@selector(setFirstName:)
//                              withImplementationBlock:^(Person *_self, NSString *name, NSString *extra){
//                                  
//                                  setFirstNameCalled = YES;
//                                  
//                              }],
//                    
//                    @"Our block has too many arguments.");
//    
//    
//    STAssertEquals(setFirstNameCalled, NO, @"Our block has not run yet.");
//    STAssertThrows([self.p1 setFirstName:@"Timmy"], @"Our block has too many arguments...crashes.");
//    STAssertEquals(setFirstNameCalled, NO, @"And our block still has not run.");
    
//    STFail(@"Finish writing test cases");
}

- (void)testOnClassClusters {
    
    NSArray *array = @[@1, @2, @3];
    
    
    // *** Trying on the Class Cluster ***
    restoreMethodBlock restoreCount =
    [self createRestoreBlockForClass:[NSArray class] selector:@selector(count)];
    
    STAssertEquals([array count], (NSUInteger)3, @"This is the default behavior for count");
    
    __block BOOL newCountMethodCalled = NO;
    [NSArray FMS_replaceInstanceMethod:@selector(count) withImplementationBlock:^(NSArray *_self) {
       
        newCountMethodCalled = YES;
        return 0;
        
    }];
    
    STAssertEquals([array count], (NSUInteger)3, @"We still get the original value");
    STAssertFalse(newCountMethodCalled, @"Our new count method was NOT called");
    
    restoreCount();
    
    // *** Trying on the concrete hidden subclass ***
    
    restoreCount =
    [self createRestoreBlockForClass:[array class] selector:@selector(count)];
    
    STAssertEquals([array count], (NSUInteger)3, @"This still works...");
    
    newCountMethodCalled = NO;
    [[array class] FMS_replaceInstanceMethod:@selector(count) withImplementationBlock:^(id _self) {
        
        newCountMethodCalled = YES;
        return 0;
        
    }];
    
    
    STAssertEquals([array count], (NSUInteger)0, @"We get the new return value");
    STAssertTrue(newCountMethodCalled, @"Our new count method was called");
    
    restoreCount();
    
//    STFail(@"Finish writing test cases");
}

- (void)testReplacingSuperclassMethod {
    
    restoreMethodBlock restoreDescription =
    [self createRestoreBlockForClass:[Person class]
                            selector:@selector(description)];
    
    // Sanity Check
    STAssertNotNil([self.p1 description], @"This should be the default implementation");
    
    __block BOOL ourDescriptionCalled = NO;
    [[Person class] FMS_replaceInstanceMethod:@selector(description)
                      withImplementationBlock:^(id _self) {
                      
                          ourDescriptionCalled = YES;
                          return nil;
                          
                      }];
    
    STAssertNil([self.p1 description], @"Should use our new return value.");
    STAssertTrue(ourDescriptionCalled, @"And our description has been called");
    
    restoreDescription();
    
//    STFail(@"Finish writing test cases");
}

- (void)testReplaceClassMethod {
    
    restoreMethodBlock restoreConvenianceMethod =
    [self createRestoreBlockForClass:object_getClass([Person class])
                            selector:@selector(personWithFirstName:lastName:age:)];
    
    __block BOOL ourPersonWithNameCalled = NO;
    [[Person class] FMS_replaceClassMethod:@selector(personWithFirstName:lastName:age:)
                   withImplementationBlock:^(id _self, NSString *firstName, NSString *lastName, NSUInteger age){
                   
                       ourPersonWithNameCalled = YES;
                       return nil;
                   
                   }];
    
    STAssertNil([Person personWithFirstName:@"John" lastName:@"Doe" age:31], @"Our new method returns nil");
    STAssertTrue(ourPersonWithNameCalled, @"Our method was called");
    
    restoreConvenianceMethod();
    Person *p = [Person personWithFirstName:@"Tess" lastName:@"Ty" age:13];
    STAssertEqualObjects(p.firstName, @"Tess", @"The original class method still works");
    
//    STFail(@"Finish writing test cases");
}

- (void)testReplacementsAndKVO {
    
    // Start observing p1
    [self.p1 addObserver:self forKeyPath:@"firstName" options:NSKeyValueObservingOptionNew context:NULL];
    
    // Replace Method
    __block BOOL ourMethodCalled = NO;
    self.b1 = NO;
    self.b2 = NO;
    
    STAssertNoThrow([Person FMS_replaceInstanceMethod:@selector(setFirstName:)
                              withImplementationBlock:^(Person *_self, NSString *name) {
                                  ourMethodCalled = YES;
                              }],
                    @"This should not have any errors");
    
    // Alias can be used to bypass KVO
    STAssertNoThrow([self.p1 setFirstName:@"Pinkey"],
                    @"This also should not have any errors");
    
    STAssertEquals(ourMethodCalled, YES, @"We've called our version of the method.");
    STAssertEqualObjects(self.p1.firstName, @"John", @"The first name variable did not change");
    STAssertEquals(self.b1, YES, @"However, the KVO notification is still called");
    ourMethodCalled = NO;
    
    STAssertNoThrow([self.p2 setFirstName:@"The Brain"],
                    @"This also should not have any errors");
    
    STAssertEquals(ourMethodCalled, YES, @"We've called our version of the method.");
    STAssertEqualObjects(self.p2.firstName, @"Sara", @"The first name variable did not change");
    STAssertEquals(self.b2, NO, @"We are not listening to p2 yet.");
    
    // Add Observer for p2
    [self.p2 addObserver:self forKeyPath:@"firstName" options:NSKeyValueObservingOptionNew context:NULL];
    
    ourMethodCalled = NO;
    self.b1 = NO;
    self.b2 = NO;
    
    STAssertNoThrow([self.p1 setFirstName:@"Ernie"],
                    @"This also should not have any errors");
    
    STAssertEquals(ourMethodCalled, YES, @"We've called our version of the method.");
    STAssertEqualObjects(self.p1.firstName, @"John", @"The first name variable did not change");
    STAssertEquals(self.b1, YES, @"However, the KVO notification is still called");
    
    STAssertNoThrow([self.p2 setFirstName:@"Bert"],
                    @"This also should not have any errors");
    
    STAssertEquals(ourMethodCalled, YES, @"We've called our version of the method.");
    STAssertEqualObjects(self.p2.firstName, @"Sara", @"The first name variable did not change");
    STAssertEquals(self.b2, YES, @"However, the KVO notification is still called.");
    
    [self.p1 removeObserver:self forKeyPath:@"firstName"];
    [self.p2 removeObserver:self forKeyPath:@"firstName"];
    
    
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
