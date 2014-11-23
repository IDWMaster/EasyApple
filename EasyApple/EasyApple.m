//
//  EasyApple.m
//  ChapterAdviser
//
//  Created by owner on 8/1/14.
//  Copyright (c) 2014 IDWNet Cloud Computing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EasyApple.h"
#import <objc/runtime.h>



#import "sqlite3.h"


id class_createInstanceOf(Class template) {
    
    Method ology = class_getClassMethod(template, NSSelectorFromString(@"alloc"));
    IMP pressive = method_getImplementation(ology);
    id val = ((id(*)(Class))pressive)(template);
    ology = class_getInstanceMethod(template, NSSelectorFromString(@"init"));
    pressive = method_getImplementation(ology);
    return ((id(*)(id,SEL))pressive)(val,NSSelectorFromString(@"init"));
}
Class property_getType(objc_property_t property) {
    
    
    unsigned int count;
    objc_property_attribute_t* list = property_copyAttributeList(property, &count);
    const char* val = list[0].value;
    NSString * rtname = [[[NSString alloc] initWithUTF8String:val+2] substringToIndex:strlen(val)-1-1];
    Class retval = NSClassFromString(rtname);
    free(list);
    return retval;
}

@implementation SQLTable
- (id) init {
    self = [super init];
    return self;
}
- (NSArray*)getIndexes {
    return [[NSArray alloc] initWithObjects:nil];
}
-(NSString*)primaryKey {
    return nil;
}
@end




static id internal_query_init(NSString* sql, SQLDatabase* db);

@implementation CompiledQuery
- (id) init {
    self = [super init];
    return self;
}
- (id) initWithSQL:(NSString *)sql boundDatabase:(SQLDatabase *)database {
    self = [super init];
    return internal_query_init(sql, database);
}
@end

enum PropertyType resolveType(const char* __restrict val) {
    if (strcmp(val, "d") == 0) {
        return Double;
    }else {
        if(strcmp(val, "@\"NSString\"") == 0) {
            return String;
        }else {
            if(strcmp(val, "i") == 0) {
                return Int32;
            }else {
                if(strcmp(val, "q") == 0) {
                    return Int64;
                }else {
                    if(strcmp(val, "@\"NSData\"") == 0) {
                        return Binary;
                    }
                }
            }
        }
    }
    return ForeignKey;
}
enum PropertyType property_resolveType(objc_property_t property) {
    unsigned int count;
    objc_property_attribute_t* list = property_copyAttributeList(property, &count);
    const char* val = list[0].value;
    enum PropertyType retval = resolveType(val);
    free(list);
    return retval;
}


