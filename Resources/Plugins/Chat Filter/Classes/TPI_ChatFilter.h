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

#import "TextualApplication.h"

typedef NS_ENUM(NSUInteger, TPI_ChatFilterLimitToValue) {
	TPI_ChatFilterLimitToNoLimitValue				= 0,
	TPI_ChatFilterLimitToChannelsValue				= 1,
	TPI_ChatFilterLimitToPrivateMessagesValue		= 2,
	TPI_ChatFilterLimitToSpecificItemsValue			= 3
};

typedef NS_OPTIONS(NSUInteger, TPI_ChatFilterEventType) {
	TPI_ChatFilterNumericEventType					= 1 << 0,
	TPI_ChatFilterPlainTextMessageEventType			= 1 << 1,
	TPI_ChatFilterActionMessageEventType			= 1 << 2,
	TPI_ChatFilterNoticeMessageEventType			= 1 << 3,
	TPI_ChatFilterUserJoinedChannelEventType		= 1 << 4,
	TPI_ChatFilterUserLeftChannelEventType			= 1 << 5,
	TPI_ChatFilterUserKickedFromChannelEventType	= 1 << 6,
	TPI_ChatFilterUserDisconnectedEventType			= 1 << 7,
	TPI_ChatFilterUserChangedNicknameEventType		= 1 << 8,
	TPI_ChatFilterChannelTopicReceivedEventType		= 1 << 9,
	TPI_ChatFilterChannelTopicChangedEventType		= 1 << 10,
	TPI_ChatFilterChannelModeReceivedEventType		= 1 << 11,
	TPI_ChatFilterChannelModeChangedEventType		= 1 << 12
};

@interface TPI_ChatFilter : NSObject <NSCopying>
@property (nonatomic, assign) BOOL filterIgnoreContent;
@property (nonatomic, assign) BOOL filterIgnoresOperators;
@property (nonatomic, assign) BOOL filterLogMatch;
@property (nonatomic, assign) BOOL filterLimitedToMyself;
@property (nonatomic, assign) TPI_ChatFilterEventType filterEvents;
@property (nonatomic, assign) TPI_ChatFilterLimitToValue filterLimitedToValue;
@property (nonatomic, copy) NSArray *filterLimitedToChannelsIDs;
@property (nonatomic, copy) NSArray *filterLimitedToClientsIDs;
@property (nonatomic, copy) NSArray *filterEventsNumerics;
@property (nonatomic, copy) NSString *filterAction;
@property (nonatomic, copy) NSString *filterForwardToDestination;
@property (nonatomic, copy) NSString *filterItemID;
@property (nonatomic, copy) NSString *filterMatch;
@property (nonatomic, copy) NSString *filterNotes;
@property (nonatomic, copy) NSString *filterSenderMatch;
@property (nonatomic, copy) NSString *filterTitle;
@property (readonly, copy) NSString *filterDescription;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryValue;

- (BOOL)isEventTypeEnabled:(TPI_ChatFilterEventType)eventType;
@end
