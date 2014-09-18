//
//  Juego.m
//  TxoroTxori
//
//  Created by Berganza on 16/09/14.
//  Copyright (c) 2014 Berganza. All rights reserved.
//

#import "Juego.h"

    AVAudioPlayer * musicaPintxo;

// Definición de constantes
#define TIME 1.5
#define ALTURA_MINIMA_TXISTU 50.0f
#define DISTANCIA_ENTRE_OBSTACULOS 100.0f


// Integer masking bits, nos ayudan a identificar qué objetos colisionan con otros
static const uint32_t categoriaObstaculos = 0x1<<0;
static const uint32_t categoriaTxori = 0x1<<1;
// Para detectar colisión contra el suelo
static const uint32_t categoriaSuelo = 0x1<<2;

// Velocidad del fondo
static const float VELOCIDAD_SCROLL = (TIME * 60);

// Funciones que nos ahorrarán código más adelante --> HELPERS

// Función para sumar dos puntos
static inline CGPoint PuntoParaSumar(const CGPoint a, const CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

// Función para multiplicar dos puntos
static inline CGPoint PuntoParaEscalar(const CGPoint a, const CGFloat b) {
    return CGPointMake(a.x * b, a.y * b);
}


@implementation Juego

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        // Inicializar fondo estático
        [self fondoEscena:size];
        
        // Inicializar fondo dinámico
        [self fondoScroll];
        
        // Inicializar pájaro
        [self inicializarTxori];
        
        
        // Inicializar música
        [self startPintxo];
        
        
        [self inicializarCapaJuego];
        [self inicializarCapaTximpum];
        
        // Así se le añade gravedad, para que caiga si no se toca la pantalla
        // Ponemos la gravedad a 0.0, para que el pájaro no caiga (negativa hacia abajo, positiva hacia arriba)
        self.physicsWorld.gravity = CGVectorMake(0, 0.0);
        
        // Para detectar colisiones
        self.physicsWorld.contactDelegate = self;
        
        _tximpum = NO;
        _goazen = NO;
        [self comenzarJuego];
        
    }
    return self;
}


// Iniciar música
-(void) startPintxo {
    
    NSURL * rutaMusica = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Pintxo2" ofType:@"mp3"]];
    musicaPintxo = [[AVAudioPlayer alloc] initWithContentsOfURL:rutaMusica error:nil];
    
    [musicaPintxo prepareToPlay];
    
    musicaPintxo.numberOfLoops = INFINITY;
    //[_backgroundAudioPlayer setVolume:1.0];
    [musicaPintxo play];
}

-(void) stopPintxo {
    
    [musicaPintxo stop];
    
}


// Inicializar fondo estático

- (void) fondoEscena:(CGSize) medidaEscena {
    
    self.imagenFondo = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    self.imagenFondo.size = medidaEscena;
    self.imagenFondo.position = CGPointMake(self.imagenFondo.size.width/2, self.frame.size.height/2);
    [self addChild:self.imagenFondo];
}


// Initializar fondo dinámico.
// Para conseguir recrear que el fondo se mueve, tendremos que crear un duplicado del mismo fondo
// y colocarlo justo al final del primero, de forma consecutiva.
// Reconocemos el choque contra el suelo

-(void) fondoScroll {
    
    for (int i = 0; i < 2; i++) {
        
        SKSpriteNode * imagenScroll = [SKSpriteNode spriteNodeWithImageNamed:@"fondoScroll"];
        imagenScroll.zPosition = 100;
        bottomScrollerHeight = imagenScroll.size.height;
        imagenScroll.position = CGPointMake((i * imagenScroll.size.width) + (imagenScroll.size.width * 0.5f) - 1, imagenScroll.size.height * 0.5f);
        imagenScroll.name = @"imagenScroll";
        
        // Creamos la física y su forma geométrica para que las colisiones funcionen de forma óptima
        imagenScroll.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:imagenScroll.size];
        
        // Categoría a la que pertenece el objeto
        imagenScroll.physicsBody.categoryBitMask = categoriaSuelo;
        
        // Notificamos intersecciones con objetos
        imagenScroll.physicsBody.contactTestBitMask = categoriaTxori;
        
        // Detectamos colisiones
        imagenScroll.physicsBody.collisionBitMask = 0;
        
        // Hay que especificar que no le afecta la gravedad, sino el suelo se caería
        
        imagenScroll.physicsBody.affectedByGravity = NO;
        [self addChild:imagenScroll];
    }
}


