/* 
 *  Copyright (c) 2008, Alessandro Decina <alessandro.d@gmail.com>
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

#import <objc/runtime.h>
#import <Foundation/NSException.h>

#import "sext.h"


static SExt *instance;

@implementation SExt

/* singleton implementation */
+ (SExt *)sharedInstance
{
  @synchronized(self) {
    if (instance == nil) {
      instance = [[self alloc] init];
    }
  }

  return instance;
}

+ (id)allocWithZone:(NSZone *)zone
{
  @synchronized(self) {
    if (instance == nil) {
      instance = [super allocWithZone:zone];
      return instance;
    }
  }

  return nil;
}

/* main entry point */
- (void)load
{
  /* for the moment we only process keyboard events */
  [self hijackSendEvent];

  /* ...aaand we're in! */
}

- (void)hijackSendEvent
{
  /* NSApp is a BrowserApplication instance. Override
   * BrowserApplication::sendEvent: to intercept key presses. */
  Class BrowserApplication = [NSApp class];
  
  Method origSendEvent = class_getInstanceMethod(BrowserApplication,
      NSSelectorFromString(@"sendEvent:"));
  Method ourSendEvent = class_getInstanceMethod([self class],
      NSSelectorFromString(@"ourSendEvent:"));
  
  /* add BrowserApplication::originalSendEvent: which is a copy of
   * BrowserApplication::sendEvent:. Keep it so that we can forward the events
   * we don't consume directly. */
  class_addMethod(BrowserApplication, NSSelectorFromString(@"originalSendEvent:"),
      method_getImplementation(origSendEvent),
      method_getTypeEncoding(origSendEvent));
  
  /* now override BrowserApplication::sendEvent: with ourSendEvent: */
  method_exchangeImplementations(origSendEvent, ourSendEvent);

  /* in ur Safari, stealin ur key prssez */
}

- (void)ourSendEvent:(NSEvent *)event
{
  /* if != nil, forward the 'forward' event to originalSendEvent:. When nil, it
   * means that the event was consumed here and doesn't need to be forwarded.
   * The common case is to forward incoming events unchanged. */
  NSEvent *forward = event;

  /* cmd-N is used to go to the bookmark N by default, remap it as alt-N.
   * We override cmd-N to switch to tab N (cmd-1 switches to tab 1, cmd-2 to
   * tab-2 and so on...).
   */
  if ([event type] == NSKeyDown) {
    NSString *keys = [event charactersIgnoringModifiers];

    if ([keys length] == 1) {
      unichar key = [keys characterAtIndex:0];

      /* check if key is in [0-9]. Note that cmd-1 goes to the 1st tab and cmd-0
       * goes to the 10th. */
      if (key >= 0x30 && key <= 0x39) {
        NSUInteger modifiers = [event modifierFlags] & \
            NSDeviceIndependentModifierFlagsMask;

        if (modifiers == NSAlternateKeyMask) {
          /* create a new event and change the modifier from NSAlternateKeyMask
           * to NSCommandKeyMask. We'll then forward the event to the
           * originalSendEvent: which will implement switch to bookmark N */
          forward = [NSEvent keyEventWithType:[event type] \
              location: [event locationInWindow] modifierFlags:NSCommandKeyMask \
              timestamp: [event timestamp] windowNumber: [event windowNumber] \
              context: [event context] characters: [event characters] \
              charactersIgnoringModifiers: [event charactersIgnoringModifiers] \
              isARepeat: [event isARepeat] keyCode: [event keyCode]];
        } else if (modifiers == NSCommandKeyMask) {
          /* take over cmd+N to switch between tabs */
          forward = nil;
          
          /* get the tab number */
          int tab = key - 0x30;
          if (tab == 0)
            tab = 9;
          else
            tab -= 1;

          /* and we're done! */
          [[SExt sharedInstance] switchToTab:tab];
        }
      }
    }
  }
    
  if (forward)
    [self originalSendEvent:forward];
}

- (void)originalSendEvent:(NSEvent *)event
{
  /* unused method, here just to shut up a warning */
}

- (id)sharedDocumentController
{
  if (sharedDocumentController == nil) {
    /* BrowserDocumentController is where we start at to finally get to
     * BrowserWindowController(s) */
    Class BrowserDocumentController = objc_getClass ("BrowserDocumentController");

    sharedDocumentController = \
        [BrowserDocumentController sharedDocumentController];
  }
  
  return sharedDocumentController;
}

- (id)frontmostBrowserWindowController
{
  /* get an object that keeps a list with all the browser document controllers */
  id sharedDocController = [self sharedDocumentController];

  /* we're interested in the frontmost browser document */ 
  id frontBrowserDocument = [sharedDocController frontmostBrowserDocument];

  /* from here we can get the frontmost BrowserWindowController instance WIN \o/
   */
  id frontBrowserWindowController = [frontBrowserDocument browserWindowController];
  return frontBrowserWindowController;
}

- (void)switchToTab:(int)tab
{
  id frontBrowserWindowController = [self frontmostBrowserWindowController];
  @try {
    [frontBrowserWindowController _showTabAtIndex:tab];
  }
  @catch (NSException *e) {
    if (![NSRangeException isEqualTo: [e name]])
      @throw;
  }
}

@end
