//
//  MyTracer.m
//  Sample-Objective-C
//
//  Created by NooN on 18/9/23.
//

#import <Foundation/Foundation.h>
#import <UqudoSDK/UqudoSDK.h>

@implementation UQTracer

- (instancetype)init {
    self = [super init];
    if (self) {
        NSLog(@"Initiating UQTrace...");
    }
    
    return self;
}
- (void)trace:(UQTrace *)trace {

    NSString *documentTypeName = @"";
    if (trace.documentType != UNSPECIFY) {
        UQDocumentConfig *document = [[UQDocumentConfig alloc] initWithDocumentType:trace.documentType];
        documentTypeName = document.documentName;
    }
    
    NSString *timeStamp = [self timeStamp:trace.timestamp];
    
    NSLog(@"MyTrace(sessionId=%@, category=%@, event=%@, page=%@, status=%@, statusCode=%@, statusMessage=%@, documentType=%@, timestamp=%@)" , trace.sessionId, trace.category->name, trace.event->name, trace.page->name ,trace.status->name, trace.statusCode->name, trace.statusMessage, documentTypeName, timeStamp);
}


- (NSString *)timeStamp:(NSDate *)currentDate {
    return [NSDateFormatter localizedStringFromDate:currentDate
                                            dateStyle:NSDateFormatterFullStyle
                                            timeStyle:NSDateFormatterFullStyle];
}

@end

