/* -Fruit appears for Pacman to eat after eating 70 dots and 170 dots.
 * -Bonus Pacman for 10000 points
 *
 * AI
 * - Blinky is the strict chaser and will never stray from Pacman's back.
 * - Pinky and Inky use different strategies and paths in attempts to position themselves in front of Pacman
 * - Clyde chases when far away from Pac-Man but turns away to block an alternate path (usually deviating towards the bottom left of the screen) when coming closer.
 *
 *
 */

import GUI
setscreen ("graphics:448;576, nobuttonbar, position:center;center, noecho, offscreenonly")
var exitProgram := false

type GhostType : enum (blinky_menu, pinky_menu, inky_menu, clyde_menu, blinky, pinky, inky, clyde)
type Direction : enum (up, down, left, right, none)
type FontType : enum (normal_white, normal_pink, normal_red, normal_orange, normal_blue, normal_yellow)

% Initializes all the procedures and their parameters
forward proc drawPlayScreen
forward proc drawTextRight (x, y : int, font : FontType, text : string)
forward proc drawTextCenter (x, y : int, font : FontType, text : string)
forward proc drawText (x, y : int, font : FontType, text : string)
forward proc drawNumber (x, y : int, font : FontType, num : int)
forward proc drawNumberRight (x, y : int, font : FontType, num : int)
forward proc drawNumberCenter (x, y : int, font : FontType, num : int)
forward proc gameInput
forward proc drawMenuScreen
forward proc addScore (toAdd : int)
forward proc menuInput
forward proc gameMath
forward proc reset
forward proc setupNextLevel
forward proc updateAI
forward proc loadFile
forward proc saveFile
forward proc resetSaveVariables
forward proc closeGame

const debug := false

const typeface := "Fixedsys"
const halfx := floor (maxx / 2)
const halfy := floor (maxy / 2)
const xMenuOff := 110
const yMenuOff := 430

const pelletFlashTicks := 6

const tickInterval := (1000 / 40) % The time in milliseconds between ticks
var currentTime := 0
var lastTick := 0

var inGame := false % Defaults to Main Menu

var openTime := 0 % The amount of times this has been opened

var score := 0
var highScore := 0

% Loads all the sprites
const iMap : int := Pic.Scale (Pic.FileNew ("pacman/textures/map.bmp"), maxx, maxy)
const iTitle : int := Pic.Scale (Pic.FileNew ("pacman/textures/title.bmp"), maxx, maxy)
const iLogo : int := Pic.FileNew ("pacman/textures/logo.bmp")

var iPacmanLeft : array 0 .. 3 of int
iPacmanLeft (0) := Pic.Scale (Pic.FileNew ("pacman/textures/pacman0.bmp"), 32, 32)
iPacmanLeft (1) := Pic.Scale (Pic.FileNew ("pacman/textures/pacman1.bmp"), 32, 32)
iPacmanLeft (2) := Pic.Scale (Pic.FileNew ("pacman/textures/pacman2.bmp"), 32, 32)
iPacmanLeft (3) := Pic.Scale (Pic.FileNew ("pacman/textures/pacman1.bmp"), 32, 32)

var iPacmanDown : array 0 .. 3 of int
iPacmanDown (0) := Pic.Flip (Pic.Rotate (Pic.Scale (Pic.FileNew ("pacman/textures/pacman0.bmp"), 32, 32), 270, 16, 16))
iPacmanDown (1) := Pic.Flip (Pic.Rotate (Pic.Scale (Pic.FileNew ("pacman/textures/pacman1.bmp"), 32, 32), 270, 16, 16))
iPacmanDown (2) := Pic.Flip (Pic.Rotate (Pic.Scale (Pic.FileNew ("pacman/textures/pacman2.bmp"), 32, 32), 270, 16, 16))
iPacmanDown (3) := Pic.Flip (Pic.Rotate (Pic.Scale (Pic.FileNew ("pacman/textures/pacman1.bmp"), 32, 32), 270, 16, 16))

var iPacmanRight : array 0 .. 3 of int
iPacmanRight (0) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/textures/pacman0.bmp"), 32, 32))
iPacmanRight (1) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/textures/pacman1.bmp"), 32, 32))
iPacmanRight (2) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/textures/pacman2.bmp"), 32, 32))
iPacmanRight (3) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/textures/pacman1.bmp"), 32, 32))

var iPacmanUp : array 0 .. 3 of int
iPacmanUp (0) := Pic.Rotate (Pic.Scale (Pic.FileNew ("pacman/textures/pacman0.bmp"), 32, 32), 270, 16, 16)
iPacmanUp (1) := Pic.Rotate (Pic.Scale (Pic.FileNew ("pacman/textures/pacman1.bmp"), 32, 32), 270, 16, 16)
iPacmanUp (2) := Pic.Rotate (Pic.Scale (Pic.FileNew ("pacman/textures/pacman2.bmp"), 32, 32), 270, 16, 16)
iPacmanUp (3) := Pic.Rotate (Pic.Scale (Pic.FileNew ("pacman/textures/pacman1.bmp"), 32, 32), 270, 16, 16)

var iPacmanDead : array 0 .. 12 of int
iPacmanDead (0) := Pic.Scale (Pic.FileNew ("pacman/textures/pacman3.bmp"), 32, 32)
iPacmanDead (1) := Pic.Scale (Pic.FileNew ("pacman/textures/pacman4.bmp"), 32, 32)
iPacmanDead (2) := Pic.Scale (Pic.FileNew ("pacman/textures/pacman5.bmp"), 32, 32)
iPacmanDead (3) := Pic.Scale (Pic.FileNew ("pacman/textures/pacman6.bmp"), 32, 32)
iPacmanDead (4) := Pic.Scale (Pic.FileNew ("pacman/textures/pacman7.bmp"), 32, 32)
iPacmanDead (5) := Pic.Scale (Pic.FileNew ("pacman/textures/pacman8.bmp"), 32, 32)
iPacmanDead (6) := Pic.Scale (Pic.FileNew ("pacman/textures/pacman9.bmp"), 32, 32)
iPacmanDead (7) := Pic.Scale (Pic.FileNew ("pacman/textures/pacman10.bmp"), 32, 32)
iPacmanDead (8) := Pic.Scale (Pic.FileNew ("pacman/textures/pacman11.bmp"), 32, 32)
iPacmanDead (9) := Pic.Scale (Pic.FileNew ("pacman/textures/pacman12.bmp"), 32, 32)
iPacmanDead (10) := Pic.Scale (Pic.FileNew ("pacman/textures/pacman13.bmp"), 32, 32)
iPacmanDead (11) := Pic.Scale (Pic.FileNew ("pacman/textures/pacman14.bmp"), 32, 32)
iPacmanDead (12) := Pic.Scale (Pic.FileNew ("pacman/textures/pacman15.bmp"), 32, 32)


var iBlinkyLeft : array 0 .. 1 of int
iBlinkyLeft (0) := Pic.Scale (Pic.FileNew ("pacman/textures/blinky_side1.bmp"), 32, 32)
iBlinkyLeft (1) := Pic.Scale (Pic.FileNew ("pacman/textures/blinky_side2.bmp"), 32, 32)

var iBlinkyDown : array 0 .. 1 of int
iBlinkyDown (0) := Pic.Scale (Pic.FileNew ("pacman/textures/blinky_down1.bmp"), 32, 32)
iBlinkyDown (1) := Pic.Scale (Pic.FileNew ("pacman/textures/blinky_down2.bmp"), 32, 32)

var iBlinkyRight : array 0 .. 1 of int
iBlinkyRight (0) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/textures/blinky_side1.bmp"), 32, 32))
iBlinkyRight (1) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/textures/blinky_side2.bmp"), 32, 32))

var iBlinkyUp : array 0 .. 1 of int
iBlinkyUp (0) := Pic.Scale (Pic.FileNew ("pacman/textures/blinky_up1.bmp"), 32, 32)
iBlinkyUp (1) := Pic.Scale (Pic.FileNew ("pacman/textures/blinky_up2.bmp"), 32, 32)

var iClydeLeft : array 0 .. 1 of int
iClydeLeft (0) := Pic.Scale (Pic.FileNew ("pacman/textures/clyde_side1.bmp"), 32, 32)
iClydeLeft (1) := Pic.Scale (Pic.FileNew ("pacman/textures/clyde_side2.bmp"), 32, 32)

var iClydeDown : array 0 .. 1 of int
iClydeDown (0) := Pic.Scale (Pic.FileNew ("pacman/textures/clyde_down1.bmp"), 32, 32)
iClydeDown (1) := Pic.Scale (Pic.FileNew ("pacman/textures/clyde_down2.bmp"), 32, 32)

var iClydeRight : array 0 .. 1 of int
iClydeRight (0) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/textures/clyde_side1.bmp"), 32, 32))
iClydeRight (1) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/textures/clyde_side2.bmp"), 32, 32))

var iClydeUp : array 0 .. 1 of int
iClydeUp (0) := Pic.Scale (Pic.FileNew ("pacman/textures/clyde_up1.bmp"), 32, 32)
iClydeUp (1) := Pic.Scale (Pic.FileNew ("pacman/textures/clyde_up2.bmp"), 32, 32)


var iInkyLeft : array 0 .. 1 of int
iInkyLeft (0) := Pic.Scale (Pic.FileNew ("pacman/textures/inky_side1.bmp"), 32, 32)
iInkyLeft (1) := Pic.Scale (Pic.FileNew ("pacman/textures/inky_side2.bmp"), 32, 32)

var iInkyDown : array 0 .. 1 of int
iInkyDown (0) := Pic.Scale (Pic.FileNew ("pacman/textures/inky_down1.bmp"), 32, 32)
iInkyDown (1) := Pic.Scale (Pic.FileNew ("pacman/textures/inky_down2.bmp"), 32, 32)

var iInkyRight : array 0 .. 1 of int
iInkyRight (0) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/textures/inky_side1.bmp"), 32, 32))
iInkyRight (1) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/textures/inky_side2.bmp"), 32, 32))

var iInkyUp : array 0 .. 1 of int
iInkyUp (0) := Pic.Scale (Pic.FileNew ("pacman/textures/inky_up1.bmp"), 32, 32)
iInkyUp (1) := Pic.Scale (Pic.FileNew ("pacman/textures/inky_up2.bmp"), 32, 32)

var iPinkyLeft : array 0 .. 1 of int
iPinkyLeft (0) := Pic.Scale (Pic.FileNew ("pacman/textures/pinky_side1.bmp"), 32, 32)
iPinkyLeft (1) := Pic.Scale (Pic.FileNew ("pacman/textures/pinky_side2.bmp"), 32, 32)

var iPinkyDown : array 0 .. 1 of int
iPinkyDown (0) := Pic.Scale (Pic.FileNew ("pacman/textures/pinky_down1.bmp"), 32, 32)
iPinkyDown (1) := Pic.Scale (Pic.FileNew ("pacman/textures/pinky_down2.bmp"), 32, 32)

var iPinkyRight : array 0 .. 1 of int
iPinkyRight (0) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/textures/pinky_side1.bmp"), 32, 32))
iPinkyRight (1) := Pic.Mirror (Pic.Scale (Pic.FileNew ("pacman/textures/pinky_side2.bmp"), 32, 32))

var iPinkyUp : array 0 .. 1 of int
iPinkyUp (0) := Pic.Scale (Pic.FileNew ("pacman/textures/pinky_up1.bmp"), 32, 32)
iPinkyUp (1) := Pic.Scale (Pic.FileNew ("pacman/textures/pinky_up2.bmp"), 32, 32)

var iScaredGhost : array 0 .. 1 of int
iScaredGhost (0) := Pic.Scale (Pic.FileNew ("pacman/textures/scared_ghost1.bmp"), 32, 32)
iScaredGhost (1) := Pic.Scale (Pic.FileNew ("pacman/textures/scared_ghost2.bmp"), 32, 32)


