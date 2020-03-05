//
//  Document.m
//  CamScan
//
//  Created by Amit Kulkarni on 22/07/16.
//  Copyright © 2016 Amit Kulkarni. All rights reserved.
//

#import "Document.h"

@implementation File

- (NSString *)originalPath {
    return [NSString pathWithComponents:@[NSHomeDirectory(), @"Documents", self.originalFile]];
}

- (NSString *)modifiedPath {
    return [NSString pathWithComponents:@[NSHomeDirectory(), @"Documents", self.modifiedFile]];
}

- (NSString *)thumbnailPath {
    return [NSString pathWithComponents:@[NSHomeDirectory(), @"Documents", self.thumbnailFile]];
}

@end

@implementation Document
@end
