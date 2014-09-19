//
//  Juego.h
//  TxoroTxori
//
//  Created by Berganza on 16/09/14.
//  Copyright (c) 2014 Berganza. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Jugar.h"
#import "Tximpum.h"
#import "Menu.h"

@interface Juego : SKScene <SKPhysicsContactDelegate, GoazenDelegate, TximpumDelegate> {
    
    // Declaramos variables privadas + setters y getters
    NSTimeInterval tiempo;
    float bottomScrollerHeight;
    
    BOOL _goazen;
    BOOL _tximpum;
    
    Jugar * _goazenCapa;
    Tximpum * _tximpumCapa;
    
    int _puntos;
}

// Cada escena en SpriteKit se compone de nodos, siendo los sprites los más comunes
// Los utilizamos para cargar imágenes y añadirlas a la escena mediante el objeto SKSpriteNode
@property (nonatomic) SKSpriteNode * imagenFondo;
@property (nonatomic) SKSpriteNode * txoroTxori;

@property (nonatomic) NSTimeInterval ultimoTimeInterval;
@property (nonatomic) NSTimeInterval adaptacionTimeInterval;

// Para los diferentes estados del pájaro: Alas arriba, abajo y plegadas, para simular el vuelo.
@property (nonatomic) NSArray * txoriFrames;

@property SKLabelNode * puntacion;

@end