var iWhiteText : array 0 .. 54 of int
iWhiteText (0) := Pic.Scale (Pic.FileNew ("pacman/font/white0.bmp"), 16, 16)
iWhiteText (1) := Pic.Scale (Pic.FileNew ("pacman/font/white1.bmp"), 16, 16)
iWhiteText (2) := Pic.Scale (Pic.FileNew ("pacman/font/white2.bmp"), 16, 16)
iWhiteText (3) := Pic.Scale (Pic.FileNew ("pacman/font/white3.bmp"), 16, 16)
iWhiteText (4) := Pic.Scale (Pic.FileNew ("pacman/font/white4.bmp"), 16, 16)
iWhiteText (5) := Pic.Scale (Pic.FileNew ("pacman/font/white5.bmp"), 16, 16)
iWhiteText (6) := Pic.Scale (Pic.FileNew ("pacman/font/white6.bmp"), 16, 16)
iWhiteText (7) := Pic.Scale (Pic.FileNew ("pacman/font/white7.bmp"), 16, 16)
iWhiteText (8) := Pic.Scale (Pic.FileNew ("pacman/font/white8.bmp"), 16, 16)
iWhiteText (9) := Pic.Scale (Pic.FileNew ("pacman/font/white9.bmp"), 16, 16)
iWhiteText (10) := Pic.Scale (Pic.FileNew ("pacman/font/whitea.bmp"), 16, 16)
iWhiteText (11) := Pic.Scale (Pic.FileNew ("pacman/font/whiteb.bmp"), 16, 16)
iWhiteText (12) := Pic.Scale (Pic.FileNew ("pacman/font/whitec.bmp"), 16, 16)
iWhiteText (13) := Pic.Scale (Pic.FileNew ("pacman/font/whited.bmp"), 16, 16)
iWhiteText (14) := Pic.Scale (Pic.FileNew ("pacman/font/whitee.bmp"), 16, 16)
iWhiteText (15) := Pic.Scale (Pic.FileNew ("pacman/font/whitef.bmp"), 16, 16)
iWhiteText (16) := Pic.Scale (Pic.FileNew ("pacman/font/whiteg.bmp"), 16, 16)
iWhiteText (17) := Pic.Scale (Pic.FileNew ("pacman/font/whiteh.bmp"), 16, 16)
iWhiteText (18) := Pic.Scale (Pic.FileNew ("pacman/font/whitei.bmp"), 16, 16)
iWhiteText (19) := Pic.Scale (Pic.FileNew ("pacman/font/whitej.bmp"), 16, 16)
iWhiteText (20) := Pic.Scale (Pic.FileNew ("pacman/font/whitek.bmp"), 16, 16)
iWhiteText (21) := Pic.Scale (Pic.FileNew ("pacman/font/whitel.bmp"), 16, 16)
iWhiteText (22) := Pic.Scale (Pic.FileNew ("pacman/font/whitem.bmp"), 16, 16)
iWhiteText (23) := Pic.Scale (Pic.FileNew ("pacman/font/whiten.bmp"), 16, 16)
iWhiteText (24) := Pic.Scale (Pic.FileNew ("pacman/font/whiteo.bmp"), 16, 16)
iWhiteText (25) := Pic.Scale (Pic.FileNew ("pacman/font/whitep.bmp"), 16, 16)
iWhiteText (26) := Pic.Scale (Pic.FileNew ("pacman/font/whiteq.bmp"), 16, 16)
iWhiteText (27) := Pic.Scale (Pic.FileNew ("pacman/font/whiter.bmp"), 16, 16)
iWhiteText (28) := Pic.Scale (Pic.FileNew ("pacman/font/whites.bmp"), 16, 16)
iWhiteText (29) := Pic.Scale (Pic.FileNew ("pacman/font/whitet.bmp"), 16, 16)
iWhiteText (30) := Pic.Scale (Pic.FileNew ("pacman/font/whiteu.bmp"), 16, 16)
iWhiteText (31) := Pic.Scale (Pic.FileNew ("pacman/font/whitev.bmp"), 16, 16)
iWhiteText (32) := Pic.Scale (Pic.FileNew ("pacman/font/whitew.bmp"), 16, 16)
iWhiteText (33) := Pic.Scale (Pic.FileNew ("pacman/font/whitex.bmp"), 16, 16)
iWhiteText (34) := Pic.Scale (Pic.FileNew ("pacman/font/whitey.bmp"), 16, 16)
iWhiteText (35) := Pic.Scale (Pic.FileNew ("pacman/font/whitez.bmp"), 16, 16)
iWhiteText (36) := Pic.Scale (Pic.FileNew ("pacman/font/whiteperiod.bmp"), 16, 16)
iWhiteText (37) := Pic.Scale (Pic.FileNew ("pacman/font/whiteexclaim.bmp"), 16, 16)
iWhiteText (38) := Pic.Scale (Pic.FileNew ("pacman/font/whiteslash.bmp"), 16, 16)
iWhiteText (39) := Pic.Scale (Pic.FileNew ("pacman/font/whitequote.bmp"), 16, 16)
iWhiteText (40) := Pic.Scale (Pic.FileNew ("pacman/font/whitehyphen.bmp"), 16, 16)
iWhiteText (41) := Pic.Scale (Pic.FileNew ("pacman/font/whitecopy.bmp"), 16, 16)
iWhiteText (42) := Pic.Scale (Pic.FileNew ("pacman/font/whitecomma.bmp"), 16, 16)
iWhiteText (43) := Pic.Scale (Pic.FileNew ("pacman/font/whiteapos.bmp"), 16, 16)
iWhiteText (44) := Pic.Scale (Pic.FileNew ("pacman/font/white10.bmp"), 32, 16)
iWhiteText (45) := Pic.Scale (Pic.FileNew ("pacman/font/white20.bmp"), 32, 16)
iWhiteText (46) := Pic.Scale (Pic.FileNew ("pacman/font/white30.bmp"), 32, 16)
iWhiteText (47) := Pic.Scale (Pic.FileNew ("pacman/font/white40.bmp"), 32, 16)
iWhiteText (48) := Pic.Scale (Pic.FileNew ("pacman/font/white50.bmp"), 32, 16)
iWhiteText (49) := Pic.Scale (Pic.FileNew ("pacman/font/white160.bmp"), 32, 16)
iWhiteText (50) := Pic.Scale (Pic.FileNew ("pacman/font/white200.bmp"), 32, 16)
iWhiteText (51) := Pic.Scale (Pic.FileNew ("pacman/font/white400.bmp"), 32, 16)
iWhiteText (52) := Pic.Scale (Pic.FileNew ("pacman/font/white800.bmp"), 32, 16)
iWhiteText (53) := Pic.Scale (Pic.FileNew ("pacman/font/white1600.bmp"), 32, 16)
iWhiteText (54) := Pic.Scale (Pic.FileNew ("pacman/font/whitepts.bmp"), 36, 16)

var iPinkText : array 0 .. 54 of int
iPinkText (0) := Pic.Scale (Pic.FileNew ("pacman/font/pink0.bmp"), 16, 16)
iPinkText (1) := Pic.Scale (Pic.FileNew ("pacman/font/pink1.bmp"), 16, 16)
iPinkText (2) := Pic.Scale (Pic.FileNew ("pacman/font/pink2.bmp"), 16, 16)
iPinkText (3) := Pic.Scale (Pic.FileNew ("pacman/font/pink3.bmp"), 16, 16)
iPinkText (4) := Pic.Scale (Pic.FileNew ("pacman/font/pink4.bmp"), 16, 16)
iPinkText (5) := Pic.Scale (Pic.FileNew ("pacman/font/pink5.bmp"), 16, 16)
iPinkText (6) := Pic.Scale (Pic.FileNew ("pacman/font/pink6.bmp"), 16, 16)
iPinkText (7) := Pic.Scale (Pic.FileNew ("pacman/font/pink7.bmp"), 16, 16)
iPinkText (8) := Pic.Scale (Pic.FileNew ("pacman/font/pink8.bmp"), 16, 16)
iPinkText (9) := Pic.Scale (Pic.FileNew ("pacman/font/pink9.bmp"), 16, 16)
iPinkText (10) := Pic.Scale (Pic.FileNew ("pacman/font/pinka.bmp"), 16, 16)
iPinkText (11) := Pic.Scale (Pic.FileNew ("pacman/font/pinkb.bmp"), 16, 16)
iPinkText (12) := Pic.Scale (Pic.FileNew ("pacman/font/pinkc.bmp"), 16, 16)
iPinkText (13) := Pic.Scale (Pic.FileNew ("pacman/font/pinkd.bmp"), 16, 16)
iPinkText (14) := Pic.Scale (Pic.FileNew ("pacman/font/pinke.bmp"), 16, 16)
iPinkText (15) := Pic.Scale (Pic.FileNew ("pacman/font/pinkf.bmp"), 16, 16)
iPinkText (16) := Pic.Scale (Pic.FileNew ("pacman/font/pinkg.bmp"), 16, 16)
iPinkText (17) := Pic.Scale (Pic.FileNew ("pacman/font/pinkh.bmp"), 16, 16)
iPinkText (18) := Pic.Scale (Pic.FileNew ("pacman/font/pinki.bmp"), 16, 16)
iPinkText (19) := Pic.Scale (Pic.FileNew ("pacman/font/pinkj.bmp"), 16, 16)
iPinkText (20) := Pic.Scale (Pic.FileNew ("pacman/font/pinkk.bmp"), 16, 16)
iPinkText (21) := Pic.Scale (Pic.FileNew ("pacman/font/pinkl.bmp"), 16, 16)
iPinkText (22) := Pic.Scale (Pic.FileNew ("pacman/font/pinkm.bmp"), 16, 16)
iPinkText (23) := Pic.Scale (Pic.FileNew ("pacman/font/pinkn.bmp"), 16, 16)
iPinkText (24) := Pic.Scale (Pic.FileNew ("pacman/font/pinko.bmp"), 16, 16)
iPinkText (25) := Pic.Scale (Pic.FileNew ("pacman/font/pinkp.bmp"), 16, 16)
iPinkText (26) := Pic.Scale (Pic.FileNew ("pacman/font/pinkq.bmp"), 16, 16)
iPinkText (27) := Pic.Scale (Pic.FileNew ("pacman/font/pinkr.bmp"), 16, 16)
iPinkText (28) := Pic.Scale (Pic.FileNew ("pacman/font/pinks.bmp"), 16, 16)
iPinkText (29) := Pic.Scale (Pic.FileNew ("pacman/font/pinkt.bmp"), 16, 16)
iPinkText (30) := Pic.Scale (Pic.FileNew ("pacman/font/pinku.bmp"), 16, 16)
iPinkText (31) := Pic.Scale (Pic.FileNew ("pacman/font/pinkv.bmp"), 16, 16)
iPinkText (32) := Pic.Scale (Pic.FileNew ("pacman/font/pinkw.bmp"), 16, 16)
iPinkText (33) := Pic.Scale (Pic.FileNew ("pacman/font/pinkx.bmp"), 16, 16)
iPinkText (34) := Pic.Scale (Pic.FileNew ("pacman/font/pinky.bmp"), 16, 16)
iPinkText (35) := Pic.Scale (Pic.FileNew ("pacman/font/pinkz.bmp"), 16, 16)
iPinkText (36) := Pic.Scale (Pic.FileNew ("pacman/font/pinkperiod.bmp"), 16, 16)
iPinkText (37) := Pic.Scale (Pic.FileNew ("pacman/font/pinkexclaim.bmp"), 16, 16)
iPinkText (38) := Pic.Scale (Pic.FileNew ("pacman/font/pinkslash.bmp"), 16, 16)
iPinkText (39) := Pic.Scale (Pic.FileNew ("pacman/font/pinkquote.bmp"), 16, 16)
iPinkText (40) := Pic.Scale (Pic.FileNew ("pacman/font/pinkhyphen.bmp"), 16, 16)
iPinkText (41) := Pic.Scale (Pic.FileNew ("pacman/font/pinkcopy.bmp"), 16, 16)
iPinkText (42) := Pic.Scale (Pic.FileNew ("pacman/font/pinkcomma.bmp"), 16, 16)
iPinkText (43) := Pic.Scale (Pic.FileNew ("pacman/font/pinkapos.bmp"), 16, 16)
iPinkText (44) := Pic.Scale (Pic.FileNew ("pacman/font/pink10.bmp"), 32, 16)
iPinkText (45) := Pic.Scale (Pic.FileNew ("pacman/font/pink20.bmp"), 32, 16)
iPinkText (46) := Pic.Scale (Pic.FileNew ("pacman/font/pink30.bmp"), 32, 16)
iPinkText (47) := Pic.Scale (Pic.FileNew ("pacman/font/pink40.bmp"), 32, 16)
iPinkText (48) := Pic.Scale (Pic.FileNew ("pacman/font/pink50.bmp"), 32, 16)
iPinkText (49) := Pic.Scale (Pic.FileNew ("pacman/font/pink160.bmp"), 32, 16)
iPinkText (50) := Pic.Scale (Pic.FileNew ("pacman/font/pink200.bmp"), 32, 16)
iPinkText (51) := Pic.Scale (Pic.FileNew ("pacman/font/pink400.bmp"), 32, 16)
iPinkText (52) := Pic.Scale (Pic.FileNew ("pacman/font/pink800.bmp"), 32, 16)
iPinkText (53) := Pic.Scale (Pic.FileNew ("pacman/font/pink1600.bmp"), 32, 16)
iPinkText (54) := Pic.Scale (Pic.FileNew ("pacman/font/pinkpts.bmp"), 36, 16)

