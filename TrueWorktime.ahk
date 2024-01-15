Version :="v1.1.0"
FileEncoding "UTF-8"
;引入外部JSON库，来自https://github.com/G33kDude/cJson.ahk
FileInstall "JSON.ahk", "JSON.ahk" ,1 ;把JSON.ahk写入exe文件里
FileInstall "ItemdataDEF.json", "ItemdataDEF.json" ,1 ;把保底JSON写入exe文件里
FileInstall "configDEF.ini", "configDEF.ini" ,1 ;把保底JSON写入exe文件里
FileInstall "ItemIcon.dll", "ItemIcon.dll" ,1 ;把保底JSON写入exe文件里
;FileCreateShortcut A_ScriptFullPath,A_Startup "/TrueWorkTime.lnk"   创建开机启动
#Include JSON.ahk 

ClockWidth :=90
ClockHeight :=30
ItemWidth :=60
TipsWidth :=ClockWidth+ItemWidth
IdleLimit:=30000 ;无操作超时30秒（30000毫秒
SitLimit:=1800 ; 久坐时间（秒-----此功能已废除
Try{
    WorkExe:=StrSplit(IniRead("Config.ini","data","workexe"),",") ;工作软件列表
}Catch{
    OutputDebug "文件不存在，使用保底文件"
    WorkExe:=StrSplit(IniRead("ConfigDEF.ini","data","workexe"),",")
    FileCopy("ConfigDEF.ini","Config.ini")
}

;主题颜色map
Theme := Map()
Theme["red"]:="f92f60" ;红f92f60/ffd8d9黄ffc700/7d4533蓝1c5cd7/aeddff绿008463/c6fbe7
Theme["redT"]:="ffd8d9"
Theme["yellow"]:="ffc700"
Theme["yellowT"]:="7d4533"
Theme["blue"]:="1c5cd7"
Theme["blueT"]:="aeddff"
Theme["green"]:="008463"
Theme["greenT"]:="c6fbe7"
Theme["black"]:="000000"
Theme["blackT"]:="ffffff"
Theme["white"]:="ffffff"
Theme["whiteT"]:="000000"
Theme["gray"]:="919191"
Theme["grayT"]:="1f1f1f"

;JSON读取
Try{
    ItemJson:=FileRead("Itemdata.json")
}Catch{
    Try{
        OutputDebug "文件不存在，使用备份文件"
        ItemJson:=FileRead("ItemdataBAK.json")
        FileCopy("ItemdataBAK.json","Itemdata.json")
    }Catch{
        OutputDebug "备份文件不存在，使用保底文件"
        ItemJson:=FileRead("ItemdataDEF.json")
        FileCopy("ItemdataDEF.json","Itemdata.json")
        FileCopy("ItemdataDEF.json","ItemdataBAK.json")

    }
}

Items:=JSON.Load(ItemJson)

logger := StateLog() ;定义计时器对象
TraySetIcon(, , 1) ;冻结托盘图标

;计时器悬浮窗
ClockGui := Gui()
ClockGui.Opt("+AlwaysOnTop -Caption +ToolWindow +DPIScale" ) ; +ToolWindow 避免显示任务栏按钮和 alt-tab 菜单项.
ClockGui.MarginY:=4
ClockGui.BackColor := Theme["black"] ; 初始白色背景(下面会变成半透明的).
ClockGui.SetFont("s12","Microsoft YaHei UI") 
;WinSetTransColor(" 0", ClockGui) ; 半透明:
WinSetExStyle("+0x20", ClockGui) ;鼠标穿透
ClockGui.Show("NoActivate") ; NoActivate 让当前活动窗口继续保持活动状态.
ClockGui.Move(logger.x,logger.y,ClockWidth,ClockHeight)