// Inicializar pájaro. Añadimos 3 imágenes (alas arriba, abajo y plegadas) a un array,y usamos una acción para animarlas y
// recrear el efecto del vuelo.

- (void) inicializarTxori {
    
    NSMutableArray * txoriFrames = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        
        NSString * nombreTextura = nil;
        switch (i) {
                
            case 0: {
                
                nombreTextura = @"txoriVuelo1";
                break;
            }
            case 1: {
                
                nombreTextura = @"txoriVuelo2";
                break;
            }
            case 2: {
                
                nombreTextura = @"txoriVuelo3";
                break;
            }
            default:
                break;
        }
        
        SKTexture * textura = [SKTexture textureWithImageNamed:nombreTextura];
        [txoriFrames addObject:textura];
    }
    
    [self setTxoriFrames:txoriFrames];
    
    self.txoroTxori = [SKSpriteNode spriteNodeWithTexture:[_txoriFrames objectAtIndex:1]];
    
    
    // Creamos la física y su forma geométrica para que las colisiones funcionen de forma óptima
    _txoroTxori.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_txoroTxori.size];
    
    // Categoría a la que pertenece el objeto
    _txoroTxori.physicsBody.categoryBitMask = categoriaTxori;
    
    // Notificamos intersecciones con objetos
    _txoroTxori.physicsBody.contactTestBitMask = categoriaObstaculos | categoriaSuelo;
    
    // Detectamos colisiones
    _txoroTxori.physicsBody.collisionBitMask = 0;
    
    [self addChild:self.txoroTxori];
}

- (void) volarTxori {
    
    // Con este método hacemos al pájaro volar.
    [_txoroTxori runAction:[SKAction repeatActionForever: [SKAction animateWithTextures:_txoriFrames
                                                                           timePerFrame:0.10f
                                                                                 resize:NO
                                                                                restore:YES]]
                   withKey:@"txoriVolando"];
    return;
}


// Capas de inicio y fin de juego

- (void) inicializarCapaJuego {
    
    _goazenCapa = [[Jugar alloc]initWithSize:self.size];
    _goazenCapa.userInteractionEnabled = YES;
    _goazenCapa.zPosition = 150;
    _goazenCapa.delegate = self;
}

- (void) inicializarCapaTximpum {
    
    _tximpumCapa = [[Tximpum alloc]initWithSize:self.size];
    _tximpumCapa.userInteractionEnabled = YES;
    _tximpumCapa.zPosition = 200;
    _tximpumCapa.delegate = self;
}

- (void) comenzarJuego {
    
    // Eliminar el obstaculo actual de la escena
    for (NSInteger i = self.children.count - 1; i >= 0; i--) {
        
        SKNode * nodo = [self.children objectAtIndex:i];
        if(nodo.physicsBody.categoryBitMask == categoriaObstaculos) {
            
            [nodo removeFromParent];
        }
    }
    
    // Mover el nodo del pájaro al centro de la escena
    self.txoroTxori.position = CGPointMake(self.imagenFondo.size.width * 0.5f, self.frame.size.height * 0.6f);
    
    [_tximpumCapa removeFromParent];
    _txoroTxori.hidden = NO;
    [self volarTxori];
    [self addChild:_goazenCapa];
}