var iRedText : array 0 .. 54 of int
iRedText (0) := Pic.Scale (Pic.FileNew ("pacman/font/red0.bmp"), 16, 16)
iRedText (1) := Pic.Scale (Pic.FileNew ("pacman/font/red1.bmp"), 16, 16)
iRedText (2) := Pic.Scale (Pic.FileNew ("pacman/font/red2.bmp"), 16, 16)
iRedText (3) := Pic.Scale (Pic.FileNew ("pacman/font/red3.bmp"), 16, 16)
iRedText (4) := Pic.Scale (Pic.FileNew ("pacman/font/red4.bmp"), 16, 16)
iRedText (5) := Pic.Scale (Pic.FileNew ("pacman/font/red5.bmp"), 16, 16)
iRedText (6) := Pic.Scale (Pic.FileNew ("pacman/font/red6.bmp"), 16, 16)
iRedText (7) := Pic.Scale (Pic.FileNew ("pacman/font/red7.bmp"), 16, 16)
iRedText (8) := Pic.Scale (Pic.FileNew ("pacman/font/red8.bmp"), 16, 16)
iRedText (9) := Pic.Scale (Pic.FileNew ("pacman/font/red9.bmp"), 16, 16)
iRedText (10) := Pic.Scale (Pic.FileNew ("pacman/font/reda.bmp"), 16, 16)
iRedText (11) := Pic.Scale (Pic.FileNew ("pacman/font/redb.bmp"), 16, 16)
iRedText (12) := Pic.Scale (Pic.FileNew ("pacman/font/redc.bmp"), 16, 16)
iRedText (13) := Pic.Scale (Pic.FileNew ("pacman/font/redd.bmp"), 16, 16)
iRedText (14) := Pic.Scale (Pic.FileNew ("pacman/font/rede.bmp"), 16, 16)
iRedText (15) := Pic.Scale (Pic.FileNew ("pacman/font/redf.bmp"), 16, 16)
iRedText (16) := Pic.Scale (Pic.FileNew ("pacman/font/redg.bmp"), 16, 16)
iRedText (17) := Pic.Scale (Pic.FileNew ("pacman/font/redh.bmp"), 16, 16)
iRedText (18) := Pic.Scale (Pic.FileNew ("pacman/font/redi.bmp"), 16, 16)
iRedText (19) := Pic.Scale (Pic.FileNew ("pacman/font/redj.bmp"), 16, 16)
iRedText (20) := Pic.Scale (Pic.FileNew ("pacman/font/redk.bmp"), 16, 16)
iRedText (21) := Pic.Scale (Pic.FileNew ("pacman/font/redl.bmp"), 16, 16)
iRedText (22) := Pic.Scale (Pic.FileNew ("pacman/font/redm.bmp"), 16, 16)
iRedText (23) := Pic.Scale (Pic.FileNew ("pacman/font/redn.bmp"), 16, 16)
iRedText (24) := Pic.Scale (Pic.FileNew ("pacman/font/redo.bmp"), 16, 16)
iRedText (25) := Pic.Scale (Pic.FileNew ("pacman/font/redp.bmp"), 16, 16)
iRedText (26) := Pic.Scale (Pic.FileNew ("pacman/font/redq.bmp"), 16, 16)
iRedText (27) := Pic.Scale (Pic.FileNew ("pacman/font/redr.bmp"), 16, 16)
iRedText (28) := Pic.Scale (Pic.FileNew ("pacman/font/reds.bmp"), 16, 16)
iRedText (29) := Pic.Scale (Pic.FileNew ("pacman/font/redt.bmp"), 16, 16)
iRedText (30) := Pic.Scale (Pic.FileNew ("pacman/font/redu.bmp"), 16, 16)
iRedText (31) := Pic.Scale (Pic.FileNew ("pacman/font/redv.bmp"), 16, 16)
iRedText (32) := Pic.Scale (Pic.FileNew ("pacman/font/redw.bmp"), 16, 16)
iRedText (33) := Pic.Scale (Pic.FileNew ("pacman/font/redx.bmp"), 16, 16)
iRedText (34) := Pic.Scale (Pic.FileNew ("pacman/font/redy.bmp"), 16, 16)
iRedText (35) := Pic.Scale (Pic.FileNew ("pacman/font/redz.bmp"), 16, 16)
iRedText (36) := Pic.Scale (Pic.FileNew ("pacman/font/redperiod.bmp"), 16, 16)
iRedText (37) := Pic.Scale (Pic.FileNew ("pacman/font/redexclaim.bmp"), 16, 16)
iRedText (38) := Pic.Scale (Pic.FileNew ("pacman/font/redslash.bmp"), 16, 16)
iRedText (39) := Pic.Scale (Pic.FileNew ("pacman/font/redquote.bmp"), 16, 16)
iRedText (40) := Pic.Scale (Pic.FileNew ("pacman/font/redhyphen.bmp"), 16, 16)
iRedText (41) := Pic.Scale (Pic.FileNew ("pacman/font/redcopy.bmp"), 16, 16)
iRedText (42) := Pic.Scale (Pic.FileNew ("pacman/font/redcomma.bmp"), 16, 16)
iRedText (43) := Pic.Scale (Pic.FileNew ("pacman/font/redapos.bmp"), 16, 16)
iRedText (44) := Pic.Scale (Pic.FileNew ("pacman/font/red10.bmp"), 32, 16)
iRedText (45) := Pic.Scale (Pic.FileNew ("pacman/font/red20.bmp"), 32, 16)
iRedText (46) := Pic.Scale (Pic.FileNew ("pacman/font/red30.bmp"), 32, 16)
iRedText (47) := Pic.Scale (Pic.FileNew ("pacman/font/red40.bmp"), 32, 16)
iRedText (48) := Pic.Scale (Pic.FileNew ("pacman/font/red50.bmp"), 32, 16)
iRedText (49) := Pic.Scale (Pic.FileNew ("pacman/font/red160.bmp"), 32, 16)
iRedText (50) := Pic.Scale (Pic.FileNew ("pacman/font/red200.bmp"), 32, 16)
iRedText (51) := Pic.Scale (Pic.FileNew ("pacman/font/red400.bmp"), 32, 16)
iRedText (52) := Pic.Scale (Pic.FileNew ("pacman/font/red800.bmp"), 32, 16)
iRedText (53) := Pic.Scale (Pic.FileNew ("pacman/font/red1600.bmp"), 32, 16)
iRedText (54) := Pic.Scale (Pic.FileNew ("pacman/font/redpts.bmp"), 36, 16)

var iOrangeText : array 0 .. 54 of int
iOrangeText (0) := Pic.Scale (Pic.FileNew ("pacman/font/orange0.bmp"), 16, 16)
iOrangeText (1) := Pic.Scale (Pic.FileNew ("pacman/font/orange1.bmp"), 16, 16)
iOrangeText (2) := Pic.Scale (Pic.FileNew ("pacman/font/orange2.bmp"), 16, 16)
iOrangeText (3) := Pic.Scale (Pic.FileNew ("pacman/font/orange3.bmp"), 16, 16)
iOrangeText (4) := Pic.Scale (Pic.FileNew ("pacman/font/orange4.bmp"), 16, 16)
iOrangeText (5) := Pic.Scale (Pic.FileNew ("pacman/font/orange5.bmp"), 16, 16)
iOrangeText (6) := Pic.Scale (Pic.FileNew ("pacman/font/orange6.bmp"), 16, 16)
iOrangeText (7) := Pic.Scale (Pic.FileNew ("pacman/font/orange7.bmp"), 16, 16)
iOrangeText (8) := Pic.Scale (Pic.FileNew ("pacman/font/orange8.bmp"), 16, 16)
iOrangeText (9) := Pic.Scale (Pic.FileNew ("pacman/font/orange9.bmp"), 16, 16)
iOrangeText (10) := Pic.Scale (Pic.FileNew ("pacman/font/orangea.bmp"), 16, 16)
iOrangeText (11) := Pic.Scale (Pic.FileNew ("pacman/font/orangeb.bmp"), 16, 16)
iOrangeText (12) := Pic.Scale (Pic.FileNew ("pacman/font/orangec.bmp"), 16, 16)
iOrangeText (13) := Pic.Scale (Pic.FileNew ("pacman/font/oranged.bmp"), 16, 16)
iOrangeText (14) := Pic.Scale (Pic.FileNew ("pacman/font/orangee.bmp"), 16, 16)
iOrangeText (15) := Pic.Scale (Pic.FileNew ("pacman/font/orangef.bmp"), 16, 16)
iOrangeText (16) := Pic.Scale (Pic.FileNew ("pacman/font/orangeg.bmp"), 16, 16)
iOrangeText (17) := Pic.Scale (Pic.FileNew ("pacman/font/orangeh.bmp"), 16, 16)
iOrangeText (18) := Pic.Scale (Pic.FileNew ("pacman/font/orangei.bmp"), 16, 16)
iOrangeText (19) := Pic.Scale (Pic.FileNew ("pacman/font/orangej.bmp"), 16, 16)
iOrangeText (20) := Pic.Scale (Pic.FileNew ("pacman/font/orangek.bmp"), 16, 16)
iOrangeText (21) := Pic.Scale (Pic.FileNew ("pacman/font/orangel.bmp"), 16, 16)
iOrangeText (22) := Pic.Scale (Pic.FileNew ("pacman/font/orangem.bmp"), 16, 16)
iOrangeText (23) := Pic.Scale (Pic.FileNew ("pacman/font/orangen.bmp"), 16, 16)
iOrangeText (24) := Pic.Scale (Pic.FileNew ("pacman/font/orangeo.bmp"), 16, 16)
iOrangeText (25) := Pic.Scale (Pic.FileNew ("pacman/font/orangep.bmp"), 16, 16)
iOrangeText (26) := Pic.Scale (Pic.FileNew ("pacman/font/orangeq.bmp"), 16, 16)
iOrangeText (27) := Pic.Scale (Pic.FileNew ("pacman/font/oranger.bmp"), 16, 16)
iOrangeText (28) := Pic.Scale (Pic.FileNew ("pacman/font/oranges.bmp"), 16, 16)
iOrangeText (29) := Pic.Scale (Pic.FileNew ("pacman/font/oranget.bmp"), 16, 16)
iOrangeText (30) := Pic.Scale (Pic.FileNew ("pacman/font/orangeu.bmp"), 16, 16)
iOrangeText (31) := Pic.Scale (Pic.FileNew ("pacman/font/orangev.bmp"), 16, 16)
iOrangeText (32) := Pic.Scale (Pic.FileNew ("pacman/font/orangew.bmp"), 16, 16)
iOrangeText (33) := Pic.Scale (Pic.FileNew ("pacman/font/orangex.bmp"), 16, 16)
iOrangeText (34) := Pic.Scale (Pic.FileNew ("pacman/font/orangey.bmp"), 16, 16)
iOrangeText (35) := Pic.Scale (Pic.FileNew ("pacman/font/orangez.bmp"), 16, 16)
iOrangeText (36) := Pic.Scale (Pic.FileNew ("pacman/font/orangeperiod.bmp"), 16, 16)
iOrangeText (37) := Pic.Scale (Pic.FileNew ("pacman/font/orangeexclaim.bmp"), 16, 16)
iOrangeText (38) := Pic.Scale (Pic.FileNew ("pacman/font/orangeslash.bmp"), 16, 16)
iOrangeText (39) := Pic.Scale (Pic.FileNew ("pacman/font/orangequote.bmp"), 16, 16)
iOrangeText (40) := Pic.Scale (Pic.FileNew ("pacman/font/orangehyphen.bmp"), 16, 16)
iOrangeText (41) := Pic.Scale (Pic.FileNew ("pacman/font/orangecopy.bmp"), 16, 16)
iOrangeText (42) := Pic.Scale (Pic.FileNew ("pacman/font/orangecomma.bmp"), 16, 16)
iOrangeText (43) := Pic.Scale (Pic.FileNew ("pacman/font/orangeapos.bmp"), 16, 16)
iOrangeText (44) := Pic.Scale (Pic.FileNew ("pacman/font/orange10.bmp"), 32, 16)
iOrangeText (45) := Pic.Scale (Pic.FileNew ("pacman/font/orange20.bmp"), 32, 16)
iOrangeText (46) := Pic.Scale (Pic.FileNew ("pacman/font/orange30.bmp"), 32, 16)
iOrangeText (47) := Pic.Scale (Pic.FileNew ("pacman/font/orange40.bmp"), 32, 16)
iOrangeText (48) := Pic.Scale (Pic.FileNew ("pacman/font/orange50.bmp"), 32, 16)
iOrangeText (49) := Pic.Scale (Pic.FileNew ("pacman/font/orange160.bmp"), 32, 16)
iOrangeText (50) := Pic.Scale (Pic.FileNew ("pacman/font/orange200.bmp"), 32, 16)
iOrangeText (51) := Pic.Scale (Pic.FileNew ("pacman/font/orange400.bmp"), 32, 16)
iOrangeText (52) := Pic.Scale (Pic.FileNew ("pacman/font/orange800.bmp"), 32, 16)
iOrangeText (53) := Pic.Scale (Pic.FileNew ("pacman/font/orange1600.bmp"), 32, 16)
iOrangeText (54) := Pic.Scale (Pic.FileNew ("pacman/font/orangepts.bmp"), 36, 16)

