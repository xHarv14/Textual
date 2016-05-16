/* ********************************************************************* 
                  _____         _               _
                 |_   _|____  _| |_ _   _  __ _| |
                   | |/ _ \ \/ / __| | | |/ _` | |
                   | |  __/>  <| |_| |_| | (_| | |
                   |_|\___/_/\_\\__|\__,_|\__,_|_|

 Copyright (c) 2010 - 2015 Codeux Software, LLC & respective contributors.
        Please see Acknowledgements.pdf for additional information.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Textual and/or "Codeux Software, LLC", nor the 
      names of its contributors may be used to endorse or promote products 
      derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 SUCH DAMAGE.

 *********************************************************************** */

#import "TPI_ChatFilterEditFilterSheet.h"

@interface TPI_ChatFilterEditFilterSheet ()
@property (nonatomic, copy) TPI_ChatFilter *filter;
@property (nonatomic, weak) IBOutlet NSTextField *filterMatchTextField;
@property (nonatomic, weak) IBOutlet NSTextField *filterSenderMatchTextField;
@property (nonatomic, weak) IBOutlet NSTextField *filterTitleTextField;
@property (nonatomic, weak) IBOutlet NSTextField *filterNotesTextField;
@property (nonatomic, weak) IBOutlet TVCTextFieldWithValueValidation *filterEventNumericTextField;
@property (nonatomic, weak) IBOutlet TVCTextFieldWithValueValidation *filterForwardToDestinationTextField;
@property (nonatomic, weak) IBOutlet TVCAutoExpandingTokenField *filterActionTokenField;
@property (nonatomic, weak) IBOutlet NSTokenField *filterActionTokenChannelName;
@property (nonatomic, weak) IBOutlet NSTokenField *filterActionTokenLocalNickname;
@property (nonatomic, weak) IBOutlet NSTokenField *filterActionTokenNetworkName;
@property (nonatomic, weak) IBOutlet NSTokenField *filterActionTokenOriginalMessage;
@property (nonatomic, weak) IBOutlet NSTokenField *filterActionTokenSenderAddress;
@property (nonatomic, weak) IBOutlet NSTokenField *filterActionTokenSenderHostmask;
@property (nonatomic, weak) IBOutlet NSTokenField *filterActionTokenSenderNickname;
@property (nonatomic, weak) IBOutlet NSTokenField *filterActionTokenSenderUsername;
@property (nonatomic, weak) IBOutlet NSTokenField *filterActionTokenServerAddress;
@property (nonatomic, weak) IBOutlet NSView *filterLimitedToTableHostView;
@property (nonatomic, weak) IBOutlet NSMatrix *filterLimitToMatrix;
@property (nonatomic, weak) IBOutlet NSButton *filterIgnoreContentCheck;
@property (nonatomic, weak) IBOutlet NSButton *filterIgnoresOperatorsCheck;
@property (nonatomic, weak) IBOutlet NSButton *filterLogMatchCheck;
@property (nonatomic, weak) IBOutlet NSButton *filterEventPlainTextMessageCheck;
@property (nonatomic, weak) IBOutlet NSButton *filterEventActionMessageCheck;
@property (nonatomic, weak) IBOutlet NSButton *filterEventNoticeMessageCheck;
@property (nonatomic, weak) IBOutlet NSButton *filterEventUserJoinedChannelCheck;
@property (nonatomic, weak) IBOutlet NSButton *filterEventUserLeftChannelCheck;
@property (nonatomic, weak) IBOutlet NSButton *filterEventUserKickedFromChannelCheck;
@property (nonatomic, weak) IBOutlet NSButton *filterEventUserDisconnectedCheck;
@property (nonatomic, weak) IBOutlet NSButton *filterEventUserChangedNicknameCheck;
@property (nonatomic, weak) IBOutlet NSButton *filterEventChannelTopicReceivedCheck;
@property (nonatomic, weak) IBOutlet NSButton *filterEventChannelTopicChangedCheck;
@property (nonatomic, weak) IBOutlet NSButton *filterEventChannelModeReceivedCheck;
@property (nonatomic, weak) IBOutlet NSButton *filterEventChannelModeChangedCheck;
@property (nonatomic, weak) IBOutlet NSButton *filterLimitedToMyselfCheck;
@property (nonatomic, weak) IBOutlet NSOutlineView *filterLimitToSelectionOutlineView;
@property (nonatomic, copy) NSArray *filterActionAutoCompletedTokens;
@property (nonatomic, strong) NSMutableArray *filterLimitedToClientsIDs;
@property (nonatomic, strong) NSMutableArray *filterLimitedToChannelsIDs;
@property (nonatomic, copy) NSArray *cachedClientList;
@property (nonatomic, copy) NSDictionary *cachedChannelList;

- (IBAction)viewFilterMatchHelpText:(id)sender;
- (IBAction)viewFilterActionHelpText:(id)sender;
- (IBAction)viewFilterSenderMatchHelpText:(id)sender;
- (IBAction)viewFilterForwardToDestinationHelpText:(id)sender;

- (IBAction)filteredLimitedToMatrixChanged:(id)sender;
- (IBAction)filterIgnoreContentCheckChanged:(id)sender;
- (IBAction)filterEventTypeChanged:(id)sender;
- (IBAction)filterLimitedToMyselfChanged:(id)sender;
@end

