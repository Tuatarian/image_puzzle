import raylib, raymath, rlgl, rayutils, math, lenientops

const
    screenWidth = 1920
    screenHeight = 1080

InitWindow screenWidth, screenHeight, "Puzzler"
SetTargetFPS 60

var
    image = LoadTexture "./assets/johnBrownBibleAndGun.png"

proc drawImage(t : Texture) : seq[Texture] =
    drawTexCentered(t, makevec2(screenWidth / 2, screenHeight / 2), WHITE)
    let drawpos = makevec2(int(screenWidth / 2 - t.width / 2), int(screenHeight / 2 - t.height / 2))
    DrawRectangleLines(int drawpos.x - 1, int drawpos.y - 1, t.width, t.height, WHITE)

    let sqsize = t.height / 5
    var loc = drawpos
    while loc.x <= drawpos.x + t.width:
        for i in 0..<5:
            DrawRectangleLines(roundToInt loc.x, roundToInt(loc.y.int + sqsize * i), roundToInt sqsize, roundToInt sqsize, WHITE)
        loc.x += sqsize.float



    

while not WindowShouldClose():
    ClearBackground BGREY


    BeginDrawing()

    discard drawImage(image)

    EndDrawing()
CloseWindow()