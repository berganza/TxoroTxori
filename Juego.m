//
//  Juego.m
//  TxoroTxori
//
//  Created by Berganza on 16/09/14.
//  Copyright (c) 2014 Berganza. All rights reserved.
//

#import "Juego.h"
#import "Jugar.h"
#import "Tximpum.h"
#import "Menu.h"


    AVAudioPlayer * musicaPintxo;

// Definición de constantes
#define TIME 1.5
#define MINIMUM_PILLER_HEIGHT 50.0f
#define GAP_BETWEEN_TOP_AND_BOTTOM_PILLER 100.0f

#define PILLARS     @"Pillars"
#define UPWARD_PILLER @"chimenea"
#define Downward_PILLER @"txistu"

#define BOTTOM_BACKGROUND_Z_POSITION    100
#define START_GAME_LAYER_Z_POSITION     150
#define GAME_OVER_LAYER_Z_POSITION      200


// Integer masking bits, nos ayudan a identificar qué objetos colisionan con otros
static const uint32_t pillerCategory            =  0x1 << 0;
static const uint32_t heganTxoriCategory        =  0x1 << 1;
// Para detectar colisión contra el suelo
static const uint32_t bottomBackgroundCategory  =  0x1 << 2;

// Velocidad del fondo
static const float BG_VELOCITY = (TIME * 60);

// Funciones que nos ahorrarán código más adelante --> HELPERS

// Función para sumar dos puntos
static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

// Función para multiplicar dos puntos
static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

// Declaramos variables privadas + setters y getters
@interface Juego() <SKPhysicsContactDelegate,StartGameLayerDelegate,GameOverLayerDelegate>
{
    NSTimeInterval _dt;
    float bottomScrollerHeight;
    
    BOOL _gameStarted;
    BOOL _gameOver;
    
    Jugar* _startGameLayer;
    Tximpum* _gameOverLayer;
    
    int _score;
}

// Cada escena en SpriteKit se compone de nodos, siendo los sprites los más comunes
// Los utilizamos para cargar imágenes y añadirlas a la escena mediante el objeto SKSpriteNode
@property (nonatomic) SKSpriteNode* backgroundImageNode;
@property (nonatomic) SKSpriteNode* heganTxori;

@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

// Para los diferentes estados del pájaro: Alas arriba, abajo y plegadas, para simular el vuelo.
@property (nonatomic) NSArray* heganTxoriFrames;
@end


@implementation Juego

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        // Inicializar fondo estático
        [self initializeBackGround:size];
        
        // Inicializar fondo dinámico
        [self initalizingScrollingBackground];
        
        // Inicializar pájaro
        [self initializeBird];
        
        
        // Inicializar música
        [self startPintxo];
        
        
        [self initializeStartGameLayer];
        [self initializeGameOverLayer];
        
        // Así se le añade gravedad, para que caiga si no se toca la pantalla
        // Ponemos la gravedad a 0.0, para que el pájaro no caiga (negativa hacia abajo, positiva hacia arriba)
        self.physicsWorld.gravity = CGVectorMake(0, 0.0);
        
        // Para detectar colisiones
        self.physicsWorld.contactDelegate = self;
        
        _gameOver = NO;
        _gameStarted = NO;
        [self showStartGameLayer];

        
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











// Mostrar resultado por pantalla



// Inicializar fondo estático

- (void) initializeBackGround:(CGSize) sceneSize
{
    self.backgroundImageNode = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    self.backgroundImageNode.size = sceneSize;
    self.backgroundImageNode.position = CGPointMake(self.backgroundImageNode.size.width/2, self.frame.size.height/2);
    [self addChild:self.backgroundImageNode];
}




// Initializar fondo dinámico.
// Para conseguir recrear que el fondo se mueve, tendremos que crear un duplicado del mismo fondo
// y colocarlo justo al final del primero, de forma consecutiva.
// Reconocemos el choque contra el suelo

-(void)initalizingScrollingBackground
{
    for (int i = 0; i < 2; i++)
    {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"fondoScroll"];
        bg.zPosition = BOTTOM_BACKGROUND_Z_POSITION;
        bottomScrollerHeight = bg.size.height;
        bg.position = CGPointMake((i * bg.size.width) + (bg.size.width * 0.5f) - 1, bg.size.height * 0.5f);
        bg.name = @"bg";
        
        
        // Creamos la física y su forma geométrica para que las colisiones funcionen de forma óptima
        bg.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bg.size];
        
        // Categoría a la que pertenece el objeto
        bg.physicsBody.categoryBitMask = bottomBackgroundCategory;
        
        // Notificamos intersecciones con objetos
        bg.physicsBody.contactTestBitMask = heganTxoriCategory;
        
        // Detectamos colisiones
        bg.physicsBody.collisionBitMask = 0;
        
        
        // Hay que especificar que no le afecta la gravedad, sino el suelo se caería
        
        bg.physicsBody.affectedByGravity = NO;
        [self addChild:bg];
    }
}






