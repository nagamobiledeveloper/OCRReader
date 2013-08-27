//
//  OCRReader.h
//  JPMC
//
//  Created by Seshu on 8/25/13.
//  Copyright (c) 2013 Nagaseshu Vadlapudi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCRReader : NSObject

- (id)initWithFile:(NSString *)fileName;
- (NSString *)readLine;
- (NSArray *)nextAccountArray;
- (NSArray *)nextAccountNumber;

+ (BOOL) isValidCheckSum:(NSArray *)accountNumber;
+ (NSString *)accountNumerToString:(NSArray *)accountNumber;
+ (BOOL)isILL:(NSArray *)accountNumber;
+ (NSArray *)fixByCheckSum:(NSArray *)accountNumber;
+ (BOOL)isSeparated:(int)firstNumber byOneSymbol:(int)secondNumber;
+ (NSArray *)findAmbiNumbers:(NSArray *)accountNumber;
+ (void)writeAllAccountNumbersToTextFile:(NSString *)accountNumberString;
+ (void)clearContentsOfFile;

@end
