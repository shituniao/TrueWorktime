Config :=Gui()
Config.Title :="TrueWorkTime"
Config.MarginX :=10
Config.MarginY :=10
Config.SetFont("s9","Microsoft YaHei UI")
ConfigTab:=Config.AddTab3("y+5",["功能设置","工作软件","每日记录","项目记录"])
ConfigTab.Move(,,364,196)
ConfigTab.OnEvent("Change",Config_SwitchTab)

;今日概览⚠️
;ConfigTab.UseTab(1)
;ConfigHotkey:=Config.AddCheckBox("x25 y45 section vHotkey Checked" IniRead("Config.ini","setting","hotkey"), "全局快捷键")
;ConfigHotkeyInfo:=Config.AddGroupBox("xs ys+25", "快捷键说明")
;ConfigHotkeyInfo.Move(,,333,120)

;设置
ConfigTab.UseTab(1)
CheckAutoRun()
ConfigAutoRun:=Config.AddCheckBox("x25 y45 section vAutoRun Checked" IniRead("Config.ini","setting","auto_run"), "开机自动启动")
ConfigAutoRun.OnEvent("Click",Config_AutoRun)
ConfigShow:=Config.AddCheckBox("xs y+10 section Checked" IniRead("Config.ini","setting","show"), "显示计时器")
ConfigShow.OnEvent("Click",Config_ClockShow)
ConfigItemShow:=Config.AddCheckBox("xs+20 y+10 Checked" IniRead("Config.ini","setting","itemshow") " Disabled" (!IniRead("Config.ini","setting","show")), "显示左侧累计时间")
ConfigItemShow.OnEvent("Click",Config_ItemShow)
ConfigBreakShow:=Config.AddCheckBox("xs+20 y+10 Checked" (!IniRead("Config.ini","setting","breakshow")) " Disabled" (!IniRead("Config.ini","setting","show")), "非工作时间隐藏计时器")
ConfigBreakShow.OnEvent("Click",Config_BreakShow)
config.AddText("xs y+15 section","计时器显示在：")
ConfigSwitchMonitor:=Config.AddDropDownList("vSwitchMonitor x+3 yp-4 w217 Choose" IniRead("Config.ini","setting","monitor"), MonitorList())
ConfigSwitchMonitor.OnEvent("Change",Config_SwitchMonitor)
config.AddText("xs y+10 section","颜色主题：")
ConfigSwitchTheme:=Config.AddDropDownList("vSwitchTheme x+3 yp-4 w242 Choose" CurrentTheme(), ["黑色","白色"])
ConfigSwitchTheme.OnEvent("Change",Config_SwitchTheme)
config.AddText("xs y+10 section","点击托盘图标显示：")
ConfigTrayIcon:=Config.AddDropDownList("x+3 yp-4 w193 Choose" IniRead("Config.ini","setting","trayicon"), ["功能设置","工作软件","每日记录","项目记录"])
ConfigTrayIcon.OnEvent("Change",Config_TrayIcon)

;工作软件
ConfigTab.UseTab(2)
Config.AddText("y45 x25 section","从左边的列表中选择工作用的软件，点击“+”号添加到右边的列表中。`n如果没有你要选的软件，可以先启动它，然后点击[↺刷新]")
config.AddText("xs ys+45 section","当前打开的软件：")
ExeList:=Array() ;当前程序列表映射
ConfigExeList :=Config.AddListView("ys+20 h280 xs vConfigExeList w190 -Hdr",["名称"])
ConfigExeList.ModifyCol(1, 160) ;第一列宽度为240（铺满只显示一列
ConfigExeList.OnEvent("ItemSelect",ExeList_ItemSelect)
ConfigRefreshExe:=Config.AddButton("xs+120 ys-5 w70 h25","↺刷新")
ConfigRefreshExe.OnEvent("Click",Config_RefreshExe)
ConfigAddExe:=Config.AddButton("x+2 yp+100 w25 h30","+")
ConfigAddExe.setFont("s12")
ConfigAddExe.OnEvent("Click",Config_AddExe)
ConfigRemoveExe:=Config.AddButton("xp yp+36 w25 h30","-")
ConfigRemoveExe.setFont("s12")
ConfigRemoveExe.OnEvent("Click",Config_RemoveExe)
config.AddText("xs+220 ys section","工作软件：")
WorkList:=Array() ;工作程序列表映射
ConfigWorkList :=Config.AddListView("ys+20 h280 xs vConfigWorkList w190 -Hdr",["名称"])
ConfigWorkList.ModifyCol(1, 160) ;第一列宽度为240（铺满只显示一列
ConfigWorkList.OnEvent("ItemSelect",WorkList_ItemSelect)