;累计计时器悬浮窗
ItemGui := Gui()
ItemGui.Opt("+AlwaysOnTop -Caption +ToolWindow +DPIScale" )
ItemGui.MarginY:=4
ItemGui.BackColor := Items[logger.CurrentItem]['theme'] ;红f92f60/ffd8d9黄ffc700/7d4533蓝1c5cd7/aeddff绿008463/c6fbe7
ItemGui.SetFont("s12","Microsoft YaHei UI") 
ItemText :=ItemGui.Add("Text","x0 ym r1 w" ItemWidth " c" Items[logger.CurrentItem]['themeT'] " Center", FormatSeconds(Items[logger.CurrentItem]['time'],False))
;WinSetTransColor(" 0", ItemGui) ; 半透明:
WinSetExStyle("+0x20", ItemGui) ;鼠标穿透
ItemGui.Show("NoActivate")
ItemGui.Move(logger.x-ItemWidth,logger.y,ItemWidth,ClockHeight)

;提醒浮窗
TipsGui :=Gui()
TipsGui.Opt("+AlwaysOnTop -Caption +ToolWindow +DPIScale" )
TipsGui.MarginY:=4
TipsGui.BackColor := Theme["white"]
TipsGui.SetFont("s12","Microsoft YaHei UI") 
TipsText :=TipsGui.Add("Text","x0 ym r1 w" ItemWidth " c" Theme["whiteT"] " Center")
WinSetExStyle("+0x20", TipsGui) ;鼠标穿透

;计时器设置窗口
Config :=Gui()
Config.Title :="工作计时器"
Config.MarginX :=12
Config.MarginY :=15
Config.SetFont("s10","Microsoft YaHei UI")
Config.AddText("y+10","目前设置的工作软件：")
WorkList :=Config.AddEdit("y+10 w300 R9 vWorkList ReadOnly Backgrounddddddd Border",)
Config.AddText("y+15","添加新的工作软件：")
ExeWork :=Config.AddListView("y+10 xm r9 vExeWork w300 -Hdr -Multi",["名称"])
ExeWorkIcon := IL_Create()
ExeWork.SetImageList(ExeWorkIcon)
ExeWork.ModifyCol(1, 250)
ExeWork.OnEvent("ItemSelect",ExeWork_ItemSelect)
Config.Add("Button", "y+10 w80", "➕添加").OnEvent("Click", ClickADD)
Config.Add("Button", "x+30 w80", "❔刷新").OnEvent("Click", ClickREFRESH)
Config.Add("Button", "x+30 w80", "❌清空").OnEvent("Click", ClickCLEAR)
;Config.Add("Button", "xm w80 w300", "✔️提交").OnEvent("Click", ClickSUBMIT)
Config.AddText("y+10 xm w300","选择你认为是工作用的软件，点击添加按钮").SetFont("s10 c000000")
Config.AddText("y+2 xm w300","如果列表中没有要选的软件，尝试先打开这个软件，然后点击刷新按钮，程序会自动检测").SetFont("s9 c444444")
Caution :=Config.AddText("y+10 vCaution w300")
Caution.SetFont("s9 c444444")
SelectItem:=["",1]

;帮助窗口
Help:=Gui()
Help.Title:="工作计时器 " Version
Help.MarginX :=12
Help.MarginY :=15
Help.SetFont("s9 c444444","Microsoft YaHei UI")

;定义托盘菜单
A_TrayMenu.Rename("E&xit","退出")
A_TrayMenu.Delete("&Suspend Hotkeys")
A_TrayMenu.Delete("&Pause Script")
ItemMenu :=Menu()
Loop Items.Length{
    ItemMenu.Add(A_Index "：" FormatSeconds(Items[A_Index]["time"],False),ItemSwitch) ;发现项目名字不能一样（Why？？？）
    ItemMenu.SetIcon(A_Index "&" ,"ItemIcon.dll",A_Index)
}
ItemMenu.Default:=logger.CurrentItem "&" ;用打勾的方式显示当前项目会覆盖掉颜色图标（可恶）所以改成默认项的加粗显示

A_TrayMenu.Insert("1&", "切换项目", ItemMenu)
A_TrayMenu.Insert("2&", "当前项目归零", MenuHandler)
A_TrayMenu.Insert("3&")
A_TrayMenu.Insert("4&", "设置", MenuHandler)
A_TrayMenu.Insert("5&", "帮助", MenuHandler)
A_TrayMenu.Insert("6&")
A_TrayMenu.Default:="4&"

