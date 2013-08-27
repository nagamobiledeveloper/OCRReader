//
//  AppDelegate.m
//  JPMC
//
//  Created by Seshu on 8/23/13.
//  Copyright (c) 2013 Nagaseshu Vadlapudi. All rights reserved.
//

#import "AppDelegate.h"
#import "OCRReader.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    OCRReader *ocrReader = [[OCRReader alloc]initWithFile:@"decimal"];
    NSArray *accountNumberArray = [ocrReader nextAccountNumber];
    NSMutableString *writeAccountNumbers;
    
    //clears file contents before writing
    [OCRReader clearContentsOfFile];
    
    //loops through each accountNumber
    while (accountNumberArray)
    {
        //checks for valid checkSum
        if ([OCRReader isValidCheckSum:accountNumberArray])
        {
            //converts array to string and writes to file
            [OCRReader writeAllAccountNumbersToTextFile:[OCRReader accountNumerToString:accountNumberArray]];
        }else if([OCRReader isILL:accountNumberArray]) //checks for illegal characters
        {
            //fixes illegal character
            accountNumberArray = [OCRReader fixByCheckSum:accountNumberArray];
            //converts array to string and writes to file
            [OCRReader writeAllAccountNumbersToTextFile:[OCRReader accountNumerToString:accountNumberArray]];
        }else //checks for invalid checkSum
        {
            //finds the number/numbers with valid checkSum and only one difference
            NSArray *ambiArray = [OCRReader findAmbiNumbers:accountNumberArray];
            if([ambiArray count]==0)
            {
                //converts array to string and writes to file with ILL status
                writeAccountNumbers = [[NSMutableString alloc]initWithFormat:@"%@ ILL",[OCRReader accountNumerToString:accountNumberArray]];
                [OCRReader writeAllAccountNumbersToTextFile:writeAccountNumbers];
                writeAccountNumbers = nil;
            }else if ([ambiArray count]==1)
            {
                //converts array to string and writes to file
                [OCRReader writeAllAccountNumbersToTextFile:[OCRReader accountNumerToString:[ambiArray lastObject]]];
            }else
            {
                //converts array to string and writes to file with AMB status and
                //preferable matches
                writeAccountNumbers = [[NSMutableString alloc]initWithString:[OCRReader accountNumerToString:accountNumberArray]];
                NSMutableString *tempString = [[NSMutableString alloc]init];
                //loops through each array, converts array to string and writes to file
                for (NSArray *eachArray in ambiArray)
                {
                    [tempString appendFormat:@" %@ ", [OCRReader accountNumerToString:eachArray]];
                }
                [writeAccountNumbers appendFormat:@" AMB [%@]",tempString];
                [OCRReader writeAllAccountNumbersToTextFile:writeAccountNumbers];
                writeAccountNumbers = nil;
            }
        }
        //gets nextAccountNumber
        accountNumberArray = [ocrReader nextAccountNumber];
    }
    return YES;
}

@end
