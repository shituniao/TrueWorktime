Config :=Gui()
Config.Title :="TrueWorkTime"
Config.MarginX :=10
Config.MarginY :=10
Config.SetFont("s9","Microsoft YaHei UI")
ConfigTab:=Config.AddTab3("y+5",["基础设置","快捷键","工作软件","计时记录"])
ConfigTab.Move(,,364,196)
ConfigTab.OnEvent("Change",Config_SwitchTab)
;基础设置
ConfigTab.UseTab(1)
ConfigAutoRun:=Config.AddCheckBox("x25 y45 section vAutoRun Checked" IniRead("Config.ini","setting","auto_run"), "开机自动启动")
ConfigAutoRun.OnEvent("Click",Config_AutoRun)
ConfigItemShow:=Config.AddCheckBox("xs y+5 section Checked" IniRead("Config.ini","setting","item_show"), "显示累计计时（左）")
ConfigItemShow.OnEvent("Click",Config_ItemShow)
ConfigClockShow:=Config.AddCheckBox("x+5 yp Checked" IniRead("Config.ini","setting","clock_show"), "显示当前计时（右）")
ConfigClockShow.OnEvent("Click",Config_ClockShow)
config.AddText("xs section","非工作时间：")
ConfigBreakSwitch:=Config.AddDropDownList("x+3 yp-3.5 w170 Choose" IniRead("Config.ini","setting","break_switch"),["暂停计时器","隐藏计时器"])
ConfigBreakSwitch.OnEvent("Change",Config_BreakSwitch)
config.AddText("xs section","计时器浮窗显示在：")
ConfigSwitchMonitor:=Config.AddDropDownList("vSwitchMonitor x+3 yp-3.5 Choose" IniRead("Config.ini","setting","monitor"), MonitorList())
ConfigSwitchMonitor.OnEvent("Change",Config_SwitchMonitor)
config.AddText("xs section","切换主题：")
ConfigSwitchTheme:=Config.AddDropDownList("vSwitchTheme x+3 yp-3.5 w184 Choose" CurrentTheme(), ["黑色","白色"])
ConfigSwitchTheme.OnEvent("Change",Config_SwitchTheme)
;快捷键
ConfigTab.UseTab(2)
ConfigHotkey:=Config.AddCheckBox("x25 y45 section vHotkey Checked" IniRead("Config.ini","setting","hotkey"), "全局快捷键")
ConfigHotkey.OnEvent("Click",Config_Hotkey)
ConfigHotkeyInfo:=Config.AddGroupBox("xs ys+25", "快捷键说明")
ConfigHotkeyInfo.Move(,,333,120)
Config.AddText("xs+15 ys+48","切换至计时器1(红):`tCtrl+Shift+F1`n切换至计时器2(黄):`tCtrl+Shift+F2`n切换至计时器3(蓝):`tCtrl+Shift+F3`n切换至计时器4(绿):`tCtrl+Shift+F4`n当前计时器归零:`t`tCtrl+Shift+F5")
;ConfigTab.Choose(3)   用这个来单独选择标签页3，用来给第一次使用的用户直接设置工作软件，记得连带设置宽高
;工作软件
ConfigTab.UseTab(3)
Config.AddText("y45 x25 section","从右边的列表中选择工作用的软件，点击“+”号添加到左边的列表中。`n如果没有你需要的软件，可以先启动它，然后点击“刷新”")
config.AddText("xs ys+45 section","工作软件：")
WorkList:=Array() ;工作程序列表映射
ConfigWorkList :=Config.AddListView("ys+20 h280 xs vConfigWorkList w190 -Hdr",["名称"])
ConfigWorkList.ModifyCol(1, 160) ;第一列宽度为240（铺满只显示一列
ConfigWorkList.OnEvent("ItemSelect",WorkList_ItemSelect)
ConfigAddExe:=Config.AddButton("x+2 yp+100 w25 h30","+")
ConfigAddExe.setFont("s12")
ConfigAddExe.OnEvent("Click",Config_AddExe)
ConfigRemoveExe:=Config.AddButton("xp yp+36 w25 h30","-")
ConfigRemoveExe.setFont("s12")
ConfigRemoveExe.OnEvent("Click",Config_RemoveExe)
config.AddText("xs+220 ys section","当前打开的软件：")
ExeList:=Array() ;当前程序列表映射
ConfigExeList :=Config.AddListView("section ys+20 h250 xs vConfigExeList w190 -Hdr",["名称"])
ConfigExeList.ModifyCol(1, 160) ;第一列宽度为240（铺满只显示一列
ConfigExeList.OnEvent("ItemSelect",ExeList_ItemSelect)
ConfigRefreshExe:=Config.AddButton("xs ys+251 w190 h30","↺刷新")
ConfigRefreshExe.OnEvent("Click",Config_RefreshExe)
;计时记录
ConfigTab.UseTab(4)
ConfigLogList :=Config.AddListView("y35 x15 h395 w430 NoSortHdr",["开始时间","工作时长","总时长","工作时长占比"])
ConfigLogList.ModifyCol(1, "130 Center")
ConfigLogList.ModifyCol(2, "100 Center")
ConfigLogList.ModifyCol(3, "100 Center")
ConfigLogList.ModifyCol(4, "AutoHdr Center")
Loop read,"log.csv"{
    result:=[]
    if(A_Index>1){
        Loop Parse,A_LoopReadLine,"CSV"{
            switch A_Index{
            case 1:
                result.Push(A_LoopField)

            case 2:
                result.Push(A_LoopField)

            case 3:
                result.Push(A_LoopField)
            case 4:
                result.Push(A_LoopField)
            }

        }
        ;OutputDebug(A_Index "----" result[1] "," result[3] "," DateDiff(result[2],result[1],"seconds") "," Round(result[3]/DateDiff(result[2],result[1],"seconds")*100))
        ConfigLogList.Insert(1,,FormatTime(result[1],"M月dd日dddHH:mm"),result[2],result[3],result[4] "%")
    }
}

