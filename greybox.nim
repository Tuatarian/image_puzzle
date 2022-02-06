import raylib, raymath, rlgl, rayutils, math, lenientops, random, sequtils, os

const
    screenWidth = 1920
    screenHeight = 1080
    screenCenter = makevec2(1920, 1080) / 2

var
    folders = toSeq(walkDir("./assets", relative=true)).filterIt(it.kind == pcDir)

InitWindow screenWidth, screenHeight, "Puzzler"
SetTargetFPS 60
randomize()

InitAudioDevice()
SetMasterVolume 1


while not WindowShouldClose():
    ClearBackground BGREY
    BeginDrawing()

    drawTextCenteredX("Select Image Set", screenCenter.x.int, 60, 50, WHITEE)
    let
        mpos = GetMousePosition()
        clicked = IsMouseButtonPressed(MOUSE_LEFT_BUTTON)

    for i in 0..<min(folders.len, (screenHeight - 180) div 60):
        let moused = mpos.in(makevec2(60, 120 + i*60), makevec2(screenWidth - 120, 120 + i*60), makevec2(screenWidth - 120, 120 + (i+1)*60), makevec2(60, 120 + (i+1)*60))
        if moused: DrawRectangle(60, 120 + i*60, screenWidth - 120, 60, makecolor(WHITED.colHex(), 50))
        if i mod 2 == 0:
            if not moused: DrawRectangle(60, 120 + i*60, screenWidth - 120, 60, AGREY)
            drawTextCentered(folders[i].path, screenCenter.x.int, 120 + i*60 + 30, 40, WHITEE)
        if clicked: 

    EndDrawing()