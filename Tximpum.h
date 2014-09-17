//
//  Tximpum.h
//  TxoroTxori
//
//  Created by Berganza on 16/09/14.
//  Copyright (c) 2014 Berganza. All rights reserved.
//

#import "CapaSuperpuesta.h"

typedef NS_ENUM(NSUInteger, BotonCapaTximpum) {
    
    GameOverLayerPlayButton = 0
};


@protocol TximpumDelegate;

@interface Tximpum : CapaSuperpuesta

@property (nonatomic, retain) SKSpriteNode* retryButton;
@property (nonatomic, assign) id<TximpumDelegate> delegate;

@end

@protocol TximpumDelegate <NSObject>
@optional

- (void) gameOverLayer:(Tximpum*)sender pulsarBoton:(BotonCapaTximpum) botonCapaTximpum;

@end