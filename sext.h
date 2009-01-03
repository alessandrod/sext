/* 
 *  Copyright (c) 2009, Alessandro Decina <alessandro.d@gmail.com>
 * 
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.
 * 
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 * 
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this program; if not, write to the
 *  Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 *  Boston, MA 02111-1307, USA.
 */

#import <Foundation/Foundation.h>

@interface SExt : NSObject
{
  id sharedDocumentController;
}

/* SExt is a singleton. The singleton is usually created by external
 * loaders (eg: an input manager or SIMBL) by sending the [SExt
 * sharedInstance] message.
 * We use a singleton here as Objective-C doesn't support closures and
 * singletons seem to be popular in Cocoa.
 */
+ (SExt *)sharedInstance;
+ (id)allocWithZone:(NSZone *)zone;

/* load is the main entry point. It's where we hook into Safari. */
- (void)load;

/* Hijack safari's event handling */
- (void)hijackSendEvent;
- (void)ourSendEvent:(NSEvent *)event;
- (void)originalSendEvent:(NSEvent *)event;

- (id)sharedDocumentController;
/* frontmostBrowserWindowController gets the frontmostmost
 * BrowserWindowController instance, which is the one having focus */
- (id)frontmostBrowserWindowController;

/* called internally in response to cmd-N */
- (void)switchToTab:(int)tab;
@end
