import raylib, raymath, rlgl, rayutils, math, lenientops, random, sequtils

const
    screenWidth = 1920
    screenHeight = 1080

InitWindow screenWidth, screenHeight, "Puzzler"
SetTargetFPS 60
randomize()

InitAudioDevice()
SetMasterVolume 1

let
    musicArr = [LoadMusicStream "./assets/Into the Gray.mp3", LoadMusicStream "./assets/Prisoner of Rock N Roll.mp3", LoadMusicStream "./assets/Shuffle Street.mp3"]

var
    imgarr = [LoadTexture "./assets/johnBrownBibleAndGun.png", LoadTexture "./assets/The Fairytale Became Truth.png", LoadTexture "./assets/NewBrazil.png"]
    imgid = 2
    image = imgarr[imgid]
    imgidban = @[imgid]
    fsScreen : bool 


proc splitImage(t : Texture, x : int = 8, y : int = 5) : seq[Rectangle] = ## 8x5 is generally reasonable
    let drawpos = makevec2(0, 0)
    # DrawRectangleLines(int drawpos.x, int drawpos.y, t.width, t.height, WHITE)

    let sqy = int(t.height / x)
    let sqx = int(t.width / y)
    let marginy = t.height mod sqy.int
    let marginx = t.width mod sqx.int 
    var loc = drawpos
    while loc.x < drawpos.x + t.width:
        if loc.x + sqx + marginx < drawpos.x + t.width:
            for i in 0..<5:
                if i != 4:
                    result.add(makerect(loc.x.int, loc.y.int + sqy * i, sqx, sqy))
                else: 
                    result.add(makerect(loc.x.int, loc.y.int + sqy * i, sqx, sqy + marginy))  
            loc.x += sqx.float
        else:
            for i in 0..<5:
                if i != 4: 
                    result.add(makerect(loc.x.int, loc.y.int + sqy * i, sqx + marginx, sqy))
                else: 
                    result.add(makerect(loc.x.int, loc.y.int + sqy * i, sqx + marginx, sqy + marginy))
            loc.x += sqx.float + marginx

proc drawRecArray(t : Texture, s : seq[Rectangle], c : seq[Color]) =
    let drawpos = makevec2(screenWidth div 2 - t.width / 2, screenHeight div 2 - t.height / 2)
    for i, r in s.pairs:
        let pos = makevec2(i div 5 * t.width div 8, i mod 5 * t.height div 5)        
        # DrawCircleV(pos, 5, colorArr[i mod colorArr.len])
        DrawTexturePro(t, makerect(r.x, r.y, r.width, r.height), makerect(pos.x + screenWidth div 2 - t.width div 2, pos.y + screenHeight div 2 - t.height div 2, r.width, r.height), makevec2(0, 0), 0, WHITE)
        # let drawpos = makevec2(int(screenWidth / 2 - t.width / 2), int(screenHeight / 2 - t.height / 2))

    DrawRectangleLines(int drawpos.x, int drawpos.y, t.width, t.height, WHITE)

    let sqy = int(t.height / 5)
    let sqx = int(t.width / 8)
    let marginy = t.height mod sqy.int
    let marginx = t.width mod sqx.int 
    var loc = drawpos
    var iters : int
    while loc.x < drawpos.x + t.width:
        if loc.x + sqx + marginx < drawpos.x + t.width:
            for i in 0..<5:
                if i != 4: 
                    DrawRectangleLines(roundToInt loc.x, loc.y.int + sqy * i, sqx, sqy, c[iters * 5 + i])
                else: 
                    DrawRectangleLines(roundToInt loc.x, loc.y.int + sqy * i, sqx, sqy + marginy, c[iters * 5 + i])
            loc.x += sqx.float
            iters += 1
        else:
            for i in 0..<5:
                if i != 4: 
                    DrawRectangleLines(roundToInt loc.x, loc.y.int + sqy * i, sqx + marginx, sqy, c[iters * 5 + i])
                else: 
                    DrawRectangleLines(roundToInt loc.x, loc.y.int + sqy * i, sqx + marginx, sqy + marginy, c[iters * 5 + i])
            loc.x += sqx.float + marginx
            iters += 1
        
