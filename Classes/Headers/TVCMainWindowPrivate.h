/* ********************************************************************* 
                  _____         _               _
                 |_   _|____  _| |_ _   _  __ _| |
                   | |/ _ \ \/ / __| | | |/ _` | |
                   | |  __/>  <| |_| |_| | (_| | |
                   |_|\___/_/\_\\__|\__,_|\__,_|_|

 Copyright (c) 2010 - 2016 Codeux Software, LLC & respective contributors.
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

typedef NS_OPTIONS(NSUInteger, TVCMainWindowShiftSelectionFlags) {
	TVCMainWindowShiftSelectionMaintainGroupingFlag			= 1 << 0,
	TVCMainWindowShiftSelectionPerformDeselectFlag			= 1 << 1, // deselect previous selection
	TVCMainWindowShiftSelectionPerformDeselectChildrenFlag	= 1 << 2, // deselect previous selection + children (if group item)
//	TVCMainWindowShiftSelectionPerformDeselectAllFlag		= 1 << 2  // deselect all
};

@interface TVCMainWindow ()
@property (nonatomic, readwrite, copy) NSArray *selectedItems;
@property (nonatomic, readwrite, strong) IRCTreeItem *selectedItem;
@property (nonatomic, copy) NSArray *previousSelectedItemsId;
@property (nonatomic, copy) NSString *previousSelectedItemId;
@property (nonatomic, assign) NSTimeInterval lastKeyWindowStateChange;
@property (nonatomic, assign) BOOL lastKeyWindowRedrawFailedBecauseOfOcclusion;
@property (nonatomic, strong) TLOKeyEventHandler *keyEventHandler;
@property (nonatomic, copy) NSValue *cachedSwipeOriginPoint;

- (void)selectItemInSelectedItems:(IRCTreeItem *)selectedItem;
- (void)selectItemInSelectedItems:(IRCTreeItem *)selectedItem refreshChannelView:(BOOL)refreshChannelView;

- (void)shiftSelection:(IRCTreeItem *)oldItem toItem:(IRCTreeItem *)newItem options:(TVCMainWindowShiftSelectionFlags)selectionOptions;

- (void)channelViewSelectionChangeTo:(IRCTreeItem *)selectedItem;
@end