@interface TPI_ChatFilterFilterActionToken : NSObject
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy, readonly) NSString *tokenTitle;

+ (TPI_ChatFilterFilterActionToken *)tokenWithToken:(NSString *)token;
+ (TPI_ChatFilterFilterActionToken *)tokenWithTokenTitle:(NSString *)tokenTitle;

+ (NSArray *)tokens;
+ (NSArray *)tokenTitles;

+ (NSString *)titleForToken:(NSString *)token;

+ (BOOL)isToken:(NSString *)token;
@end

@interface TPI_ChatFilterLimitToTableCellView : NSTableCellView
@property (nonatomic, weak) TPI_ChatFilterEditFilterSheet *parentDialog;
@property (nonatomic, weak) IRCTreeItem *associatedItem;
@property (nonatomic, weak) IBOutlet NSButton *checkbox;

- (void)populateDefaults;
- (void)reloadCheckboxForChildren;

- (IBAction)checkboxToggled:(id)sender;
@end

@implementation TPI_ChatFilterEditFilterSheet

#pragma mark -
#pragma mark Primary Sheet Structure

- (instancetype)init
{
	if ((self = [super init])) {
		(void)[TPIBundleFromClass() loadNibNamed:@"TPI_ChatFilterEditFilterSheet" owner:self topLevelObjects:nil];
	}

	return self;
}

- (void)startWithFilter:(TPI_ChatFilter *)filter
{
	if (filter == nil) {
		self.filter = [TPI_ChatFilter new];
	} else {
		self.filter = filter;
	}

	[self addObserverForChannelListUpdates];

	[self populateTokenFieldStringValues];

	[self setupTextFieldRules];

	[self loadFilter];

	[self updateEnabledStateOfSenderMatch];
	[self updateEnabledStateOfFilterEvents];
	[self updateEnableStateOfFilterActionTokenField];
	[self updateEnabledStateOfComponentsConstrainedByFilterEvents];
	[self updateVisibilityOfLimitedToTableHostView];

	[self rebuildCachedChannelList];

	[self toggleOkButton];

	[self startSheet];
}

- (void)loadFilter
{
	[self.filterMatchTextField setStringValue:[self.filter filterMatch]];

	[self setTokens:[self.filter filterAction] inTokenField:self.filterActionTokenField];

	[self.filterTitleTextField setStringValue:[self.filter filterTitle]];
	[self.filterNotesTextField setStringValue:[self.filter filterNotes]];

	[self.filterSenderMatchTextField setStringValue:[self.filter filterSenderMatch]];

	[self.filterForwardToDestinationTextField setStringValue:[self.filter filterForwardToDestination]];

	[self.filterIgnoresOperatorsCheck setState:[self.filter filterIgnoresOperators]];

	[self.filterIgnoreContentCheck setState:[self.filter filterIgnoreContent]];

	[self.filterLogMatchCheck setState:[self.filter filterLogMatch]];

	[self.filterLimitedToMyselfCheck setState:[self.filter filterLimitedToMyself]];

	[self.filterEventPlainTextMessageCheck setState:[self.filter isEventTypeEnabled:TPI_ChatFilterPlainTextMessageEventType]];
	[self.filterEventActionMessageCheck setState:[self.filter isEventTypeEnabled:TPI_ChatFilterActionMessageEventType]];
	[self.filterEventNoticeMessageCheck setState:[self.filter isEventTypeEnabled:TPI_ChatFilterNoticeMessageEventType]];
	[self.filterEventUserJoinedChannelCheck setState:[self.filter isEventTypeEnabled:TPI_ChatFilterUserJoinedChannelEventType]];
	[self.filterEventUserLeftChannelCheck setState:[self.filter isEventTypeEnabled:TPI_ChatFilterUserLeftChannelEventType]];
	[self.filterEventUserKickedFromChannelCheck setState:[self.filter isEventTypeEnabled:TPI_ChatFilterUserKickedFromChannelEventType]];
	[self.filterEventUserDisconnectedCheck setState:[self.filter isEventTypeEnabled:TPI_ChatFilterUserDisconnectedEventType]];
	[self.filterEventUserChangedNicknameCheck setState:[self.filter isEventTypeEnabled:TPI_ChatFilterUserChangedNicknameEventType]];
	[self.filterEventChannelTopicReceivedCheck setState:[self.filter isEventTypeEnabled:TPI_ChatFilterChannelTopicReceivedEventType]];
	[self.filterEventChannelTopicChangedCheck setState:[self.filter isEventTypeEnabled:TPI_ChatFilterChannelTopicChangedEventType]];
	[self.filterEventChannelModeReceivedCheck setState:[self.filter isEventTypeEnabled:TPI_ChatFilterChannelModeReceivedEventType]];
	[self.filterEventChannelModeChangedCheck setState:[self.filter isEventTypeEnabled:TPI_ChatFilterChannelModeChangedEventType]];

	NSArray *filterEventsNumerics = [self.filter filterEventsNumerics];

	if (filterEventsNumerics) {
		NSString *filterEventsNumericsJoined = [filterEventsNumerics componentsJoinedByString:@", "];

		[self.filterEventNumericTextField setStringValue:filterEventsNumericsJoined];
	} else {
		[self.filterEventNumericTextField performValidation];
	}

	NSCell *filterLimitedToMatrixCell = [self.filterLimitToMatrix cellWithTag:[self.filter filterLimitedToValue]];

	[self.filterLimitToMatrix selectCell:filterLimitedToMatrixCell];

	NSArray *filterLimitedToClientsIDs = [self.filter filterLimitedToClientsIDs];
	NSArray *filterLimitedToChannelsIDs = [self.filter filterLimitedToChannelsIDs];

	if (filterLimitedToClientsIDs == nil) {
		self.filterLimitedToClientsIDs = [NSMutableArray array];
	} else {
		self.filterLimitedToClientsIDs = [filterLimitedToClientsIDs mutableCopy];
	}

	if (filterLimitedToChannelsIDs == nil) {
		self.filterLimitedToChannelsIDs = [NSMutableArray array];
	} else {
		self.filterLimitedToChannelsIDs = [filterLimitedToChannelsIDs mutableCopy];
	}
}