@interface InternalCompiledQuery:CompiledQuery
@property sqlite3* db;
@property NSString* query;
@property sqlite3_stmt* compiled;
@end
@implementation SQLDatabase {
    sqlite3* db;
    NSDictionary* tables;
}
- (bool) attachQuery:(InternalCompiledQuery*)query {
    query.db = db;
    const char* tail;
    sqlite3_stmt* ptr = 0;
    sqlite3_prepare(db, query.query.UTF8String, (int)query.query.length, &ptr, &tail);
    if (ptr) {
        query.compiled = ptr;
        return true;
    }
    return false;
}
- (void) dropTable:(NSString*)name {
    CompiledQuery* query = [[CompiledQuery alloc] initWithSQL:@"DROP TABLE IF NOT EXISTS ?" boundDatabase:self];
    [query executeRaw:^bool(NSDictionary* sportinggoods){return true;},String,name,DBEnd];
    
}
- (void) attachTable:(Class)class {
    unsigned int count;
    objc_property_t* properties = class_copyPropertyList(class, &count);
    NSMutableString* creationQuery = [[NSMutableString alloc] initWithUTF8String:"CREATE TABLE IF NOT EXISTS "];
    [creationQuery appendString:[[NSString alloc] initWithUTF8String:class_getName(class)]];
    [creationQuery appendString:@" ("];
    size_t i = 0;
    size_t length = (size_t)count;
    for (i = 0; i<length; i++) {
        [creationQuery appendString:[[NSString alloc] initWithUTF8String:property_getName(properties[i])]];
        [creationQuery appendString:@" "];
        //TODO: Compute data type
        enum PropertyType type = property_resolveType(properties[i]);
        switch (type) {
            case Int32:
                [creationQuery appendString:@"INTEGER"];
                break;
            case Int64:
                [creationQuery appendString:@"INTEGER"];
                break;
            case Double:
                [creationQuery appendString:@"DOUBLE"];
                break;
            case String:
                [creationQuery appendString:@"TEXT"];
                break;
            case Binary:
                [creationQuery appendString:@"BLOB"];
                break;
            default:
                break;
        }
        
        if (i !=length-1) {
            [creationQuery appendString:@", "];
        }
    }
    [creationQuery appendString:@")"];
    char* err;
    sqlite3_exec(db, [creationQuery UTF8String], 0, 0, &err);
    //Get table schema
    //and perform migration (if necessary)
    CompiledQuery* query = [[CompiledQuery alloc] initWithSQL:@"PRAGMA table_info(?)" boundDatabase:self];
    NSMutableDictionary* missingColumns = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* extraColumns = [[NSMutableDictionary alloc] init];
    for (i = 0; i<length; i++) {
        missingColumns[[[NSString alloc] initWithUTF8String:property_getName(properties[i])]] = [[NSNumber alloc] initWithInt:property_resolveType(properties[i])];
    }
    [query executeRaw:^bool(NSDictionary* callback){
        if (missingColumns[callback[@"name"]]) {
            [missingColumns removeObjectForKey:callback[@"name"]];
            
        }else {
            extraColumns[callback[@"name"]] = callback[@"type"];
        }
        return true;
    },String,[[NSString alloc] initWithUTF8String:class_getName(class)],DBEnd];
    free(properties);
    NSUInteger dcount;
    id __unsafe_unretained keys[dcount];
    id __unsafe_unretained values[dcount];
    [missingColumns getObjects:values andKeys:keys];
    CompiledQuery* additionQuery = [[CompiledQuery alloc] initWithSQL:@"ALTER TABLE ? ADD ? ?" boundDatabase:self];
    for (size_t i = 0; i<dcount; i++) {
        //Alter the database to add this column
        NSString* colname = keys[i];
        NSNumber* nval = values[i];
        NSString* coltype = @"TEXT";
        enum PropertyType monopoly = ((NSNumber*)values[i]).intValue;
        switch (monopoly) {
            case Int32:
                coltype = @"INTEGER";
                break;
            case Int64:
                coltype = @"INTEGER";
                break;
            case Double:
                coltype = @"DOUBLE";
                break;
            case String:
                coltype = @"TEXT";
                break;
            case Binary:
                coltype = @"BLOB";
                break;
            default:
                break;
        }
        [additionQuery executeRaw:^bool(NSDictionary* vals){return true;},String,[[NSString alloc] initWithUTF8String:class_getName(class)],String,colname,String,coltype,DBEnd];
        
    }
}
- (id) initWithPath:(NSString *)path {
    self = [super init];
    sqlite3_open([path UTF8String], &db);
    tables = [[NSDictionary alloc] init];
    
    return self;
}
- (void) dealloc {
    sqlite3_close(db);
}

@end


