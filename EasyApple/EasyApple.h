//
//  EasyApple.h
//  ChapterAdviser
//
//  Created by owner on 8/1/14.
//  Copyright (c) 2014 IDWNet Cloud Computing. All rights reserved.
//

#ifndef ChapterAdviser_EasyApple_h
#define ChapterAdviser_EasyApple_h

#ifdef __cplusplus
#else
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

enum PropertyType {
    Int32, Int64, Double, String, Binary, ForeignKey, DBEnd
};

@interface WebRequest : NSObject<NSURLConnectionDataDelegate>
- (id) initWithRequest:(NSString*)url postData:(NSData*)data;
@end
NSData* SerializeToJSON(id object);
extern NSString* sessionID;
FILE* OpenOrCreateFile(const char* filename);
NSString* GetRealPath(const char* filename);
@interface SQLDatabase : NSObject
- (id) initWithPath:(NSString*)path;
- (void) attachTable:(Class)class;
@end
@interface CompiledQuery : NSObject
- (id) initWithSQL:(NSString*)sql boundDatabase:(SQLDatabase*)database;
- (void) executeWithTemplate:(Class)template callbackFunction:(bool(^)(id))callback, ...;
- (void) executeRaw:(bool(^)(NSDictionary*))callback, ...;
@end


@interface SQLTable : NSObject
- (NSArray*) getIndexes;
- (NSString*) primaryKey;
@end


@interface EasyViewController : UIViewController
@end


#endif

#endif