// Inicializar pájaro. Añadimos 3 imágenes (alas arriba, abajo y plegadas) a un array,y usamos una acción para animarlas y
// recrear el efecto del vuelo.

- (void)initializeBird
{
    NSMutableArray *heganTxoriFrames = [NSMutableArray array];
    for (int i = 0; i < 3; i++)
    {
        NSString* textureName = nil;
        switch (i)
        {
            case 0:
            {
                textureName = @"txoriVuelo1";
                break;
            }
            case 1:
            {
                textureName = @"txoriVuelo2";
                break;
            }
            case 2:
            {
                textureName = @"txoriVuelo3";
                break;
            }
            default:
                break;
        }
        
        SKTexture* texture = [SKTexture textureWithImageNamed:textureName];
        [heganTxoriFrames addObject:texture];
    }
    [self setHeganTxoriFrames:heganTxoriFrames];
    
    self.heganTxori = [SKSpriteNode spriteNodeWithTexture:[_heganTxoriFrames objectAtIndex:1]];
    
    
    // Creamos la física y su forma geométrica para que las colisiones funcionen de forma óptima
    _heganTxori.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_heganTxori.size];
    
    // Categoría a la que pertenece el objeto
    _heganTxori.physicsBody.categoryBitMask = heganTxoriCategory;
    
    // Notificamos intersecciones con objetos
    _heganTxori.physicsBody.contactTestBitMask = pillerCategory | bottomBackgroundCategory;
    
    // Detectamos colisiones
    _heganTxori.physicsBody.collisionBitMask = 0;
    
    [self addChild:self.heganTxori];
}

- (void) flyingBird
{
    // Con este método hacemos al pájaro volar.
    [_heganTxori runAction:[SKAction repeatActionForever:
                            [SKAction animateWithTextures:_heganTxoriFrames
                                             timePerFrame:0.15f
                                                   resize:NO
                                                  restore:YES]] withKey:@"flyingheganTxori"];
    return;
}




// Capas de inicio y fin de juego

- (void) initializeStartGameLayer
{
    _startGameLayer = [[Jugar alloc]initWithSize:self.size];
    _startGameLayer.userInteractionEnabled = YES;
    _startGameLayer.zPosition = START_GAME_LAYER_Z_POSITION;
    _startGameLayer.delegate = self;
}

- (void) initializeGameOverLayer
{
    _gameOverLayer = [[Tximpum alloc]initWithSize:self.size];
    _gameOverLayer.userInteractionEnabled = YES;
    _gameOverLayer.zPosition = GAME_OVER_LAYER_Z_POSITION;
    _gameOverLayer.delegate = self;
}

- (void) showStartGameLayer
{
    // Eliminar el pilar actual de la escena
    for (NSInteger i = self.children.count - 1; i >= 0; i--)
    {
        SKNode* childNode = [self.children objectAtIndex:i];
        if(childNode.physicsBody.categoryBitMask == pillerCategory)
        {
            [childNode removeFromParent];
        }
    }
    
    // Mover el nodo del pájaro al centro de la escena
    self.heganTxori.position = CGPointMake(self.backgroundImageNode.size.width * 0.5f, self.frame.size.height * 0.6f);
    
    [_gameOverLayer removeFromParent];
    
    _heganTxori.hidden = NO;
    [self flyingBird];
    [self addChild:_startGameLayer];
}

- (void) showGameOverLayer
{
    // Eliminar el pilar actual de la escena
    for (NSInteger i = self.children.count - 1; i >= 0; i--)
    {
        SKNode* childNode = [self.children objectAtIndex:i];
        if(childNode.physicsBody.categoryBitMask == pillerCategory)
        {
            [childNode removeAllActions];
        }
    }
    
    [_heganTxori removeAllActions];
    _heganTxori.physicsBody.velocity = CGVectorMake(0, 0);
    self.physicsWorld.gravity = CGVectorMake(0, 0.0);
    _heganTxori.hidden = YES;
    
    _gameOver = YES;
    _gameStarted = NO;
    
    _dt = 0;
    _lastUpdateTimeInterval = 0;
    _lastSpawnTimeInterval = 0;
    
    
    [_startGameLayer removeFromParent];
    [self addChild:_gameOverLayer];
}

