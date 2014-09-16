//
//  Jugar.h
//  TxoroTxori
//
//  Created by Berganza on 16/09/14.
//  Copyright (c) 2014 Berganza. All rights reserved.
//

#import "CapaSuperpuesta.h"



typedef NS_ENUM(NSUInteger, StartGameLayerButtonType)
{
    StartGameLayerPlayButton = 0
};


@protocol StartGameLayerDelegate;
@interface Jugar : CapaSuperpuesta
@property (nonatomic, assign) id<StartGameLayerDelegate> delegate;
@end


//**********************************************************************
@protocol StartGameLayerDelegate <NSObject>
@optional

- (void) startGameLayer:(Jugar*)sender tapRecognizedOnButton:(StartGameLayerButtonType) startGameLayerButton;
@end