var 
    solved = splitImage image
    mixed = shuffleIt solved
    sqcols = newSeqWith(mixed.len, WHITE)
    held = -1
    shown = false
    showntimer : int
    isSolved : bool
    musicid = -1
    waiting = true
    waittime : int

while not WindowShouldClose():
    ClearBackground BGREY
            
    if not musicArr.mapIt(IsMusicPlaying it).foldl(a or b):
        musicArr.iterIt StopMusicStream it
        var inx = rand(musicArr.len - 1)
        while inx == musicid:
           inx = rand(musicArr.len - 1)
        PlayMusicStream musicArr[inx]
        musicid = inx

    musicArr.iterIt(UpdateMusicStream it)

    BeginDrawing()

    if mixed != solved and shown:
        drawRecArray(image, mixed, sqcols)
    else:
        drawTexCentered(image, makevec2(screenWidth / 2, screenHeight / 2), WHITE)
        let drawpos = makevec2(int(screenWidth / 2 - image.width / 2), int(screenHeight / 2 - image.height / 2))
        DrawRectangleLines(drawpos.x.int - 1, drawpos.y.int - 1, image.width + 2, image.height + 2, WHITE)
        if showntimer >= 350:
            shown = true
            showntimer = 0
        elif not waiting and not shown: showntimer += 1
        if mixed == solved: 
            isSolved = true
            if IsKeyPressed(KEY_SPACE):
                # while imgid in imgidban:
                #     imgid = rand(imgarr.len - 1)
                # imgidban.add imgid
                imgid += -1
                isSolved = false
                shown = false
                image = imgarr[imgid]
                solved = splitImage image
                mixed = shuffleIt solved



    if IsMouseButtonPressed(MOUSE_LEFT_BUTTON):
        let spos = GetMousePosition()
        let marginx = (screenWidth - image.width) div 2
        let marginy = (screenHeight - image.height) div 2
        let indv = makevec2(int(spos.x - marginx) div (image.width div 8), int(spos.y - marginy) div (image.height div 5))
        let ind = int(indv.x * 5 + indv.y)
        if ind < 0 or ind > 39: held = -1
        else:
            if held == -1:
                held = ind
                sqcols[ind] = makecolor(0, 0, 0, 0)
            else:
                swap(mixed[held], mixed[ind])
                sqcols[held] = WHITE
                held = -1

    # --- TEXT --- #

    if not shown:
        drawTextCenteredX "Preview of image", screenWidth div 2, 100, 70, WHITE
    else:
        if imgid == 0:
            drawTextCenteredX "John Brown, Antislavery crusader", screenWidth div 2, 100, 40, WHITE
            drawTextCenteredX "This painting is part of the Tragic Prelude in Topeka,", screenWidth div 2, 150, 40, WHITE
        if imgid == 1:
            drawTextCenteredX "CKA3LA CTANA BBINBIO", screenWidth div 2, 100, 40, WHITE
            drawTextCenteredX "The Fairtytale Became Truth (Yuri Gagarin)", screenWidth div 2, 150, 40, WHITE
        if imgid == 2:
            drawTextCenteredX "Ordem e Progresso", screenWidth div 2, 100, 40, WHITE
    if isSolved:
        drawTextCenteredX "Congratualations!", screenWidth div 2, screenHeight - 160, 50, WHITE
        drawTextCenteredX "Press Space to continue", screenWidth div 2, screenHeight - 100, 50, WHITE

    if waiting:
        if waittime >= 255:
            waiting = false
            waittime = 0
        else:
            DrawRectangle(0, 0, screenWidth, screenHeight, makecolor(BGREY.r, BGREY.g, BGREY.b, uint8 255 - waittime))
            waittime += 1

    EndDrawing()
CloseWindow()