;托盘菜单功能函数
MenuHandler(ItemName, ItemPos, MyMenu) {
    Switch ItemPos{
    Case 2:
        {
            ResetItem()
        }
    Case 4:
        {
            ShowConfig()
        }
    Case 5:
        {
            Help.Show("AutoSize Center")
        }
    }
}
;---------------------用到的各种托盘功能函数👇--------------------------------------
ItemSwitch(ItemName, ItemPos, MyMenu){
    ChangeItem(ItemPos)
    MyMenu.Default:=ItemPos "&"
}
MonitorChoose(ItemName, ItemPos, MyMenu){
    MonitorGet ItemPos, &WL, &WT, &WR, &WB
    logger.x := WR/(A_ScreenDPI/96)-(ClockWidth + 137)
    logger.y := WT/(A_ScreenDPI/96)
    ClockGui.Move(logger.x,logger.y)
    IniWrite ItemPos,"Config.ini","setting","monitor"
}

ShowConfig(){
    Config.Show("AutoSize Center")
    ExeWork.Focus()
    WorkCACHE:=""
    for n in WorkExe{
        WorkCACHE .=StrSplit(StrTitle(n),".exe")[1] "`n"
    }
    WorkList.Value:=WorkCACHE
    ExeWork.Delete()
    ids := WinGetList() ;获取当前程序列表
    ;ExeNameList :=[]
    ENL_p :=[] ;程序列表去重
    hased :=0
    for this_id in ids
    {
        for this_n in ENL_p{
            if (WinGetProcessName(this_id) =this_n){
                hased:=1
                Break
            }
        }
        if (hased =0){
            ;ExeNameList.Push(StrSplit(WinGetProcessName(this_id),".exe")[1])
            ExeWork.Add("Icon" IL_Add(ExeWorkIcon, WinGetProcessPath(this_id)) ,StrSplit(StrTitle(WinGetProcessName(this_id)),".exe")[1])
            ENL_p.Push(StrTitle(WinGetProcessName(this_id)))
            ;OutputDebug WinGetProcessPath(this_id)  ;测试程序的进程地址（涉及到获取程序Icon图标
        }
        hased :=0
    }
    Return 
}
;---------------------------用到的各种托盘功能函数👆----------------------------------
;---------------------------软件设置窗口的功能函数👇----------------------------------
ClickADD(thisGui, *)
{
    hased :=0
    ;Choosed := thisGui.Gui.Submit(0).SelectItem
    if(SelectItem[1]!=""){
        for n in WorkExe{
            if ((SelectItem[1] ".exe") =n){
                hased :=1
                Break
            }
        }
        if(hased =0){
            WorkExe.Push(SelectItem[1] ".exe")
            WorkList.Value.=SelectItem[1] "`n"
            Caution.Value := "添加成功！"
        }else{
            Caution.Value := "这个软件已经添加过了！"
        }
        iniCache:=""
        for n in WorkExe{
            iniCache .=n ","
        }
        ;写入ini文件
        iniCache := RTrim(iniCache,",")
        IniWrite iniCache,"Config.ini","data","workexe"
    }else{
        Caution.Value := "你选了啥？"
    }
}

ClickREFRESH(thisGui, *){
    ids := WinGetList() ;获取当前程序列表
    hased :=0
    for this_id in ids
    {
        Loop ExeWork.GetCount()
        {
            if(ExeWork.GetText(A_Index)=StrSplit(StrTitle(WinGetProcessName(this_id)),".exe")[1]){
                hased:=1
                Break
            }
        }
        if (hased =0){
            ;ExeNameList.Push(StrSplit(WinGetProcessName(this_id),".exe")[1])
            ExeWork.Add("Icon" IL_Add(ExeWorkIcon, WinGetProcessPath(this_id)) ,StrSplit(StrTitle(WinGetProcessName(this_id)),".exe")[1])
        }
        hased :=0
    }
    Caution.Value := "软件列表刷新完成！"
}

ClickCLEAR(thisGui, *){
    if(WorkExe.Length >0){
        WorkExe.RemoveAt(1, WorkExe.Length)
        iniCache:=""
        for n in WorkExe{
            iniCache .=n ","
        }
        ;写入ini文件
        iniCache := RTrim(iniCache,",")
        IniWrite iniCache,"Config.ini","data","workexe"
        WorkList.Value:=""
        Caution.Value := "工作软件已清空！"
    }else{
        Caution.Value := "已经是空的了啊！"
    }

}

