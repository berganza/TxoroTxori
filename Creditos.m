//
//  Creditos.m
//  TxoroTxori
//
//  Created by Berganza on 16/09/14.
//  Copyright (c) 2014 Berganza. All rights reserved.
//

#import "Creditos.h"

static NSString* const FONDO = @"creditos";


@implementation Creditos

    AVAudioPlayer * reproductor;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        
        //****************************
        // Scroll Vertical
        //****************************
        self.escena = [self fondoCreditos];
        [self addChild:self.escena];
        
        [self addChild:self.volver];
        
        SKAction * sonido = [SKAction playSoundFileNamed:@"EfectoPuerta.wav" waitForCompletion:YES];
        [self runAction:sonido];

        [self startReproductor];
        
        SKSpriteNode * imagen = [SKSpriteNode spriteNodeWithImageNamed:@"imagenCreditos"];
        imagen.position = CGPointMake (CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        imagen.size = self.size;
        imagen.zPosition = 1;
        [self addChild: imagen];
        
        
        SKSpriteNode * sobreCreditos = [SKSpriteNode spriteNodeWithImageNamed:@"sobreCreditos"];
        
        sobreCreditos.anchorPoint = CGPointMake(0.5, 0);
        sobreCreditos.position = CGPointMake (CGRectGetMidX(self.frame), CGRectGetMinY(self.frame));
        sobreCreditos.zPosition = 5;
        [self addChild:sobreCreditos];

        
    }
    return self;
}

-(void) startReproductor {
    
    NSURL * rutaMusica = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Pintxo1" ofType:@"mp3"]];
    reproductor = [[AVAudioPlayer alloc] initWithContentsOfURL:rutaMusica error:nil];
    
    [reproductor prepareToPlay];
    
    reproductor.numberOfLoops = 2;
    [reproductor play];
}


-(void) stopReproductor {
    
    [reproductor stop];
    
}

- (SKLabelNode *) volver {
    SKLabelNode * volver = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
    volver.text = @"itzuli";
    volver.fontSize = 24;
    volver.fontColor = [SKColor grayColor];
    volver.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMinY(self.frame) + 30);
    volver.name = @"volver";
    volver.zPosition = 10;
    return volver;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * toque = [touches anyObject];
    CGPoint tocarLabel = [toque locationInNode:self];
    SKNode * nodo = [self nodeAtPoint:tocarLabel];
    
    if ([nodo.name isEqualToString:@"volver"]) {
        
        SKTransition * efectoTransicion = [SKTransition doorsCloseVerticalWithDuration:2];
        Menu * escena1 = [Menu sceneWithSize:self.frame.size];
        [self.view presentScene:escena1 transition: efectoTransicion];
        
        [self stopReproductor];
        
        SKAction * sonido = [SKAction playSoundFileNamed:@"EfectoPuerta.wav" waitForCompletion:YES];
        [self runAction:sonido];
    }
}

-(void)update:(CFTimeInterval)tiempoActual {
    //****************************
    // Scroll Vertical
    //****************************
    CFTimeInterval tiempo = tiempoActual - self.tiempoTranscurrido;
    
    self.tiempoTranscurrido = tiempoActual;
    
    if (tiempo > 1) {
        tiempo = 1.0 / 60.0;
        self.tiempoTranscurrido = tiempoActual;
    }
    
    [self enumerateChildNodesWithName:FONDO usingBlock:^(SKNode * node, BOOL *stop) {
        
        node.position = CGPointMake(node.position.x, node.position.y + 30 * tiempo);
        
        if (node.position.y < -(node.frame.size.height + 1)) {
            [node removeFromParent];
        }
    }];
    
}

//****************************
// Scroll Vertical
//****************************
- (SKSpriteNode *)fondoCreditos {
    
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"creditos.png"];
    background.anchorPoint = CGPointMake(0, 0);
    background.position = CGPointMake(0, -900);
    background.name = FONDO;
    background.zPosition = 2;
    
    return background;
}



@end