var iBlueText : array 0 .. 54 of int
iBlueText (0) := Pic.Scale (Pic.FileNew ("pacman/font/blue0.bmp"), 16, 16)
iBlueText (1) := Pic.Scale (Pic.FileNew ("pacman/font/blue1.bmp"), 16, 16)
iBlueText (2) := Pic.Scale (Pic.FileNew ("pacman/font/blue2.bmp"), 16, 16)
iBlueText (3) := Pic.Scale (Pic.FileNew ("pacman/font/blue3.bmp"), 16, 16)
iBlueText (4) := Pic.Scale (Pic.FileNew ("pacman/font/blue4.bmp"), 16, 16)
iBlueText (5) := Pic.Scale (Pic.FileNew ("pacman/font/blue5.bmp"), 16, 16)
iBlueText (6) := Pic.Scale (Pic.FileNew ("pacman/font/blue6.bmp"), 16, 16)
iBlueText (7) := Pic.Scale (Pic.FileNew ("pacman/font/blue7.bmp"), 16, 16)
iBlueText (8) := Pic.Scale (Pic.FileNew ("pacman/font/blue8.bmp"), 16, 16)
iBlueText (9) := Pic.Scale (Pic.FileNew ("pacman/font/blue9.bmp"), 16, 16)
iBlueText (10) := Pic.Scale (Pic.FileNew ("pacman/font/bluea.bmp"), 16, 16)
iBlueText (11) := Pic.Scale (Pic.FileNew ("pacman/font/blueb.bmp"), 16, 16)
iBlueText (12) := Pic.Scale (Pic.FileNew ("pacman/font/bluec.bmp"), 16, 16)
iBlueText (13) := Pic.Scale (Pic.FileNew ("pacman/font/blued.bmp"), 16, 16)
iBlueText (14) := Pic.Scale (Pic.FileNew ("pacman/font/bluee.bmp"), 16, 16)
iBlueText (15) := Pic.Scale (Pic.FileNew ("pacman/font/bluef.bmp"), 16, 16)
iBlueText (16) := Pic.Scale (Pic.FileNew ("pacman/font/blueg.bmp"), 16, 16)
iBlueText (17) := Pic.Scale (Pic.FileNew ("pacman/font/blueh.bmp"), 16, 16)
iBlueText (18) := Pic.Scale (Pic.FileNew ("pacman/font/bluei.bmp"), 16, 16)
iBlueText (19) := Pic.Scale (Pic.FileNew ("pacman/font/bluej.bmp"), 16, 16)
iBlueText (20) := Pic.Scale (Pic.FileNew ("pacman/font/bluek.bmp"), 16, 16)
iBlueText (21) := Pic.Scale (Pic.FileNew ("pacman/font/bluel.bmp"), 16, 16)
iBlueText (22) := Pic.Scale (Pic.FileNew ("pacman/font/bluem.bmp"), 16, 16)
iBlueText (23) := Pic.Scale (Pic.FileNew ("pacman/font/bluen.bmp"), 16, 16)
iBlueText (24) := Pic.Scale (Pic.FileNew ("pacman/font/blueo.bmp"), 16, 16)
iBlueText (25) := Pic.Scale (Pic.FileNew ("pacman/font/bluep.bmp"), 16, 16)
iBlueText (26) := Pic.Scale (Pic.FileNew ("pacman/font/blueq.bmp"), 16, 16)
iBlueText (27) := Pic.Scale (Pic.FileNew ("pacman/font/bluer.bmp"), 16, 16)
iBlueText (28) := Pic.Scale (Pic.FileNew ("pacman/font/blues.bmp"), 16, 16)
iBlueText (29) := Pic.Scale (Pic.FileNew ("pacman/font/bluet.bmp"), 16, 16)
iBlueText (30) := Pic.Scale (Pic.FileNew ("pacman/font/blueu.bmp"), 16, 16)
iBlueText (31) := Pic.Scale (Pic.FileNew ("pacman/font/bluev.bmp"), 16, 16)
iBlueText (32) := Pic.Scale (Pic.FileNew ("pacman/font/bluew.bmp"), 16, 16)
iBlueText (33) := Pic.Scale (Pic.FileNew ("pacman/font/bluex.bmp"), 16, 16)
iBlueText (34) := Pic.Scale (Pic.FileNew ("pacman/font/bluey.bmp"), 16, 16)
iBlueText (35) := Pic.Scale (Pic.FileNew ("pacman/font/bluez.bmp"), 16, 16)
iBlueText (36) := Pic.Scale (Pic.FileNew ("pacman/font/blueperiod.bmp"), 16, 16)
iBlueText (37) := Pic.Scale (Pic.FileNew ("pacman/font/blueexclaim.bmp"), 16, 16)
iBlueText (38) := Pic.Scale (Pic.FileNew ("pacman/font/blueslash.bmp"), 16, 16)
iBlueText (39) := Pic.Scale (Pic.FileNew ("pacman/font/bluequote.bmp"), 16, 16)
iBlueText (40) := Pic.Scale (Pic.FileNew ("pacman/font/bluehyphen.bmp"), 16, 16)
iBlueText (41) := Pic.Scale (Pic.FileNew ("pacman/font/bluecopy.bmp"), 16, 16)
iBlueText (42) := Pic.Scale (Pic.FileNew ("pacman/font/bluecomma.bmp"), 16, 16)
iBlueText (43) := Pic.Scale (Pic.FileNew ("pacman/font/blueapos.bmp"), 16, 16)
iBlueText (44) := Pic.Scale (Pic.FileNew ("pacman/font/blue10.bmp"), 32, 16)
iBlueText (45) := Pic.Scale (Pic.FileNew ("pacman/font/blue20.bmp"), 32, 16)
iBlueText (46) := Pic.Scale (Pic.FileNew ("pacman/font/blue30.bmp"), 32, 16)
iBlueText (47) := Pic.Scale (Pic.FileNew ("pacman/font/blue40.bmp"), 32, 16)
iBlueText (48) := Pic.Scale (Pic.FileNew ("pacman/font/blue50.bmp"), 32, 16)
iBlueText (49) := Pic.Scale (Pic.FileNew ("pacman/font/blue160.bmp"), 32, 16)
iBlueText (50) := Pic.Scale (Pic.FileNew ("pacman/font/blue200.bmp"), 32, 16)
iBlueText (51) := Pic.Scale (Pic.FileNew ("pacman/font/blue400.bmp"), 32, 16)
iBlueText (52) := Pic.Scale (Pic.FileNew ("pacman/font/blue800.bmp"), 32, 16)
iBlueText (53) := Pic.Scale (Pic.FileNew ("pacman/font/blue1600.bmp"), 32, 16)
iBlueText (54) := Pic.Scale (Pic.FileNew ("pacman/font/bluepts.bmp"), 36, 16)

var iYellowText : array 0 .. 54 of int
iYellowText (0) := Pic.Scale (Pic.FileNew ("pacman/font/yellow0.bmp"), 16, 16)
iYellowText (1) := Pic.Scale (Pic.FileNew ("pacman/font/yellow1.bmp"), 16, 16)
iYellowText (2) := Pic.Scale (Pic.FileNew ("pacman/font/yellow2.bmp"), 16, 16)
iYellowText (3) := Pic.Scale (Pic.FileNew ("pacman/font/yellow3.bmp"), 16, 16)
iYellowText (4) := Pic.Scale (Pic.FileNew ("pacman/font/yellow4.bmp"), 16, 16)
iYellowText (5) := Pic.Scale (Pic.FileNew ("pacman/font/yellow5.bmp"), 16, 16)
iYellowText (6) := Pic.Scale (Pic.FileNew ("pacman/font/yellow6.bmp"), 16, 16)
iYellowText (7) := Pic.Scale (Pic.FileNew ("pacman/font/yellow7.bmp"), 16, 16)
iYellowText (8) := Pic.Scale (Pic.FileNew ("pacman/font/yellow8.bmp"), 16, 16)
iYellowText (9) := Pic.Scale (Pic.FileNew ("pacman/font/yellow9.bmp"), 16, 16)
iYellowText (10) := Pic.Scale (Pic.FileNew ("pacman/font/yellowa.bmp"), 16, 16)
iYellowText (11) := Pic.Scale (Pic.FileNew ("pacman/font/yellowb.bmp"), 16, 16)
iYellowText (12) := Pic.Scale (Pic.FileNew ("pacman/font/yellowc.bmp"), 16, 16)
iYellowText (13) := Pic.Scale (Pic.FileNew ("pacman/font/yellowd.bmp"), 16, 16)
iYellowText (14) := Pic.Scale (Pic.FileNew ("pacman/font/yellowe.bmp"), 16, 16)
iYellowText (15) := Pic.Scale (Pic.FileNew ("pacman/font/yellowf.bmp"), 16, 16)
iYellowText (16) := Pic.Scale (Pic.FileNew ("pacman/font/yellowg.bmp"), 16, 16)
iYellowText (17) := Pic.Scale (Pic.FileNew ("pacman/font/yellowh.bmp"), 16, 16)
iYellowText (18) := Pic.Scale (Pic.FileNew ("pacman/font/yellowi.bmp"), 16, 16)
iYellowText (19) := Pic.Scale (Pic.FileNew ("pacman/font/yellowj.bmp"), 16, 16)
iYellowText (20) := Pic.Scale (Pic.FileNew ("pacman/font/yellowk.bmp"), 16, 16)
iYellowText (21) := Pic.Scale (Pic.FileNew ("pacman/font/yellowl.bmp"), 16, 16)
iYellowText (22) := Pic.Scale (Pic.FileNew ("pacman/font/yellowm.bmp"), 16, 16)
iYellowText (23) := Pic.Scale (Pic.FileNew ("pacman/font/yellown.bmp"), 16, 16)
iYellowText (24) := Pic.Scale (Pic.FileNew ("pacman/font/yellowo.bmp"), 16, 16)
iYellowText (25) := Pic.Scale (Pic.FileNew ("pacman/font/yellowp.bmp"), 16, 16)
iYellowText (26) := Pic.Scale (Pic.FileNew ("pacman/font/yellowq.bmp"), 16, 16)
iYellowText (27) := Pic.Scale (Pic.FileNew ("pacman/font/yellowr.bmp"), 16, 16)
iYellowText (28) := Pic.Scale (Pic.FileNew ("pacman/font/yellows.bmp"), 16, 16)
iYellowText (29) := Pic.Scale (Pic.FileNew ("pacman/font/yellowt.bmp"), 16, 16)
iYellowText (30) := Pic.Scale (Pic.FileNew ("pacman/font/yellowu.bmp"), 16, 16)
iYellowText (31) := Pic.Scale (Pic.FileNew ("pacman/font/yellowv.bmp"), 16, 16)
iYellowText (32) := Pic.Scale (Pic.FileNew ("pacman/font/yelloww.bmp"), 16, 16)
iYellowText (33) := Pic.Scale (Pic.FileNew ("pacman/font/yellowx.bmp"), 16, 16)
iYellowText (34) := Pic.Scale (Pic.FileNew ("pacman/font/yellowy.bmp"), 16, 16)
iYellowText (35) := Pic.Scale (Pic.FileNew ("pacman/font/yellowz.bmp"), 16, 16)
iYellowText (36) := Pic.Scale (Pic.FileNew ("pacman/font/yellowperiod.bmp"), 16, 16)
iYellowText (37) := Pic.Scale (Pic.FileNew ("pacman/font/yellowexclaim.bmp"), 16, 16)
iYellowText (38) := Pic.Scale (Pic.FileNew ("pacman/font/yellowslash.bmp"), 16, 16)
iYellowText (39) := Pic.Scale (Pic.FileNew ("pacman/font/yellowquote.bmp"), 16, 16)
iYellowText (40) := Pic.Scale (Pic.FileNew ("pacman/font/yellowhyphen.bmp"), 16, 16)
iYellowText (41) := Pic.Scale (Pic.FileNew ("pacman/font/yellowcopy.bmp"), 16, 16)
iYellowText (42) := Pic.Scale (Pic.FileNew ("pacman/font/yellowcomma.bmp"), 16, 16)
iYellowText (43) := Pic.Scale (Pic.FileNew ("pacman/font/yellowapos.bmp"), 16, 16)
iYellowText (44) := Pic.Scale (Pic.FileNew ("pacman/font/yellow10.bmp"), 32, 16)
iYellowText (45) := Pic.Scale (Pic.FileNew ("pacman/font/yellow20.bmp"), 32, 16)
iYellowText (46) := Pic.Scale (Pic.FileNew ("pacman/font/yellow30.bmp"), 32, 16)
iYellowText (47) := Pic.Scale (Pic.FileNew ("pacman/font/yellow40.bmp"), 32, 16)
iYellowText (48) := Pic.Scale (Pic.FileNew ("pacman/font/yellow50.bmp"), 32, 16)
iYellowText (49) := Pic.Scale (Pic.FileNew ("pacman/font/yellow160.bmp"), 32, 16)
iYellowText (50) := Pic.Scale (Pic.FileNew ("pacman/font/yellow200.bmp"), 32, 16)
iYellowText (51) := Pic.Scale (Pic.FileNew ("pacman/font/yellow400.bmp"), 32, 16)
iYellowText (52) := Pic.Scale (Pic.FileNew ("pacman/font/yellow800.bmp"), 32, 16)
iYellowText (53) := Pic.Scale (Pic.FileNew ("pacman/font/yellow1600.bmp"), 32, 16)
iYellowText (54) := Pic.Scale (Pic.FileNew ("pacman/font/yellowpts.bmp"), 36, 16)

View.SetTransparentColor (black)