;--------------用到的函数---------------
;开机自动启动
Config_AutoRun(GuiCtrlObj, Info){
    if(GuiCtrlObj.Value){
        FileCreateShortcut A_ScriptFullPath,A_Startup "/TrueWorkTime.lnk"
    }Else{
        Try{
            FileDelete A_Startup "/TrueWorkTime.lnk"
        }
    }
    IniWrite GuiCtrlObj.Value,"Config.ini","setting","auto_run"
}

;显示本次计时器
Config_ClockShow(GuiCtrlObj, Info){
    logger.ClockShow:=GuiCtrlObj.Value
    IniWrite GuiCtrlObj.Value,"Config.ini","setting","clock_show"
    if(GuiCtrlObj.Value){
        ClockGui.Show("NoActivate")
        ClockGui.Move(logger.x,logger.y,ClockWidth,ClockHeight)
    }Else{
        ClockGui.Hide()
    }
}

;显示项目累计计时
Config_ItemShow(GuiCtrlObj, Info){
    logger.ItemShow:=GuiCtrlObj.Value
    IniWrite GuiCtrlObj.Value,"Config.ini","setting","item_show"
    if(logger.ItemShow){
        ItemGui.Show("NoActivate")
        ItemGui.Move(logger.x-ItemWidth,logger.y,ItemWidth,ClockHeight)
    }Else{
        ItemGui.Hide()
    }
}
;摸鱼时显示器状态
Config_BreakSwitch(GuiCtrlObj, Info){
    logger.BreakSwitch:=GuiCtrlObj.Value
    IniWrite GuiCtrlObj.Value,"Config.ini","setting","break_switch"
    if(!ifwinAct()){
        if(logger.BreakSwitch==2){
            ClockGui.Move(,,,0)
            ItemGui.Move(,,,0)
        }Else{
            ClockGui.Move(,,,30)
            ItemGui.Move(,,,30)
            ClockText.SetFont("c" Theme["gray"])
            ItemGui.BackColor := Items[logger.CurrentItem]['themeB']
            ItemText.SetFont("c" Items[logger.CurrentItem]['themeT'])
        }
    }
}

;切换显示器
Config_SwitchMonitor(GuiCtrlObj, Info){
    MonitorGet GuiCtrlObj.Value, &WL, &WT, &WR, &WB
    logger.x := WR/(A_ScreenDPI/96)-(ClockWidth + 137)
    logger.y := WT/(A_ScreenDPI/96)
    ClockGui.Move(logger.x,logger.y)
    ItemGui.Move(logger.x-ItemWidth,logger.y)
    IniWrite GuiCtrlObj.Value,"Config.ini","setting","monitor"
}
MonitorList(){
    ML:=[]
    Loop MonitorGetCount(){
        ML.Push("显示器" A_Index)
    }
    Return ML
}

;切换亮暗主题
Config_SwitchTheme(GuiCtrlObj, Info){
    if(GuiCtrlObj.Value==1){
        logger.Theme:="black"
        IniWrite "black","Config.ini","setting","theme"
    }Else{
        logger.Theme:="white"
        IniWrite "white","Config.ini","setting","theme"
    }
    ClockGui.BackColor := Theme[logger.Theme]
}
CurrentTheme(){
    if(logger.Theme=="black"){
        Return 1
    }Else{
        Return 2
    }
}

;摸鱼时自动隐藏
Config_BreakHide(GuiCtrlObj, Info){
    logger.BreakHide:=GuiCtrlObj.Value
    if(!ifwinAct()){
        if(logger.BreakHide){
            ClockGui.Move(,,,0)
            ItemGui.Move(,,,0)
        }Else{
            ClockGui.Move(,,,30)
            ItemGui.Move(,,,30)
        }
    }
    IniWrite GuiCtrlObj.Value,"Config.ini","setting","break_hide"
}

