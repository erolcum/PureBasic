;-TOP
; https://www.purebasic.fr/english/viewtopic.php?t=79759
; Comment : Comport Manager Over Thread and Callback
; Author  : mk-soft
; Version : v0.07.1
; Created : 26.01.2018
; Updated : 03.09.2022

; *****************************************************************************

CompilerIf #PB_Compiler_Thread = 0
  CompilerError "Use Option Threadsafe!"
CompilerEndIf

Prototype ProtoReceiveCB(Text.s)
Prototype ProtoStatusCB(Status, *ComData)

Enumeration
  #ComThread_Stopped
  #ComThread_Startup
  #ComThread_Running
EndEnumeration

Enumeration
  #ComStatus_Nothing
  #ComStatus_OpenPort
  #ComStatus_ClosePort
  #ComStatus_ErrorOpenPort
  #ComStatus_ErrorSend
  #ComStatus_ErrorReceive
  #ComStatus_ErrorDataSize
EndEnumeration

Structure udtComData
  ; Header
  ThreadID.i
  Exit.i
  Status.i
  ; Port Data
  ComID.i
  Port.s
  Baud.i
  Parity.i
  DataBit.i
  StopBit.i
  Handshake.i
  BufferSize.i
  ; End Of Text
  EndOfText.s
  ; Send Data
  SendSignal.i
  SendCount.i
  SendText.s
  SendError.i
  ; Receive data
  ReceiveCount.i
  ReceiveText.s
  ReceiveError.i
  ; Callback
  *StatusCB.ProtoStatusCB
  *ReceiveCB.ProtoReceiveCB
EndStructure