class Rectangle
    import debug, Direction
    %% This tells us what can be used outside the class
    %% if not listed here it cannot be used outside the class
    export setRectangle, x, y, width, height, isTouching, move, draw, setPosition, collisionMove, dir, autoCollisionMove, setDirection, reset

    var x, y, origX, origY, width, height : int
    var initOrigPos := true

    var dir := Direction.none
    var origDir := Direction.none
    var initOrigDir := true



    proc setPosition (xPos, yPos : int)
	if initOrigPos then
	    origX := xPos
	    origY := yPos
	    initOrigPos := false
	end if
	x := xPos
	y := yPos
    end setPosition

    proc setRectangle (newX, newY, newWidth, newHeight : int)
	setPosition (newX, newY)
	width := newWidth
	height := newHeight
    end setRectangle


    fcn isTouching (rect : ^Rectangle) : boolean
	result (x < rect -> x + rect -> width and x + width > rect -> x and y < rect -> y + rect -> height and y + height > rect -> y)
    end isTouching

    fcn intersects (inX, inY : int) : boolean
	result (inX > x and inX < x + width and inY > y and inY < inY + height)
    end intersects

    proc move (xOff, yOff : int)
	x += xOff
	y += yOff
    end move

    % Use for when the player uses the keys to try and move
    fcn collisionMove (xOff, yOff : int, rects : array 0 .. * of ^Rectangle) : boolean
	move (xOff, yOff)

	for i : 0 .. upper (rects)
	    if isTouching (rects (i)) then
		move (-xOff, -yOff)

		if xOff > 0 and yOff = 0 and dir = Direction.right then
		    dir := Direction.none
		elsif xOff < 0 and yOff = 0 and dir = Direction.left then
		    dir := Direction.none
		elsif xOff = 0 and yOff > 0 and dir = Direction.up then
		    dir := Direction.none
		elsif xOff = 0 and yOff < 0 and dir = Direction.down then
		    dir := Direction.none
		end if

		result false
	    end if
	end for

	if xOff > 0 and yOff = 0 then
	    dir := Direction.right
	elsif xOff < 0 and yOff = 0 then
	    dir := Direction.left
	elsif xOff = 0 and yOff > 0 then
	    dir := Direction.up
	elsif xOff = 0 and yOff < 0 then
	    dir := Direction.down
	end if

	result true
    end collisionMove

    proc setDirection (newDir : Direction)
	if initOrigDir then
	    origDir := newDir
	    initOrigDir := false
	end if
	dir := newDir
    end setDirection

    proc reset
	if not initOrigDir then
	    setDirection (origDir)
	end if
	if not initOrigPos then
	    setPosition (origX, origY)
	end if
    end reset

    % Only used for when the game automatically moves the player
    fcn autoCollisionMove (xOff, yOff : int, rects : array 0 .. * of ^Rectangle) : boolean
	move (xOff, yOff)

	for i : 0 .. upper (rects)
	    if isTouching (rects (i)) then
		move (-xOff, -yOff)
		dir := Direction.none
		result false
	    end if
	end for
	result true
    end autoCollisionMove

    proc draw (fill : boolean)
	if debug then
	    if fill then
		drawfillbox (x * 2, y * 2, (x + width) * 2, (y + height) * 2, white)
	    else
		Draw.Line (x * 2, y * 2, x * 2, (y + height) * 2, white)
		Draw.Line (x * 2, (y + height) * 2, (x + width) * 2, (y + height) * 2, white)
		Draw.Line ((x + width) * 2, (y + height) * 2, (x + width) * 2, y * 2, white)
		Draw.Line ((x + width) * 2, y * 2, x * 2, y * 2, white)
	    end if
	end if
    end draw

end Rectangle

class FrameHolder
    export frames, framesLength, setFrames

    var frames : array 0 .. 15 of int
    var framesLength := 0

    proc setFrames (inFrames : array 0 .. * of int)
	framesLength := upper (inFrames)
	for i : 0 .. framesLength
	    frames (i) := inFrames (i)
	end for
    end setFrames
end FrameHolder

class AnimationRectangle
    import Rectangle, FrameHolder
    %% This tells us what can be used outside the class
    %% if not listed here it cannot be used outside the class
    export setRectangle, x, y, width, height, isTouching, move, draw, setPosition, setFrames, collisionMove, autoCollisionMove, reset

    var rec : ^Rectangle
    new rec

    var currentFrameTrack := 0

    var frameTrack : ^FrameHolder
    new frameTrack

    var spriteOffsetX := 0
    var spriteOffsetY := 0

    var framesPassed := 0
    var currentFrame := 0
    var ticksPerFrame := 0

    % tpf = ticks per frame. The amount of render ticks required to pass before the sprite changes.
    proc setFrames (newFrames : array 0 .. * of int, tpf, spriteOffX, spriteOffY : int)
	ticksPerFrame := tpf

	spriteOffsetX := spriteOffX
	spriteOffsetY := spriteOffY

	frameTrack -> setFrames (newFrames)
    end setFrames

    proc setRectangle (newX, newY, newWidth, newHeight : int)
	rec -> setRectangle (newX, newY, newWidth, newHeight)
    end setRectangle

    fcn isTouching (rect : ^Rectangle) : boolean
	result rec -> isTouching (rect)
    end isTouching

    proc setPosition (xPos, yPos : int)
	rec -> setPosition (xPos, yPos)
    end setPosition

    fcn x : int
	result rec -> x
    end x

    fcn y : int
	result rec -> y
    end y

    fcn width : int
	result rec -> width
    end width

    fcn height : int
	result rec -> height
    end height

    fcn collisionMove (xOff, yOff : int, rects : array 0 .. * of ^Rectangle) : boolean
	result rec -> collisionMove (xOff, yOff, rects)
    end collisionMove

    fcn autoCollisionMove (xOff, yOff : int, rects : array 0 .. * of ^Rectangle) : boolean
	result rec -> autoCollisionMove (xOff, yOff, rects)
    end autoCollisionMove

    proc move (xOff, yOff : int)
	rec -> move (xOff, yOff)
    end move

    proc reset
	rec -> reset
    end reset

    proc draw
	framesPassed := framesPassed + 1

	if framesPassed >= ticksPerFrame then
	    framesPassed := 0
	    currentFrame := currentFrame + 1

	    if currentFrame > frameTrack -> framesLength then
		currentFrame := 0
	    end if
	end if

	Pic.Draw (frameTrack -> frames (currentFrame), (x * 2) + spriteOffsetX, (y * 2) + spriteOffsetY, picUnderMerge)

	rec -> draw (false)
    end draw

end AnimationRectangle

class TextHolder
    import FontType
    export setText, font, text

    var font : FontType
    var text : string

    proc setText (newFont : FontType, newText : string)
	font := newFont
	text := newText
    end setText
end TextHolder

class AnimationText
    import Rectangle, TextHolder, drawText
    %% This tells us what can be used outside the class
    %% if not listed here it cannot be used outside the class
    export getX, getY, draw, setPosition, setFrames

    var currentFrameTrack := 0

    var frameTrack : array 0 .. 15 of ^TextHolder
    var trackLength := 0

    var x := 0
    var y := 0

    var framesPassed := 0
    var currentFrame := 0
    var ticksPerFrame := 0

    % tpf = ticks per frame. The amount of render ticks required to pass before the sprite changes.
    proc setFrames (newFrames : array 0 .. * of ^TextHolder, tpf : int)
	ticksPerFrame := tpf

	trackLength := upper (newFrames)

	for i : 0 .. trackLength
	    frameTrack (i) := newFrames (i)
	end for
    end setFrames

    proc setPosition (xPos, yPos : int)
	x := xPos
	y := yPos
    end setPosition

    fcn getX : int
	result x
    end getX

    fcn getY : int
	result y
    end getY

    proc move (xOff, yOff : int)
	x := x + xOff
	y := y + yOff
    end move

    proc draw
	framesPassed := framesPassed + 1

	if framesPassed >= ticksPerFrame then
	    framesPassed := 0
	    currentFrame := currentFrame + 1

	    if currentFrame > trackLength then
		currentFrame := 0
	    end if
	end if

	drawText (x, y, frameTrack (currentFrame) -> font, frameTrack (currentFrame) -> text)
    end draw

end AnimationText

class SpriteRectangle
    import Rectangle, Direction, FrameHolder
    %% This tells us what can be used outside the class
    %% if not listed here it cannot be used outside the class
    export setRectangle, x, y, width, height, isTouching, move, draw, setPosition, setFrames, collisionMove, direction, autoCollisionMove, setDirection, reset

    var rec : ^Rectangle
    new rec

    var currentFrameTrack := 0

    var frameTracks : array 0 .. 3 of ^FrameHolder
    new frameTracks (0)
    new frameTracks (1)
    new frameTracks (2)
    new frameTracks (3)

    var spriteOffsetX := 0
    var spriteOffsetY := 0

    var framesPassed := 0
    var currentFrame := 0
    var ticksPerFrame := 0

    % tpf = ticks per frame. The amount of render ticks required to pass before the sprite changes.
    proc setFrames (up : array 0 .. * of int, down : array 0 .. * of int, left : array 0 .. * of int, right : array 0 .. * of int, tpf, spriteOffX, spriteOffY : int)
	ticksPerFrame := tpf

	spriteOffsetX := spriteOffX
	spriteOffsetY := spriteOffY

	frameTracks (0) -> setFrames (up)

	frameTracks (1) -> setFrames (down)

	frameTracks (2) -> setFrames (left)

	frameTracks (3) -> setFrames (right)
    end setFrames

    proc setRectangle (newX, newY, newWidth, newHeight : int)
	rec -> setRectangle (newX, newY, newWidth, newHeight)
    end setRectangle

    fcn isTouching (rect : ^Rectangle) : boolean
	result rec -> isTouching (rect)
    end isTouching

    proc setPosition (xPos, yPos : int)
	rec -> setPosition (xPos, yPos)
    end setPosition

    fcn x : int
	result rec -> x
    end x

    fcn y : int
	result rec -> y
    end y

    fcn width : int
	result rec -> width
    end width

    fcn height : int
	result rec -> height
    end height

    fcn collisionMove (xOff, yOff : int, rects : array 0 .. * of ^Rectangle) : boolean
	result rec -> collisionMove (xOff, yOff, rects)
    end collisionMove

    fcn autoCollisionMove (xOff, yOff : int, rects : array 0 .. * of ^Rectangle) : boolean
	result rec -> autoCollisionMove (xOff, yOff, rects)
    end autoCollisionMove

    proc move (xOff, yOff : int)
	rec -> move (xOff, yOff)
    end move

    proc reset
	rec -> reset
	framesPassed := 0
	currentFrame := 0
    end reset

    fcn direction : Direction
	result rec -> dir
    end direction

    proc setDirection (newDir : Direction)
	rec -> setDirection (newDir)
    end setDirection

    proc draw
	framesPassed := framesPassed + 1

	if rec -> dir = Direction.none then
	    currentFrame := 1
	elsif framesPassed >= ticksPerFrame then
	    framesPassed := 0
	    currentFrame := currentFrame + 1

	    if currentFrame > frameTracks (currentFrameTrack) -> framesLength then
		currentFrame := 0
	    end if
	end if

	if rec -> dir = Direction.up then
	    currentFrameTrack := 0
	elsif rec -> dir = Direction.down then
	    currentFrameTrack := 1
	elsif rec -> dir = Direction.left then
	    currentFrameTrack := 2
	elsif rec -> dir = Direction.right then
	    currentFrameTrack := 3
	end if

	Pic.Draw (frameTracks (currentFrameTrack) -> frames (currentFrame), (x * 2) + spriteOffsetX, (y * 2) + spriteOffsetY, picUnderMerge)

	rec -> draw (false)
    end draw

end SpriteRectangle

class Ghost
    import Rectangle, GhostType, SpriteRectangle, Direction, iBlinkyUp, iBlinkyDown, iBlinkyLeft, iBlinkyRight, iPinkyUp, iPinkyDown, iPinkyLeft, iPinkyRight, iInkyUp, iInkyDown, iInkyLeft,
	iInkyRight, iClydeUp,
	iClydeDown, iClydeLeft, iClydeRight

    export updateAI, setGhost, ghostType, x, y, width, height, isTouching, move, draw, setPosition, direction, setDirection, reset

    var rec : ^SpriteRectangle
    new rec

    var ghostType : GhostType

    proc setGhost (newX, newY : int, gType : GhostType, dir : Direction) % Rectangle, dir, frames
	rec -> setRectangle (newX, newY, 16, 16)
	rec -> setDirection (dir)

	ghostType := gType

	if (ghostType = GhostType.blinky_menu) then
	    rec -> setFrames (iBlinkyUp, iBlinkyDown, iBlinkyLeft, iBlinkyRight, 15, 0, 0)
	elsif (ghostType = GhostType.pinky_menu) then
	    rec -> setFrames (iPinkyUp, iPinkyDown, iPinkyLeft, iPinkyRight, 15, 0, 0)
	elsif (ghostType = GhostType.inky_menu) then
	    rec -> setFrames (iInkyUp, iInkyDown, iInkyLeft, iInkyRight, 15, 0, 0)
	elsif (ghostType = GhostType.clyde_menu) then
	    rec -> setFrames (iClydeUp, iClydeDown, iClydeLeft, iClydeRight, 15, 0, 0)
	elsif (ghostType = GhostType.blinky) then
	    rec -> setFrames (iBlinkyUp, iBlinkyDown, iBlinkyLeft, iBlinkyRight, 15, 0, 0)
	elsif (ghostType = GhostType.pinky) then
	    rec -> setFrames (iPinkyUp, iPinkyDown, iPinkyLeft, iPinkyRight, 15, 0, 0)
	elsif (ghostType = GhostType.inky) then
	    rec -> setFrames (iInkyUp, iInkyDown, iInkyLeft, iInkyRight, 15, 0, 0)
	elsif (ghostType = GhostType.clyde) then
	    rec -> setFrames (iClydeUp, iClydeDown, iClydeLeft, iClydeRight, 15, 0, 0)
	end if
    end setGhost

    fcn isTouching (rect : ^Rectangle) : boolean
	result rec -> isTouching (rect)
    end isTouching

    proc setPosition (xPos, yPos : int)
	rec -> setPosition (xPos, yPos)
    end setPosition

    fcn x : int
	result rec -> x
    end x

    fcn y : int
	result rec -> y
    end y

    fcn width : int
	result rec -> width
    end width

    fcn height : int
	result rec -> height
    end height

    fcn collisionMove (xOff, yOff : int, rects : array 0 .. * of ^Rectangle) : boolean
	result rec -> collisionMove (xOff, yOff, rects)
    end collisionMove

    proc autoCollisionMove (direc : Direction, rects : array 0 .. * of ^Rectangle)
	var xMove, yMove : int

	if direc = Direction.up then
	    xMove := 0
	    yMove := 1
	elsif direc = Direction.down then
	    xMove := 0
	    yMove := -1
	elsif direc = Direction.left then
	    xMove := -1
	    yMove := 0
	elsif direc = Direction.right then
	    xMove := 1
	    yMove := 0
	elsif direc = Direction.none then
	    xMove := 0
	    yMove := 0
	end if

	var sauce := rec -> autoCollisionMove (xMove, yMove, rects)
    end autoCollisionMove

    proc move (xOff, yOff : int)
	rec -> move (xOff, yOff)
    end move

    proc reset
	rec -> reset
    end reset

    fcn direction : Direction
	result rec -> direction
    end direction

    proc setDirection (newDir : Direction)
	rec -> setDirection (newDir)
    end setDirection

    proc draw
	rec -> draw
    end draw

    proc updateAI (rects : array 0 .. * of ^Rectangle)

	if (ghostType = GhostType.blinky_menu) then
	    autoCollisionMove (Direction.right, rects)
	elsif (ghostType = GhostType.pinky_menu) then

	elsif (ghostType = GhostType.inky_menu) then

	elsif (ghostType = GhostType.clyde_menu) then

	elsif (ghostType = GhostType.blinky) then

	elsif (ghostType = GhostType.pinky) then

	elsif (ghostType = GhostType.inky) then

	elsif (ghostType = GhostType.clyde) then

	end if

    end updateAI
