// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>// You can redistribute it and/or modify it under the new BSD license.

#define INPUT_HISTORY_MAX	50

@implementation InputHistory

@synthesize buf;
@synthesize pos;
@synthesize lastHistoryItem;

- (id)init
{
	if ((self = [super init])) {
		buf = [NSMutableArray new];
	}
	
	return self;
}

- (void)dealloc
{
	[buf drain];
	[lastHistoryItem drain];
	
	[super dealloc];
}

- (void)add:(NSAttributedString *)s
{
	pos = buf.count;
	
	if (NSObjectIsEmpty(s)) return;
	if ([[[buf lastObject] string] isEqualToString:[s string]]) return;
	
	[buf addObject:s];
	
	if (buf.count > INPUT_HISTORY_MAX) {
		[buf safeRemoveObjectAtIndex:0];
	}
	
	pos = buf.count;
}

- (NSAttributedString *)up:(NSAttributedString *)s
{
	if (NSObjectIsNotEmpty(s)) {
		NSAttributedString *cur = nil;
		
		if (0 <= pos && pos < buf.count) {
			cur = [buf safeObjectAtIndex:pos];
		}
		
		if (NSObjectIsEmpty(cur) || [[cur string] isEqualToString:[s string]] == NO) {
			[buf addObject:s];
			
			if (buf.count > INPUT_HISTORY_MAX) {
				[buf safeRemoveObjectAtIndex:0];
				
				--pos;
			}
		}
	}
	
	--pos;
	
	if (pos < 0) {
		pos = 0;
		
		return nil;
	} else if (0 <= pos && pos < buf.count) {
		return [buf safeObjectAtIndex:pos];
	} else {
		return nil;
	}
}

- (NSAttributedString *)down:(NSAttributedString *)s
{
	if (NSObjectIsEmpty(s)) {
		pos = buf.count;
		
		return nil;
	}
	
	NSAttributedString *cur = nil;
	
	if (0 <= pos && pos < buf.count) {
		cur = [buf safeObjectAtIndex:pos];
	}

	if (NSObjectIsEmpty(cur) || [[cur string] isEqualToString:[s string]] == NO) {
		[self add:s];
		
		return nil;
	} else {
		++pos;
		
		if (0 <= pos && pos < buf.count) {
			return [buf safeObjectAtIndex:pos];
		}
		
		return nil;
	}
}

@end