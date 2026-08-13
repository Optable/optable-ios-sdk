//
//  OptableSDKIdentifier.m
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

#import "OptableSDKIdentifier.h"

@implementation OptableSDKIdentifier {
    OptableSDKIdentifierType _type;
    NSString *_value;
    NSNumber *_customIdx;
}

- (instancetype)initWithType:(OptableSDKIdentifierType)type
                        value:(NSString *)value
                    customIdx:(nullable NSNumber *)customIdx
{
    self = [super init];
    if (!self) return nil;

    _type = type;
    _value = [value copy];
    _customIdx = customIdx;

    return self;
}

- (nullable instancetype)initWithTypeRawValue:(NSString *)typeRawValue
                                        value:(NSString *)value
{
    if (typeRawValue.length == 0) return nil;

    OptableSDKIdentifierType type;
    NSNumber *customIdx = nil;

    if ([typeRawValue isEqual:@"e"]) type = OptableSDKIdentifierType_EmailAddress;
    else if ([typeRawValue isEqual:@"p"]) type = OptableSDKIdentifierType_PhoneNumber;
    else if ([typeRawValue isEqual:@"z"]) type = OptableSDKIdentifierType_PostalCode;
    else if ([typeRawValue isEqual:@"i4"]) type = OptableSDKIdentifierType_IPv4Address;
    else if ([typeRawValue isEqual:@"i6"]) type = OptableSDKIdentifierType_IPv6Address;
    else if ([typeRawValue isEqual:@"a"]) type = OptableSDKIdentifierType_AppleIDFA;
    else if ([typeRawValue isEqual:@"g"]) type = OptableSDKIdentifierType_GoogleGAID;
    else if ([typeRawValue isEqual:@"r"]) type = OptableSDKIdentifierType_RokuRIDA;
    else if ([typeRawValue isEqual:@"s"]) type = OptableSDKIdentifierType_SamsungTIFA;
    else if ([typeRawValue isEqual:@"f"]) type = OptableSDKIdentifierType_AmazonFireAFAI;
    else if ([typeRawValue isEqual:@"n"]) type = OptableSDKIdentifierType_NetID;
    else if ([typeRawValue isEqual:@"id5"]) type = OptableSDKIdentifierType_ID5;
    else if ([typeRawValue isEqual:@"utiq"]) type = OptableSDKIdentifierType_UTIQ;
    else if ([typeRawValue isEqual:@"v"]) type = OptableSDKIdentifierType_OptableVID;
    else if ([typeRawValue isEqual:@"c"]) {
        type = OptableSDKIdentifierType_Custom;
        customIdx = nil;
    } else if ([typeRawValue hasPrefix:@"c"]) {
        type = OptableSDKIdentifierType_Custom;
        
        NSString *suffix = [typeRawValue substringFromIndex:1];
        
        if (suffix.length == 0) return nil;
        
        NSCharacterSet *nonDigits =
        [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        
        if ([suffix rangeOfCharacterFromSet:nonDigits].location != NSNotFound) {
            return nil;
        }
        
        customIdx = @([suffix integerValue]);
    } else {
        return nil;
    }

    return [self initWithType:type value:value customIdx:customIdx];
}

/// Convenience factory method
+ (instancetype)identifierWithType:(OptableSDKIdentifierType)type
                             value:(NSString *)value
{
    return [[self alloc] initWithType:type
                                value:value
                            customIdx:nil];
}

/// Convenience factory method
+ (instancetype)identifierWithType:(OptableSDKIdentifierType)type
                             value:(NSString *)value
                         customIdx:(NSNumber *)customIdx
{
    return [[self alloc] initWithType:type
                                value:value
                            customIdx:customIdx];
}

/// Convenience factory method
+ (nullable instancetype)identifierWithRawType:(NSString *)typeRawValue
                                         value:(NSString *)value
{
    return [[self alloc] initWithTypeRawValue:typeRawValue
                                        value:value];
}

/// Convenience factory method
+ (nullable instancetype)identifierWithString:(NSString *)string
{
    if (string.length == 0) return nil;

    NSRange range = [string rangeOfString:@":"];
    if (range.location == NSNotFound) return nil;

    NSString *typeRaw = [string substringToIndex:range.location];
    NSString *value   = [string substringFromIndex:range.location + 1];

    return [[self alloc] initWithTypeRawValue:typeRaw value:value];
}

@end
