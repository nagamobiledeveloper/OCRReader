//
//  OCRReader.m
//  JPMC
//
//  Created by Seshu on 8/25/13.
//  Copyright (c) 2013 Nagaseshu Vadlapudi. All rights reserved.
//  This class will read all the acount numbers from decimal.txt file, checks for the validation of numbers and writes the processed account number to accounts.txt in the sandbox documents directory.

#import "OCRReader.h"

@interface OCRReader ()
{
    NSFileHandle *fileHandle;
    NSArray *lineArray;
    int currentLine;
}
@end
@implementation OCRReader
static NSArray *constArray;

#pragma mark - init
//
//init function with valid file name
//
- (id)initWithFile:(NSString *)fileName
{
    self = [super init];
    if (self)
    {
        //creating sample array with digits 0-9 for comparision
        constArray = @[
                         @[@0, @1, @0, @1, @0, @1, @1, @1, @1],//0
                         @[@0, @0, @0, @0, @0, @1, @0, @0, @1],//1
                         @[@0, @1, @0, @0, @1, @1, @1, @1, @0],//2
                         @[@0, @1, @0, @0, @1, @1, @0, @1, @1],//3
                         @[@0, @0, @0, @1, @1, @1, @0, @0, @1],//4
                         @[@0, @1, @0, @1, @1, @0, @0, @1, @1],//5
                         @[@0, @1, @0, @1, @1, @0, @1, @1, @1],//6
                         @[@0, @1, @0, @0, @0, @1, @0, @0, @1],//7
                         @[@0, @1, @0, @1, @1, @1, @1, @1, @1],//8
                         @[@0, @1, @0, @1, @1, @1, @0, @1, @1] //9
                    ];
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
        //checks for the invalid path and returns nil
        if (!path)
        {
            return nil;
        }
        fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
        NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        //separats each line using newline character and reeads in to array
        lineArray = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        currentLine=-1;
    }
    return self;
}

//
//Reads and returns each line from lineArray and returns nil
//if current line is greater than lineArray count
//
- (NSString *)readLine
{
    currentLine++;
    if(currentLine>=[lineArray count])
        return nil;
    
    return lineArray[currentLine];
}

//
//calls the readline function and breaks each line in to 9 arrays of 3 objects each
//till line count reaches 3, thus by parsing each entry and returns array of arrays
//identifying each digit
//
- (NSArray *)nextAccountArray
{
    int position=0, digit=0, line=0;
    NSMutableArray *accountNumber = [[NSMutableArray alloc]init];
    NSString *aLine = [self readLine];
    while (aLine)
    {
        NSMutableArray *digitArray;
        //checks for digit and adding correspoding array from accountNumber array
        //to digitArray array
        if(digit<[accountNumber count])
            digitArray = accountNumber[digit];
        else
        {
            digitArray = [[NSMutableArray alloc]init];
            [accountNumber addObject:digitArray];
        }
        for(int i=0; i<[aLine length];i++)
        {
            if (line<3)
            {
                //converts spaces in to 0's, pipes and underbars to 1's 
                if([aLine characterAtIndex:i] == ' ')
                    [digitArray addObject:@0];
                else
                    [digitArray addObject:@1];
                position++;
                //for every position%3, checks for digit and adding correspoding array
                //from accountNumber array to digitArray array
                if(position%3==0 && position<10)
                {
                    digit++;
                    if(digit<[accountNumber count])
                    {
                        digitArray = accountNumber[digit];
                    }else
                    {
                        digitArray = [[NSMutableArray alloc]init];
                        [accountNumber addObject:digitArray];
                    }
                    position = line*3;
                }
            }
        }
        line++;
        aLine = [self readLine];
        //for every third line returns accountNumber array and ignoring emptyline
        if(line==3)
            return [NSArray arrayWithArray:accountNumber];

        position=line*3;
        digit=0;
    }
    return nil;
}

//
//calls nextAccountArray and identifies each digit
//if current line is greater than lineArray count
//
- (NSArray *)nextAccountNumber
{
    NSArray *tempArray = [self nextAccountArray];
    //returns nil if tempArray is nil
    if (!tempArray)
    {
        return nil;
    }
    
    //loops through each array in temp array and checks for the equality
    //with the numbers in the constArray, adds "?" if it can't find any equality
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    for(NSArray *eachItemInAccountArray in tempArray)
    {
        int i=0;
        BOOL isMatched = NO;
        for (NSArray *numArray in constArray)
        {
            if([eachItemInAccountArray isEqualToArray:numArray])
            {
                [returnArray addObject:[NSNumber numberWithInt:i]];
                isMatched = YES;
                break;
            }
            i++;
        }
        //adds "?" in case of inEquality
        if(!isMatched && [returnArray count]<9)
        {
            [returnArray addObject:@"?"];
        }
    }
    return [NSArray arrayWithArray:returnArray];
}

