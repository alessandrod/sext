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

#import "sext-simbl-plugin.h"
#import "sext.h"

@implementation SExtSimblPlugin

+ (void)load
{
  /* this is the first call to sharedInstance that actually creates the
   * singleton */
  SExt *ext = [SExt sharedInstance];
  [ext load];
}
@end
