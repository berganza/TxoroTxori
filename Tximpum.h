//
//  Tximpum.h
//  TxoroTxori
//
//  Created by Berganza on 16/09/14.
//  Copyright (c) 2014 Berganza. All rights reserved.
//

#import "CapaSuperpuesta.h"

typedef NS_ENUM(NSUInteger, GameOverLayerButtonType)
{
    GameOverLayerPlayButton = 0
};


@protocol GameOverLayerDelegate;
@interface Tximpum : CapaSuperpuesta
@property (nonatomic, assign) id<GameOverLayerDelegate> delegate;
@end


//**********************************************************************
@protocol GameOverLayerDelegate <NSObject>
@optional

- (void) gameOverLayer:(Tximpum*)sender tapRecognizedOnButton:(GameOverLayerButtonType) gameOverLayerButtonType;
@end