ExeWork_ItemSelect(EW, Item, Selected){
    if(Selected){
        SelectItem[1]:=EW.GetText(Item)
        SelectItem[2]:=Item
        ;MsgBox(SelectItem[1] " " SelectItem[2])
    }
}

;启动时检测是否程序列表为空
if(WorkExe.Length<=0){
    ;TrayTip "右键点击任务栏图标进行设置", "尚未设置工作软件"
    ;Sleep 5000 ; 让它显示 3 秒钟.
    ;TrayTip
}
;---------------------------软件设置窗口的功能函数👆----------------------------------

;-------------------启动时第一次检查-----------------------
if(WorkExe.Length>0){
    ClockText := ClockGui.Add("Text", "x0 ym r1 w" ClockWidth " c" Theme["blackT"] " Center", "准备") 
}else{
    ClockGui.BackColor := Theme["black"]
    ClockText := ClockGui.Add("Text", "x0 ym r1 w" ClockWidth " c" Theme["blackT"] " Center", "未设置软件")
    if(MsgBox("尚未设置工作软件，是否进行设置？","工作计时器","4 64")="Yes"){
        ShowConfig()
    } 
}

;✅✅✅✅✅✅启动计时器✅✅✅✅✅✅
logger.Start 

;⭐⭐⭐⭐⭐⭐计时器类（核心程序⭐⭐⭐⭐⭐⭐
class StateLog {
    __New(){
        MonitorGet IniRead("Config.ini","setting","monitor"), &WL, &WT, &WR, &WB
        this.x:=WR/(A_ScreenDPI/96) - (ClockWidth + 137)
        this.y:=WT/(A_ScreenDPI/96)
        this.WorkTime :=0 ;工作时间
        this.BreakTime :=0 ;摸鱼时间
        this.LeaveTime :=0 ;离开时间
        this.CurrentItem :=IniRead("Config.ini","data","current_item") ;当前项目
        this.StartTime :=FormatTime(,"yyyy-MM-dd HH:mm:ss") ;本次计时开始运行时间
        this.RunTime :=0 ;总运行时间
        this.State :=1 ;计时器状态，1-工作中，2-摸鱼中，3-离开中， 0-未设置工作软件   ,4-久坐提醒
        this.sitTime :=0
        this.BreakHide:=IniRead("Config.ini","setting","break_hide")
        this.check :=ObjBindMethod(this, "StateCheck")
    }
    Start() {
        SetTimer this.check, 1000 ;开启主循环
    }
    StateCheck() {
        this.RunTime++
        if(WorkExe.Length<=0){ ;0-未设置工作软件
            this.State:=0
            ChangeGui(0) ;更新悬浮窗
        }else{
            if(A_TimeIdlePhysical>=IdleLimit){
                ChangeGui(3) ;更新悬浮窗
                this.LeaveTime++
                this.BreakTime++ ;改动：离开后时间也计入摸鱼时间
                this.sitTime:=0
            }Else{
                if(ifwinAct()){
                    this.WorkTime++
                    this.sitTime++
                    if(Items[logger.CurrentItem]['time']==0){
                        OutputDebug "项目" this.CurrentItem "开始计时！开始时间已录入：" FormatTime(,"yyyy-MM-dd HH:mm:ss")
                        Items[logger.CurrentItem]['start']:= FormatTime(,"yyyy-MM-dd HH:mm:ss") ;检查项目计时是否为零
                    }
                    Items[this.CurrentItem]['time']++
                    ChangeGui(1) ;更新悬浮窗
                    JsonFileReUpdate() ;更新JSON文件
                }Else{
                    ChangeGui(2) ;更新悬浮窗
                    this.BreakTime++
                    this.sitTime++
                }
            }
            ; 托盘图标提示
            Switch this.State{
            Case 1:
                A_IconTip := "工作中...`n工作时间：" FormatSeconds(this.WorkTime) "`n摸鱼时间：" FormatSeconds(this.BreakTime) "`n离开时间：" FormatSeconds(this.LeaveTime)
            Case 2:
                A_IconTip := "摸鱼中...`n工作时间：" FormatSeconds(this.WorkTime) "`n摸鱼时间：" FormatSeconds(this.BreakTime) "`n离开时间：" FormatSeconds(this.LeaveTime)
            Case 0:
                A_IconTip := "尚未设置工作软件`n右键图标选择设置" 
            }

        }
    }
}

