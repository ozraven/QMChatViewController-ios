//
//  QMChatDataSource.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 8/10/16.
//
//

#import "QMChatDataSource.h"

@interface QMChatDataSource()

@property (strong, nonatomic, readwrite) NSMutableArray *messages;

@end

@implementation QMChatDataSource

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _messages = [NSMutableArray array];
        _timeIntervalBetweenMessages = 300.0f; // default time interval
    }
    
    return self;
}


- (NSInteger)messagesCount {
    
    return self.messages.count;
}

- (void)addMessage:(QBChatMessage *)message {
    [self addMessages:@[message]];
}
- (void)addMessages:(NSArray<QBChatMessage *> *)messages {
    
    NSMutableArray *itemsIndexPaths = [NSMutableArray arrayWithCapacity:messages.count];
   
    
    for (QBChatMessage *message in messages) {
        
        NSAssert(message.dateSent != nil, @"Message must have dateSent!");
        
        if ([self messageExists:message]) {
            // message already exists
            continue;
        }
        
        NSInteger messageIndex = NSNotFound;
        messageIndex = [self insertMessage:message];
        if (messageIndex != NSNotFound) {
        [itemsIndexPaths addObject:[NSIndexPath indexPathForItem:messageIndex
                                                       inSection:0]];
        }
    }
    
    if (itemsIndexPaths.count && [self.delegate respondsToSelector:@selector(chatDataSource:didInsertItems:animated:)]) {
        [self.delegate chatDataSource:self didInsertItems:itemsIndexPaths animated:YES];
    }
}

- (NSUInteger)insertMessage:(QBChatMessage *)message {
    
    NSUInteger index = [self indexThatConformsToMessage:message];
    [self.messages insertObject:message atIndex:index];
    
    return index;
}

- (QBChatMessage *)messageForIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item == NSNotFound) {
        return nil;
    }

    return self.messages[indexPath.item];
}


- (BOOL)messageExists:(QBChatMessage *)message {
    
    return [self.messages containsObject:message];
}

- (NSUInteger)indexThatConformsToMessage:(QBChatMessage *)message {
    
    NSUInteger index = self.messages.count;
    NSArray *messages = self.messages.copy;
    
    for (QBChatMessage *message_t in messages) {
        
        NSComparisonResult dateSentComparison = [message.dateSent compare:message_t.dateSent];
        
        if ((dateSentComparison == NSOrderedDescending)
            // if date of messages is same compare them by their IDs
            // to determine whether message should be upper or lower in message stack
            // if messages IDs are same - return same index
            || (dateSentComparison == NSOrderedSame && [message.ID compare:message_t.ID] != NSOrderedAscending)) {
            
            index = [messages indexOfObject:message_t];
            break;
        }
    }
    
    return index;
}

- (NSIndexPath *)indexPathForMessage:(QBChatMessage *)message {
    
    NSIndexPath *indexPath = nil;
    
    if ([self.messages containsObject:message]) {
        
        indexPath = [NSIndexPath indexPathForItem:[self.messages indexOfObject:message] inSection:0];
        
    }
    return indexPath;
}

@end