- (void) finJuego {
    
    // Eliminar el obstaculo actual de la escena
    for (NSInteger i = self.children.count - 1; i >= 0; i--) {
        
        SKNode * nodo = [self.children objectAtIndex:i];
        if(nodo.physicsBody.categoryBitMask == categoriaObstaculos) {
            
            [nodo removeAllActions];
        }
    }
    
    [_txoroTxori removeAllActions];
    _txoroTxori.physicsBody.velocity = CGVectorMake(0, 0);
    self.physicsWorld.gravity = CGVectorMake(0, 0.0);
    _txoroTxori.hidden = YES;
    
    _tximpum = YES;
    _goazen = NO;
    
    tiempo = 0;
    _adaptacionTimeInterval = 0;
    _ultimoTimeInterval = 0;
    
    [_goazenCapa removeFromParent];
    
    [self addChild:_tximpumCapa];
}

- (void) startGame {
    
    _puntos = 0;
    _goazen = YES;
    [_goazenCapa removeFromParent];
    [_tximpumCapa removeFromParent];
    
    self.txoroTxori.position = CGPointMake(self.imagenFondo.size.width * 0.28f, self.frame.size.height * 0.7f);
    
    // Añadimos la gravedad, para que el pájaro caiga si no tocamos la pantalla
    self.physicsWorld.gravity = CGVectorMake(0, -5.0);
}


// Procedemos a crear los obstaculos contra los que se chocará nuestro txoria
// En este caso, txistus y chimeneas del Parque Etxebarria ;)

// Con este método hacemos que los obstaculos se muevan de derecha a izquierda

- (void) sumarObstaculos {
    
    // Creamos las chimeneas (obstaculos hacia arriba)
    SKSpriteNode * obstaculosInferiores = [self crearDireccionObstaculo:YES];
    
    int minY = ALTURA_MINIMA_TXISTU;
    int maxY = self.frame.size.height - bottomScrollerHeight - DISTANCIA_ENTRE_OBSTACULOS - ALTURA_MINIMA_TXISTU;
    int rangoY = maxY - minY;
    
    float obstaculosInferioresY = ((arc4random() % rangoY) + minY) - obstaculosInferiores.size.height;
    obstaculosInferioresY += bottomScrollerHeight;
    obstaculosInferioresY += obstaculosInferiores.size.height * 0.5f;
    
    
    // Indicar posición de los obstaculos. Primero fuera de la pantalla, así nos aseguramos que la imagen se ha creado cuando entra en la zona visible.
    obstaculosInferiores.position = CGPointMake(self.frame.size.width + obstaculosInferiores.size.width/2, obstaculosInferioresY);
    
    
    // Creamos los txistus (obstaculos hacia abajo)
    SKSpriteNode* obstaculosSuperiores = [self crearDireccionObstaculo:NO];
    float obstaculosSuperioresY = obstaculosInferioresY + obstaculosInferiores.size.height + DISTANCIA_ENTRE_OBSTACULOS;
    obstaculosSuperiores.position = CGPointMake(obstaculosInferiores.position.x, obstaculosSuperioresY);
    
    
    // Acciones de los obstaculos. Lo primero, moverlo de derecha a izquierda, cuando se complete la acción, eliminar nodo de la escena.
    
    // Creamos las acciones de las chimeneas
    SKAction * obstaculosInferioresActionMove = [SKAction moveTo:CGPointMake(-obstaculosInferiores.size.width/2, obstaculosInferioresY) duration:(TIME * 2)];
    SKAction * obstaculosInferioresActionMoveDone = [SKAction removeFromParent];
    [obstaculosInferiores runAction:[SKAction sequence:@[obstaculosInferioresActionMove, obstaculosInferioresActionMoveDone]]];
    
    
    // Creamos las acciones de los txistus
    SKAction * obstaculosSuperioresActionMove = [SKAction moveTo:CGPointMake(-obstaculosSuperiores.size.width/2, obstaculosSuperioresY) duration:(TIME * 2)];
    SKAction * obstaculosSuperioresActionMoveDone = [SKAction removeFromParent];
    [obstaculosSuperiores runAction:[SKAction sequence:@[obstaculosSuperioresActionMove, obstaculosSuperioresActionMoveDone]]];
}


