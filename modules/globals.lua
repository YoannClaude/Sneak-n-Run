MINE = require "modules.mine"

QUADSIZE = 128

GAMEPAD = nil

PLAYER_POS = Vector2()

SCREEN = {WIDTH = 960, HEIGHT = 704}

levels = {TUTORIAL = 1, MINE = 2}

menus = {START = 1, PAUSE = 2, SETTINGS = 3, SFX = 4, MUSIC = 5, VICTORY = 6, QUIT = 7}

dir = {DOWN = 1, UP = 2, LEFT = 3, RIGHT = 4}

layer = {WALLS = 1, UNWALKABLE = 2, HOLES = 3, GROUND = 4,
         OBSTACLES = 5, SOUND_AREA = 6, EXTRA_COLLIDE = 7, EXTRA = 8}

position_layer = {TUTORIAL = 9, GAME = 10, ENNEMIES = 11, OBJECTS = 12, PLAYER = 13}

action = {IDLE = 1, MOVE = 2, ATTACK = 3, STUNNED = 4}

sType = {PLAYER = 1, ARROW = 2, GUARD = 3, PRIEST = 4, BAT = 5,
         SPELL = 6, SWITCH = 7, DOOR = 8, TRAP = 9, HIDING_PLACE = 10}

gState = {PASSIVE = 1, SUSPICIOUS = 2, ACTIVE = 3, DEFEAT = 4}

pState = {STATIC = 1, WALKING = 2, RUNNING = 3, SNEAKING = 4,
          SHOOTING = 5, HIT = 6, CAUGHT = 7, DEAD = 8}

eState = {STATIC = 1, PATROL = 2, SUSPICIOUS = 3, CHASE = 4,
          SURPRISE = 5, LOOK_AROUND = 6, GETTING_CALM = 7, HIT = 8,
          SLAY = 9, CAST = 10, KO = 11, TURNING = 12, FALLING = 13}

mState = {PLAY = 1, PAUSE = 2, MENU = 3, START = 4, END = 5}