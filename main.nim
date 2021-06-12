import raylib, raymath, rlgl, rayutils, math, lenientops, random

const
    screenWidth = 1920
    screenHeight = 1080

InitWindow screenWidth, screenHeight, "Puzzler"
SetTargetFPS 60
randomize()

var
    image = LoadTexture "./assets/johnBrownBibleAndGun.png"

proc drawImage(t : Texture) : seq[Rectangle] =
    drawTexCentered(t, makevec2(screenWidth / 2, screenHeight / 2), WHITE)
    # let drawpos = makevec2(int(screenWidth / 2 - t.width / 2), int(screenHeight / 2 - t.height / 2))
    let drawpos = makevec2(0, 0)
    # DrawRectangleLines(int drawpos.x, int drawpos.y, t.width, t.height, WHITE)

    let sqy = int(t.height / 5)
    let sqx = int(t.width / 8)
    echo sqx, " ", t.width
    let marginy = t.height mod sqy.int
    let marginx = t.width mod sqx.int 
    var loc = drawpos
    while loc.x < drawpos.x + t.width:
        if loc.x + sqx + marginx < drawpos.x + t.width:
            for i in 0..<5:
                if i != 4: 
                    DrawRectangleLines(roundToInt loc.x, loc.y.int + sqy * i, sqx, sqy, WHITE)
                    result.add(makerect(loc.x.int, loc.y.int + sqy * i, sqx, sqy))
                else: 
                    DrawRectangleLines(roundToInt loc.x, loc.y.int + sqy * i, sqx, sqy + marginy, WHITE)
                    result.add(makerect(loc.x.int, loc.y.int + sqy * i, sqx, sqy + marginy))  
            loc.x += sqx.float
        else:
            for i in 0..<5:
                if i != 4: 
                    DrawRectangleLines(roundToInt loc.x, loc.y.int + sqy * i, sqx + marginx, sqy, WHITE)
                    result.add(makerect(loc.x.int, loc.y.int + sqy * i, sqx + marginx, sqy))
                else: 
                    DrawRectangleLines(roundToInt loc.x, loc.y.int + sqy * i, sqx + marginx, sqy + marginy, WHITE)
                    result.add(makerect(loc.x.int, loc.y.int + sqy * i, sqx + marginx, sqy + marginy))
            loc.x += sqx.float + marginx

proc drawRecArray(t : Texture, s : seq[Rectangle]) =
    for r in s:
        DrawTexturePro(t, makerect(r.x, r.y, r.width, r.height), makerect(r.x.int + screenWidth div 2 - t.width div 2, r.y.int + screenHeight div 2 - t.height div 2, r.width, r.height), makevec2(0, 0), 0, WHITE)

proc mixRecs(s : seq[Rectangle]) : seq[Rectangle] =
    var s = s; s.shuffle(); return s
        

    

while not WindowShouldClose():
    ClearBackground BGREY

    BeginDrawing()

    drawRecArray(image, drawImage image)
    # for r in drawImage image:
    #     DrawCircleV(makevec2(r.x, r.y), 5, RED)

    EndDrawing()
CloseWindow()