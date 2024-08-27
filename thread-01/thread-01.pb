EnableExplicit

CompilerIf Not #PB_Compiler_Thread
  CompilerError "Use Compiler-Option ThreadSafe!"
CompilerEndIf

Enumeration #PB_Event_FirstCustomValue
  #ThreadEvent
EndEnumeration

Structure ThreadStructure
  Thread.i
  Semaphore.i
  Programm.i
  Exit.i
EndStructure


Procedure WaitForProgrammEnd(*Thread.ThreadStructure)
  
  Protected i.i
  
  While ProgramRunning(*Thread\Programm) And Not *Thread\Exit
    i + 1
    PostEvent(#ThreadEvent, 0, 0, 0, i)
    Debug "Inside thread: " + GetCurrentThreadId_()
    
    
    WaitSemaphore(*Thread\Semaphore)
    Delay(1000)
  Wend
  If *Thread\Exit
    KillProgram(*Thread\Programm)
  EndIf
  CloseProgram(*Thread\Programm)
  
EndProcedure


Define Event.i, Thread.ThreadStructure

OpenWindow(0, 0, 0, 100, 50, "", #PB_Window_SystemMenu|#PB_Window_ScreenCentered)

TextGadget(0, 10, 10, 200, 20, "")

Thread\Semaphore = CreateSemaphore()

Thread\Programm = RunProgram("notepad", "", "", #PB_Program_Open)

If Thread\Programm
  Thread\Thread = CreateThread(@WaitForProgrammEnd(), @Thread)
EndIf

Repeat
  Event = WaitWindowEvent()
  Debug "PID           : " + GetCurrentProcessId_()
  Debug "Ana thread: " + GetCurrentThreadId_()
  
  Select Event
    Case #ThreadEvent
      SetGadgetText(0, Str(EventData()) + " saniye")
      SignalSemaphore(Thread\Semaphore)
  EndSelect
Until Event = #PB_Event_CloseWindow

If IsThread(Thread\Thread)
  Thread\Exit = #True
  SignalSemaphore(Thread\Semaphore)
  If WaitThread(Thread\Thread, 3000) = 0
    KillThread(Thread\Thread)
  EndIf
EndIf

FreeSemaphore(Thread\Semaphore)