- (void) startGame
{
    _score = 0;
    
    _gameStarted = YES;
    
    [_startGameLayer removeFromParent];
    [_gameOverLayer removeFromParent];
    
    self.heganTxori.position = CGPointMake(self.backgroundImageNode.size.width * 0.3f, self.frame.size.height * 0.6f);
    
    // Añadimos la gravedad, para que el pájaro caiga si no tocamos la pantalla
    self.physicsWorld.gravity = CGVectorMake(0, -4.0);
}




// Procedemos a crear los pilares contra los que se chocará nuestro txoria
// En este caso, txistus y chimeneas del Parque Etxebarria ;)


// Con este método hacemos que los pilares se muevan de derecha a izquierda

- (void)addAPiller
{
    // Creamos las chimeneas (pilares hacia arriba)
    SKSpriteNode* upwardPiller = [self createPillerWithUpwardDirection:YES];
    
    int minY = MINIMUM_PILLER_HEIGHT;
    int maxY = self.frame.size.height - bottomScrollerHeight - GAP_BETWEEN_TOP_AND_BOTTOM_PILLER - MINIMUM_PILLER_HEIGHT;
    int rangeY = maxY - minY;
    
    float upwardPillerY = ((arc4random() % rangeY) + minY) - upwardPiller.size.height;
    upwardPillerY += bottomScrollerHeight;
    upwardPillerY += upwardPiller.size.height * 0.5f;
    
    
    // Indicar posición de los pilares. Primero fuera de la pantalla, así nos aseguramos que la imagen se ha creado cuando entra en la zona visible.
    upwardPiller.position = CGPointMake(self.frame.size.width + upwardPiller.size.width/2, upwardPillerY);
    
    
    // Creamos los txistus (pilares hacia abajo)
    SKSpriteNode* downwardPiller = [self createPillerWithUpwardDirection:NO];
    float downloadPillerY = upwardPillerY + upwardPiller.size.height + GAP_BETWEEN_TOP_AND_BOTTOM_PILLER;
    downwardPiller.position = CGPointMake(upwardPiller.position.x, downloadPillerY);
    
    
    // Acciones de los pilares. Lo primero, moverlo de derecha a izquierda, cuando se complete la acción, eliminar nodo de la escena.
    
    // Creamos las acciones de las chimeneas
    SKAction * upwardPillerActionMove = [SKAction moveTo:CGPointMake(-upwardPiller.size.width/2, upwardPillerY) duration:(TIME * 2)];
    SKAction * upwardPillerActionMoveDone = [SKAction removeFromParent];
    [upwardPiller runAction:[SKAction sequence:@[upwardPillerActionMove, upwardPillerActionMoveDone]]];
    
    
    // Creamos las acciones de los txistus
    SKAction * downwardPillerActionMove = [SKAction moveTo:CGPointMake(-downwardPiller.size.width/2, downloadPillerY) duration:(TIME * 2)];
    SKAction * downwardPillerActionMoveDone = [SKAction removeFromParent];
    [downwardPiller runAction:[SKAction sequence:@[downwardPillerActionMove, downwardPillerActionMoveDone]]];
}




// Con este método creamos pilares en la dirección que queremos

- (SKSpriteNode*) createPillerWithUpwardDirection:(BOOL) isUpwards
{
    NSString* pillerImageName = nil;
    if (isUpwards)
    {
        pillerImageName = UPWARD_PILLER;
    }
    else
    {
        pillerImageName = Downward_PILLER;
    }
    
    SKSpriteNode * piller = [SKSpriteNode spriteNodeWithImageNamed:pillerImageName];
    piller.name = PILLARS;
    
    //Creamos la física y su forma geométrica para que las colisiones funcionen de forma óptima
    piller.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:piller.size];
    
    // Categoría a la que pertenece el objeto
    piller.physicsBody.categoryBitMask = pillerCategory;
    
    // Notificamos intersección con objetos
    piller.physicsBody.contactTestBitMask = heganTxoriCategory;
    
    // Detectamos colisión con objetos. Por defecto, todas las categorías.
    piller.physicsBody.collisionBitMask = 0;
    
    
    // Hay que especificar que no le afecta la gravedad, sino los pilares se caerían
    piller.physicsBody.affectedByGravity = NO;
    
    [self addChild:piller];
    
    return piller;
}




// Le damos sensación de movimiento al suelo

- (void)moveBottomScroller
{
    [self enumerateChildNodesWithName:@"bg" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode * bg = (SKSpriteNode *) node;
         CGPoint bgVelocity = CGPointMake(-BG_VELOCITY, 0);
         CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,_dt);
         bg.position = CGPointAdd(bg.position, amtToMove);
         
         // Comprobar que el nodo del fondo ha pasado por completo, si es así volver a colocarlo al final del otro nodo
         if (bg.position.x + bg.size.width * 0.5f <= 0)
         {
             bg.position = CGPointMake(bg.size.width*2 - (bg.size.width * 0.5f) - 2,
                                       bg.position.y);
         }
     }];
} // Al terminarlo, lo añadimos al método update:, que es el que marca el paso del tiempo...ciclo de vida del juego





