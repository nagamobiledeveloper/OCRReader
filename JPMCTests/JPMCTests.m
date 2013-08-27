//
//  JPMCTests.m
//  JPMCTests
//
//  Created by Seshu on 8/23/13.
//  Copyright (c) 2013 Nagaseshu Vadlapudi. All rights reserved.
//

#import "JPMCTests.h"
#import "OCRReader.h"

@implementation JPMCTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    NSArray *temArray1 = @[@3, @4, @5, @8, @8, @2, @8, @6, @5];
    NSArray *temArray2 = @[@3, @9, @0, @8, @6, @7, @7, @1, @5];
    NSArray *temArray2a = @[@3, @9, @0, @8, @6, @7, @7, @1, @5, @3];
    NSArray *temArray2b = @[@3, @9, @0, @8, @6, @7, @7, @1,];
    NSArray *temArray3 = @[@4, @9, @0, @8, @6, @7, @7, @1, @5];
    NSArray *temArray3a = @[@"?", @9, @0, @8, @6, @7, @7, @1, @5];
    NSArray *temArray4 = @[@4, @"?", @0, @8, @6, @7, @7, @1, @5];
    NSArray *temArray5 = @[@3, @3, @3, @3, @3, @3, @3, @3, @3];
    NSArray *temArray6 = @[@[@3, @3, @3, @3, @9, @3, @3, @3, @3]];
    NSArray *temArray7 = @[@1, @1, @1, @1, @1, @1, @1, @1, @1];
    NSArray *temArray7a = @[@"?", @1, @1, @1, @1, @1, @1, @1, @1];
    NSArray *temArray8 = @[@[@7, @1, @1, @1, @1, @1, @1, @1, @1]];
    NSArray *temArray8a = @[@7, @1, @1, @1, @1, @1, @1, @1, @1];
    NSArray *temArray9 = @[@5, @5, @5, @5, @5, @5, @5, @5, @5];
    NSArray *temArray10 = @[@[@5, @5, @9, @5, @5, @5, @5, @5, @5],
                            @[@5, @5, @5, @6, @5, @5, @5, @5, @5]
                            ];
    
    //*************************************************************
    //[OCRReader initWithFile:filename]
    //possible outcomes nil or instance of OCRReader
    //*************************************************************
    //
    //verifying for nil incase of invalid file
    OCRReader *ocr = [[OCRReader alloc]initWithFile:@"decimal1"];
    STAssertNil(ocr, @"Test failed found invalid file");
    
    //verifying not nil incase of valid file
    OCRReader *ocrTest = [[OCRReader alloc]initWithFile:@"decimal"];
    STAssertNotNil(ocrTest, @"Test failed for valid file");
    
    //*************************************************************
    //[ocrTest readLine]
    //possible outcomes nil or not nil
    //*************************************************************
    //
    //checking not nil
    STAssertNotNil([ocrTest readLine], @"readLine failed");
    
    //*************************************************************
    //[ocrTest nextAccountArray]
    //possible outcomes array of arrays
    //*************************************************************
    //
    //checking for not nil
    STAssertNotNil([ocrTest nextAccountArray], @"test case for entry failed");
    
    //*************************************************************
    //[OCRReader isValidCheckSum]
    //returns true for valid checkSum
    //possible inputs: valid checkSum, invalid checkSum, special characters,
    //array's with more or less than 9 digits
    //*************************************************************
    //
    //checking for True or False
    STAssertTrue([OCRReader isValidCheckSum:temArray1], @"Checksum Validation failed");
    STAssertFalse([OCRReader isValidCheckSum:temArray2], @"Checksum validation failed");
    STAssertFalse([OCRReader isValidCheckSum:temArray2a], @"Checksum validation failed");
    STAssertFalse([OCRReader isValidCheckSum:temArray2b], @"Checksum validation failed");
    STAssertTrue([OCRReader isValidCheckSum:temArray3], @"Checksum validation failed");
    STAssertFalse([OCRReader isValidCheckSum:temArray4], @"Checksum validation failed");
    STAssertFalse([OCRReader isValidCheckSum:temArray5], @"Checksum validation failed");
    STAssertFalse([OCRReader isValidCheckSum:temArray7], @"Checksum validation failed");
    STAssertFalse([OCRReader isValidCheckSum:temArray9], @"Checksum validation failed");
    
    //*************************************************************
    //[OCRReader isValidCheckSum]
    //retuns a string object
    //possible inputs: valid checkSum, invalid checkSum, special characters,
    //array's with more or less than 9 digits
    //*************************************************************
    //
    //checking for euality
    STAssertEqualObjects(@"345882865", [OCRReader accountNumerToString:temArray1], @"Convert to string failed");
    STAssertEqualObjects(@"390867715", [OCRReader accountNumerToString:temArray2], @"Convert to string failed");
    STAssertEqualObjects(@"490867715", [OCRReader accountNumerToString:temArray3], @"Convert to string failed");
    STAssertEqualObjects(@"4?0867715", [OCRReader accountNumerToString:temArray4], @"Convert to string failed");
    STAssertEqualObjects(@"3908677153", [OCRReader accountNumerToString:temArray2a], @"Convert to string failed");
    
    //*************************************************************
    //[OCRReader isILL]
    //retuns True if array has a special character
    //*************************************************************
    //
    //checking for True and False
    STAssertFalse([OCRReader isILL:temArray1], @"isILL failed");
    STAssertFalse([OCRReader isILL:temArray2], @"isILL failed");
    STAssertFalse([OCRReader isILL:temArray3], @"isILL failed");
    STAssertTrue([OCRReader isILL:temArray3a], @"isILL failed");
    STAssertTrue([OCRReader isILL:temArray4], @"isILL failed");
    
    //*************************************************************
    //[OCRReader fixByCheckSum]
    //retuns array fixed array with valid checkSum 
    //*************************************************************
    //
    //checking for equality
    STAssertEqualObjects(temArray3, [OCRReader fixByCheckSum:temArray4], @"FixByCheckSum failed");
    STAssertEqualObjects(temArray8a, [OCRReader fixByCheckSum:temArray7a], @"FixByCheckSum failed");
    
    //*************************************************************
    //[OCRReader fixByCheckSum]
    //retuns True if separated by one pipe
    //*************************************************************
    //
    //checking for True and False
    STAssertTrue([OCRReader isSeparated:0 byOneSymbol:8], @"isSeperated failed");
    STAssertFalse([OCRReader isSeparated:2 byOneSymbol:1], @"isSeperated failed");
    STAssertTrue([OCRReader isSeparated:1 byOneSymbol:7], @"isSeperated failed");
    
    
    //*************************************************************
    //[OCRReader fixByCheckSum]
    //retuns array of objects/object according to the according to numer of matches
    //
    //*************************************************************
    //
    //checking for equality
    STAssertEqualObjects(temArray6, [OCRReader findAmbiNumbers:temArray5], @"FixByCheckSum failed");
    STAssertEqualObjects(temArray8, [OCRReader findAmbiNumbers:temArray7], @"FixByCheckSum failed");    
    STAssertEqualObjects(temArray10, [OCRReader findAmbiNumbers:temArray9], @"FixByCheckSum failed");
    

    
    //*************************************************************
    //[OCRReader writeAllAccountNumbersToTextFile]
    //
    //*************************************************************
    //
    //writing string to file
    [OCRReader writeAllAccountNumbersToTextFile:@"222222222"];
    [OCRReader writeAllAccountNumbersToTextFile:[OCRReader accountNumerToString:temArray1]];
    [OCRReader writeAllAccountNumbersToTextFile:[OCRReader accountNumerToString:temArray2]];
    [OCRReader writeAllAccountNumbersToTextFile:[OCRReader accountNumerToString:temArray3]];
    [OCRReader writeAllAccountNumbersToTextFile:[OCRReader accountNumerToString:temArray4]];
    [OCRReader writeAllAccountNumbersToTextFile:[OCRReader accountNumerToString:temArray2a]];
    
    //*************************************************************
    //[OCRReader clearContentsOfFile]
    //
    //*************************************************************
    //
    //clearing contents of file if file exists
    [OCRReader clearContentsOfFile];
    
    
}

@end
