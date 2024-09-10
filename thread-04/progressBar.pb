; https://www.purebasic.fr/english/viewtopic.php?t=85136  from TI-994A
; this example simulates a lengthy blocking process executed in a thread to
; demonstrate the implementations of PostEvent and the ProgressBar gadget 

; assign the custom event value
#progressBarEvent = #PB_Event_FirstCustomValue

; read a large 13mb file to simulate a blocking process
CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
  file$ = #PB_Compiler_Home + "compilers/engine3d.dylib"
CompilerElseIf #PB_Compiler_OS = #PB_OS_Linux   
  file$ = #PB_Compiler_Home + "compilers/engine3d.so"
CompilerElse
  file$ = #PB_Compiler_Home + "compilers/engine3d.dll"
CompilerEndIf

Procedure threadedProcess(null)     
  Shared file$
  If ReadFile(0, file$)        
    fileLen = Lof(0)    
    While Not Eof(0)
      
      ; read one byte at a time 
      ReadByte(0)      
      
      ; get current read location
      readBytes = Loc(0)      
      
      ; update the progress bar in 1k increments
      If Mod(readBytes, 1000) = 0   
        
        ; post the custom event with the current read location
        PostEvent(#progressBarEvent, -1, -1, -1, readBytes)   
        
        Delay(1)        
      EndIf
    Wend    
    
    ; one last post to send the total read size
    PostEvent(#progressBarEvent, -1, -1, -1, readBytes)
    
    CloseFile(0)    
  EndIf  
EndProcedure

; ensure threadsafe enabled
CompilerIf #PB_Compiler_Thread
  
  wFlags = #PB_Window_SystemMenu | #PB_Window_ScreenCentered
  OpenWindow(0, 0, 0, 800, 300,"ProgressBar/PostEvent Example", wFlags)
  TextGadget(0, 10, 10, 780, 50, "00:00:00", #PB_Text_Right)
  TextGadget(1, 10, 200, 780,  40, "", #PB_Text_Center)
  ButtonGadget(2, 300, 60, 200, 30, "Start threaded process...")
  AddWindowTimer(0, 0, 1000)   
  
  ; instantiate a progress bar scaled to the file size
  If FileSize(file$) > 0 And ReadFile(0, file$)      
    
    ; ProgressBar() maximum allowable x-platform value = 65536
    ; calculate the maximum value according to this scale
    fileLen = Lof(0)
    If fileLen > 65536
      max = 65536
    Else
      max = fileLen
    EndIf    
    ProgressBarGadget(3, 10, 120, 780, 50, 0, max)  
    
    HideGadget(3, #True)
    CloseFile(0)
  Else 
    MessageRequester("ProgressBar/PostEvent Example", "File error!")
    appQuit = 1
  EndIf    
  
  Repeat
    event = WaitWindowEvent()
    Select event
        
      Case #PB_Event_CloseWindow
        appQuit = 1
        
      Case #PB_Event_Gadget
        If EventGadget() = 2
          HideGadget(3, #False)
          DisableGadget(2, #True)
          
          ; start reading the file in a thread
          CreateThread(@threadedProcess(), 0)
          
        EndIf
        
      Case #PB_Event_Timer
        If EventTimer() = 0
          
          ; a running clock shows that window events are not blocked
          SetGadgetText(0, FormatDate("%hh:%ii:%ss", Date()))     
          
        EndIf
        
        ; process the custom event   
      Case #progressBarEvent        
        
        ; get the current read location
        currentRead = EventData()       
        
        ; calculate the current location of the progress bar
        If fileLen > 65536
          inc = currentRead / (fileLen / 65536)
        Else
          inc = currentRead
        EndIf
        
        ; increment the progress bar & label with the read location value
        SetGadgetState (3, inc)               
        SetGadgetText(1, "File Progress (" + Str(currentRead) + "/" + Str(fileLen) + ")")
        
        If currentRead = fileLen
          DisableGadget(2, #False)
        EndIf
        
    EndSelect
  Until appQuit
  
CompilerElse 
  
  MessageRequester("ProgressBar/PostEvent Example", "Please enable Compiler > Compiler Options > Create threadsafe executable.")
  
CompilerEndIf
