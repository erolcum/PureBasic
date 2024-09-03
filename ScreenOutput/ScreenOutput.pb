EnableExplicit

Define.i Event, Exit, snake_x, snake_y, x
Define.f move


InitSprite()
InitKeyboard()

OpenWindow(0, 0, 0, 800 / DesktopResolutionX(), 600 / DesktopResolutionY(), "Snake",  #PB_Window_SystemMenu|#PB_Window_ScreenCentered)
OpenWindowedScreen(WindowID(0), 0, 0, 800, 600)
SetFrameRate(30)

Repeat
  
  Repeat ; While WindowEvent() : Wend
    Event = WindowEvent()
    If Event = #PB_Event_CloseWindow
      Exit = #True
    EndIf
  Until Event = 0
  
  ClearScreen(#Black)
  
  If StartDrawing(ScreenOutput())
    For x = 0 To 360
      move + 1/10000
      
      snake_x = 10 * Cos(30 * Cos(move - ((x / 5))) / 10)
      snake_y = 10 * (move * 2 - x) - x
      
      Box(snake_x + 400, snake_y + x, 5 * Cos(x / 4) / 2, Cos(x / 4) * 5, #Red)
    Next
    
    StopDrawing()
  EndIf
  
  FlipBuffers()
  
  ExamineKeyboard()
  If KeyboardReleased(#PB_Key_Escape)
    Exit = #True
  EndIf
  
Until Exit
