import raylib, rayutils, lenientops, random, sequtils, os, algorithm, strutils

const
    screenWidth = 1920
    screenHeight = 1080
    screenCenter = makevec2(1920, 1080) / 2


InitWindow screenWidth, screenHeight, "Some Puzzling Pictures"
SetTargetFPS 60
randomize()

InitAudioDevice()
SetMasterVolume 0.5

let
    folders = toSeq(walkDir("assets/sets")).mapIt(it.path).filterIt(dirExists(it) and fileExists(it & "\\imdat.txt"))
    musicArr = toSeq(walkDir("assets/music")).mapIt(it.path).filterIt(it.endsWith ".mp3").mapIt(LoadMusicStream $$it)
    isMusic = musicArr.len > 0
    volIcon = LoadTexture $$"assets/volume.png"

proc LoadImgs(folder : string) : seq[Texture] = toSeq(folder.walkDir()).mapIt(it.path).filterIt(it[^4..^1] == ".png").sorted(Ascending).mapIt(LoadTexture $$it)

var
    imgarr : seq[Texture]
    imgid : int
    image : Texture
    imgidban = @[imgid]
    fsScreen = true
    sliderRect = makerect(screenWidth - 400, screenHeight - 70, 340, 20)
    volLvl = 0.5
    adjVol : bool

proc splitImage(t : Texture, x : int = 8, y : int = 5) : seq[Rectangle] = ## 8x5 is generally reasonable
    let drawpos = makevec2(0, 0)
    # DrawRectangleLines(int drawpos.x, int drawpos.y, t.width, t.height, WHITE)

    let sqy = int(t.height / y)
    let sqx = int(t.width / x)
    var marginy : int
    var marginx : int
    if sqy != 0: marginy = t.height mod sqy
    else: marginy = 1
    if sqy != 0: marginx = t.width mod sqx
    else: marginx = 1
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
    solved : seq[Rectangle]
    pg : int
    mixed : seq[Rectangle]
    sqcols = newSeqWith(mixed.len, WHITE)
    held = -1
    shown = false
    showntimer : int
    isSolved : bool
    musicid = -1
    waiting = true
    waittime : int
    imgtxt : seq[string]

while not WindowShouldClose():
    ClearBackground BGREY

    if isMusic:
        if not musicArr.mapIt(IsMusicStreamPlaying it).foldl(a or b):
            var inx = musicid
            while inx == musicid:
                inx = rand(musicArr.len - 1)
            PlayMusicStream musicArr[inx]
            musicid = inx
        else: UpdateMusicStream musicArr[musicid]

    # --- FILE SELECT --- #
    let
        mpos = GetMousePosition()
        clicked = IsMouseButtonPressed(MOUSE_LEFT_BUTTON)

    if fsScreen:
        BeginDrawing()

        drawTextCenteredX("Select Image Set", screenCenter.x.int, 60, 50, WHITEE)

        for i in pg*16..<min(folders.len, (screenHeight - 180) div 60): ## second term min() has max of 16
            let moused = mpos.in(makevec2(60, 120 + i*60), makevec2(screenWidth - 120, 120 + i*60), makevec2(screenWidth - 120, 120 + (i+1)*60), makevec2(60, 120 + (i+1)*60))
            if moused:
                DrawRectangle(60, 120 + i*60, screenWidth - 120, 60, makecolor(WHITED.colHex(), 50))
                if clicked: 
                    imgarr = LoadImgs folders[i]
                    let therealpath = (toSeq(walkDir(folders[i])).mapIt(it.path).filterIt(it.endsWith "imdat.txt")[0])
                    imgtxt = therealpath.readLines(toSeq(therealpath.lines).len)
                    fsScreen = false
            else: 
                DrawRectangle(60, 120 + i*60, screenWidth - 120, 60, AGREY)
            drawTextCentered(folders[i].split("\\")[^1], screenCenter.x.int, 120 + i*60 + 30, 40, WHITEE)

        
        if mpos in makerect(1555, 890, 335, 145):
            DrawRectangle 1555, 890, 335, 145, makecolor(WHITED.colhex(), 50)
            if clicked: 
                if pg + 1 <= folders.len div 16: pg += 1
        else:
            DrawRectangle(1555, 890, 335, 145, AGREY)
            DrawRectangleLines(1555, 890, 335, 145, WHITEE)
        drawTextCentered("Next ->", 1555 + 335 div 2, 890 + 145 div 2, 40, WHITEE)

        if mpos in makerect(35, 850, 335, 185):
            DrawRectangle 35, 890, 335, 145, makecolor(WHITED.colhex(), 50)
            if clicked: 
                if pg - 1 >= 0: pg += -1
        else:
            DrawRectangle(35, 890, 335, 145, AGREY)
            DrawRectangleLines(35, 890, 335, 145, WHITEE)
        drawTextCentered("<- Prev", 35 + 335 div 2, 890 + 145 div 2, 40, WHITEE)


        EndDrawing()
        if not fsScreen:
            imgid = 0
            isSolved = false
            shown = false
            showntimer = 0
            image = imgarr[imgid]
            imgidban.add imgid
            solved = splitImage image
            mixed = shuffleIt solved
            sqcols = newSeqWith(mixed.len, WHITE)

    if not fsScreen:
        BeginDrawing()

        if mixed != solved and shown:
            drawRecArray(image, mixed, sqcols)
        else:
            drawTexCentered(image, makevec2(screenWidth / 2, screenHeight / 2), WHITE)
            let drawpos = makevec2(int(screenWidth / 2 - image.width / 2), int(screenHeight / 2 - image.height / 2))
            DrawRectangleLines(drawpos.x.int - 1, drawpos.y.int - 1, image.width + 2, image.height + 2, WHITE)
            if showntimer >= 350: ## this should be 350, lowered for debugging
                shown = true
                showntimer = 0
            elif not waiting and not shown: showntimer += 1
            if mixed == solved: 
                isSolved = true
                if IsKeyPressed(KEY_SPACE):
                    imgidban.add imgid
                    imgid += 1
                    isSolved = false
                    shown = false
                    image = imgarr[imgid]
                    solved = splitImage image
                    mixed = shuffleIt solved
                    sqcols = newSeqWith(mixed.len, WHITE)

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

        # --- VOLUME SLIDER --- #

        DrawRectangleGradientEx(sliderRect, AGREY, AGREY, AGREY, AGREY)
        # DrawRectangleLinesEx(sliderRect, 1, WHITEE)
        DrawCircle(int(volLvl * sliderRect.width + sliderRect.x), int sliderRect.y + sliderRect.height.int div 2, 14, WHITEE)
        
        
        if not fsScreen and IsMouseButtonDown(MOUSE_LEFT_BUTTON) and mpos in sliderRect:
            adjVol = true
        if adjVol:
            volLvl = clamp((mpos.x - sliderRect.x) / sliderRect.width, 0, 1)
            SetMasterVolume volLvl
            if not IsMouseButtonDown(MOUSE_LEFT_BUTTON):
                adjVol = false

        # --- TEXT --- #

        if shown:
            var inx = 0
            for s in imgtxt[imgid].split("&!&"):
                drawTextCenteredX s, screenWidth div 2, 50 + 60*inx, 60, WHITE
                inx += 1
            inx += 0
        else:
            drawTextCenteredX "Preview of image", screenWidth div 2, 100, 70, WHITE
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
        
        drawTexCenteredEx(volIcon, makevec2(sliderRect.x - 50, sliderRect.y + sliderRect.height/2), 0, 0.25, makecolor "333333")
        EndDrawing()
CloseWindow()