#pragma mark - class methods
//
//checks if accountNumber has only 9 objects, illegal characters and calculates checksum
//
+ (BOOL) isValidCheckSum:(NSArray *)accountNumber
{
    if([accountNumber count]==9)
    {
        NSString *validateAccount = [OCRReader accountNumerToString:accountNumber];
        //checking if account number contains any illegal characters
        if ([validateAccount rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
        {
            return NO;
        }else
        {
            int checkSum = 0;
            int sum=9;
            //loops through each object and calculates checkSum
            for (int i=0; i<[accountNumber count]; i++)
            {
                checkSum += [[accountNumber objectAtIndex:i] integerValue]*sum;
                sum--;
            }
            //checks for a valid account number
            if (checkSum%11 == 0)
                return YES;
            else
                return NO;
        }
    }else
    {
        return NO;
    }
}

//
//converts accountNumber array to string and returns a string
//
+ (NSString *)accountNumerToString:(NSArray *)accountNumber
{
    NSMutableString *returnString = [[NSMutableString alloc]init];
    for (id item in accountNumber)
    {
        [returnString appendFormat:@"%@",item];
    }
    return [NSString stringWithString:returnString];
}

//
//checks for illegal characters in the accountNumber array and returns a BOOL
//
+ (BOOL)isILL:(NSArray *)accountNumber
{
    NSString *validateAccount = [OCRReader accountNumerToString:accountNumber];
    if ([validateAccount rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
    {
        return YES;
    }
    return NO;
}

//
//trys to find appropriate number for the illegal character and calculates checkSum
//returns fixed array for valid checksum otherwise returns the actual array
//
+ (NSArray *)fixByCheckSum:(NSArray *)accountNumber
{
    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:accountNumber];
    int index = [tempArray indexOfObject:@"?"];
    for (int i=0; i<10; i++)
    {
        [tempArray replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:i]];
        if ([self isValidCheckSum:tempArray])
        {
            return [NSArray arrayWithArray:tempArray];
        }
    }
    return accountNumber;
}

//
//compares with numbers from 0-9 from constArray and loops through to find only one
//difference between the digits and returns a BOOL
//
+ (BOOL)isSeparated:(int)firstNumber byOneSymbol:(int)secondNumber
{
    BOOL match = NO;
    NSArray *firstArray = [constArray objectAtIndex:firstNumber];
    NSArray *secondArray = [constArray objectAtIndex:secondNumber];
    for (int i=0; i<[firstArray count]; i++)
    {
        //compares each objects and returns YES if there is only one match
        if ([firstArray objectAtIndex:i] != [secondArray objectAtIndex:i])
        {
            if (match)
            {
                return NO;
            }
            match=YES;
        }
    }
    return match;
}

//
//loops through array that is has neithr illegal character nor valid checkSum
//to find the valid checkSum with only one difference in the digits between passed
//array and fixed array
//
+ (NSArray *)findAmbiNumbers:(NSArray *)accountNumber
{
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    for (int i=0; i<[accountNumber count]; i++)
    {
        //replaces each digit with "?" and finds a valid checkSum
        NSMutableArray *aArray = [[NSMutableArray alloc]initWithArray:accountNumber];
        [aArray replaceObjectAtIndex:i withObject:@"?"];
        NSArray *fixedArray = [OCRReader fixByCheckSum:aArray];
        if(![fixedArray isEqualToArray:aArray])
        {
            //is it better to do this check before or here?
            if ([OCRReader isSeparated:[[accountNumber objectAtIndex:i] integerValue] byOneSymbol:[[fixedArray objectAtIndex:i] integerValue]])
            {
                [tempArray addObject:fixedArray];
            }
        }
    }
    return tempArray;
}

//
//checks if file exists at path and creats if there isn't one. Writes each account number
//to the file
//
+ (void)writeAllAccountNumbersToTextFile:(NSString *)accountNumberString
{
    NSFileHandle *fileHandleForWriting;
    NSFileManager *fileManager;
    NSString *fullpath;
    
    NSString *writingString = [[NSString alloc]initWithFormat:@"%@\n", accountNumberString];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    fullpath = [[paths lastObject] stringByAppendingPathComponent:@"accounts.txt"];
    fileManager = [NSFileManager defaultManager];
    [fileManager changeCurrentDirectoryPath:fullpath];
    
    //checks if file exists, if not creats a file
    BOOL fileExists = [fileManager fileExistsAtPath:fullpath];
    if(!fileExists)
    {
        [fileManager createFileAtPath:fullpath contents:nil attributes:nil];
    }
    
    fileHandleForWriting = [NSFileHandle fileHandleForWritingAtPath:fullpath];
    [fileHandleForWriting seekToEndOfFile];
    [fileHandleForWriting writeData:[writingString dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandleForWriting closeFile];
}

//
//clears the contents of the file before writing to it at
//application didFinishLauchingWithOptions
//
+ (void)clearContentsOfFile
{
    NSFileHandle *fileHandleForClearing;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths lastObject] stringByAppendingPathComponent:@"accounts.txt"];
    fileHandleForClearing = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    
    //checks if fileExists at path
    if (fileHandleForClearing != nil)
    {
        [fileHandleForClearing truncateFileAtOffset: 0];
        [fileHandleForClearing closeFile];
    }
    
}

@end
