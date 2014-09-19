//
//  Jugar.h
//  TxoroTxori
//
//  Created by Berganza on 16/09/14.
//  Copyright (c) 2014 Berganza. All rights reserved.
//

#import "CapaSuperpuesta.h"



typedef NS_ENUM(NSUInteger, BotonInicio) {
    
    BotonInicioPlay = 0
};

@protocol GoazenDelegate;

@interface Jugar : CapaSuperpuesta

@property (nonatomic, retain) SKSpriteNode * botonJugar;
//@property SKSpriteNode * altavozON;
//@property SKSpriteNode * altavozOFF;
@property int musicaBoton;
@property (nonatomic, assign) id<GoazenDelegate> delegate;

@end

@protocol GoazenDelegate <NSObject>
@optional

- (void) capaInicio:(Jugar*)sender pulsarBoton:(BotonInicio) botonInicio;

@end