- (void)saveFilter
{
	[self.filter setFilterMatch:[self.filterMatchTextField stringValue]];

	NSString *filterActionStringValue = [self stringValueForTokenField:self.filterActionTokenField];;

	[self.filter setFilterAction:filterActionStringValue];

	[self.filter setFilterTitle:[self.filterTitleTextField stringValue]];
	[self.filter setFilterNotes:[self.filterNotesTextField stringValue]];

	[self.filter setFilterSenderMatch:[self.filterSenderMatchTextField stringValue]];

	[self.filter setFilterForwardToDestination:[self.filterForwardToDestinationTextField stringValue]];

	[self.filter setFilterIgnoresOperators:([self.filterIgnoresOperatorsCheck state] == NSOnState)];

	[self.filter setFilterIgnoreContent:([self.filterIgnoreContentCheck state] == NSOnState)];

	[self.filter setFilterLimitedToValue:[self.filterLimitToMatrix selectedTag]];

	[self.filter setFilterLogMatch:([self.filterLogMatchCheck state] == NSOnState)];

	[self.filter setFilterLimitedToMyself:([self.filterLimitedToMyselfCheck state] == NSOnState)];

	[self.filter setFilterEvents:[self compileFilterEvents]];

	[self.filter setFilterEventsNumerics:[self compileFilterEventsNumerics]];

	[self.filter setFilterLimitedToClientsIDs:self.filterLimitedToClientsIDs];
	[self.filter setFilterLimitedToChannelsIDs:self.filterLimitedToChannelsIDs];
}

- (NSArray *)compileFilterEventsNumerics
{
	NSString *numericsString = [self.filterEventNumericTextField value];

	NSArray *numericsArray = [numericsString componentsSeparatedByString:@","];

	NSMutableArray *filterEventsNumerics = nil; // Create later so we don't waste memory if error.

	for (NSString *numeric in numericsArray) {
		NSString *numericTrimmed = [numeric trim];

		if ([numericTrimmed length] == 0) {
			continue; // Empty segment. We can ignore.
		}

		if ([numericTrimmed isNumericOnly]) {
			if ([numericTrimmed length] > 3) {
				return nil; // Bad value, fail completely
			}

			// Convert to integer and back to remove leading zeros
			numericTrimmed = [NSString stringWithFormat:@"%ld", [numericTrimmed integerValue]];
		} else if ([numericTrimmed isAlphabeticNumericOnly]) {
			if ([numericTrimmed length] > 20) {
				return nil; // Bad value, fail completely
			}

			numericTrimmed = [numericTrimmed uppercaseString];
		} else {
			return nil; // Bad value, fail completely
		}

		if (filterEventsNumerics == nil) {
			filterEventsNumerics = [NSMutableArray array];
		}

		if ([filterEventsNumerics containsObject:numericTrimmed] == NO) {
			[filterEventsNumerics addObject:numericTrimmed];
		}
	}

	return [filterEventsNumerics copy];
}

- (TPI_ChatFilterEventType)compileFilterEvents
{
	TPI_ChatFilterEventType filterEvents = 0;

	if ([self.filterEventPlainTextMessageCheck state] == NSOnState)
		filterEvents |= TPI_ChatFilterPlainTextMessageEventType;

	if ([self.filterEventActionMessageCheck state] == NSOnState)
		filterEvents |= TPI_ChatFilterActionMessageEventType;

	if ([self.filterEventNoticeMessageCheck state] == NSOnState)
		filterEvents |= TPI_ChatFilterNoticeMessageEventType;

	if ([self.filterEventUserJoinedChannelCheck state] == NSOnState)
		filterEvents |= TPI_ChatFilterUserJoinedChannelEventType;

	if ([self.filterEventUserLeftChannelCheck state] == NSOnState)
		filterEvents |= TPI_ChatFilterUserLeftChannelEventType;

	if ([self.filterEventUserKickedFromChannelCheck state] == NSOnState)
		filterEvents |= TPI_ChatFilterUserKickedFromChannelEventType;

	if ([self.filterEventUserDisconnectedCheck state] == NSOnState)
		filterEvents |= TPI_ChatFilterUserDisconnectedEventType;

	if ([self.filterEventUserChangedNicknameCheck state] == NSOnState)
		filterEvents |= TPI_ChatFilterUserChangedNicknameEventType;

	if ([self.filterEventChannelTopicReceivedCheck state] == NSOnState)
		filterEvents |= TPI_ChatFilterChannelTopicReceivedEventType;

	if ([self.filterEventChannelTopicChangedCheck state] == NSOnState)
		filterEvents |= TPI_ChatFilterChannelTopicChangedEventType;

	if ([self.filterEventChannelModeReceivedCheck state] == NSOnState)
		filterEvents |= TPI_ChatFilterChannelModeReceivedEventType;

	if ([self.filterEventChannelModeChangedCheck state] == NSOnState)
		filterEvents |= TPI_ChatFilterChannelModeChangedEventType;

	return filterEvents;
}

