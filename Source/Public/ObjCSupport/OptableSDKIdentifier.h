//
//  OptableSDKIdentifier.h
//  OptableSDK
//
//  Copyright © 2026 Optable Technologies, Inc. All rights reserved.
//

#ifndef OptableSDKIdentifier_h
#define OptableSDKIdentifier_h

#import <Foundation/Foundation.h>

//#import <OptableSDK/OptableSDKIdentifierType.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, OptableSDKIdentifierType) {
    OptableSDKIdentifierType_EmailAddress,
    OptableSDKIdentifierType_PhoneNumber,
    OptableSDKIdentifierType_PostalCode,

    OptableSDKIdentifierType_IPv4Address,
    OptableSDKIdentifierType_IPv6Address,

    OptableSDKIdentifierType_AppleIDFA,
    OptableSDKIdentifierType_GoogleGAID,
    OptableSDKIdentifierType_RokuRIDA,
    OptableSDKIdentifierType_SamsungTIFA,
    OptableSDKIdentifierType_AmazonFireAFAI,

    OptableSDKIdentifierType_NetID,
    OptableSDKIdentifierType_ID5,
    OptableSDKIdentifierType_UTIQ,

    OptableSDKIdentifierType_Custom,
    
    OptableSDKIdentifierType_OptableVID
};

@interface OptableSDKIdentifier : NSObject

@property (nonatomic, readonly) OptableSDKIdentifierType type;
@property (nonatomic, readonly, nullable) NSNumber *customIdx; // support of the custom ids ( c1, c2, c3 )
@property (nonatomic, readonly) NSString *value;

- (instancetype)init NS_UNAVAILABLE;

/// Designated initializer
- (instancetype)initWithType:(OptableSDKIdentifierType)type
                       value:(NSString *)value
                   customIdx:(nullable NSNumber *)customIdx
NS_DESIGNATED_INITIALIZER;

/// Convenience initializer using raw type string ("e", "c3", "id5", etc.)
- (nullable instancetype)initWithTypeRawValue:(NSString *)typeRawValue
                                        value:(NSString *)value;

/// Convenience factory method
+ (instancetype)identifierWithType:(OptableSDKIdentifierType)type
                             value:(NSString *)value;

/// Convenience factory method
+ (instancetype)identifierWithType:(OptableSDKIdentifierType)type
                             value:(NSString *)value
                         customIdx:(NSNumber *)customIdx;

/// Convenience factory method
+ (nullable instancetype)identifierWithRawType:(NSString *)raw
                                         value:(NSString *)value;

/// Convenience factory method
+ (nullable instancetype)identifierWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END

#endif /* OptableSDKIdentifier_h */