// Con este método creamos obstaculos en la dirección que queremos

- (SKSpriteNode *) crearDireccionObstaculo:(BOOL) paraArriba {
    
    NSString * imagenObstaculo = nil;
    
    if (paraArriba) {
        imagenObstaculo = @"chimenea";
    } else {
        imagenObstaculo = @"txistu";
    }
    
    SKSpriteNode * obstaculo = [SKSpriteNode spriteNodeWithImageNamed:imagenObstaculo];
    obstaculo.name = @"Obstaculos";
    
    //Creamos la física y su forma geométrica para que las colisiones funcionen de forma óptima
    obstaculo.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:obstaculo.size];
    
    // Categoría a la que pertenece el objeto
    obstaculo.physicsBody.categoryBitMask = categoriaObstaculos;
    
    // Notificamos intersección con objetos
    obstaculo.physicsBody.contactTestBitMask = categoriaTxori;
    
    // Detectamos colisión con objetos. Por defecto, todas las categorías.
    obstaculo.physicsBody.collisionBitMask = 0;
    
    
    // Hay que especificar que no le afecta la gravedad, sino los pilares se caerían
    obstaculo.physicsBody.affectedByGravity = NO;
    
    [self addChild:obstaculo];
    
    return obstaculo;
}


// Le damos sensación de movimiento al suelo

- (void) crearScroll {
    
    [self enumerateChildNodesWithName:@"imagenScroll" usingBlock: ^(SKNode * nodo, BOOL *stop) {
        
        SKSpriteNode * imagenScroll = (SKSpriteNode *) nodo;
        CGPoint velocidadScroll = CGPointMake(-VELOCIDAD_SCROLL, 0);
        CGPoint movimiento = PuntoParaEscalar(velocidadScroll,tiempo);
        imagenScroll.position = PuntoParaSumar(imagenScroll.position, movimiento);
        
        // Comprobar que el nodo del fondo ha pasado por completo, si es así volver a colocarlo al final del otro nodo
        if (imagenScroll.position.x + imagenScroll.size.width * 0.5f <= 0) {
            
            imagenScroll.position = CGPointMake(imagenScroll.size.width * 2 - (imagenScroll.size.width * 0.5f) - 2, imagenScroll.position.y);
        }
    }];
} // Al terminarlo, lo añadimos al método update:, que es el que marca el paso del tiempo...ciclo de vida del juego


// Creamos obstaculos a partir de un tiempo determinado, para dar la sensación de que aparecen y dar tiempo a empezar al jugador

- (void) adaptarTiempo:(CFTimeInterval) ultimaAdaptacionTiempo {
    
    self.ultimoTimeInterval += ultimaAdaptacionTiempo;
    if (self.ultimoTimeInterval > TIME) {
        
        self.ultimoTimeInterval = 0;
        [self sumarObstaculos];
    }
}


// Método update: incluir explicación sobre el ciclo del juego (Game loop)

- (void) update:(NSTimeInterval) currentTime {
    
    if(_tximpum == NO) {
        
        if (self.adaptacionTimeInterval) {
            tiempo = currentTime - _adaptacionTimeInterval;
        } else {
            tiempo = 0;
        }
        
        CFTimeInterval ultimaAdaptacionTiempo = currentTime - self.adaptacionTimeInterval;
        self.adaptacionTimeInterval = currentTime;
        if (ultimaAdaptacionTiempo > TIME) {
            
            ultimaAdaptacionTiempo = 1.0 / (TIME * 60.0);
            self.adaptacionTimeInterval = currentTime;
        }
        
        [self crearScroll];
        [self puntuacion];
        
        if(_goazen) {
            
            [self adaptarTiempo:ultimaAdaptacionTiempo];
        }
    }
}