- (void)ok:(id)sender
{
	[self saveFilter];

	if ([[self delegate] respondsToSelector:@selector(chatFilterEditFilterSheet:onOK:)]) {
		[[self delegate] chatFilterEditFilterSheet:self onOK:self.filter];
	}

	[super ok:nil];
}

- (void)windowWillClose:(NSNotification *)note
{
	[self.filterLimitToSelectionOutlineView setDelegate:nil];
	[self.filterLimitToSelectionOutlineView setDataSource:nil];

	[RZNotificationCenter() removeObserver:self];

	if ([[self delegate] respondsToSelector:@selector(chatFilterEditFilterSheetWillClose:)]) {
		[[self delegate] chatFilterEditFilterSheetWillClose:self];
	}
}

#pragma mark -
#pragma mark Token Field Delegate

- (void)populateTokenFieldStringValues
{
	NSCharacterSet *emptyCharacterSet = [NSCharacterSet characterSetWithCharactersInString:NSStringEmptyPlaceholder];

	[self.filterActionTokenField setTokenizingCharacterSet:emptyCharacterSet];

	[self.filterActionTokenField setCompletionDelay:0.2];

	[self setToken:@"%_channelName_%" inTokenField:self.filterActionTokenChannelName];
	[self setToken:@"%_localNickname_%" inTokenField:self.filterActionTokenLocalNickname];
	[self setToken:@"%_networkName_%" inTokenField:self.filterActionTokenNetworkName];
	[self setToken:@"%_originalMessage_%" inTokenField:self.filterActionTokenOriginalMessage];
	[self setToken:@"%_senderAddress_%" inTokenField:self.filterActionTokenSenderAddress];
	[self setToken:@"%_senderHostmask_%" inTokenField:self.filterActionTokenSenderHostmask];
	[self setToken:@"%_senderNickname_%" inTokenField:self.filterActionTokenSenderNickname];
	[self setToken:@"%_senderUsername_%" inTokenField:self.filterActionTokenSenderUsername];
	[self setToken:@"%_serverAddress_%" inTokenField:self.filterActionTokenServerAddress];
}

- (NSArray *)tokenField:(NSTokenField *)tokenField readFromPasteboard:(NSPasteboard *)pboard
{
	NSString *stringContent = [pboard stringContent];

	return [self tokensFromString:stringContent];
}

- (BOOL)tokenField:(NSTokenField *)tokenField writeRepresentedObjects:(NSArray *)objects toPasteboard:(NSPasteboard *)pboard
{
	NSString *stringContent = [objects componentsJoinedByString:NSStringEmptyPlaceholder];

	[pboard setStringContent:stringContent];

	return YES;
}

- (NSTokenStyle)tokenField:(NSTokenField *)tokenField styleForRepresentedObject:(id)representedObject
{
	if ([representedObject isKindOfClass:[TPI_ChatFilterFilterActionToken class]]) {
		return NSRoundedTokenStyle;
	} else {
		return NSPlainTextTokenStyle;
	}
}

- (NSString *)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject
{
	if ([representedObject isKindOfClass:[TPI_ChatFilterFilterActionToken class]]) {
		return [representedObject tokenTitle];
	}

	return representedObject;
}

- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString:(NSString *)editingString
{
	if (tokenField == self.filterActionTokenField) {
		NSArray *tokenTitles = [self.filterActionAutoCompletedTokens filteredArrayUsingPredicate:
				[NSPredicate predicateWithFormat:@"SELF beginswith[cd] %@", editingString]];

		if ([tokenTitles count] > 0) {
			NSString *tokenTitle = [tokenTitles firstObject];

			return [TPI_ChatFilterFilterActionToken tokenWithTokenTitle:tokenTitle];
		}
	}

	return editingString;
}

