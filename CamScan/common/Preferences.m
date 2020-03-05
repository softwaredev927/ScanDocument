//
//  Preferences.m
//  PDFScanner
//
//  Created by Amit Kulkarni on 15/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "Preferences.h"

@implementation Preferences

#define KEY_DEFAULT_PROCESS @"KEY_DEFAULT_PROCESS"
#define KEY_PASSCODE_ENABLED @"KEY_PASSCODE_ENABLED"
#define KEY_PASSCODE @"KEY_PASSCODE"

#define KEY_OCR_APP_ID @"KEY_OCR_APP_ID"
#define KEY_OCR_PASSWORD @"KEY_OCR_PASSWORD"

static Preferences *instace;

//static NSString* MyApplicationID = @"Scanning App";
//static NSString* MyPassword = @"dXTsOFSUef96xP76tLQjCg2X";

+ (Preferences *)sharedInstance {
    if (!instace) {
        instace = [[Preferences alloc] init];
    }
    
    return instace;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //[defaults setValue:@"Scanning App" forKey:KEY_OCR_APP_ID];
        //[defaults setValue:@"dXTsOFSUef96xP76tLQjCg2X" forKey:KEY_OCR_PASSWORD];
        [defaults setValue:@"Scandex App" forKey:KEY_OCR_APP_ID];
        [defaults setValue:@"9AbxQTdPrXw0ivCrwR0LkTBd" forKey:KEY_OCR_PASSWORD];
        
        if ([defaults valueForKey:KEY_PASSCODE] == nil) {
            [self setPasscode:@"1234"];
        }
        
        if ([defaults boolForKey:KEY_PASSCODE_ENABLED] == nil) {
            [self setPassCodeEnabled:NO];
        }
        
        if ([defaults integerForKey:KEY_DEFAULT_PROCESS] == nil) {
            [self setDefaultProcess:@"Gray"];
        }
    }
    return self;
}

- (void)setDefaultProcess:(NSString *)defaultProcess {
    NSArray *options = @[@"Normal", @"B & W", @"Gray"];
    int index = 0;
    for (int i = 0; i < [options count]; i++) {
        NSString *str = [options objectAtIndex:i];
        if ([str isEqualToString:defaultProcess]) {
            index = i;
            break;
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:index forKey:KEY_DEFAULT_PROCESS];
    [defaults synchronize];
}

- (NSInteger)defaultProcessIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:KEY_DEFAULT_PROCESS];
}

- (NSString *)ocrAppId {
    return [[NSUserDefaults standardUserDefaults] valueForKey:KEY_OCR_APP_ID];
}

- (NSString *)ocrPassword {
    return [[NSUserDefaults standardUserDefaults] valueForKey:KEY_OCR_PASSWORD];
}


- (NSString *)defaultProcess {
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:KEY_DEFAULT_PROCESS];
    NSArray *options = @[@"Normal", @"B & W", @"Gray"];
    return [options objectAtIndex:index];
}

- (BOOL)passCodeEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:KEY_PASSCODE_ENABLED];
}

- (void)setPassCodeEnabled:(BOOL)passCodeEnabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:passCodeEnabled forKey:KEY_PASSCODE_ENABLED];
    [defaults synchronize];
}

- (NSString *)passcode {
    return [[NSUserDefaults standardUserDefaults] valueForKey:KEY_PASSCODE];
}

- (void)setPasscode:(NSString *)passcode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:passcode forKey:KEY_PASSCODE];
    [defaults synchronize];
}

@end
