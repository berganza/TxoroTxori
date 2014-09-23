//
//  Tximpum.m
//  TxoroTxori
//
//  Created by Berganza on 16/09/14.
//  Copyright (c) 2014 Berganza. All rights reserved.
//

#import "Tximpum.h"
#import "Menu.h"
#import "Juego.h"

    AVAudioPlayer * musicaPintxo;

CGFloat alturaEscena;
CGFloat anchuraEscena;

@implementation Tximpum

// Subclase Tximpum de CapaOverlay y añadimos un nodo con texto "Tximpum" y el botón para volver a jugar.

- (id)initWithSize:(CGSize)size {
    
    if(self = [super initWithSize:size]) {
        
        alturaEscena = size.height;
        anchuraEscena = size.width;
        
        SKSpriteNode* startGameText = [SKSpriteNode spriteNodeWithImageNamed:@"tximpum"];
        startGameText.position = CGPointMake(size.width * 0.5f, size.height * 0.8f);
        [self addChild:startGameText];
        
        SKSpriteNode* retryButton = [SKSpriteNode spriteNodeWithImageNamed:@"botonPlay"];
        retryButton.position = CGPointMake(size.width * 0.50f, size.height * 0.50f);
        [self addChild:retryButton];
        
        [self addChild:self.volver];
        
        [self setRetryButton:retryButton];
        
        [self altavozON];
    }
    return self;
}

-(void) altavozON {
    
    SKSpriteNode * altavozON = [SKSpriteNode spriteNodeWithImageNamed:@"altavozON"];
    altavozON.position =  CGPointMake((anchuraEscena * 0.5) + (anchuraEscena * 0.5/2), alturaEscena * 0.5);
    altavozON.zPosition = 50;
    altavozON.name = @"altavozON";
    _musicaBoton = 1;
    [self addChild:altavozON];
}

-(void) altavozOFF {
    
    SKSpriteNode * altavozOFF = [SKSpriteNode spriteNodeWithImageNamed:@"altavozOFF"];
    altavozOFF.position =  CGPointMake((anchuraEscena * 0.5) + (anchuraEscena * 0.5/2), alturaEscena * 0.5);
    altavozOFF.zPosition = 50;
    altavozOFF.name = @"altavozOFF";
    _musicaBoton = 0;
    [self addChild:altavozOFF];
}

- (SKLabelNode *) volver {
    
    SKLabelNode * volver = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
    volver.text = @"itzuli";
    volver.fontSize = 18;
    volver.fontColor = [SKColor grayColor];
    volver.position = CGPointMake((anchuraEscena * 0.5) - (anchuraEscena * 0.5/2), alturaEscena * 0.5);
    volver.name = @"volver";
    volver.zPosition = 10;
    return volver;
}

// Detectamos el toque en el botón de Jugar, mandamos el mensaje de evento táctil a la escena del Juego y empezamos nuevo juego.

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode * ON = [self nodeAtPoint:location];
    SKNode * OFF = [self nodeAtPoint:location];
    
    SKNode * nodo = [self nodeAtPoint:location];
 
    if ([nodo.name isEqualToString:@"volver"]) {
        
        SKTransition * efectoTransicion = [SKTransition doorsCloseVerticalWithDuration:2];
        Menu * escena1 = [Menu sceneWithSize:self.scene.size];
        [self.scene.view presentScene:escena1 transition: efectoTransicion];
        
        [self stopPintxo];
        
        SKAction * sonido = [SKAction playSoundFileNamed:@"EfectoPuerta.wav" waitForCompletion:YES];
        [self runAction:sonido];
    }

    if ([_retryButton containsPoint:location]) {
        
        if([self.delegate respondsToSelector:@selector(delegadoFin:pulsarBoton:)]) {
            
            [self.delegate delegadoFin:self pulsarBoton:BotonFinPlay];
        }
    }
    
    if ([ON.name isEqualToString:@"altavozON"]) {
        
        if (_musicaBoton == 1) {
            _musicaBoton = 0;
            
            [self altavozOFF];
            [ON removeFromParent];
            [self stopPintxo];
        }
    }
    
    if ([OFF.name isEqualToString:@"altavozOFF"]) {
        
        if (_musicaBoton == 0) {
            _musicaBoton = 1;
            
            [self altavozON];
            [OFF removeFromParent];
            [self startPintxo];
        }
    }

}

// Iniciar música
-(void) startPintxo {
    
    NSURL * rutaMusica = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Pintxo2" ofType:@"mp3"]];
    musicaPintxo = [[AVAudioPlayer alloc] initWithContentsOfURL:rutaMusica error:nil];
    
    [musicaPintxo prepareToPlay];
    _musicaBoton = 1;
    
    musicaPintxo.numberOfLoops = INFINITY;
    //[_backgroundAudioPlayer setVolume:1.0];
    [musicaPintxo play];
}

-(void) stopPintxo {
    
    [musicaPintxo stop];
}

@end