- (NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex
{
	if (tokenField == self.filterActionTokenField) {
		NSArray *tokenTitles = [TPI_ChatFilterFilterActionToken tokenTitles];

		NSArray *tokenTitlesFiltered = [tokenTitles filteredArrayUsingPredicate:
				[NSPredicate predicateWithFormat:@"SELF beginswith[cd] %@", substring]];

		self.filterActionAutoCompletedTokens = tokenTitlesFiltered;

		return tokenTitlesFiltered;
	}

	return nil;
}

- (void)performFilterActionTokenCompletion
{
	;
}

- (NSString *)stringValueForTokenField:(NSTokenField *)tokenField
{
	return [[tokenField objectValue] componentsJoinedByString:NSStringEmptyPlaceholder];
}

- (void)setTokens:(NSString *)tokens inTokenField:(NSTokenField *)tokenField
{
	NSArray *tokenObjects = [self tokensFromString:tokens];

	[tokenField setObjectValue:tokenObjects];
}

- (void)setToken:(NSString *)token inTokenField:(NSTokenField *)tokenField
{
	 TPI_ChatFilterFilterActionToken *tokenObject =
	[TPI_ChatFilterFilterActionToken tokenWithToken:token];

	[tokenField setObjectValue:@[tokenObject]];
}

- (NSArray *)tokensFromString:(NSString *)string
{
	NSString *tokenString = string;

	if (tokenString == nil) {
		tokenString = NSStringEmptyPlaceholder;
	}

	NSInteger start = 0;

	NSInteger length = [tokenString length];

	NSMutableArray *tokens = [NSMutableArray array];

	while (start < length) {
		NSRange searchRange = NSMakeRange(start, (length - start));

		NSRange r = [tokenString rangeOfString:@"%_([a-zA-Z]+)_%"
									   options:NSRegularExpressionSearch
										 range:searchRange];

		if (r.location == NSNotFound) {
			NSString *tokenStringPrefix = [tokenString substringWithRange:searchRange];

			[tokens addObject:tokenStringPrefix];

			break;
		}

		NSRange tokenStringPrefixRange = NSMakeRange(start, (r.location - start));

		if (tokenStringPrefixRange.length > 0) {
			NSString *tokenStringPrefix = [tokenString substringWithRange:tokenStringPrefixRange];

			[tokens addObject:tokenStringPrefix];
		}

		NSString *tokenStringToken = [tokenString substringWithRange:r];

		if ([TPI_ChatFilterFilterActionToken isToken:tokenStringToken]) {
			 TPI_ChatFilterFilterActionToken *token =
			[TPI_ChatFilterFilterActionToken tokenWithToken:tokenStringToken];

			[tokens addObject:token];
		} else {
			[tokens addObject:tokenStringToken];
		}

		start = NSMaxRange(r);
	}

	if ([tokens count] == 0) {
		[tokens addObject:tokenString];
	}

	return tokens;
}

#pragma mark -
#pragma mark Utilities

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
	if (control != self.filterActionTokenField && control != self.filterNotesTextField) {
		return NO;
	}

	NSRange selectedRange = [textView selectedRange];

	if (selectedRange.length > 0) {
		return NO;
	}

	if (commandSelector == @selector(insertNewline:))
	{
		NSRange editedRange = [[textView textStorage] editedRange];

		if (editedRange.length > 1) {
			return NO;
		}

		[textView insertNewlineIgnoringFieldEditor:self];

		return YES;
	}
	else if (commandSelector == @selector(insertTab:))
	{
//		if (control == self.filterActionTokenField) {
//			[self performFilterActionTokenCompletion];
//
//			return YES;
//		}
	}

	return NO;
}

- (void)controlTextDidChange:(NSNotification *)obj
{
	[self toggleOkButton];
}

- (void)validatedTextFieldTextDidChange:(id)sender
{
	[self toggleOkButton];
}

- (void)toggleOkButton
{
	BOOL disabled = NO;

	if ([[self.filterTitleTextField stringValue] length] == 0) {
		disabled = YES;
	}

	if (disabled == NO) {
		if ([self.filterEventNumericTextField valueIsValid] == NO) {
			disabled = YES;
		} else if ([self.filterForwardToDestinationTextField valueIsValid] == NO) {
			disabled = YES;
		}
	}

/*	if (disabled == NO) {
		if ([[self.filterMatchTextField stringValue] length] == 0 &&
			[[self.filterSenderMatchTextField stringValue] length] == 0 &&
			([self.filterEventPlainTextMessageCheck state] == NSOnState ||
			 [self.filterEventActionMessageCheck state] == NSOnState ||
			 [self.filterEventNoticeMessageCheck state] == NSOnState))
		{
			disabled = YES;
		}
	} */

	if (disabled == NO) {
		if ([self.filterIgnoreContentCheck state] == NSOffState &&
			[[self.filterForwardToDestinationTextField stringValue] length] == 0)
		{
			if ([[self.filterActionTokenField stringValue] length] == 0) {
				disabled = YES;
			}
		}
	}

	[[self okButton] setEnabled:(disabled == NO)];
}

- (void)setupTextFieldRules
{
	/* "Forward To" text field */
	[self.filterForwardToDestinationTextField setTextDidChangeCallback:self];

	[self.filterForwardToDestinationTextField setPerformValidationWhenEmpty:NO];

	[self.filterForwardToDestinationTextField setOnlyShowStatusIfErrorOccurs:YES];

	[self.filterForwardToDestinationTextField setStringValueIsInvalidOnEmpty:NO];
	[self.filterForwardToDestinationTextField setStringValueIsTrimmed:YES];
	[self.filterForwardToDestinationTextField setStringValueUsesOnlyFirstToken:NO];

	[self.filterForwardToDestinationTextField setValidationBlock:^BOOL(NSString *currentValue) {
		if ([currentValue length] > 125) {
			return NO;
		}

		if ([XRRegularExpression string:currentValue isMatchedByRegex:@"^([a-zA-Z0-9\\-\\_\\s]+)$"]) {
			return YES;
		} else {
			return NO;
		}
	}];

	/* "Numerics" text field */
	[self.filterEventNumericTextField setTextDidChangeCallback:self];

	[self.filterEventNumericTextField setPerformValidationWhenEmpty:NO];

	[self.filterEventNumericTextField setOnlyShowStatusIfErrorOccurs:YES];

	[self.filterEventNumericTextField setStringValueIsInvalidOnEmpty:NO];
	[self.filterEventNumericTextField setStringValueIsTrimmed:NO];
	[self.filterEventNumericTextField setStringValueUsesOnlyFirstToken:NO];

	[self.filterEventNumericTextField setValidationBlock:^BOOL(NSString *currentValue) {
		return ([self compileFilterEventsNumerics] != nil);
	}];
}

