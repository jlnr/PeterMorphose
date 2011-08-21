unit PMConst;

interface

const
  // Aktuelle Version
  PMVersion            =  'Final';

  // Spielstatuskonstanten
  State_Welcome        =   0;
  State_MainMenu       =   1;
  State_Options        =   5;
  State_Options2       =   6;
  State_LevelSelection =  10;
  State_Game           = 100;
  State_Dead           = 101;
  State_Won            = 102;
  State_WonInfo        = 103;
  State_Paused         = 104;
  State_ReadMe1        = 200;
  State_ReadMe2        = 201;
  State_ReadMe3        = 202;
  State_ReadMe4        = 203;
  State_ReadMe5        = 204;
  State_ReadMe6        = 205;
  State_ReadMe7        = 206;
  State_ReadMe8        = 207;
  State_Credits        = 220;

  // Bilder
  Image_Sky            =   0;
  Image_Player         =   1;
  Image_Enemies        =   2;
  Image_Stuff          =   3;
  Image_Effects        =   4;
  Image_Danger         =   5;
  Image_Tiles          =   6;
  Image_GUI            =   7;

  // Geräusche
  Sound_Woosh          =   0;
  Sound_WooshBack      =   1;

  Sound_PlayerArg      =   0;
  Sound_Jump           =   1;
  Sound_Arg            =   2;
  Sound_Arg2           =   3;
  Sound_Death          =   4;
  Sound_Help           =   5;
  Sound_Help2          =   6;
  Sound_Jeepee         =   7;
  Sound_StarCollect    =   8;
  Sound_HealthCollect  =   9;
  Sound_PointCollect   =  10;
  Sound_AmmoCollect    =  11;
  Sound_FreezeCollect  =  12;
  Sound_KeyCollect     =  13;
  Sound_Morph          =  14;
  Sound_Eat            =  15;
  Sound_Slime          =  16;
  Sound_Slime2         =  17;
  Sound_Slime3         =  18;
  Sound_Door           =  19;
  Sound_Door2          =  20;
  Sound_Stairs         =  21;
  Sound_StairsRnd      =  22;
  Sound_Break          =  23;
  Sound_Break2         =  24;
  Sound_Water          =  25;
  Sound_Water2         =  26;
  Sound_Lava           =  27;
  Sound_Shshsh         =  28;
  Sound_Explosion      =  29;
  Sound_Turbo          =  30;
  Sound_Lever          =  31;
  Sound_SwordWoosh     =  32;
  Sound_BlockerBreak   =  33;
  Sound_Bow            =  34;
  Sound_ArrowHit       =  35;

  // Actions für ID_Player - ID_LivingMax
  Act_Num              =  20;
  Act_Stand            =   0;
  Act_Walk1            =   1;
  Act_Walk2            =   2;
  Act_Walk3            =   3;
  Act_Walk4            =   4;
  Act_Jump             =   5;
  Act_Land             =   6;
  Act_Impact1          =   7;
  Act_Impact2          =   8;
  Act_Impact3          =   9;
  Act_Impact4          =  10;
  Act_Impact5          =  11;
  Act_Action1          =  12;
  Act_Action2          =  13;
  Act_Action3          =  14;
  Act_Action4          =  15;
  Act_Action5          =  16;
  Act_Pain1            =  17;
  Act_Pain2            =  18;
  Act_Dead             =  19;
  Act_InvUp            =  20;
  Act_InvDown          =  21;

  // Richtungen
  Dir_Left             =   0;
  Dir_Right            =   1;
  Dir_Up               =   2;
  Dir_Down             =   3;

  // Spezialkartenteile
  // Massiv, erste Reihe
  Tile_RocketUp          = $C0;
  Tile_RocketUpLeft      = $C1;
  Tile_RocketUpRight     = $C2;
  Tile_RocketUp2         = $C3;
  Tile_RocketUpLeft2     = $C4;
  Tile_RocketUpRight2    = $C5;
  Tile_RocketUp3         = $C6;
  Tile_MorphFighter      = $C7;
  Tile_MorphGun          = $C8;
  Tile_MorphBerserker    = $C9;
  Tile_MorphBomb         = $CA;
  Tile_MorphMax          = $CA;
  Tile_MorphEmpty        = $CB;
  Tile_ClosedDoor        = $CC;
  Tile_ClosedDoor2       = $CD;
  Tile_ClosedDoor3       = $CE;
  Tile_BigBlocker3       = $CF;
  // Massiv, zweite Reihe
  Tile_Blocker           = $D0;
  Tile_Blocker2          = $D1;
  Tile_Blocker3          = $D2;
  Tile_BigBlocker        = $D3;
  Tile_BigBlocker2       = $D4;
  Tile_RocketUpLeft3     = $D5;
  Tile_RocketUpRight3    = $D6;
  Tile_PullLeft          = $D7;
  Tile_PullRight         = $D8;
  Tile_Slime             = $D9;
  Tile_Slime2            = $DA;
  Tile_Slime3            = $DB;
  Tile_Bridge            = $DC;
  Tile_Bridge2           = $DD;
  Tile_Bridge3           = $DE;
  Tile_Bridge4           = $DF;
  // Hintergrund, erste Reihe
  Tile_AirRocketUp       = $E0;
  Tile_AirRocketUpLeft   = $E1;
  Tile_AirRocketUpRight  = $E2;
  Tile_AirRocketLeft     = $E3;
  Tile_AirRocketRight    = $E4;
  Tile_AirRocketDown     = $E5;
  Tile_Water5            = $E6;
  Tile_Hole              = $E7;
  Tile_Water             = $E8;
  Tile_Water2            = $E9;
  Tile_Water3            = $EA;
  Tile_Water4            = $EB;
  Tile_OpenDoor          = $EC;
  Tile_OpenDoor2         = $ED;
  Tile_OpenDoor3         = $EE;
  Tile_Spikes            = $EF;
  // Hintergrund, zweite Reihe
  Tile_BlockerBroken     = $F0;
  Tile_Blocker3Broken    = $F1;
  Tile_BigBlockerBroken  = $F2;
  Tile_SlowRocketUp      = $F3;
  Tile_AirRocketUp2      = $F4;
  Tile_AirRocketUp3      = $F5;
  Tile_SpikesTop         = $F6;
  Tile_Hole2             = $F7;
  Tile_StairsUpLocked    = $F8;
  Tile_StairsUp          = $F9;
  Tile_StairsUp2         = $FA;
  Tile_StairsDownLocked  = $FB;
  Tile_StairsDown        = $FC;
  Tile_StairsDown2       = $FD;
  Tile_StairsEnd         = $FE;
  Tile_StairsEnd2        = $FF;

  // Objekt-IDs
  // -1: Objekteorganisation
  ID_Break             = $-1;

  // 00 - 04 = Spieler
  ID_Player            = $00;
  ID_PlayerFighter     = $01;
  ID_PlayerGun         = $02;
  ID_PlayerBerserker   = $03;
  ID_PlayerBomber      = $04;
  ID_PlayerMax         = $04;
  // 05 - 09 = Gegner
  ID_Enemy             = $05;
  ID_EnemyFighter      = $06;
  ID_EnemyGun          = $07;
  ID_EnemyBerserker    = $08;
  ID_EnemyBomber       = $09;
  ID_EnemyMax          = $09;
  ID_LivingMax         = $09;

  // 10 - 1F Andere Objekte
  ID_OtherObjectsMin   = $10;
  ID_Firewall1         = $10;
  ID_Firewall2         = $11;
  ID_Fire              = $12;
  ID_HelpArrow         = $13;
  ID_Fish              = $14;
  ID_Fish2             = $15;
  ID_TrashIdle         = $16;
  ID_FusingBomb        = $17;
  ID_Trash             = $18;
  ID_Trash2            = $19;
  ID_Trash3            = $1A;
  ID_Trash4            = $1B;
  ID_LeverDown         = $1C;
  ID_Lever             = $1D;
  ID_LeverLeft         = $1E;
  ID_LeverRight        = $1F;
  ID_OtherObjectsMax   = $1F;

  // 20 - 2F = Einsammelbare Objekte
  ID_CollectibleMin    = $20;
  ID_Key               = $20;
  ID_Health            = $21;
  ID_Health2           = $22;
  ID_Star              = $23;
  ID_Star2             = $24;
  ID_Star3             = $25;
  ID_Points            = $26;
  ID_Points2           = $27;
  ID_Points3           = $28;
  ID_Points4           = $29;
  ID_Points5           = $2A;
  ID_Points6           = $2B;
  ID_PointsMax         = $2B;
  ID_Carolin           = $2C;
  ID_Speed             = $2D;
  ID_Jump              = $2E;
  ID_Fly               = $2F;

  // 30 - 3F = andere einsammelbare Objekte
  ID_MoreTime2         = $30;
  ID_EdibleFish        = $31;
  ID_EdibleFish2       = $32;
  ID_MoreTime          = $33;
  ID_Seamine           = $34;
  ID_Cookie            = $35;
  ID_SlowDown          = $36;
  ID_Crystal           = $37;       
  ID_MorphFighter      = $38;
  ID_MorphGun          = $39;
  ID_MorphBomber       = $3A;
  ID_MorphGrenadier    = $3B;
  ID_MorphMax          = $3B;
  ID_MunitionMin       = $3C;
  ID_MunitionGun       = $3C;
  ID_MunitionGun2      = $3D;
  ID_MunitionBomber    = $3E;
  ID_MunitionBomber2   = $3F;
  ID_MunitionMax       = $3F;
  ID_CollectibleMax    = $3F;

  // 40 - 4F = Effekte
  ID_FXMin             = $40;
  ID_FXSmoke           = $40;
  ID_FXFlame           = $41;
  ID_FXSpark           = $42;
  ID_FXBubble          = $43;
  ID_FXRicochet        = $44;
  ID_FXLine            = $45;
  ID_FXBlockerParts    = $46;
  ID_FXBreak           = $47;
  ID_FXBreak2          = $48;
  ID_FXBreakingParts   = $49;
  ID_FXBlood           = $4A;
  ID_FXFire            = $4B;
  ID_FXFlyingCarolin   = $4C;
  ID_FXFlyingChain     = $4D;
  ID_FXFlyingBlob      = $4E;
  ID_FXText            = $4F;
  ID_FXSlowText        = $50;
  ID_FXWaterBubble     = $51;
  ID_FXWater           = $52;
  ID_FXSparkle         = $53;
  ID_FXMax             = $53;

  // Mehr IDs gibt's nicht
  ID_Max               = $51;

implementation

end.