@implementation InternalCompiledQuery
- (void) executeRaw:(bool (^)(NSDictionary *))callback, ... {
    {
        va_list args;
        va_start(args, callback);
        int i = 1;
        while (true) {
            enum PropertyType argType = va_arg(args, enum PropertyType);
            if (argType == DBEnd) {
                break;
            }
            switch (argType) {
                case Int32:
                {
                    sqlite3_bind_int(self.compiled, i,va_arg(args, int32_t));
                }
                    break;
                case Int64: {
                    sqlite3_bind_int64(self.compiled, i, va_arg(args, int64_t));
                }
                    break;
                case Double: {
                    sqlite3_bind_double(self.compiled, i, va_arg(args, double));
                }
                    break;
                case String: {
                    NSString* str = va_arg(args, NSString*);
                    sqlite3_bind_text(self.compiled, i, [str UTF8String], (int)str.length, 0);
                }
                    break;
                case ForeignKey: {
                    SQLTable* obj = va_arg(args, SQLTable*);
                    //TODO: Handle foreign key reference
                    //Get the primary key
                    NSString* pkey = [obj primaryKey];
                    objc_property_t property = class_getProperty([obj class], [pkey UTF8String]);
                    enum PropertyType ptype = property_resolveType(property);
                    switch (ptype) {
                        case Int32:
                        {
                            NSNumber* number = (NSNumber*)[obj valueForKey:pkey];
                            int32_t val = number.intValue;
                            sqlite3_bind_int(self.compiled, i, val);
                        }
                            break;
                        case Int64:
                        {
                            NSNumber* number = (NSNumber*)[obj valueForKey:pkey];
                            int64_t val = number.longValue;
                            sqlite3_bind_int64(self.compiled, i, val);
                        }
                            break;
                        case Double:
                        {
                            NSNumber* number = (NSNumber*)[obj valueForKey:pkey];
                            double val = number.doubleValue;
                            sqlite3_bind_double(self.compiled, i, val);
                        }
                            break;
                        case String:
                        {
                            NSString* string = (NSString*)[obj valueForKey:pkey];
                            sqlite3_bind_text(self.compiled, i, string.UTF8String, (int)string.length, 0);
                            
                        }
                            break;
                        default:
                            break;
                    }
                }
                default:
                    break;
            }
            i++;
        }
        va_end(args);
        
    }
    
    
    
    
    
    int val;
    while ((val = sqlite3_step(self.compiled)) != SQLITE_DONE) {
        if (val == SQLITE_ROW && callback != nil) {
            int colcount = sqlite3_column_count(self.compiled);
            NSMutableDictionary* mdict = [[NSMutableDictionary alloc] init];
            for (int i = 0; i<colcount; i++) {
                NSString* name = [[NSString alloc] initWithUTF8String:sqlite3_column_name(self.compiled, i)];
                switch (sqlite3_column_type(self.compiled, i)) {
                    case SQLITE_INTEGER:
                        mdict[name] = [[NSNumber alloc] initWithLong:sqlite3_column_int64(self.compiled, i)];
                        break;
                    case SQLITE_FLOAT:
                        mdict[name] = [[NSNumber alloc] initWithDouble:sqlite3_column_double(self.compiled, i)];
                        break;
                    case SQLITE_TEXT:
                        mdict[name] = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(self.compiled, i)];
                        break;
                    case SQLITE_BLOB:
                        mdict[name] = [[NSData alloc] initWithBytes:sqlite3_column_blob(self.compiled, i) length:sqlite3_column_bytes(self.compiled, i)];
                        break;
                    default:
                        break;
                }
            }
            if(!callback([[NSDictionary alloc] initWithDictionary:mdict copyItems:TRUE])) {
                break;
            }
            
        }
    }
    sqlite3_reset(self.compiled);
}


