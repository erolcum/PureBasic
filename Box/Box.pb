OpenWindow(0, 0, 0, 222, 200, "ButtonGadgets", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)

If CreateImage(0, 222, 100, 24,  RGB(239, 239, 239)) And StartDrawing(ImageOutput(0))
  Box(0, 0, 222, 100, RGB(20, 244, 254))
  StopDrawing() 
  ImageGadget(0, 0, 0, 200, 200, ImageID(0))
EndIf

;https://www.purebasic.fr/english/viewtopic.php?t=83958
;You should use a Canvasgadget() with container flag
;gadget overlapping isn't supported in PB
;ImageGadget'ı disable ediyoruz ki buton tıklanabilsin
;MacOS da disable'a gerek kalmıyormuş

;*****************
CompilerIf #PB_Compiler_OS = #PB_OS_Windows ;Derleme işi Windows'da yapılıyorsa demek
  DisableGadget(0, 1)  ;ImageGadget
CompilerEndIf
;*****************

ButtonGadget(1, 10, 40, 200, 20, "Standard Button")
Repeat 
  Event = WaitWindowEvent()
  Gadget = EventGadget();
  Type_Event= EventType()
  
  Select Event
    Case #PB_Event_Gadget  
      Select Gadget
        Case 1
          Debug "button pressed"
      EndSelect
  EndSelect 
Until Event = #PB_Event_CloseWindow 