- (void)updateVisibilityOfLimitedToTableHostView
{
	if ([self.filterLimitToMatrix selectedTag] == TPI_ChatFilterLimitToSpecificItemsValue) {
		[self.filterLimitedToTableHostView setHidden:NO];
	} else {
		[self.filterLimitedToTableHostView setHidden:YES];
	}
}

- (void)updateEnableStateOfFilterActionTokenField
{
	;
}

- (void)updateEnabledStateOfFilterEvents
{
	BOOL enabled = ([self.filterLimitToMatrix selectedTag] != TPI_ChatFilterLimitToPrivateMessagesValue);

	[self.filterEventUserJoinedChannelCheck setEnabled:enabled];
	[self.filterEventUserLeftChannelCheck setEnabled:enabled];
	[self.filterEventUserKickedFromChannelCheck setEnabled:enabled];
	[self.filterEventUserDisconnectedCheck setEnabled:enabled];
	[self.filterEventUserChangedNicknameCheck setEnabled:enabled];
	[self.filterEventChannelTopicReceivedCheck setEnabled:enabled];
	[self.filterEventChannelTopicChangedCheck setEnabled:enabled];
	[self.filterEventChannelModeReceivedCheck setEnabled:enabled];
	[self.filterEventChannelModeChangedCheck setEnabled:enabled];
}

- (void)updateEnabledStateOfComponentsConstrainedByFilterEvents
{
	BOOL enabled1 = ([self.filterEventPlainTextMessageCheck state] == NSOnState ||
					 [self.filterEventActionMessageCheck state] == NSOnState ||
					 [self.filterEventNoticeMessageCheck state] == NSOnState);

	[self.filterForwardToDestinationTextField setEnabled:enabled1];

	[self.filterIgnoresOperatorsCheck setEnabled:enabled1];
}

- (void)updateEnabledStateOfSenderMatch
{
	BOOL enabled1 = ([self.filterLimitedToMyselfCheck state] == NSOffState);

	[self.filterSenderMatchTextField setEnabled:enabled1];
}

- (void)filterLimitedToMyselfChanged:(id)sender
{
	[self updateEnabledStateOfSenderMatch];
}

- (void)filterEventTypeChanged:(id)sender
{
	[self updateEnabledStateOfComponentsConstrainedByFilterEvents];
}

- (void)viewFilterMatchHelpText:(id)sender
{
	[TLOpenLink openWithString:@"https://help.codeux.com/textual/Introduction-to-the-Chat-Filter-Addon.kb#faq-entry-1"];
}

- (void)viewFilterActionHelpText:(id)sender
{
	[TLOpenLink openWithString:@"https://help.codeux.com/textual/Introduction-to-the-Chat-Filter-Addon.kb#faq-entry-2"];
}

- (void)viewFilterSenderMatchHelpText:(id)sender
{
	[TLOpenLink openWithString:@"https://help.codeux.com/textual/Introduction-to-the-Chat-Filter-Addon.kb#faq-entry-3"];
}

- (void)viewFilterForwardToDestinationHelpText:(id)sender
{
	[TLOpenLink openWithString:@"https://help.codeux.com/textual/Introduction-to-the-Chat-Filter-Addon.kb#faq-entry-4"];
}

- (void)filteredLimitedToMatrixChanged:(id)sender
{
	[self updateVisibilityOfLimitedToTableHostView];

	[self updateEnabledStateOfFilterEvents];
}

- (void)filterIgnoreContentCheckChanged:(id)sender
{
	[self updateEnableStateOfFilterActionTokenField];

	[self toggleOkButton];
}

- (void)addObserverForChannelListUpdates
{
	[RZNotificationCenter() addObserver:self selector:@selector(channelListChanged:) name:@"IRCWorldClientListWasModifiedNotification" object:nil];

	[RZNotificationCenter() addObserver:self selector:@selector(channelListChanged:) name:@"IRCClientChannelListWasModifiedNotification" object:nil];
}

- (void)channelListChanged:(id)sender
{
	[self rebuildCachedChannelList];

	[self.filterLimitToSelectionOutlineView reloadData];
}

#pragma mark -
#pragma mark Outline View Delegate

