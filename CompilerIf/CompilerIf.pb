#FullVersion = 0

CompilerIf #FullVersion
  #Warning=""
  Macro FullVersion()
    (#True)
  EndMacro
  
CompilerElse
  #Warning=" (not available)"
  Procedure VersionWarning()
    MessageRequester("Warning","This function is not available in the trial version")
    ProcedureReturn #False
  EndProcedure
  Macro FullVersion()
    VersionWarning()
  EndMacro
  
CompilerEndIf


Procedure Function1()
  If FullVersion()
    SetGadgetText(0,"Execute Function 1")
  EndIf
EndProcedure
Procedure Function2()
  SetGadgetText(0,"Execute Function 2")
EndProcedure
Procedure Function3()
  SetGadgetText(0,"Execute Function 3")
EndProcedure
Procedure Function4()
  If FullVersion()
    SetGadgetText(0,"Execute Function 4")
  EndIf
EndProcedure


Procedure Main()
  
  OpenWindow(0, 0, 0, 222, 210, "ButtonGadgets", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  
  TextGadget(0, 10, 10, 200, 25, "Status", #PB_Text_Center|#PB_Text_Border|#SS_CENTERIMAGE)
  ButtonGadget(1, 10, 50, 200, 25, "Function 1" + #Warning)
  ButtonGadget(2, 10, 80, 200, 25, "Function 2")
  ButtonGadget(3, 10,110, 200, 25, "Function 3")
  ButtonGadget(4, 10,140, 200, 25, "Function 4" + #Warning)
  ButtonGadget(5, 10,180, 200, 25, "Quit")
  
  Repeat
    Select WaitWindowEvent()
        
      Case #PB_Event_Gadget
        Select EventGadget()
          Case 1
            Function1()
          Case 2
            Function2()
          Case 3
            Function3()
          Case 4
            Function4()
          Case 5
            End
        EndSelect
        
      Case #PB_Event_CloseWindow
        End
    EndSelect
  ForEver
  
EndProcedure

Main()