// Detección de colisiones, cuando ocurra --> Tximpum

- (void) obstaculo:(SKSpriteNode *)obstaculo colisionarConObstaculo:(SKSpriteNode *)txori {
    
    [self finJuego];
}

- (void) txoroTxori:(SKSpriteNode *)txori colisionarConSuelo:(SKSpriteNode *)suelo {
    
    [self finJuego];
}


// Método para detectar la colisión entre nuestro txoria con los chistus, las chimeneas y el suelo

- (void) didBeginContact:(SKPhysicsContact *)contact {
    
    SKPhysicsBody * elemento1, * elemento2;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        
        elemento1 = contact.bodyA;
        elemento2 = contact.bodyB;
        
    } else {
        
        elemento1 = contact.bodyB;
        elemento2 = contact.bodyA;
    }
    
    SKAction * sonido1 = [SKAction playSoundFileNamed:@"golpeTxori.mp3" waitForCompletion:YES];
    
    [self runAction:sonido1];
    
    if ((elemento1.categoryBitMask & categoriaObstaculos) != 0 && (elemento2.categoryBitMask & categoriaTxori) != 0) {
        
        [self obstaculo:(SKSpriteNode *) elemento1.node colisionarConObstaculo:(SKSpriteNode *) elemento2.node];
        
    } else if ((elemento1.categoryBitMask & categoriaTxori) != 0 && (elemento2.categoryBitMask & categoriaSuelo) != 0) {
        
        [self txoroTxori:(SKSpriteNode *)elemento1.node colisionarConSuelo:(SKSpriteNode *)elemento2.node];
    }
    
    SKAction * sonido2 = [SKAction playSoundFileNamed:@"golpeTxori.mp3" waitForCompletion:YES];
    
    [self runAction:sonido2];
}

// Con este método conseguimos que el pájaro vuele cuando tocamos la pantalla.
// Añadimos una velocidad positiva en el eje Y, acelera y empieza a volar una vez termina la aceleración

- (void) touchesBegan:(NSSet *) touches withEvent:(UIEvent *) event {
    
    if(_goazen && _tximpum == NO) {
        
        _txoroTxori.physicsBody.velocity = CGVectorMake(0, 250);
    }
}

// Delegados, métodos para pantallas de Inicio, Tximpum y actualización de resultado (por consola)

- (void)capaInicio:(Jugar *)sender pulsarBoton:(BotonInicio)botonInicio {
    
    _tximpum = NO;
    _goazen = YES;
    
    // Label puntuación
    _puntacion = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];
    _puntacion.text = @" 0";
    _puntacion.fontSize = 24;
    _puntacion.position = CGPointMake(self.size.width /2, self.size.height * 9/10);
    _puntacion.zPosition = 5;
    
    [self addChild:_puntacion];
    
    [self startGame];
}

- (void)gameOverLayer:(Tximpum *)sender pulsarBoton:(BotonCapaTximpum)botonCapaTximpum {
    
    _tximpum = NO;
    _goazen = NO;
    [_puntacion removeFromParent];
    
    [self comenzarJuego];
    
}

// Método para actualizar el resultado: Por consola
- (void) puntuacion {
    
    [self enumerateChildNodesWithName:@"Obstaculos" usingBlock:^(SKNode * nodo, BOOL * stop) {
        if(_txoroTxori.position.x > nodo.position.x) {
            
            nodo.name = @"";    // Resetear a un nombre vacío, para no contar el obstaculo una vez ha pasado la posición del pájaro.
            
            ++_puntos;
            
            
            // Al haber dos obstaculos (txistus y chimeneas), esta función se ejecutará dos veces, por tanto, dividimos
            // el resultado entre 2, para obtener el resultado correcto.
            
            if (_puntos % 2 == 0) {
                
                _puntacion.text = [NSString stringWithFormat:@" %i", _puntos/2];
            }
            
            * stop = YES;    // Paramos de contar
        }
    }];
}

@end

