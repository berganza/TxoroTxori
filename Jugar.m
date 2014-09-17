//
//  Jugar.m
//  TxoroTxori
//
//  Created by Berganza on 16/09/14.
//  Copyright (c) 2014 Berganza. All rights reserved.
//

#import "Jugar.h"
#import "Menu.h"

    AVAudioPlayer * musicaPintxo;

@interface Jugar()
@property (nonatomic, retain) SKSpriteNode* playButton;
@end

@implementation Jugar

- (id)initWithSize:(CGSize)size
{
    if(self = [super initWithSize:size])
    {
        SKSpriteNode* startGameText = [SKSpriteNode spriteNodeWithImageNamed:@"tituloTxori"];
        startGameText.position = CGPointMake(size.width * 0.5f, size.height * 0.8f);
        [self addChild:startGameText];
        
        SKSpriteNode* playButton = [SKSpriteNode spriteNodeWithImageNamed:@"botonPlay"];
        playButton.position = CGPointMake(size.width * 0.5f, size.height * 0.50f);
        [self addChild:playButton];
        
        _altavoz = [SKSpriteNode spriteNodeWithImageNamed:@"altavoz1"];
        _altavoz.position = CGPointMake(size.width * 0.9f, size.height * 0.95f);
        _altavoz.name = @"altavoz";
        _musicaBoton = 1;
        
        [self addChild:_altavoz];
        
        [self setPlayButton:playButton];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode * nodo = [self nodeAtPoint:location];
    
    if ([_playButton containsPoint:location])
    {
        if([self.delegate respondsToSelector:@selector(startGameLayer:tapRecognizedOnButton:)])
        {
            [self.delegate startGameLayer:self tapRecognizedOnButton:StartGameLayerPlayButton];
        }
    }
    
    if ([nodo.name isEqualToString:@"altavoz"]) {
        
        if (_musicaBoton == 1) {
            _musicaBoton = 0;
            [self stopPintxo];
            //[_altavoz removeFromParent];
        } else {
            _musicaBoton = 0;
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