- (void)rebuildCachedChannelList
{
	NSArray *cachedClientList = [worldController() clientList];

	NSMutableDictionary *cachedChannelList = [NSMutableDictionary dictionary];

	for (IRCClient *u in cachedClientList) {
		NSMutableArray *uChannelList = [NSMutableArray array];

		for (IRCChannel *c in [u channelList]) {
			if ([c isChannel]) {
				[uChannelList addObject:c];
			}
		}

		[cachedChannelList setObject:[uChannelList copy] forKey:[u uniqueIdentifier]];
	}

	self.cachedClientList = cachedClientList;

	self.cachedChannelList = cachedChannelList;
}

- (NSInteger)outlineView:(NSOutlineView *)sender numberOfChildrenOfItem:(id)item
{
	if (item) {
		NSString *uniqueIdentifier = [item uniqueIdentifier];

		return [self.cachedChannelList[uniqueIdentifier] count];
	} else {
		return [self.cachedClientList count];
	}
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	if (item) {
		NSString *uniqueIdentifier = [item uniqueIdentifier];

		return self.cachedChannelList[uniqueIdentifier][index];
	} else {
		return self.cachedClientList[index];
	}
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	TPI_ChatFilterLimitToTableCellView *newView = (id)[outlineView makeViewWithIdentifier:@"tableEntry" owner:self];

	[newView setParentDialog:self];

	[newView setAssociatedItem:item];

	[newView populateDefaults];

	return newView;
}

- (void)outlineView:(NSOutlineView *)outlineView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
	XRPerformBlockAsynchronouslyOnMainQueue(^{
		NSView *cellView = [rowView viewAtColumn:0];

		[(id)cellView reloadCheckboxForChildren];
	});

	if ((row + 1) == [outlineView numberOfRows]) {
		XRPerformBlockAsynchronouslyOnMainQueue(^{
			[outlineView expandItem:nil expandChildren:YES];
		});
	}
}