;全局快捷键开关
Config_Hotkey(GuiCtrlObj, Info){
    Suspend !GuiCtrlObj.Value
    IniWrite GuiCtrlObj.Value,"Config.ini","setting","hotkey"
}

;切换Tab
Config_SwitchTab(GuiCtrlObj, Info){
    switch GuiCtrlObj.Value{
    Case 1:
        {
            Config.Move(,,400,250)
            ConfigTab.Move(,,364,196)
        }
    Case 2:
        {
            Config.Move(,,400,260)
            ConfigTab.Move(,,364,205)

        }
    Case 3:
        {
            Config.Move(,,476,455)
            ConfigTab.Move(,,442,400)
            ShowWorkList()
            ShowExeList()
        }
    Case 4:
        {
            Config.Move(,,476,485)
            ConfigTab.Move(,,442,430)

        }
    }

}

;显示当前程序列表
ShowExeList(){
    ConfigExeList.Delete()
    ConfigExeListIcon := IL_Create()
    ConfigExeList.SetImageList(ConfigExeListIcon)
    loop ExeList.Length{
        ExeList.Pop()
    }
    ids := WinGetList() ;获取当前程序列表
    hased :=0
    for this_id in ids
    {
        ;去重
        hased :=0
        for this_n in ExeList{
            Try{
                if (WinGetProcessName(this_id) ==this_n.Name){
                    hased:=1
                    Break
                }
            }

        }
        if (hased ==0){
            ExeList.Push(Exe(WinGetProcessName(this_id),WinGetProcessPath(this_id))) ;;存入当前程序列表映射
        }
    }
    for a in ExeList{
        ;OutputDebug a.Name "-----" a.Path
        ConfigExeList.Add("Icon" IL_Add(ConfigExeListIcon, a.Path) ,a.Name)
        ;OutputDebug ExeList.Length
    }
    Return 
}
;显示工作程序列表
ShowWorkList(){
    W:=StrSplit(IniRead("Config.ini","data","workexe"),",") ;工作软件列表
    WPath:=StrSplit(IniRead("Config.ini","data","workexe_path"),",") ;工作软件文件地址列表
    ConfigWorkList.Delete()
    ConfigWorkListIcon := IL_Create()
    ConfigWorkList.SetImageList(ConfigWorkListIcon)
    loop WorkList.Length{
        WorkList.Pop()
    }
    Loop W.Length{
        WorkList.Push(Exe(W[A_Index],WPath[A_Index]))
    }
    for a in WorkList{
        OutputDebug a.Name "-----" a.Path
        ConfigWorkList.Add("Icon" IL_Add(ConfigWorkListIcon, a.Path) ,a.Name)
    }
}

ExeList_ItemSelect(GuiCtrlObj, Item, Selected){
    ;OutputDebug ExeList.Length
    ExeList[Item].Choose:=Selected
}

WorkList_ItemSelect(GuiCtrlObj, Item, Selected){
    ;OutputDebug WorkList.Length
    WorkList[Item].Choose:=Selected
}

Config_AddExe(GuiCtrlObj, Info){
    for n in WorkExe{
        WorkExe.Pop()
    }
    W:=StrSplit(IniRead("Config.ini","data","workexe"),",") ;工作软件列表
    b:=IniRead("Config.ini","data","workexe")
    c:=IniRead("Config.ini","data","workexe_path")
    for a in ExeList{
        has:=0
        if(a.Choose){
            for i in W{
                ;OutputDebug a.Name "VS" i
                if (a.Name==i){
                    has:=1
                    Break
                }
            }
            if(!has){
                b:=b "," a.Name
                c:=c "," a.Path
            }
        }
    }
    b:=LTrim(b,",")
    c:=LTrim(c,",")
    IniWrite(b,"Config.ini","data","workexe")
    IniWrite(c,"Config.ini","data","workexe_path")
    for m in StrSplit(b,","){
        WorkExe.Push(m)
    }
    ShowWorkList()
}

Config_RemoveExe(GuiCtrlObj, Info){
    for n in WorkExe{
        WorkExe.Pop()
    }
    b:=""
    c:=""
    for a in WorkList{
        if(!a.Choose){
            b:=b "," a.Name
            c:=c "," a.Path
        }
    }
    b:=LTrim(b,",")
    c:=LTrim(c,",")
    IniWrite(b,"Config.ini","data","workexe")
    IniWrite(c,"Config.ini","data","workexe_path")
    ShowWorkList()
    for m in StrSplit(b,","){
        WorkExe.Push(m)
    }
}

Config_RefreshExe(GuiCtrlObj, Info){
    ShowExeList()
}

;备忘：打算用一个自定义对象数组来管理程序列表，对象包含属性：程序名，程序地址（存图标）；程序是否被选中。数组序号对应ListView里的序号

class Exe {
    __New(n,pa){
        this.Name:=n
        this.Path:=pa
        this.Choose:=0
    }
}
