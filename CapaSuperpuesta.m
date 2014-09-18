//
//  CapaSuperpuesta.m
//  TxoroTxori
//
//  Created by Berganza on 16/09/14.
//  Copyright (c) 2014 Berganza. All rights reserved.
//

#import "CapaSuperpuesta.h"

@implementation CapaSuperpuesta

// Para superponer una vista sobre la escena actual
// Creamos un SKNode y lo añadimos como hijo de la vista de la escena del juego
// Para ello, creamos una capa de superposición (overlay) y le añadimos un nodo transparente como hijo

- (id)initWithSize:(CGSize)size
{
    self = [super init];
    if (self)
    {
        SKSpriteNode * node = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:1.0 alpha:0.0] size:size];
        node.anchorPoint = CGPointZero;
        [self addChild:node];
        node.zPosition = -10;
        node.name = @"transparent";
    }
    return self;
}


@end