end Ghost

class Pellet
    import Rectangle, Direction, FrameHolder, addScore, SpriteRectangle
    %% This tells us what can be used outside the class
    %% if not listed here it cannot be used outside the class
    export setPellet, x, y, width, height, isTouching, draw, setPosition, setFrames, update, reset, setStill

    var rec : ^Rectangle
    new rec

    var isLargePellet := false
    var isEaten := false
    var scoreValue := 0

    var spriteOffsetX := 0
    var spriteOffsetY := 0

    var framesPassed := 0
    var currentFrame := 0
    var ticksPerFrame := 0

    var isStill := false

    % tpf = ticks per frame. The amount of render ticks required to pass before the sprite changes.
    proc setFrames (tpf : int)
	ticksPerFrame := tpf
	isLargePellet := true
    end setFrames

    proc setPellet (newX, newY : int)
	var newHeight, newWidth : int

	if isLargePellet then
	    newHeight := 8
	    newWidth := 8
	    scoreValue := 50
	else
	    newHeight := 2
	    newWidth := 2
	    scoreValue := 10
	end if
	rec -> setRectangle (newX, newY, newWidth, newHeight)
    end setPellet

    fcn isTouching (rect : ^Rectangle) : boolean
	result rec -> isTouching (rect)
    end isTouching

    proc update (user : ^Rectangle)
	if user -> isTouching (rec) and not isEaten then
	    isEaten := true
	    addScore (scoreValue)
	end if
    end update

    proc setPosition (xPos, yPos : int)
	rec -> setPosition (xPos, yPos)
    end setPosition

    proc setStill (newStill : boolean)
	isStill := newStill
    end setStill

    proc reset
	isEaten := false
	framesPassed := 0
	currentFrame := 0
	rec -> reset
    end reset

    fcn x : int
	result rec -> x
    end x

    fcn y : int
	result rec -> y
    end y

    fcn width : int
	result rec -> width
    end width

    fcn height : int
	result rec -> height
    end height

    proc draw
	if not isEaten then
	    if not isLargePellet then
		drawfillbox ((x * 2) + spriteOffsetX, (y * 2) + spriteOffsetY, (x * 2) + spriteOffsetX + 3, (y * 2) + spriteOffsetY + 3, 89)
	    else
		if not isStill then
		    framesPassed := framesPassed + 1

		    if framesPassed >= ticksPerFrame then
			framesPassed := 0
			currentFrame := currentFrame + 1

			if currentFrame >= 2 then
			    currentFrame := 0
			end if
		    end if
		end if

		if currentFrame = 0 then
		    drawfillbox ((x * 2) + spriteOffsetX + 4, (y * 2) + spriteOffsetY, (x * 2) + spriteOffsetX + 11, (y * 2) + spriteOffsetY + 15, 89)
		    drawfillbox ((x * 2) + spriteOffsetX, (y * 2) + spriteOffsetY + 4, (x * 2) + spriteOffsetX + 15, (y * 2) + spriteOffsetY + 11, 89)
		    drawfillbox ((x * 2) + spriteOffsetX + 2, (y * 2) + spriteOffsetY + 2, (x * 2) + spriteOffsetX + 13, (y * 2) + spriteOffsetY + 13, 89)
		end if

		%Pic.Draw (frameTracks (currentFrameTrack) -> frames (currentFrame), (x * 2) + spriteOffsetX, (y * 2) + spriteOffsetY, picUnderMerge)
	    end if
	    rec -> draw (false)
	end if
    end draw

end Pellet

var bottomWall0 : ^Rectangle
new bottomWall0
bottomWall0 -> setRectangle (0, 16, 224, 4)

var bottomWall1 : ^Rectangle
new bottomWall1
bottomWall1 -> setRectangle (0, 16, 4, 124)

var bottomWall2 : ^Rectangle
new bottomWall2
bottomWall2 -> setRectangle (20, 36, 72, 8)

var bottomWall3 : ^Rectangle
new bottomWall3
bottomWall3 -> setRectangle (132, 36, 72, 8)

var bottomWall4 : ^Rectangle
new bottomWall4
bottomWall4 -> setRectangle (220, 16, 4, 124)

var bottomWall5 : ^Rectangle
new bottomWall5
bottomWall5 -> setRectangle (108, 36, 8, 32)

var bottomWall6 : ^Rectangle
new bottomWall6
bottomWall6 -> setRectangle (84, 60, 56, 8)

var bottomWall7 : ^Rectangle
new bottomWall7
bottomWall7 -> setRectangle (60, 36, 8, 32)

var bottomWall8 : ^Rectangle
new bottomWall8
bottomWall8 -> setRectangle (156, 36, 8, 32)

var bottomWall9 : ^Rectangle
new bottomWall9
bottomWall9 -> setRectangle (0, 60, 20, 8)

var bottomWall10 : ^Rectangle
new bottomWall10
bottomWall10 -> setRectangle (204, 60, 20, 8)

var bottomWall11 : ^Rectangle
new bottomWall11
bottomWall11 -> setRectangle (60, 84, 32, 8)

var bottomWall12 : ^Rectangle
new bottomWall12
bottomWall12 -> setRectangle (132, 84, 32, 8)

var bottomWall13 : ^Rectangle
new bottomWall13
bottomWall13 -> setRectangle (108, 84, 8, 32)

var bottomWall14 : ^Rectangle
new bottomWall14
bottomWall14 -> setRectangle (84, 108, 56, 8)

var leftWall1 : ^Rectangle
new leftWall1
leftWall1 -> setRectangle (0, 108, 44, 32)

var leftWall2 : ^Rectangle
new leftWall2
leftWall2 -> setRectangle (36, 60, 8, 32)

var rightWall1 : ^Rectangle
new rightWall1
rightWall1 -> setRectangle (180, 108, 44, 32)

var rightWall2 : ^Rectangle
new rightWall2
rightWall2 -> setRectangle (180, 60, 8, 32)

var leftWall3 : ^Rectangle
new leftWall3
leftWall3 -> setRectangle (20, 84, 24, 8)

var rightWall3 : ^Rectangle
new rightWall3
rightWall3 -> setRectangle (180, 84, 24, 8)

var leftWall4 : ^Rectangle
new leftWall4
leftWall4 -> setRectangle (0, 156, 44, 32)

var rightWall4 : ^Rectangle
new rightWall4
rightWall4 -> setRectangle (180, 156, 44, 32)

var leftWall5 : ^Rectangle
new leftWall5
leftWall5 -> setRectangle (60, 108, 8, 32)

var rightWall5 : ^Rectangle
new rightWall5
rightWall5 -> setRectangle (156, 108, 8, 32)

var centerWall1 : ^Rectangle
new centerWall1
centerWall1 -> setRectangle (84, 132, 56, 4)

var centerWall2 : ^Rectangle
new centerWall2
centerWall2 -> setRectangle (84, 132, 4, 32)

var centerWall3 : ^Rectangle
new centerWall3
centerWall3 -> setRectangle (84, 160, 20, 4)

var centerWall4 : ^Rectangle
new centerWall4
centerWall4 -> setRectangle (120, 160, 20, 4)

var centerWall5 : ^Rectangle
new centerWall5
centerWall5 -> setRectangle (136, 132, 4, 32)

var leftWall6 : ^Rectangle
new leftWall6
leftWall6 -> setRectangle (0, 156, 4, 108)

var rightWall6 : ^Rectangle
new rightWall6
rightWall6 -> setRectangle (220, 156, 4, 108)

var upperWall1 : ^Rectangle
new upperWall1
upperWall1 -> setRectangle (0, 260, 224, 4)

var upperWall2 : ^Rectangle
new upperWall2
upperWall2 -> setRectangle (108, 228, 8, 36)

var upperWall3 : ^Rectangle
new upperWall3
upperWall3 -> setRectangle (108, 180, 8, 32)

var upperWall4 : ^Rectangle
new upperWall4
upperWall4 -> setRectangle (84, 204, 56, 8)

var upperWall5 : ^Rectangle
new upperWall5
upperWall5 -> setRectangle (60, 228, 32, 16)

var upperWall6 : ^Rectangle
new upperWall6
upperWall6 -> setRectangle (132, 228, 32, 16)

var upperWall7 : ^Rectangle
new upperWall7
upperWall7 -> setRectangle (20, 228, 24, 16)

var upperWall8 : ^Rectangle
new upperWall8
upperWall8 -> setRectangle (180, 228, 24, 16)

var upperWall9 : ^Rectangle
new upperWall9
upperWall9 -> setRectangle (20, 204, 24, 8)

var upperWall10 : ^Rectangle
new upperWall10
upperWall10 -> setRectangle (180, 204, 24, 8)

var upperWall11 : ^Rectangle
new upperWall11
upperWall11 -> setRectangle (60, 156, 8, 56)

var upperWall12 : ^Rectangle
new upperWall12
upperWall12 -> setRectangle (156, 156, 8, 56)

var upperWall13 : ^Rectangle
new upperWall13
upperWall13 -> setRectangle (60, 180, 32, 8)

var upperWall14 : ^Rectangle
new upperWall14
upperWall14 -> setRectangle (132, 180, 32, 8)

var walls : array 0 .. 45 of ^Rectangle
walls (0) := bottomWall0
walls (1) := bottomWall1
walls (2) := bottomWall2
walls (3) := bottomWall3
walls (4) := bottomWall4
walls (5) := bottomWall5
walls (6) := bottomWall6
walls (7) := bottomWall7
walls (8) := bottomWall8
walls (9) := bottomWall9
walls (10) := bottomWall10
walls (11) := bottomWall11
walls (12) := bottomWall12
walls (13) := bottomWall13
walls (14) := bottomWall14
walls (15) := leftWall1
walls (16) := leftWall2
walls (17) := rightWall1
walls (18) := rightWall2
walls (19) := leftWall3
walls (20) := rightWall3
walls (21) := leftWall4
walls (22) := rightWall4
walls (23) := leftWall5
walls (24) := rightWall5
walls (25) := centerWall1
walls (26) := centerWall2
walls (27) := centerWall3
walls (28) := centerWall4
walls (29) := centerWall5
walls (30) := leftWall6
walls (31) := rightWall6
walls (32) := upperWall1
walls (33) := upperWall2
walls (34) := upperWall3
walls (35) := upperWall4
walls (36) := upperWall5
walls (37) := upperWall6
walls (38) := upperWall7
walls (39) := upperWall8
walls (40) := upperWall9
walls (41) := upperWall10
walls (42) := upperWall11
walls (43) := upperWall12
walls (44) := upperWall13
walls (45) := upperWall14

var leftTelePad : ^Rectangle
new leftTelePad
leftTelePad -> setRectangle (-12, 140, 0, 16)

var rightTelePad : ^Rectangle
new rightTelePad
rightTelePad -> setRectangle (224 + 12, 140, 0, 16)

var pellets : array 0 .. 1123 of ^Pellet
var totalPellets := 0

for i : 0 .. 25 % Bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (11 + (8 * i), 27)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 4 % Second bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (11 + (8 * i), 51)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Second bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (75 + (8 * i), 51)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Second bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (123 + (8 * i), 51)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 4 % Second bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (179 + (8 * i), 51)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

var newPellet1 : ^Pellet
new newPellet1
newPellet1 -> setFrames (pelletFlashTicks)
newPellet1 -> setPellet (8, 72)

pellets (totalPellets) := newPellet1
totalPellets := totalPellets + 1