- (void) executeWithTemplate:(Class)template callbackFunction:(bool(^)(id))callback, ... {
    va_list args;
    va_start(args, callback);
    id val;
    int i = 1;
    while (true) {
        enum PropertyType argType = va_arg(args, enum PropertyType);
        if (argType == DBEnd) {
            break;
        }
        switch (argType) {
            case Int32:
            {
                sqlite3_bind_int(self.compiled, i,va_arg(args, int32_t));
            }
                break;
            case Int64: {
                sqlite3_bind_int64(self.compiled, i, va_arg(args, int64_t));
            }
                break;
            case Double: {
                sqlite3_bind_double(self.compiled, i, va_arg(args, double));
            }
                break;
            case String: {
                NSString* str = va_arg(args, NSString*);
                sqlite3_bind_text(self.compiled, i, [str UTF8String], (int)str.length, 0);
            }
                break;
            case ForeignKey: {
                SQLTable* obj = va_arg(args, SQLTable*);
                //TODO: Handle foreign key reference
                //Get the primary key
                NSString* pkey = [obj primaryKey];
                objc_property_t property = class_getProperty([obj class], [pkey UTF8String]);
                enum PropertyType ptype = property_resolveType(property);
                switch (ptype) {
                    case Int32:
                    {
                        NSNumber* number = (NSNumber*)[obj valueForKey:pkey];
                        int32_t val = number.intValue;
                        sqlite3_bind_int(self.compiled, i, val);
                    }
                        break;
                    case Int64:
                    {
                        NSNumber* number = (NSNumber*)[obj valueForKey:pkey];
                        int64_t val = number.longValue;
                        sqlite3_bind_int64(self.compiled, i, val);
                    }
                        break;
                    case Double:
                    {
                        NSNumber* number = (NSNumber*)[obj valueForKey:pkey];
                        double val = number.doubleValue;
                        sqlite3_bind_double(self.compiled, i, val);
                    }
                        break;
                    case String:
                    {
                        NSString* string = (NSString*)[obj valueForKey:pkey];
                        sqlite3_bind_text(self.compiled, i, string.UTF8String, (int)string.length, 0);
                        
                    }
                        break;
                    default:
                        break;
                }
            }
            default:
                break;
        }
        i++;
    }
    va_end(args);
    int status;
    //TODO: Execute query based on template and arguments
    while ((status = sqlite3_step(self.compiled)) != SQLITE_DONE) {
        if (status == SQLITE_ROW) {
            //We have a VERY HONORABLE ROW!
            //Set row values
            id row = class_createInstanceOf(template);
            int colcount = sqlite3_column_count(self.compiled);
            
            
            void(^assignIfValid)(int,SQLTable*) = ^(int column, SQLTable* instance) {
                Class ctemplate = [instance class];
                objc_property_t property = class_getProperty(ctemplate, sqlite3_column_name(self.compiled, column));
                if(property == nil) {
                    //TODO: Scan foreign keys
                    unsigned int count;
                    objc_property_t* properties = class_copyPropertyList(ctemplate, &count);
                    for (unsigned int i = 0; i<count; i++) {
                        if (property_resolveType(properties[i]) == ForeignKey) {
                            id webmd = class_createInstanceOf(property_getType(properties[i]));
                            assignIfValid(column,webmd);
                            [instance setValue:webmd forKey:[[NSString alloc] initWithUTF8String:property_getName(properties[i])]];
                        }
                    }
                    free(properties);
                }else {
                    //Column found! Get datatype
                    enum PropertyType type = property_resolveType(property);
                    switch (type) {
                        case Int32:
                            [instance setValue:[[NSNumber alloc] initWithInt:sqlite3_column_int(self.compiled, column)] forKey:[[NSString alloc] initWithUTF8String:property_getName(property)]];
                            break;
                        case Int64:
                            [instance setValue:[[NSNumber alloc] initWithLong:sqlite3_column_int64(self.compiled, column)] forKey:[[NSString alloc] initWithUTF8String:property_getName(property)]];
                            break;
                        case Double:
                            [instance setValue:[[NSNumber alloc] initWithDouble:sqlite3_column_double(self.compiled, column)] forKey:[[NSString alloc] initWithUTF8String:property_getName(property)]];
                            break;
                        case String:
                            [instance setValue:[[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(self.compiled, column)] forKey:[[NSString alloc] initWithUTF8String:property_getName(property)]];
                            break;
                        default:
                            break;
                    }
                }
            };
            for (int i = 0; i<colcount; i++) {
                //Find a column matching our specifications
                assignIfValid(i,row);
                
            }
            if(!callback(row)) {
                break;
            }
        }
    }
    sqlite3_reset(self.compiled);
}

- (id) initWithSQL:(NSString *)sql boundDatabase:(SQLDatabase *)database {
    self = [super init];
    self.query = sql;
    if([database attachQuery:self]) {
        return self;
    }
    return nil;
}
@end



static id internal_query_init(NSString* sql, SQLDatabase* db) {
    return [[InternalCompiledQuery alloc] initWithSQL:sql boundDatabase:db];
}



NSData* SerializeToJSON(id object) {
    //Get an array of keys (property names)
    unsigned int length;
    objc_property_t* properties = class_copyPropertyList([object class], &length);
    NSMutableArray* keys = [[NSMutableArray alloc] init];
    NSMutableArray* values = [[NSMutableArray alloc] init];
    for(unsigned int i = 0;i<length;i++) {
        const char* name = property_getName(properties[i]);
        [keys addObject:[[NSString alloc] initWithUTF8String:name]];
        id value = [object valueForKey:[[NSString alloc] initWithUTF8String:name]];
        [values addObject:value];
    }
    free(properties);
    NSError* err;
    return [NSJSONSerialization dataWithJSONObject:[[NSDictionary alloc] initWithObjects:values forKeys:keys] options:NSJSONWritingPrettyPrinted error:&err];
}
NSString* sessionID;
NSString* GetRealPath(const char* filename) {
    NSString* path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[[NSString alloc] initWithUTF8String:filename]];
    return path;
}
FILE* OpenOrCreateFile(const char* filename) {
    NSString* rp = GetRealPath(filename);
    const char* realpath = rp.UTF8String;
    FILE* fptr = fopen(realpath, "r+b");
    if (fptr) {
        return fptr;
    }else {
        return fopen(realpath, "w+b");
    }
}



@implementation EasyViewController
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [[event allTouches] anyObject];
    
    if(![[touch view] isFirstResponder]) {
        [self.view endEditing:YES];
    }
    [super touchesBegan:touches withEvent:event];
    
}
@end