ifwinAct() ;判断当前软件是否为工作软件
{
    for app in WorkExe{
        if(WinActive("ahk_exe " app)){
            Return 1
        }
    }
    Return 0
}

FormatSeconds(NumberOfSeconds,full := True) ; 把指定的秒数转换成 hh:mm:ss 格式.
{
    ;重写了时间格式化
    HH:=Floor(NumberOfSeconds/3600)
    mm:=Floor(Mod(NumberOfSeconds,3600)/60)
    ss:=Mod(NumberOfSeconds,60)
    if(full){
        Return Format("{1:02u}:{2:02u}:{3:02u}" , HH,mm,ss) 
    }else{ 
        Return Format("{1:02u}:{2:02u}" , HH,mm) 
    }
}

;窗口集体置顶
AlwaysOnTop(){
    ClockGui.Opt("+AlwaysOnTop")
    ItemGui.Opt("+AlwaysOnTop")
    TipsGui.Opt("+AlwaysOnTop")
}

;修改悬浮窗
ChangeGui(stateNew){
    if(stateNew==1){
        ItemText.Value := FormatSeconds(Items[logger.CurrentItem]['time'],False)
        ClockText.Value :=FormatSeconds(logger.WorkTime)
    }
    if(stateNew!=logger.State){
        logger.State:=stateNew
        Switch stateNew{
        Case 0:
            {
                ClockText.Value := "未设置软件"
                ClockGui.BackColor := Theme["black"]
                ClockText.SetFont("c" Theme["blackT"])
                ItemGui.BackColor := Items[logger.CurrentItem]['themeB']
                ItemText.SetFont("c" Items[logger.CurrentItem]['themeT'])
                ClockGui.Move(,,,30)
                ItemGui.Move(,,,30)
            }
        Case 1:
            {
                ClockGui.BackColor := Theme["black"]
                ClockText.SetFont("c" Theme["blackT"])
                ItemGui.BackColor := Items[logger.CurrentItem]['theme']
                ItemText.SetFont("c" Items[logger.CurrentItem]['themeT'])
                ClockGui.Move(,,,30)
                ItemGui.Move(,,,30)
                AlwaysOnTop()
            }
        Default:
            {

                if(logger.BreakHide){
                    ClockGui.Move(,,,0)
                    ItemGui.Move(,,,0)
                }Else{
                    ClockGui.BackColor := Theme["gray"]
                    ClockText.SetFont("c" Theme["grayT"])
                    ItemGui.BackColor := Items[logger.CurrentItem]['themeB']
                    ItemText.SetFont("c" Items[logger.CurrentItem]['themeT'])

                }
                ;ClockText.Value :=FormatSeconds(logger.BreakTime)
            }
        }
        ;OutputDebug "状态改变为" stateNew "，刷新Gui"
    }Else{
        ;OutputDebug "状态未改变仍然是" stateNew
    }
}

;切换Item
ChangeItem(Item){
    logger.CurrentItem := Item
    ItemText.Value := FormatSeconds(Items[logger.CurrentItem]['time'],False)
    IniWrite Item, "Config.ini","data","current_item"
    ItemText.SetFont("c" Items[logger.CurrentItem]['themeT'])
    if(logger.State==1){ 
        ItemGui.BackColor := Items[logger.CurrentItem]['theme'] 
    }Else{
        ItemGui.BackColor := Items[logger.CurrentItem]['themeB']
    }
}

CloseTips(){
    TipsGui.Hide()
}

