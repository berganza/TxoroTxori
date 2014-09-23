//
//  Menu.m
//  TxoroTxori
//
//  Created by Berganza on 16/09/14.
//  Copyright (c) 2014 Berganza. All rights reserved.
//

#import "Menu.h"
#import "Juego.h"


    AVAudioPlayer * musicaInicial;


@implementation Menu

- (void)didMoveToView: (SKView *) view {
    
    if (!self.creacionDeEscena) {
        
        // Método propio
        [self crearContenidoDeEscena];
        self.creacionDeEscena = YES;
        
        [self startMusica];
    }
}


// Selector de método propio para incorporar a la escena el contenido
- (void)crearContenidoDeEscena {
    
    //self.backgroundColor = [SKColor blueColor];
    SKSpriteNode * fondo =[SKSpriteNode spriteNodeWithImageNamed:@"fondoInicio.png"];
    
    fondo.size = self.size;
    fondo.position = CGPointMake (CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:fondo];
    
    self.scaleMode = SKSceneScaleModeAspectFit;
    [self addChild:self.tituloJuego];
    [self addChild:self.jugar];
    [self addChild:self.creditos];
    
    
    //****************************************************
    //*** Implementar imágenes y animaciones título ******
    //****************************************************
    SKSpriteNode * titulo = [[SKSpriteNode alloc] initWithImageNamed:@"txori1.png"];
    titulo.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) * 1.3f);
    titulo.scale = 0.5;
    titulo.name = @"dibujoTitulo";
    
    [self addChild:titulo];
    
    //Animación Título
    SKTextureAtlas * tituloAtlas = [SKTextureAtlas atlasNamed:@"titulo"];
    
    SKTexture * txori1 = [tituloAtlas textureNamed:@"txori1.png"];
    SKTexture * txori2 = [tituloAtlas textureNamed:@"txori2.png"];
    SKTexture * txori3 = [tituloAtlas textureNamed:@"txori3.png"];
    SKTexture * txori4 = [tituloAtlas textureNamed:@"txori4.png"];
    SKTexture * txori5 = [tituloAtlas textureNamed:@"txori5.png"];
    SKTexture * txori6 = [tituloAtlas textureNamed:@"txori6.png"];
    SKTexture * txori7 = [tituloAtlas textureNamed:@"txori7.png"];
    SKTexture * txori8 = [tituloAtlas textureNamed:@"txori8.png"];
    SKTexture * txori9 = [tituloAtlas textureNamed:@"txori9.png"];
    SKTexture * txori10 = [tituloAtlas textureNamed:@"txori10.png"];
    SKTexture * txori11 = [tituloAtlas textureNamed:@"txori11.png"];
    SKTexture * txori12 = [tituloAtlas textureNamed:@"txori12.png"];
    SKTexture * txori13 = [tituloAtlas textureNamed:@"txori13.png"];
    SKTexture * txori14 = [tituloAtlas textureNamed:@"txori14.png"];
    SKTexture * txori15 = [tituloAtlas textureNamed:@"txori15.png"];
    SKTexture * txori16 = [tituloAtlas textureNamed:@"txori16.png"];
    SKTexture * txori17 = [tituloAtlas textureNamed:@"txori17.png"];
    SKTexture * txori18 = [tituloAtlas textureNamed:@"txori18.png"];
    SKTexture * txori19 = [tituloAtlas textureNamed:@"txori19.png"];
    SKTexture * txori20 = [tituloAtlas textureNamed:@"txori20.png"];
    SKTexture * txori21 = [tituloAtlas textureNamed:@"txori21.png"];
    SKTexture * txori22 = [tituloAtlas textureNamed:@"txori22.png"];
    
    NSArray * arrayTexturas = @[txori1,txori2,txori3,txori4,txori5,txori6,txori7,txori8,txori9,txori10,txori11,txori12,txori13,txori14,txori15,txori16,txori17,txori18,txori19,txori20,txori21,txori22];
    
    SKAction * animacion = [SKAction animateWithTextures:arrayTexturas timePerFrame:0.2];
    
    //[titulo runAction:[SKAction repeatActionForever:animacion]];
    [titulo runAction:[SKAction repeatAction:animacion count:1]];
}


//****************************************************
//*** Implementar Labels de Menu, Juego y Créditos ***
//****************************************************
- (SKLabelNode *) tituloJuego {
    SKLabelNode * pantallaMenu = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
    pantallaMenu.text = @"TxoroTxori ®";
    pantallaMenu.fontSize = 10;
    pantallaMenu.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame) * 1/3 - 60);
    return pantallaMenu;
}

- (SKLabelNode *) jugar {
    SKLabelNode * juego = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Bold"];
    juego.text = @"Jolastu !";
    juego.fontSize = 30;
    juego.fontColor = [SKColor colorWithRed:1 green:0.65 blue:0 alpha:1];
    
    juego.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame) * 0.8);
    juego.name=@"juego";
    return juego;
}

- (SKLabelNode *) creditos {
    SKLabelNode * imagenCreditos = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
    imagenCreditos.text = @"Kredituak";
    imagenCreditos.fontSize = 20;
    imagenCreditos.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame) * 2/6);
    imagenCreditos.name = @"imagenCreditos";
    return imagenCreditos;
}


//****************************************************
//*** Implementar Música *****************************
//****************************************************
-(void) startMusica {
    
        NSURL * rutaMusica = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Pintxo1" ofType:@"mp3"]];
        musicaInicial = [[AVAudioPlayer alloc] initWithContentsOfURL:rutaMusica error:nil];
    
        [musicaInicial prepareToPlay];
    
        musicaInicial.numberOfLoops = INFINITY;
        [musicaInicial play];
}

-(void) stopMusica {
    
    [musicaInicial stop];
}


//****************************************************
//*** Implementar transiciones ***********************
//****************************************************
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch * toque = [touches anyObject];
    CGPoint tocarLabel = [toque locationInNode:self];
    SKNode * nodo = [self nodeAtPoint:tocarLabel];
    
    if ([nodo.name isEqualToString:@"juego"]) {
        
        SKTransition * transicion = [SKTransition doorsOpenVerticalWithDuration:2];
        Juego * escena1 = [Juego sceneWithSize:self.frame.size];
        [self.view presentScene:escena1 transition: transicion];
        
        [self stopMusica];
    }
    
    if ([nodo.name isEqualToString:@"imagenCreditos"]) {
        
        SKTransition * transicion = [SKTransition doorsOpenVerticalWithDuration:2];
        Creditos * escena2 = [Creditos sceneWithSize:self.frame.size];
        [self.view presentScene:escena2 transition: transicion];
        
        [self stopMusica];
    }
}

@end
