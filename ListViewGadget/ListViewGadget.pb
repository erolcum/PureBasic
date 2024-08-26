Enumeration
  #WIN_MAIN
  #TEXT
  #STRING_INPUT
  #LIST_INPUT
  #BUTTON
  #BUTTON_CLOSE
EndEnumeration
Global Quit = #False
#FLAGS = #PB_Window_SystemMenu | #PB_Window_ScreenCentered
OpenWindow(#WIN_MAIN, 0, 0, 300, 200, "ListViewGadget", #FLAGS) 
TextGadget(#TEXT, 10, 10, 280, 20, "Enter text here:")
StringGadget(#STRING_INPUT, 10, 30, 280, 20, "")
ListViewGadget(#LIST_INPUT, 10, 60, 280, 100)
ButtonGadget(#BUTTON, 10, 170, 120, 20, "Enter text")
ButtonGadget(#BUTTON_CLOSE, 190, 170, 100, 20, "Close window")
SetActiveGadget(#STRING_INPUT)
Repeat
  Event = WaitWindowEvent()
  Select Event
    Case #PB_Event_Gadget
      Select EventGadget()
        Case #BUTTON
          AddGadgetItem(#LIST_INPUT, -1, GetGadgetText(#STRING_INPUT))
          ;alttaki satır, liste dolunca son girilen listede gözüksün diye
          ;farkı anlamak için alttaki satırın önüne ; koyun
          SetGadgetState(#LIST_INPUT, CountGadgetItems(#LIST_INPUT) - 1)
          SetGadgetState(#LIST_INPUT, -1)
          SetGadgetText(#STRING_INPUT, "")
          SetActiveGadget(#STRING_INPUT)
        Case #BUTTON_CLOSE
          Quit = #True
      EndSelect
  EndSelect
Until Event = #PB_Event_CloseWindow Or Quit = #True
End