var newPellet2 : ^Pellet
new newPellet2
newPellet2 -> setFrames (pelletFlashTicks)
newPellet2 -> setPellet (208, 72)

pellets (totalPellets) := newPellet2
totalPellets := totalPellets + 1

var newPellet3 : ^Pellet
new newPellet3
newPellet3 -> setFrames (pelletFlashTicks)
newPellet3 -> setPellet (8, 232)

pellets (totalPellets) := newPellet3
totalPellets := totalPellets + 1

var newPellet4 : ^Pellet
new newPellet4
newPellet4 -> setFrames (pelletFlashTicks)
newPellet4 -> setPellet (208, 232)

pellets (totalPellets) := newPellet4
totalPellets := totalPellets + 1

for i : 0 .. 1 % Third bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (19 + (8 * i), 75)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 5 % Third bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (59 + (8 * i), 75)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 5 % Third bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (123 + (8 * i), 75)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Third bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (195 + (8 * i), 75)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 4 % Fourth bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (11 + (8 * i), 99)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 5 % Fourth bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (59 + (8 * i), 99)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 5 % Fourth bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (123 + (8 * i), 99)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 4 % Fourth bottom row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (179 + (8 * i), 99)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 9 % Top row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (19 + (8 * i), 251)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 9 % Top row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (131 + (8 * i), 251)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Second top row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (19 + (8 * i), 219)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 13 % Second top row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (59 + (8 * i), 219)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Second top row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (179 + (8 * i), 219)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 4 % Third top row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (11 + (8 * i), 195)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Third top row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (75 + (8 * i), 195)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Third top row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (123 + (8 * i), 195)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 4 % Third top row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (179 + (8 * i), 195)

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (11, 35 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (99, 35 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (123, 35 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (211, 35 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column 2nd row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (27, 59 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column 2nd row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (75, 59 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column 2nd row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (147, 59 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column 2nd row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (195, 59 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 24 % Left column
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (51, 51 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 24 % Right column
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (171, 51 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column 3nd row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (11, 83 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left column 3nd row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (99, 83 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Right column 3nd row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (123, 83 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Right column 3nd row
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (211, 83 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Left Column top
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (11, 203 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left Column top
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (11, 243 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Left Column top
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (75, 203 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Left Column top
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (99, 227 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Right Column top
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (123, 227 + (8 * i))


    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Right Column top
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (147, 203 + (8 * i))

    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 1 % Right Column top
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (211, 243 + (8 * i))


    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

for i : 0 .. 3 % Right Column top
    var newPellet : ^Pellet
    new newPellet
    newPellet -> setPellet (211, 203 + (8 * i))


    pellets (totalPellets) := newPellet
    totalPellets := totalPellets + 1
end for

var User : ^SpriteRectangle
new User

User -> setRectangle (104, 68, 16, 16)
User -> setDirection (Direction.up)
User -> setFrames (iPacmanUp, iPacmanDown, iPacmanLeft, iPacmanRight, 2, 1, 0)

var titleCredits1 : ^TextHolder
new titleCredits1
titleCredits1 -> setText (FontType.normal_white, "CREDIT 1")

var titleCredits2 : ^TextHolder
new titleCredits2
titleCredits2 -> setText (FontType.normal_white, "")

var titleCreditsText : array 0 .. 1 of ^TextHolder
titleCreditsText (0) := titleCredits1
titleCreditsText (1) := titleCredits2

var titleCredits : ^AnimationText
new titleCredits
titleCredits -> setPosition (16, 0)
titleCredits -> setFrames (titleCreditsText, 38)

var largeMenuPellet1 : ^Pellet
new largeMenuPellet1
largeMenuPellet1 -> setStill (true)
largeMenuPellet1 -> setFrames (pelletFlashTicks)
largeMenuPellet1 -> setPellet (80, 72)

var largeMenuPellet2 : ^Pellet
new largeMenuPellet2
largeMenuPellet2 -> setStill (true)
largeMenuPellet2 -> setFrames (pelletFlashTicks)
largeMenuPellet2 -> setPellet (32, 119)

var smallMenuPellet : ^Pellet
new smallMenuPellet
smallMenuPellet -> setPellet (83, 91)


var inGame1Up1 : ^TextHolder
new inGame1Up1
inGame1Up1 -> setText (FontType.normal_white, "1UP")

var inGame1Up2 : ^TextHolder
new inGame1Up2
inGame1Up2 -> setText (FontType.normal_white, "")

var inGameOneUpText : array 0 .. 1 of ^TextHolder
inGameOneUpText (0) := inGame1Up1
inGameOneUpText (1) := inGame1Up2

var inGameOneUp : ^AnimationText
new inGameOneUp
inGameOneUp -> setPosition (25, 279)
inGameOneUp -> setFrames (inGameOneUpText, 16)


var walls2 : array 0 .. 1 of ^Rectangle
walls2 (0) := bottomWall0
walls2 (1) := bottomWall1


var menuBlinky : ^Ghost
new menuBlinky
menuBlinky -> setGhost (80, 110, GhostType.blinky_menu, Direction.right)


loadFile

% Draws the splash screen
drawfillbox (0, 0, maxx, maxy, black)

var xTitleOff := 39
var yTitleOff := 160

drawText (xTitleOff, yTitleOff, FontType.normal_white, "CODED IN TURING BY")
drawText (xTitleOff + 25, yTitleOff - (16 * 1), FontType.normal_white, "SAMSON CLOSE")

var splashDelay := 3000

% Use to set the openTime count for debugging
%openTime := 3

if openTime = 0 or openTime = 1 or openTime = 2 then
    splashDelay := 5000
    drawText (xTitleOff - 12, yTitleOff - (16 * 3), FontType.normal_white, "I DO NOT CLAIM RIGHTS")
    drawText (xTitleOff - 12, yTitleOff - (16 * 4), FontType.normal_white, "TO ANY OF THE IMAGES")
    drawText (xTitleOff - 12, yTitleOff - (16 * 5), FontType.normal_white, "OR SOUNDS USED IN THIS")
    drawText (xTitleOff - 12, yTitleOff - (16 * 6), FontType.normal_white, "PROJECT.NO MONEY IS")
    drawText (xTitleOff - 12, yTitleOff - (16 * 7), FontType.normal_white, "BEING MADE FROM THIS")
    drawText (xTitleOff - 12, yTitleOff - (16 * 8), FontType.normal_white, "OPEN SOURCE PROJECT.")
elsif openTime = 3 then
    splashDelay := 5000
    drawText (xTitleOff + 15, yTitleOff - (16 * 3), FontType.normal_white, "THANK YOU FOR")
    drawText (xTitleOff + 15, yTitleOff - (16 * 4), FontType.normal_white, "PLAYING!")
elsif openTime >= 4 then
    splashDelay := 3000
    var trivia := Rand.Int (0, 6)

    % Use to set the trivia number for debugging
    %trivia := 6

    if trivia = 0 then
	drawText (xTitleOff - 22, yTitleOff - (16 * 3), FontType.normal_white, "PACMAN WAS ORIGINALLY")
	drawText (xTitleOff - 22, yTitleOff - (16 * 4), FontType.normal_white, "DESIGNED BY Toru Iwatani")
	drawText (xTitleOff - 22, yTitleOff - (16 * 5), FontType.normal_white, "IN May 22, 1980")
    elsif trivia = 1 then
	drawText (xTitleOff - 22, yTitleOff - (16 * 3), FontType.normal_white, "PACMAN'S DESIGN WAS MADE")
	drawText (xTitleOff - 22, yTitleOff - (16 * 4), FontType.normal_white, "BY ROUNDING THE JAPANESE")
	drawText (xTitleOff - 22, yTitleOff - (16 * 5), FontType.normal_white, "SYMBOL FOR \"MOUTH\"")
    elsif trivia = 2 then
	drawText (xTitleOff - 8, yTitleOff - (16 * 3), FontType.normal_white, "THE HIGHEST POSSIBLE")
	drawText (xTitleOff - 8, yTitleOff - (16 * 4), FontType.normal_white, "SCORE YOU CAN GET IS")
	drawText (xTitleOff + 34, yTitleOff - (16 * 5), FontType.normal_white, "3 333 360")
    elsif trivia = 3 then
	drawText (xTitleOff - 8, yTitleOff - (16 * 3), FontType.normal_white, "PACMAN WAS CREATED IN")
	drawText (xTitleOff - 8, yTitleOff - (16 * 4), FontType.normal_white, "RESPONSE TO MINDLESS")
	drawText (xTitleOff - 8, yTitleOff - (16 * 5), FontType.normal_white, "ARCADE SHOOTERS")
    elsif trivia = 4 then
	drawText (xTitleOff - 20, yTitleOff - (16 * 3), FontType.normal_white, "THE DESIGNERS OF PACMAN")
	drawText (xTitleOff - 20, yTitleOff - (16 * 4), FontType.normal_white, "EARNED NO PROFIT MADE")
	drawText (xTitleOff - 20, yTitleOff - (16 * 5), FontType.normal_white, "FROM PACMAN'S SUCCESS.")
	drawText (xTitleOff - 20, yTitleOff - (16 * 6), FontType.normal_white, "NAMCO COMPANY PAID THEM")
	drawText (xTitleOff - 20, yTitleOff - (16 * 7), FontType.normal_white, "THEIR REGULAR SALARY")
    elsif trivia = 5 then
	drawText (xTitleOff - 10, yTitleOff - (16 * 3), FontType.normal_white, "A 35TH ANNIVERSARY")
	drawText (xTitleOff - 10, yTitleOff - (16 * 4), FontType.normal_white, "GAME CALLED \"PACMAN")
	drawText (xTitleOff - 10, yTitleOff - (16 * 5), FontType.normal_white, "256\" REVOLVES AROUND")
	drawText (xTitleOff - 10, yTitleOff - (16 * 6), FontType.normal_white, "A GLITCH WHICH OCCURS")
	drawText (xTitleOff - 10, yTitleOff - (16 * 7), FontType.normal_white, "IN LEVEL 256 OF PACMAN")
    elsif trivia = 5 then
	drawText (xTitleOff - 10, yTitleOff - (16 * 3), FontType.normal_white, "A 35TH ANNIVERSARY")
	drawText (xTitleOff - 10, yTitleOff - (16 * 4), FontType.normal_white, "GAME CALLED \"PACMAN")
	drawText (xTitleOff - 10, yTitleOff - (16 * 5), FontType.normal_white, "256\" REVOLVES AROUND")
	drawText (xTitleOff - 10, yTitleOff - (16 * 6), FontType.normal_white, "A GLITCH WHICH OCCURS")
	drawText (xTitleOff - 10, yTitleOff - (16 * 7), FontType.normal_white, "IN LEVEL 256 OF PACMAN")
    elsif trivia = 6 then
	var howManyTimes := "GAME "
	howManyTimes += intstr (openTime)
	howManyTimes += " TIMES"
	drawText (xTitleOff - 7, yTitleOff - (16 * 3), FontType.normal_white, "YOU'VE LOADED THIS")
	drawText (xTitleOff - 7, yTitleOff - (16 * 4), FontType.normal_white, howManyTimes)
    end if
end if

Pic.Draw (iLogo, 74, 400, 0)

View.Update

openTime += 1

var lastEnter := false

loop
    exit when exitProgram = true
    var chars : array char of boolean
    Input.KeyDown (chars)
    if chars ('r') then
	resetSaveVariables
    end if

    if chars (KEY_ENTER) then
	lastEnter := true
    elsif lastEnter then
	splashDelay := 0
    end if

    currentTime := Time.Elapsed
    exit when currentTime >= splashDelay
end loop

saveFile
























































% The main gameloop
loop
    exit when exitProgram = true

    currentTime := Time.Elapsed

    if (currentTime > lastTick + tickInterval) then
	if inGame = true then

	    gameInput

	    gameMath

	    updateAI

	    drawPlayScreen

	else

	    menuInput

	    drawMenuScreen

	end if

	lastTick := currentTime
    end if

    % Updates the frame
    View.Update
end loop

% Updates the AI to move towards the closest ball
body proc updateAI

end updateAI

% Does additional game functions that isn't in Input or Rendering or AI
body proc gameMath
    if User -> isTouching (leftTelePad) then
	User -> setPosition (218, 140)
    elsif User -> isTouching (rightTelePad) then
	User -> setPosition (-12, 140)
    end if

    var playerPelletRect : ^Rectangle
    new playerPelletRect
    playerPelletRect -> setRectangle (User -> x + 6, User -> y + 6, User -> width - 12, User -> height - 12)

    for i : 0 .. upper (pellets)
	if (i < totalPellets) then
	    pellets (i) -> update (playerPelletRect)
	end if
    end for

    if score > highScore then
	highScore := score
    end if

end gameMath

% Draws the screen
body proc drawPlayScreen
    % Draws the background
    drawfillbox (0, 0, maxx, maxy, black)

    Pic.Draw (iMap, 0, 0, picUnderMerge)

    inGameOneUp -> draw
    drawTextRight (56, 271, FontType.normal_white, intstr (score))
    drawText (72, 279, FontType.normal_white, "HIGH SCORE")
    drawTextRight (136, 271, FontType.normal_white, intstr (highScore))

    User -> draw

    for i : 0 .. upper (walls)
	walls (i) -> draw (false)
    end for

    for i : 0 .. upper (pellets)
	if (i < totalPellets) then
	    pellets (i) -> draw
	end if
    end for
end drawPlayScreen

% Detects when players presses the key for in-game
body proc gameInput
    var autoUpOverride := true
    var autoDownOverride := true
    var autoRightOverride := true
    var autoLeftOverride := true

    var chars : array char of boolean
    Input.KeyDown (chars)

    if (chars (KEY_UP_ARROW)) then
	if User -> collisionMove (0, 2, walls) then
	    autoUpOverride := true
	end if
    else
	autoUpOverride := false
    end if

    if (chars (KEY_DOWN_ARROW)) then
	if User -> collisionMove (0, -2, walls) then
	    autoDownOverride := true
	end if
    else
	autoDownOverride := false
    end if

    if (chars (KEY_RIGHT_ARROW)) then
	if User -> collisionMove (2, 0, walls) then
	    autoRightOverride := true
	end if
    else
	autoRightOverride := false
    end if

    if (chars (KEY_LEFT_ARROW)) then
	if User -> collisionMove (-2, 0, walls) then
	    autoLeftOverride := true
	end if
    else
	autoLeftOverride := false
    end if

    if User -> direction = Direction.right and not autoRightOverride then
	if not User -> autoCollisionMove (2, 0, walls) then

	end if
    elsif User -> direction = Direction.left and not autoLeftOverride then
	if not User -> autoCollisionMove (-2, 0, walls) then

	end if
    elsif User -> direction = Direction.up and not autoUpOverride then
	if not User -> autoCollisionMove (0, 2, walls) then

	end if
    elsif User -> direction = Direction.down and not autoDownOverride then
	if not User -> autoCollisionMove (0, -2, walls) then

	end if
    end if


    if (chars ('r')) then
	reset
    end if

    if chars (KEY_ESC) then
	inGame := false
	reset
    end if
end gameInput


body proc addScore
    score += toAdd
end addScore

% Resets the in game values
body proc reset
    setupNextLevel
    score := 0
    saveFile
end reset

body proc setupNextLevel
    User -> reset

    for i : 0 .. upper (pellets)
	if (i < totalPellets) then
	    pellets (i) -> reset
	end if
    end for
end setupNextLevel

var menuTick := 0

%Draws the menu screen
body proc drawMenuScreen

    %menuBlinky -> updateAI (walls2)
    menuBlinky -> draw
    
    if menuTick >= 0 then
	% Draws the background
	drawfillbox (0, 0, maxx, maxy, black)

	drawText (25, 279, FontType.normal_white, "1UP")
	drawText (72, 279, FontType.normal_white, "HIGH SCORE")
	drawTextRight (136, 271, FontType.normal_white, intstr (highScore))
	drawText (176, 279, FontType.normal_white, "2UP")
    end if

    if menuTick >= 20 then
	drawText (56, 240, FontType.normal_white, "CHARACTER / NICKNAME")
    end if

    if menuTick >= 40 then
	Pic.Draw (iBlinkyRight (0), (33 * 2) - 2, (222 * 2) - 2, picUnderMerge)
    end if

    if menuTick >= 70 then
	drawText (56, 224, FontType.normal_red, "-SHADOW")
    end if

    if menuTick >= 90 then
	drawText (144, 224, FontType.normal_red, "\"BLINKY\"")
    end if

    if menuTick >= 110 then
	Pic.Draw (iPinkyRight (0), (33 * 2) - 2, (198 * 2) - 2, picUnderMerge)
    end if

    if menuTick >= 140 then
	drawText (56, 200, FontType.normal_pink, "-SPEEDY")
    end if

    if menuTick >= 160 then
	drawText (144, 200, FontType.normal_pink, "\"PINKY\"")
    end if

    if menuTick >= 180 then
	Pic.Draw (iInkyRight (0), (33 * 2) - 2, (174 * 2) - 2, picUnderMerge)
    end if

    if menuTick >= 210 then
	drawText (56, 176, FontType.normal_blue, "-BASHFUL")
    end if

    if menuTick >= 230 then
	drawText (144, 176, FontType.normal_blue, "\"INKY\"")
    end if

    if menuTick >= 250 then
	Pic.Draw (iClydeRight (0), (33 * 2) - 2, (150 * 2) - 2, picUnderMerge)
    end if

    if menuTick >= 280 then
	drawText (56, 152, FontType.normal_orange, "-POKEY")
    end if

    if menuTick >= 300 then
	drawText (144, 152, FontType.normal_orange, "\"CLYDE\"")
    end if

    if menuTick >= 340 then
	drawText (96, 88, FontType.normal_white, "10")
	drawText (96, 72, FontType.normal_white, "50")
	largeMenuPellet1 -> draw
	smallMenuPellet -> draw
    end if

    if menuTick >= 380 then
	drawText (32, 32, FontType.normal_pink, "� 1980 MIDWAY MFG.CO.")
	largeMenuPellet2 -> draw
    end if

    if menuTick >= 420 then
	largeMenuPellet1 -> setStill (false)
	largeMenuPellet2 -> setStill (false)
    end if

    menuTick += 1
















    Pic.Draw (iTitle, 0, 0, picUnderMerge)


    titleCredits -> draw






    Pic.Draw (iScaredGhost (0), (89 * 2) - 2, (117 * 2) - 2, picUnderMerge)
    Pic.Draw (iScaredGhost (0), (104 * 2) - 1, (117 * 2) - 2, picUnderMerge)
    Pic.Draw (iScaredGhost (0), (120 * 2) - 2, (117 * 2) - 2, picUnderMerge)

    titleCredits -> draw

end drawMenuScreen

% Tracks the last value (used for filtering input)
var upLast := false
var downLast := false
var leftLast := false
var rightLast := false

% Detects when players hit a key on the menu screen
body proc menuInput
    var chars : array char of boolean
    Input.KeyDown (chars)

    var keyUp := chars (KEY_UP_ARROW)
    var keyDown := chars (KEY_DOWN_ARROW)
    var keyLeft := chars (KEY_LEFT_ARROW)
    var keyRight := chars (KEY_RIGHT_ARROW)

    if keyUp and not upLast then

    end if

    if keyDown and not downLast then

    end if

    if keyLeft and not leftLast then

    end if

    if keyRight and not rightLast then

    end if

    if chars (KEY_ENTER) then
	inGame := true
	reset
    end if

    if chars (KEY_ESC) then
	closeGame
    end if

    % Updates the filtering variables (MUST BE LAST)
    upLast := keyUp
    downLast := keyDown
    leftLast := keyLeft
    rightLast := keyRight
end menuInput

body proc drawTextRight
    drawText (x - floor (length (text) * 8), y, font, text)
end drawTextRight

body proc drawTextCenter
    drawText (x - floor ((length (text) * 8) / 2), y, font, text)
end drawTextCenter

% Draws text to the screen
body proc drawText
    for i : 1 .. length (text)
	if not text (i) = " " then
	    var letterOrdinal := 0

	    if text (i) = "0" then
		letterOrdinal := 0
	    elsif text (i) = "1" then
		letterOrdinal := 1
	    elsif text (i) = "2" then
		letterOrdinal := 2
	    elsif text (i) = "3" then
		letterOrdinal := 3
	    elsif text (i) = "4" then
		letterOrdinal := 4
	    elsif text (i) = "5" then
		letterOrdinal := 5
	    elsif text (i) = "6" then
		letterOrdinal := 6
	    elsif text (i) = "7" then
		letterOrdinal := 7
	    elsif text (i) = "8" then
		letterOrdinal := 8
	    elsif text (i) = "9" then
		letterOrdinal := 9
	    elsif text (i) = "A" or text (i) = "a" then
		letterOrdinal := 10
	    elsif text (i) = "B" or text (i) = "b" then
		letterOrdinal := 11
	    elsif text (i) = "C" or text (i) = "c" then
		letterOrdinal := 12
	    elsif text (i) = "D" or text (i) = "d" then
		letterOrdinal := 13
	    elsif text (i) = "E" or text (i) = "e" then
		letterOrdinal := 14
	    elsif text (i) = "F" or text (i) = "f" then
		letterOrdinal := 15
	    elsif text (i) = "G" or text (i) = "g" then
		letterOrdinal := 16
	    elsif text (i) = "H" or text (i) = "h" then
		letterOrdinal := 17
	    elsif text (i) = "I" or text (i) = "i" then
		letterOrdinal := 18
	    elsif text (i) = "J" or text (i) = "j" then
		letterOrdinal := 19
	    elsif text (i) = "K" or text (i) = "k" then
		letterOrdinal := 20
	    elsif text (i) = "L" or text (i) = "l" then
		letterOrdinal := 21
	    elsif text (i) = "M" or text (i) = "m" then
		letterOrdinal := 22
	    elsif text (i) = "N" or text (i) = "n" then
		letterOrdinal := 23
	    elsif text (i) = "O" or text (i) = "o" then
		letterOrdinal := 24
	    elsif text (i) = "P" or text (i) = "p" then
		letterOrdinal := 25
	    elsif text (i) = "Q" or text (i) = "q" then
		letterOrdinal := 26
	    elsif text (i) = "R" or text (i) = "r" then
		letterOrdinal := 27
	    elsif text (i) = "S" or text (i) = "s" then
		letterOrdinal := 28
	    elsif text (i) = "T" or text (i) = "t" then
		letterOrdinal := 29
	    elsif text (i) = "U" or text (i) = "u" then
		letterOrdinal := 30
	    elsif text (i) = "V" or text (i) = "v" then
		letterOrdinal := 31
	    elsif text (i) = "W" or text (i) = "w" then
		letterOrdinal := 32
	    elsif text (i) = "X" or text (i) = "x" then
		letterOrdinal := 33
	    elsif text (i) = "Y" or text (i) = "y" then
		letterOrdinal := 34
	    elsif text (i) = "Z" or text (i) = "z" then
		letterOrdinal := 35
	    elsif text (i) = "." then
		letterOrdinal := 36
	    elsif text (i) = "!" then
		letterOrdinal := 37
	    elsif text (i) = "/" then
		letterOrdinal := 38
	    elsif text (i) = "\"" then
		letterOrdinal := 39
	    elsif text (i) = "-" then
		letterOrdinal := 40
	    elsif text (i) = "�" then
		letterOrdinal := 41
	    elsif text (i) = "," then
		letterOrdinal := 42
	    elsif text (i) = "'" then
		letterOrdinal := 43
	    end if

	    var picID : int

	    if font = FontType.normal_white then
		picID := iWhiteText (letterOrdinal)
	    elsif font = FontType.normal_pink then
		picID := iPinkText (letterOrdinal)
	    elsif font = FontType.normal_red then
		picID := iRedText (letterOrdinal)
	    elsif font = FontType.normal_blue then
		picID := iBlueText (letterOrdinal)
	    elsif font = FontType.normal_orange then
		picID := iOrangeText (letterOrdinal)
	    elsif font = FontType.normal_yellow then
		picID := iYellowText (letterOrdinal)
	    end if

	    Pic.Draw (picID, (x * 2) + ((i - 1) * 16), (y * 2), picUnderMerge)
	end if
    end for
end drawText

body proc drawNumberRight
    drawNumber (x - 16, y, font, num)
end drawNumberRight

body proc drawNumberCenter
    drawNumber (x - 8, y, font, num)
end drawNumberCenter

% Draws text to the screen
body proc drawNumber
    var letterOrdinal := 0

    if num = 10 then
	letterOrdinal := 44
    elsif num = 20 then
	letterOrdinal := 45
    elsif num = 30 then
	letterOrdinal := 46
    elsif num = 40 then
	letterOrdinal := 47
    elsif num = 50 then
	letterOrdinal := 48
    elsif num = 160 then
	letterOrdinal := 49
    elsif num = 200 then
	letterOrdinal := 50
    elsif num = 400 then
	letterOrdinal := 51
    elsif num = 800 then
	letterOrdinal := 52
    elsif num = 1600 then
	letterOrdinal := 53
    end if

    var picID : int

    if font = FontType.normal_white then
	picID := iWhiteText (letterOrdinal)
    elsif font = FontType.normal_pink then
	picID := iPinkText (letterOrdinal)
    elsif font = FontType.normal_red then
	picID := iRedText (letterOrdinal)
    elsif font = FontType.normal_blue then
	picID := iBlueText (letterOrdinal)
    elsif font = FontType.normal_orange then
	picID := iOrangeText (letterOrdinal)
    elsif font = FontType.normal_yellow then
	picID := iYellowText (letterOrdinal)
    end if

    Pic.Draw (picID, (x * 2), (y * 2), picUnderMerge)
end drawNumber

body proc loadFile
    var stremin : int
    var temp : int
    var lineNumber := 0

    open : stremin, "pacman/save.txt", get

    loop
	exit when eof (stremin)
	get : stremin, temp

	if lineNumber = 0 then
	    openTime := temp
	elsif lineNumber = 1 then
	    highScore := temp
	end if

	lineNumber += 1
    end loop

    close : stremin
end loadFile

body proc resetSaveVariables
    openTime := 0
    highScore := 0
    closeGame
end resetSaveVariables

body proc closeGame
    GUI.Quit
    loop
	exit when GUI.ProcessEvent
    end loop
    Window.Hide (defWinID)

    exitProgram := true
end closeGame

body proc saveFile
    var stremout : int
    open : stremout, "pacman/save.txt", put
    put : stremout, openTime
    put : stremout, highScore
    close : stremout
end saveFile