;每日计时
ConfigTab.UseTab(3)
Try{
    IniRead("Config.ini","setting","user_time")
    IniRead("Config.ini","setting","user_worktime")
}Catch{
    IniWrite 0,"Config.ini","setting","user_time"
    IniWrite "20240101000000","Config.ini","setting","user_worktime"
}
ConfigUserTime:=Config.AddCheckBox("x25 y40 section Checked" IniRead("Config.ini","setting","user_time"), "规定每日总时长:")
ConfigUserWorkTime:=Config.AddDateTime("xs+110 ys-4 w200 1 Choose" IniRead("Config.ini","setting","user_worktime"), "HH:mm")
ConfigUserTime.OnEvent("Click",Config_UserTime)
ConfigUserWorkTime.OnEvent("Change",Config_UserTime)
ConfigLogList :=Config.AddListView("ys+25 x15 h365 w430 Count50",["开始时间","工作时长","总时长","工作时长占比"])
ConfigLogList.ModifyCol(1, "130 Center")
ConfigLogList.ModifyCol(2, "90 Center")
ConfigLogList.ModifyCol(3, "90 Center")
ConfigLogList.ModifyCol(4, "90 Center")

;项目计时
ConfigTab.UseTab(4)
ConfigShowOldItems:=Config.AddCheckBox("x25 y40 section Checked" IniRead("Config.ini","setting","show_old"), "显示已过期项目（项目超过15天会自动过期）")
ConfigShowOldItems.OnEvent("Click",Config_ShowOldItems)
ConfigItemList :=Config.AddListView("ys+25 x15 h380 w760 Count50",["名称","开始时间","最近记录","耗时","状态"])
ConfigItemList.ModifyCol(1, "350 Center")
ConfigItemList.ModifyCol(2, "110 Center")
ConfigItemList.ModifyCol(3, "110 Center")
ConfigItemList.ModifyCol(4, "80 Center")
ConfigItemList.ModifyCol(5, "80 Center")

;--------------用到的函数---------------
;检查开机自动启动
CheckAutoRun(){
    if(FileExist(A_Startup "/TrueWorkTime.lnk")){
        if(!IniRead("Config.ini","setting","auto_run")){
            OutputDebug("设置为开机不启动，但存在快捷方式，所以删除快捷方式")
            FileDelete(A_Startup "/TrueWorkTime.lnk")
        }
    }Else if(IniRead("Config.ini","setting","auto_run")){
        OutputDebug("设置为开机启动但没有快捷方式，所以创建快捷方式")
        FileCreateShortcut A_ScriptFullPath,A_Startup "/TrueWorkTime.lnk"
    }
}

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

;显示计时器
Config_ClockShow(GuiCtrlObj, Info){
    logger.show:=GuiCtrlObj.Value
    IniWrite GuiCtrlObj.Value,"Config.ini","setting","show"
    logger.ReDraw()
    ConfigItemShow.Enabled:=GuiCtrlObj.Value
    ConfigBreakShow.Enabled:=GuiCtrlObj.Value
}

;显示累计计时
Config_ItemShow(GuiCtrlObj, Info){
    logger.itemShow:=GuiCtrlObj.Value
    IniWrite GuiCtrlObj.Value,"Config.ini","setting","itemshow"
    logger.ReDraw()
}
;摸鱼时显示
Config_BreakShow(GuiCtrlObj, Info){
    logger.breakshow:=!GuiCtrlObj.Value
    IniWrite !GuiCtrlObj.Value,"Config.ini","setting","breakshow"
    logger.ReDraw()
}

;切换显示器
Config_SwitchMonitor(GuiCtrlObj, Info){
    MonitorGet GuiCtrlObj.Value, &WL, &WT, &WR, &WB
    logger.x := WR/(A_ScreenDPI/96)-(logger.w + 137)
    logger.y := WT/(A_ScreenDPI/96)
    IniWrite GuiCtrlObj.Value,"Config.ini","setting","monitor"
    logger.ReDraw()
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
    switch GuiCtrlObj.Value {
    Case 1:
        {
            logger.color:="white"
            logger.background:="black"
            IniWrite "white","Config.ini","setting","color"
            IniWrite "black","Config.ini","setting","background"
        }
    Case 2:
        {
            logger.color:="black"
            logger.background:="white"
            IniWrite "black","Config.ini","setting","color"
            IniWrite "white","Config.ini","setting","background"
        }
    }
    logger.ReDraw()
}
CurrentTheme(){
    switch IniRead("Config.ini","setting","background"){
    Case "black":
        {
            Return 1
        }
    Case "white":
        {
            Return 2
        }
    }
}

