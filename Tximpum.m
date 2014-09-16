//
//  Tximpum.m
//  TxoroTxori
//
//  Created by Berganza on 16/09/14.
//  Copyright (c) 2014 Berganza. All rights reserved.
//

#import "Tximpum.h"

@interface Tximpum()
@property (nonatomic, retain) SKSpriteNode* retryButton;
@end

@implementation Tximpum


// Subclase Tximpum de CapaOverlay y añadimos un nodo con texto "Tximpum" y el botón para volver a jugar.

- (id)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size])
    {
        SKSpriteNode* startGameText = [SKSpriteNode spriteNodeWithImageNamed:@"tximpum"];
        startGameText.position = CGPointMake(size.width * 0.5f, size.height * 0.8f);
        [self addChild:startGameText];
        
        SKSpriteNode* retryButton = [SKSpriteNode spriteNodeWithImageNamed:@"botonPlay"];
        retryButton.position = CGPointMake(size.width * 0.5f, size.height * 0.50f);
        [self addChild:retryButton];
        
        [self setRetryButton:retryButton];
    }
    
    return self;
}




// Detectamos el toque en el botón de Jugar, mandamos el mensaje de evento táctil a la escena del Juego y empezamos nuevo juego.

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    if ([_retryButton containsPoint:location])
    {
        if([self.delegate respondsToSelector:@selector(gameOverLayer:tapRecognizedOnButton:)])
        {
            [self.delegate gameOverLayer:self tapRecognizedOnButton:GameOverLayerPlayButton];
        }
    }
}

@end