- (BOOL)outlineView:(NSOutlineView *)sender isItemExpandable:(id)item
{
	NSString *uniqueIdentifier = [item uniqueIdentifier];

	return ([self.cachedChannelList[uniqueIdentifier] count] > 0);
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item
{
	return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
	return NO;
}

@end

#pragma mark -
#pragma mark Table Cell View

@implementation TPI_ChatFilterLimitToTableCellView

- (void)populateDefaults
{
	/* Define context for current operation. */
	TPI_ChatFilterEditFilterSheet *parentDialog = [self parentDialog];

	NSOutlineView *outlineView = [parentDialog filterLimitToSelectionOutlineView];

	id currentItem = [self associatedItem];

	BOOL isGroupItem = [outlineView isGroupItem:currentItem];

	/* Update related content */
	[[self textField] setStringValue:[currentItem label]];

	[[self checkbox] setAllowsMixedState:isGroupItem];
}

- (void)reloadCheckboxForChildren
{
	/* Define context for current operation. */
	NSOutlineView *outlineView = [self parentOutlineView];

	TPI_ChatFilterLimitToTableCellView *parentItemView = [self parentCellViewOrSelf];

	id parentItem = [parentItemView associatedItem];

	/* Process child items */
	BOOL atleastOneChildChecked = NO;

	BOOL parentItemInFilter = [[self filterLimitedToClientsIDs] containsObject:[parentItem uniqueIdentifier]];

	NSArray *childrenItems = [outlineView itemsInGroup:parentItem];

	for (id childItem in childrenItems) {
		NSInteger childItemRow = [outlineView rowForItem:childItem];

		TPI_ChatFilterLimitToTableCellView *childItemView = [outlineView viewAtColumn:0 row:childItemRow makeIfNecessary:NO];

		BOOL childItemInFilter = [[self filterLimitedToChannelsIDs] containsObject:[childItem uniqueIdentifier]];

		if (parentItemInFilter) {
			[[childItemView checkbox] setState:NSOnState];
		} else if (childItemInFilter) {
			if (atleastOneChildChecked == NO) {
				atleastOneChildChecked = YES;
			}

			[[childItemView checkbox] setState:NSOnState];
		} else {
			[[childItemView checkbox] setState:NSOffState];
		}

		[[childItemView checkbox] setEnabled:(parentItemInFilter == NO)];
	}

	/* Process parent item */
	if (parentItemInFilter) {
		[[parentItemView checkbox] setState:NSOnState];
	} else {
		if (atleastOneChildChecked) {
			[[parentItemView checkbox] setState:NSMixedState];
		} else {
			[[parentItemView checkbox] setState:NSOffState];
		}
	}
}

- (void)checkboxToggled:(NSButton *)sender
{
	/* Define context for current operation. */
	TPI_ChatFilterEditFilterSheet *parentDialog = [self parentDialog];

	NSOutlineView *outlineView = [parentDialog filterLimitToSelectionOutlineView];

	id currentItem = [self associatedItem];

	BOOL isGroupItem = [outlineView isGroupItem:currentItem];

	BOOL isEnablingItem = ([sender state] == NSOnState ||
						   [sender state] == NSMixedState);

	/* Add or remove item from appropriate filter */
	if (isGroupItem) {
		if (isEnablingItem) {
			[[parentDialog filterLimitedToClientsIDs] addObject:[currentItem uniqueIdentifier]];
		} else {
			[[parentDialog filterLimitedToClientsIDs] removeObject:[currentItem uniqueIdentifier]];
		}
	} else {
		if (isEnablingItem) {
			[[parentDialog filterLimitedToChannelsIDs] addObject:[currentItem uniqueIdentifier]];
		} else {
			[[parentDialog filterLimitedToChannelsIDs] removeObject:[currentItem uniqueIdentifier]];
		}
	}

	/* Further process filters depending on state of other items */
	if (isGroupItem && isEnablingItem) {
		NSArray *childrenItems = [outlineView itemsFromParentGroup:currentItem];

		for (id childItem in childrenItems) {
			[[parentDialog filterLimitedToChannelsIDs] removeObject:[childItem uniqueIdentifier]];
		}
	}

	/* Reload checkbox state for all */
	[self reloadCheckboxForChildren];
}

- (NSMutableArray *)filterLimitedToClientsIDs
{
	TPI_ChatFilterEditFilterSheet *parentDialog = [self parentDialog];

	return [parentDialog filterLimitedToClientsIDs];
}

- (NSMutableArray *)filterLimitedToChannelsIDs
{
	TPI_ChatFilterEditFilterSheet *parentDialog = [self parentDialog];

	return [parentDialog filterLimitedToChannelsIDs];
}

- (NSOutlineView *)parentOutlineView
{
	TPI_ChatFilterEditFilterSheet *parentDialog = [self parentDialog];

	return [parentDialog filterLimitToSelectionOutlineView];
}

- (TPI_ChatFilterLimitToTableCellView *)parentCellViewOrSelf
{
	NSOutlineView *outlineView = [self parentOutlineView];

	id currentItem = [self associatedItem];

	if ([outlineView isGroupItem:currentItem]) {
		return self;
	} else {
		id parentItem = [outlineView parentForItem:currentItem];

		NSInteger parentItemViewRow = [outlineView rowForItem:parentItem];

		return [outlineView viewAtColumn:0 row:parentItemViewRow makeIfNecessary:NO];
	}
}

@end

#pragma mark -
#pragma mark Token Object

@implementation TPI_ChatFilterFilterActionToken

+ (TPI_ChatFilterFilterActionToken *)tokenWithToken:(NSString *)token
{
	TPI_ChatFilterFilterActionToken *tokenField = [TPI_ChatFilterFilterActionToken new];

	[tokenField setToken:token];

	return tokenField;
}

+ (TPI_ChatFilterFilterActionToken *)tokenWithTokenTitle:(NSString *)tokenTitle
{
	NSArray *tokenTitles = [TPI_ChatFilterFilterActionToken tokenTitles];

	NSInteger tokenTitleIndex = [tokenTitles indexOfObject:tokenTitle];

	if (tokenTitleIndex == NSNotFound) {
		return nil;
	}

	NSArray *tokens = [TPI_ChatFilterFilterActionToken tokens];

	NSString *token = [tokens objectAtIndex:tokenTitleIndex];

	return [TPI_ChatFilterFilterActionToken tokenWithToken:token];
}

+ (BOOL)isToken:(NSString *)token
{
	NSArray *tokens = [TPI_ChatFilterFilterActionToken tokens];

	return ([tokens indexOfObject:token] != NSNotFound);
}

+ (NSArray *)tokens
{
	/* The index of this array should match the index of -tokenTitles */
	static NSArray *tokens = nil;

	if (tokens == nil) {
		tokens = @[
		   @"%_channelName_%",
		   @"%_localNickname_%",
		   @"%_networkName_%",
		   @"%_originalMessage_%",
		   @"%_senderAddress_%",
		   @"%_senderHostmask_%",
		   @"%_senderNickname_%",
		   @"%_senderUsername_%",
		   @"%_serverAddress_%"
		];
	}
	
	return tokens;
}

+ (NSArray *)tokenTitles
{
	/* The index of this array should match the index of -tokens */
	static NSArray *tokens = nil;

	if (tokens == nil) {
		tokens = @[
		   TPILocalizedString(@"TPI_ChatFilterEditFilterSheet[0001]"),
		   TPILocalizedString(@"TPI_ChatFilterEditFilterSheet[0002]"),
		   TPILocalizedString(@"TPI_ChatFilterEditFilterSheet[0003]"),
		   TPILocalizedString(@"TPI_ChatFilterEditFilterSheet[0004]"),
		   TPILocalizedString(@"TPI_ChatFilterEditFilterSheet[0005]"),
		   TPILocalizedString(@"TPI_ChatFilterEditFilterSheet[0006]"),
		   TPILocalizedString(@"TPI_ChatFilterEditFilterSheet[0007]"),
		   TPILocalizedString(@"TPI_ChatFilterEditFilterSheet[0008]"),
		   TPILocalizedString(@"TPI_ChatFilterEditFilterSheet[0009]")
		];
	}
	
	return tokens;
}

+ (NSString *)titleForToken:(NSString *)token
{
	NSArray *tokens = [TPI_ChatFilterFilterActionToken tokens];

	NSInteger tokenIndex = [tokens indexOfObject:token];

	if (tokenIndex == NSNotFound) {
		return nil;
	}

	NSArray *tokenTitles = [TPI_ChatFilterFilterActionToken tokenTitles];

	return [tokenTitles objectAtIndex:tokenIndex];
}

- (NSString *)tokenTitle
{
	return [TPI_ChatFilterFilterActionToken titleForToken:[self token]];
}

- (NSString *)description
{
	return [self token];
}

@end
