import raylib, raymath, rlgl, rayutils, math, lenientops, random

const
    screenWidth = 1920
    screenHeight = 1080

InitWindow screenWidth, screenHeight, "Puzzler"
SetTargetFPS 60
randomize()

var
    image = LoadTexture "./assets/johnBrownBibleAndGun.png"

proc splitImage(t : Texture) : seq[Rectangle] =
    drawTexCentered(t, makevec2(screenWidth / 2, screenHeight / 2), WHITE)
    # let drawpos = makevec2(int(screenWidth / 2 - t.width / 2), int(screenHeight / 2 - t.height / 2))
    let drawpos = makevec2(0, 0)
    # DrawRectangleLines(int drawpos.x, int drawpos.y, t.width, t.height, WHITE)

    let sqy = int(t.height / 5)
    let sqx = int(t.width / 8)
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

proc drawRecArray(t : Texture, s : seq[Rectangle]) =
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
    while loc.x < drawpos.x + t.width:
        if loc.x + sqx + marginx < drawpos.x + t.width:
            for i in 0..<5:
                if i != 4: 
                    DrawRectangleLines(roundToInt loc.x, loc.y.int + sqy * i, sqx, sqy, WHITE)
                else: 
                    DrawRectangleLines(roundToInt loc.x, loc.y.int + sqy * i, sqx, sqy + marginy, WHITE)
            loc.x += sqx.float
        else:
            for i in 0..<5:
                if i != 4: 
                    DrawRectangleLines(roundToInt loc.x, loc.y.int + sqy * i, sqx + marginx, sqy, WHITE)
                else: 
                    DrawRectangleLines(roundToInt loc.x, loc.y.int + sqy * i, sqx + marginx, sqy + marginy, WHITE)
            loc.x += sqx.float + marginx

proc mixRecs(s : seq[Rectangle]) : seq[Rectangle] =
    var s = s; s.shuffle(); return s
        
var solved = splitImage image
var mixed = shuffleIt solved

for i in 0..<solved.len:
    if solved[i] != mixed[i]:
        echo solved[i], " / ", mixed[i]

while not WindowShouldClose():
    ClearBackground BGREY

    BeginDrawing()

    drawRecArray(image, mixed)
    # for r in drawImage image:
    #     DrawCircleV(makevec2(r.x, r.y), 5, RED)

    EndDrawing()
CloseWindow()