;切换托盘图标功能
Config_TrayIcon(GuiCtrlObj, Info){
    A_TrayMenu.Default:=GuiCtrlObj.Value "&"
    IniWrite GuiCtrlObj.Value,"Config.ini","setting","trayicon"
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
    W:=StrSplit(IniRead("Config.ini","worklist","workexe"),",") ;工作软件列表
    WPath:=StrSplit(IniRead("Config.ini","worklist","workexe_path"),",") ;工作软件文件地址列表
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
    for n in logger.workList{
        logger.workList.Pop()
    }
    W:=StrSplit(IniRead("Config.ini","worklist","workexe"),",") ;工作软件列表
    b:=IniRead("Config.ini","worklist","workexe")
    c:=IniRead("Config.ini","worklist","workexe_path")
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
    IniWrite(b,"Config.ini","worklist","workexe")
    IniWrite(c,"Config.ini","worklist","workexe_path")
    for m in StrSplit(b,","){
        logger.workList.Push(m)
    }
    ShowWorkList()
}

Config_RemoveExe(GuiCtrlObj, Info){
    for n in logger.workList{
        logger.workList.Pop()
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
    IniWrite(b,"Config.ini","worklist","workexe")
    IniWrite(c,"Config.ini","worklist","workexe_path")
    ShowWorkList()
    for m in StrSplit(b,","){
        logger.workList.Push(m)
    }
}

Config_RefreshExe(GuiCtrlObj, Info){
    ShowExeList()
}

;每日日志
LogRefresh(){
    ConfigLogList.Delete()
    UserWorkTime:=IniRead("Config.ini","setting","user_worktime")
    result:=[]
    Try{
        UserTime:=IniRead("Config.ini","setting","user_time")
    }Catch{
        UserTime:=0
        IniWrite 0,"Config.ini","setting","user_time"
    }
    Loop read,"data/log.csv"{
        if(A_Index>1){
            result:=StrSplit(A_LoopReadLine, ",")
            if(UserTime){
                result.RemoveAt(3,2)
                m:=DateDiff(UserWorkTime,"20240101000000","Seconds")
                result.Push(m)
                if(m!=0){
                    result.Push(Round(100*Number(result[2])/m))
                }Else{
                    result.Push("0")
                }
            }
            ConfigLogList.Insert(1,,FormatTime(result[1],"M月dd日ddd HH:mm"),FormatSeconds(result[2]),FormatSeconds(result[3]),result[4] "%")
        }
    }
}

Config_UserTime(GuiCtrlObj, Info){
    if(ConfigUserTime.Value){
        IniWrite 1,"Config.ini","setting","user_time"
        IniWrite ConfigUserWorkTime.Value,"Config.ini","setting","user_worktime"
    }Else{
        IniWrite 0,"Config.ini","setting","user_time"
    }
    LogRefresh()
}
;备忘：打算用一个自定义对象数组来管理程序列表，对象包含属性：程序名，程序地址（存图标）；程序是否被选中。数组序号对应ListView里的序号

;Item列表刷新
ItemsRefresh(){
    ConfigItemList.Delete()
    result:=[]
    Loop Read,"data/items.csv"{
        result:=StrSplit(A_LoopReadLine, ",")
        ConfigItemList.Add(,result[1],FormatTime(result[2],"M月dd日 HH:mm"),FormatTime(result[3],"M月dd日 HH:mm"),FormatSeconds(result[4]),"进行中")
    }
    if(IniRead("Config.ini","setting","show_old")){
        Loop Read,"data/itemsOld.csv"{
            result:=StrSplit(A_LoopReadLine, ",")
            ConfigItemList.Add(,result[1],FormatTime(result[2],"M月dd日 HH:mm"),FormatTime(result[3],"M月dd日 HH:mm"),FormatSeconds(result[4]),"已过期")
        }
    }
    ConfigItemList.ModifyCol(3, "SortDesc")

}

Config_ShowOldItems(GuiCtrlObj, Info){
    IniWrite GuiCtrlObj.Value,"Config.ini","setting","show_old"
    ItemsRefresh()
}

class Exe {
    __New(n,pa){
        this.Name:=n
        this.Path:=pa
        this.Choose:=0
    }
}

;切换Tab
Config_SwitchTab(GuiCtrlObj, Info){
    Config_Resize(GuiCtrlObj.Value)
}

;调整每个tab的尺寸和内容变化
Config_Resize(tab){
    switch tab{
    Case 1:
        {
            Config.Move(,,370,305)
            ConfigTab.Move(,,334,250)
        }
    Case 2:
        {
            Config.Move(,,476,455)
            ConfigTab.Move(,,442,400)
            ShowWorkList()
            ShowExeList()

        }
    Case 3:
        {
            Config.Move(,,476,485)
            ConfigTab.Move(,,442,430)
            LogRefresh()

        }
    Case 4:
        {
            Config.Move(,,806,505)
            ConfigTab.Move(,,772,450)
            ItemsRefresh()
        }
    }
}