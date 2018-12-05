//
//  RRVideoRenderView.h
//  rrplayer
//
//  Created by helei on 2018/12/5.
//  Copyright © 2018 何磊. All rights reserved.
//

#import <UIKit/UIKit.h>

//NS_ASSUME_NONNULL_BEGIN

@interface RRVideoRenderView : UIView
- (void)drawYuv:(unsigned char *)y u:(unsigned char *)u v:(unsigned char *)v width:(int)width height:(int)height;
@end

//NS_ASSUME_NONNULL_END