;归零当前项目
ResetItem(){
    Items[logger.CurrentItem]['time']:=0
    JsonFileReUpdate()
    ItemText.Value := FormatSeconds(Items[logger.CurrentItem]['time'],False)
    TipsOn("-归零-",-500,Items[logger.CurrentItem]['theme'],Items[logger.CurrentItem]['themeT'])
    OutputDebug "项目" logger.CurrentItem "已归零"
}

TipsOn(text,life,color,colorT){
    TipsGui.BackColor:=color
    TipsText.SetFont("c" colorT)
    TipsGui.Show("NoActivate")
    TipsGui.Move(logger.x-ItemWidth,logger.y,ItemWidth,ClockHeight)
    TipsText.Value:=text
    SetTimer(CloseTips,life)
}

;JSON文件更新
JsonFileReUpdate(){
    Try{
        FileCopy("Itemdata.json","ItemdataBAK.json",1)
    }
    Try{
        FileDelete "Itemdata.json"
    }
    FileAppend JSON.Dump(Items),"Itemdata.json"
}
;快捷键部分
^F1::
    {
        ChangeItem(1)
    }
^F2::
    {
        ChangeItem(2)
    }
^F3::
    {
        ChangeItem(3)
    }
^F4::
    {
        ChangeItem(4)
    }
^F5:: 
    {
        ResetItem()
    }
^F6::
    {
        MonitorGet 1, &WL, &WT, &WR, &WB
        ;logger.x := WR/(A_ScreenDPI/96)-(ClockWidth + 137)
        ;logger.y := WT/(A_ScreenDPI/96)
        ClockGui.Move(10,logger.y)
    }

    ; 帮助文本
    Help.AddText("y+10 w300","说明：").SetFont("s10 bold")
    Help.AddText("xp+10 y+10 w280","工作计时器是一个帮助用户记录工作时长和空闲时长的程序。")
    Help.AddText("y+10 w280","程序每秒检测当前正在使用的软件是否是预先设定的工作软件，以及用户是否在30秒内有鼠标操作或键盘输入。")
    Help.AddText("xm y+10 w300","图例：").SetFont("s10 bold")
    Help.AddText("xp+10 y+10 w280","若当前软件是工作软件，且电脑在30秒内有键鼠操作，则会记录为工作时间，显示为黑底白字。")
    Help.AddText("y+10 BackGround000000 cffffff h8 w" ClockWidth " Center","")
    Help.AddText("y+0 BackGround000000 cffffff h30 w" ClockWidth " Center","06:29:01").SetFont("s12")
    Help.AddText("y+10 w280","若当前软件不是工作软件，则会记录为空闲时间，显示为白底黑字。")
    Help.AddText("y+10 BackGroundffffff c000000 h8 w" ClockWidth " Center","")
    Help.AddText("y+0 BackGroundffffff c000000 h30 w" ClockWidth " Center","05:13:22").SetFont("s12")
    Help.AddText("y+10 w280","若超过30秒没有操作，则会记录为离开时间，显示为灰底白字。")
    Help.AddText("y+10 BackGroundffffff c666666 h8 w" ClockWidth " Center","")
    Help.AddText("y+0 BackGroundffffff c666666 h30 w" ClockWidth " Center","05:13:22").SetFont("s12")
    Help.AddText("y+10 w280","提供久坐提醒功能，当用户维持键鼠操作超过30分钟时，程序会显示红色久坐提示（这个功能可以关闭）")
    Help.AddText("y+10 BackGroundea4135 cffffff h8 w" ClockWidth " Center","")
    Help.AddText("y+0 BackGroundea4135 cffffff h30 w" ClockWidth " Center","坐太久了").SetFont("s12")
    Help.AddText("xm y+20 w300","作者与联系方式：").SetFont("s10 bold")
    Help.AddText("xp+10 y+10 w280","本程序基于AutoHotkey 2.0.2编写`n由shituniao制作`n时长统计图程序部分由C.Even编写")
    Help.AddLink("y+10 w280", '<a href="https://www.autohotkey.com/">AutoHotkey官网</a>')
    Help.AddLink("y+5 w280", '<a href="https://github.com/shituniao/TrueWorktime">Github地址</a>')
    Help.AddLink("y+5 w280 h0",).Focus()

    OnExit ExitFunc

    ExitFunc(ExitReason, ExitCode)
    {
    }