// Creamos pilares a partir de un tiempo determinado, para dar la sensación de que aparecen y dar tiempo a empezar al jugador

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast
{
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > TIME)
    {
        self.lastSpawnTimeInterval = 0;
        [self addAPiller];
    }
}




// Método update: , incluir explicación sobre el ciclo del juego (Game loop)

- (void)update:(NSTimeInterval)currentTime
{
    if(_gameOver == NO)
    {
        if (self.lastUpdateTimeInterval)
        {
            _dt = currentTime - _lastUpdateTimeInterval;
        }
        else
        {
            _dt = 0;
        }
        
        CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
        self.lastUpdateTimeInterval = currentTime;
        if (timeSinceLast > TIME)
        {
            timeSinceLast = 1.0 / (TIME * 60.0);
            self.lastUpdateTimeInterval = currentTime;
        }
        
        [self moveBottomScroller];
        [self updateScore];
        
        if(_gameStarted)
        {
            [self updateWithTimeSinceLastUpdate:timeSinceLast];
        }
    }
}



// Detección de colisiones, cuando ocurra --> Tximpum

- (void)pillar:(SKSpriteNode *)pillar didCollideWithBird:(SKSpriteNode *)txori
{
    [self showGameOverLayer];
}

- (void)heganTxori:(SKSpriteNode *)txori didCollideWithBottomScoller:(SKSpriteNode *)bottomBackground
{
    [self showGameOverLayer];
}



// Método para detectar la colisión entre nuestro txoria con los chistus, las chimeneas y el suelo

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & pillerCategory) != 0 &&
        (secondBody.categoryBitMask & heganTxoriCategory) != 0)
    {
        [self pillar:(SKSpriteNode *) firstBody.node didCollideWithBird:(SKSpriteNode *) secondBody.node];
    }
    else if ((firstBody.categoryBitMask & heganTxoriCategory) != 0 &&
             (secondBody.categoryBitMask & bottomBackgroundCategory) != 0)
    {
        [self heganTxori:(SKSpriteNode *)firstBody.node didCollideWithBottomScoller:(SKSpriteNode *)secondBody.node];
    }
}




// Con este método conseguimos que el pájaro vuele cuando tocamos la pantalla.
// Añadimos una velocidad positiva en el eje Y, acelera y empieza a acer una vez termina la aceleración

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_gameStarted && _gameOver == NO)
    {
        _heganTxori.physicsBody.velocity = CGVectorMake(0, 250);
    }
}





// Delegados, métodos para pantallas de Inicio, Tximpum y actualización de resultado (por consola)

- (void)startGameLayer:(Jugar *)sender tapRecognizedOnButton:(StartGameLayerButtonType)startGameLayerButton
{
    _gameOver = NO;
    _gameStarted = YES;
    
    // Label puntuación
    _puntacion = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];
    _puntacion.text = @"Puntos: 0";
    _puntacion.fontSize = 24;
    _puntacion.position = CGPointMake(self.size.width * 0.2f, self.size.height * 9/10);
    _puntacion.zPosition = 5;
    [self addChild:_puntacion];
    
    [self startGame];
}

- (void)gameOverLayer:(Tximpum *)sender tapRecognizedOnButton:(GameOverLayerButtonType)gameOverLayerButtonType
{
    _gameOver = NO;
    _gameStarted = NO;
    [_puntacion removeFromParent];
    
    [self showStartGameLayer];
    
}

// Método para actualizar el resultado: Por consola
- (void) updateScore
{
    [self enumerateChildNodesWithName:PILLARS usingBlock:^(SKNode *node, BOOL *stop)
     {
         if(_heganTxori.position.x > node.position.x)
         {
             node.name = @"";    // Resetear a un nombre vacío, para no contar el pilar una vez ha pasado la posición del pájaro.
             
             ++_score;
             
             
             // Al haber dos pilares (txistus y chimeneas), esta función se ejecutará dos veces, por tanto, dividimos
             // el resultado entre 2, para obtener el resultado correcto.
             
             if (_score % 2 == 0)
             {
                 //NSLog(@"Resultado: %d", _score/2);
                 _puntacion.text = [NSString stringWithFormat:@"Puntos :%i", _score/2];
             }
             
             *stop = YES;    // Paramos de contar
         }
     }];
}

@end