Procedure thComport(*ComData.udtComData)
  
  Protected *Send, *Receive, SendText.s, SendLen, ReceiveText.s, ReceiveLen, Pos
  
  With *ComData
    ; Startup
    \Status = #ComThread_Startup
    \SendCount = 0
    \ReceiveCount = 0
    \ComID = OpenSerialPort(#PB_Any, \Port, \Baud, \Parity, \DataBit, \StopBit, \Handshake, \BufferSize, \BufferSize)
    If \ComID
      \Status = #ComThread_Running
    Else
      If \StatusCB
        \StatusCB(#ComStatus_ErrorOpenPort, *ComData)
      EndIf
      \Status = #ComThread_Stopped
      ProcedureReturn 0
    EndIf
    If \StatusCB
      \StatusCB(#ComStatus_OpenPort, *ComData)
    EndIf
    *Send = AllocateMemory(\BufferSize)
    *Receive = AllocateMemory(\BufferSize)
    ; Loop
    Repeat
      If \SendSignal
        SendText = \SendText + \EndOfText
        SendLen = StringByteLength(SendText, #PB_Ascii)
        If SendLen <= \BufferSize
          PokeS(*Send, SendText, SendLen, #PB_Ascii)
          If WriteSerialPortData(\ComID, *Send, SendLen) = 0
            \SendError = SerialPortError(\ComID)
            If \StatusCB
              \StatusCB(#ComStatus_ErrorSend, *ComData)
            EndIf
          Else
            \SendError = 0
            \SendCount + 1
          EndIf
        Else
          If \StatusCB
            \StatusCB(#ComStatus_ErrorDataSize, *ComData)
          EndIf
        EndIf
        \SendSignal = #False
      EndIf
      ReceiveLen = AvailableSerialPortInput(\ComID)
      If ReceiveLen
        ReceiveLen = ReadSerialPortData(\ComID, *Receive, ReceiveLen)
        If ReceiveLen = 0
          \ReceiveError = SerialPortError(\ComID)
          If \StatusCB
            \StatusCB(#ComStatus_ErrorReceive, *ComData)
          EndIf
        Else
          \ReceiveError = 0
        EndIf
        ReceiveText + PeekS(*Receive, ReceiveLen, #PB_Ascii)
        Repeat
          pos = FindString(ReceiveText, \EndOfText, 1, #PB_String_NoCase)
          If pos
            \ReceiveText = Left(ReceiveText, pos - 1)
            ReceiveText = Mid(ReceiveText, pos + Len(\EndOfText))
            \ReceiveCount + 1
            If \ReceiveCB
              \ReceiveCB(\ReceiveText)
            EndIf
          EndIf
        Until pos = 0
      EndIf
      Delay(10)
    Until \Exit
    ; Shutdown
    CloseSerialPort(\ComID)
    If \StatusCB
      \StatusCB(#ComStatus_ClosePort, *ComData)
    EndIf
    FreeMemory(*Send)
    FreeMemory(*Receive)
    \Status = #ComThread_Stopped
    \ComID = 0
    \Exit = 0
    ProcedureReturn 1
  EndWith
  
EndProcedure

; ----

Procedure.s SerialPortErrorText(ErrorCode)
  Protected r1.s
  
  Select ErrorCode
    Case #PB_SerialPort_RxOver      : r1 = "An input buffer overflow has occurred."
    Case #PB_SerialPort_OverRun     : r1 = "A character-buffer overrun has occurred."
    Case #PB_SerialPort_RxParity    : r1 = "The hardware detected a parity error."
    Case #PB_SerialPort_Frame       : r1 = "The hardware detected a framing error."
    Case #PB_SerialPort_Break       : r1 = "The hardware detected a break condition."
    Case #PB_SerialPort_TxFull      : r1 = "The application tried to transmit a character but the output buffer was full."
    Case #PB_SerialPort_IOE         : r1 = "An I/O error occurred during communications with the device."
    Case #PB_SerialPort_WaitingCTS  : r1 = "Specifies whether transmission is waiting for the CTS (clear-To-send) signal to be sent."
    Case #PB_SerialPort_WaitingDSR  : r1 = "Specifies whether transmission is waiting for the DSR (Data-set-ready) signal to be sent."
    Case #PB_SerialPort_WaitingRLSD : r1 = "Specifies whether transmission is waiting for the RLSD (receive-line-signal-detect) signal to be sent."
    Case #PB_SerialPort_XoffReceived: r1 = "Specifies whether transmission is waiting because the XOFF character was received."
    Case #PB_SerialPort_XoffSent    : r1 = "Specifies whether transmission is waiting because the XOFF character was transmitted."
    Case #PB_SerialPort_EOFSent     : r1 = "Specifies whether the end-of-file (EOF) character has been received."
    Default                         : r1 = "ErrorCode " + Hex(ErrorCode)
  EndSelect
  ProcedureReturn r1
EndProcedure

; ----

; Threaded String Helper

Procedure AllocateString(String.s)
  Protected *mem
  *mem = AllocateMemory(StringByteLength(String) + SizeOf(Character))
  If *mem
    PokeS(*mem, String)
  EndIf
  ProcedureReturn *mem
EndProcedure

Procedure.s FreeString(*Mem)
  Protected result.s
  If *Mem
    result = PeekS(*Mem)
    FreeMemory(*Mem)
  EndIf
  ProcedureReturn result
EndProcedure

; *****************************************************************************

;- Example

CompilerIf #PB_Compiler_IsMainFile
  
  Global ComData.udtComData
  
  Enumeration EventCustomValue #PB_Event_FirstCustomValue
    #My_Event_NewData
    #My_Event_NewState
  EndEnumeration
  
  ; ---------------------------------------------------------------------------
  
  Procedure ReceiveCB(Text.s)
    PostEvent(#My_Event_NewData, 0, 0, 0, AllocateString(Text))
  EndProcedure
  
  Procedure MyEventNewDataCB()
    Protected Text.s
    Text = FreeString(EventData())
    AddGadgetItem(0, -1, Text)
    SetGadgetState(0, CountGadgetItems(0) - 1)
    SetGadgetState(0, -1)
  EndProcedure
  
  BindEvent(#My_Event_NewData, @MyEventNewDataCB())
  
  ; ---------------------------------------------------------------------------
  
  Procedure StatusCB(Status, *ComData.udtComData)
    PostEvent(#My_Event_NewState, 0, 0, Status, *ComData)
  EndProcedure
  
  Procedure MyEventNewStateCB()
    Protected Text.s, Status, *ComData.udtComData
    Status = EventType()
    *ComData = EventData()
    Select Status
      Case #ComStatus_OpenPort
        Text = "ComStatus: Open Port " + *ComData\Port
      Case #ComStatus_ClosePort
        Text = "ComStatus: Close Port " + *ComData\Port
      Case #ComStatus_ErrorOpenPort
        Text = "ComError: Open Port " + *ComData\Port
      Case #ComStatus_ErrorSend
        Text = "ComError Send: Port " + *ComData\Port + " - " + SerialPortErrorText(*ComData\SendError)
      Case #ComStatus_ErrorReceive
        Text = "ComError Receive: Port " + *ComData\Port + " - " + SerialPortErrorText(*ComData\ReceiveError)
      Case #ComStatus_ErrorDataSize
        Text = "ComError Send: Port " + *ComData\Port + " - Send data size to big."
    EndSelect
    If Bool(Text)
      StatusBarText(0, 0, Text)
    EndIf
  EndProcedure
  
  BindEvent(#My_Event_NewState, @MyEventNewStateCB())
  
  ; ---------------------------------------------------------------------------
  
  Procedure InitComport()
    With ComData
      If \Status
        ProcedureReturn 2 ; Always running
      EndIf
      \Port = "COM3"
      \Baud = 19200
      \Parity = #PB_SerialPort_NoParity
      \DataBit = 8
      \StopBit = 1
      \Handshake = #PB_SerialPort_NoHandshake
      \BufferSize = 2048
      \EndOfText = #CRLF$
      \StatusCB = @StatusCB()
      \ReceiveCB = @ReceiveCB()
      \ThreadID = CreateThread(@thComport(), ComData)
      If Not \ThreadID
        ProcedureReturn 0 ; Error create thread
      Else
        ProcedureReturn 1 ; ok
      EndIf
    EndWith
  EndProcedure
  
  Procedure Main()
    
    Protected Event, Text.s, i
    If OpenWindow(0, #PB_Ignore, #PB_Ignore, 800, 600, "Comport", #PB_Window_SystemMenu)
      CreateStatusBar(0, WindowID(0))
      AddStatusBarField(#PB_Ignore)
      ListViewGadget(0, 0, 0, 800, 540)
      StringGadget(1, 5, 545, 590, 25, "")
      ButtonGadget(2, 605, 545, 90, 25, "Send")
      ButtonGadget(3, 695, 545, 90, 25, "On/Off")
      AddKeyboardShortcut(0, #PB_Shortcut_Return, 1000)
      
      CreatePopupMenu(1)
      MenuItem(101, "Copy ListView")
      
      Repeat
        Event = WaitWindowEvent()
        Select Event
          Case #PB_Event_CloseWindow
            If ComData\Status
              MessageRequester("Info", "Comport Is Open!", #PB_MessageRequester_Warning)
            Else
              Break
            EndIf
            
          Case #PB_Event_Gadget
            Select EventGadget()
              Case 0
                If EventType() = #PB_EventType_RightClick
                  DisplayPopupMenu(1, WindowID(0))
                EndIf
                
              Case 2 ; send button
                If ComData\Status = #ComThread_Running And ComData\SendSignal = #False
                  ComData\SendText = GetGadgetText(1)
                  ComData\SendSignal = #True
                EndIf
              Case 3 ; on/off button
                If ComData\Status
                  ComData\Exit = 1
                Else
                  If Not InitComport()
                    StatusBarText(0, 0, "Comport " + ComData\Port + ": Error Create Thread")
                  EndIf
                EndIf
            EndSelect
            
          Case #PB_Event_Menu
            Select EventMenu()
              Case 101 ; popup menu
                Text = ""
                For i = 0 To CountGadgetItems(0) - 1
                  text + GetGadgetItemText(0, i) + #CRLF$
                Next
                SetClipboardText(Text)
                
            EndSelect
        EndSelect
      ForEver
    EndIf
  EndProcedure : Main()
  
CompilerEndIf

