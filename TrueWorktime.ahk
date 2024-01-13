Version :="v1.1.0"
bannerWidth :=90
ItemWidth :=60
FileEncoding "UTF-8"

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

;引入外部JSON库，来自https://github.com/G33kDude/cJson.ahk
#Include JSON.ahk 

;--------关于JSON读取和写入的测试
;objstr := [{start:"sss",time:1234,color:"ff0000"},{start:"bbb",time:1234,color:"ff0000"}]
;OutputDebug objstr[1].start
;jsonstr :=JSON.Dump(objstr)
;FileAppend jsonstr,"test.json"
ItemJson:=FileRead("Itemdata.json")
;OutputDebug jsona
Items:=JSON.Load(ItemJson)
;Items[1]['time']+=1
;OutputDebug jsonb
;--------关于JSON读取和写入的测试

logger := StateLog() ;定义计时器对象
TraySetIcon(, , 1) ;冻结托盘图标

;读取ini文件
WorkExe:=StrSplit(IniRead("Config.ini","exelist","workexe"),",") ;工作软件列表
SitLimit:=1800 ; 久坐时间
;WorkExe:=["HarmonyPremium.exe", "PureRef.exe", "tim.exe"] 

;计时器悬浮窗
ClockGui := Gui()
ClockGui.Opt("+AlwaysOnTop -Caption +ToolWindow +DPIScale" ) ; +ToolWindow 避免显示任务栏按钮和 alt-tab 菜单项.
ClockGui.MarginY:=4
ClockGui.BackColor := Theme["white"] ; 初始白色背景(下面会变成半透明的).
ClockGui.SetFont("s12","Microsoft YaHei UI") 
if(WorkExe.Length>0){
    ClockText := ClockGui.Add("Text", "x0 ym r1 w" bannerWidth " c" Theme["whiteT"] " Center", "预备") 
}else{
    ClockGui.BackColor := Theme["black"]
    ClockText := ClockGui.Add("Text", "x0 ym r1 w" bannerWidth " c" Theme["blackT"] " Center", "无工作软件") 
}
WinSetTransColor(" 230", ClockGui) ; 半透明:
WinSetExStyle("+0x20", ClockGui) ;鼠标穿透
ClockGui.Show("x" logger.x "y" logger.y " h30 w" bannerWidth " NoActivate") ; NoActivate 让当前活动窗口继续保持活动状态.

;累计计时器悬浮窗
ItemGui := Gui()
ItemGui.Opt("+AlwaysOnTop -Caption +ToolWindow +DPIScale" )
ItemGui.MarginY:=4
ItemGui.BackColor := Items[logger.CurrentItem]['Theme'] ;红f92f60/ffd8d9黄ffc700/7d4533蓝1c5cd7/aeddff绿008463/c6fbe7
ItemGui.SetFont("s12","Microsoft YaHei UI") 
ItemText :=ItemGui.Add("Text","x0 ym r1 w" ItemWidth " c" Items[logger.CurrentItem]['ThemeT'] " Center", FormatSeconds(Items[1]['time'],False))
WinSetTransColor(" 230", ItemGui) ; 半透明:
WinSetExStyle("+0x20", ItemGui) ;鼠标穿透
ItemGui.Show("x" logger.x-ItemWidth "y" logger.y " h30 w" ItemWidth " NoActivate")

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

logger.Start ;✅✅✅✅✅✅--------------------启动计时器-----------------------

;定义托盘图标
A_TrayMenu.Rename("E&xit","退出")
A_TrayMenu.Delete("&Suspend Hotkeys")
A_TrayMenu.Delete("&Pause Script")
A_TrayMenu.Insert("1&", "暂停", MenuHandler)
A_TrayMenu.Insert("2&", "重置", MenuHandler)
A_TrayMenu.Insert("3&")
A_TrayMenu.Insert("4&", "久坐30分钟提醒", MenuHandler)
if(logger.tomatoToggle){
    A_TrayMenu.check("4&")
}else{
    A_TrayMenu.UnCheck("4&")
}
A_TrayMenu.Insert("5&", "显示顶部浮窗", MenuHandler)
if(IniRead("Config.ini","setting","show","1")="1"){
    A_TrayMenu.check("5&")
}else{
    A_TrayMenu.UnCheck("5&")
}
MonitorMenu :=Menu()
A_TrayMenu.Insert("6&", "顶部浮窗显示在...", MonitorMenu)
Loop MonitorGetCount(){
    MonitorMenu.Add("显示器" A_Index , MonitorChoose)
}
A_TrayMenu.Insert("7&", "设置工作软件", MenuHandler)
A_TrayMenu.Insert("8&")
A_TrayMenu.Insert("9&", "帮助", MenuHandler)
A_TrayMenu.Insert("10&", "显示统计图", MenuHandler)

A_TrayMenu.Default:="10&"

;Persistent
;托盘控件功能及程序设置界面
MenuHandler(ItemName, ItemPos, MyMenu) {
    Switch ItemPos{
    Case 4 :
        {
            logger.sitTime:=0
            if(logger.tomatoToggle){
                logger.tomatoToggle:=0
                A_TrayMenu.Uncheck("4&")
            }else{
                logger.tomatoToggle:=1
                A_TrayMenu.Check("4&")
            }
            IniWrite logger.tomatoToggle,"Config.ini","setting","tomato_alarm"
        }
    Case 1:
        {
            Pause -1
            if(A_IsPaused){
                A_IconTip := "计时器已暂停`n工作时间：" FormatSeconds(logger.WorkTime) "`n摸鱼时间：" FormatSeconds(logger.BreakTime)
                A_TrayMenu.Rename("1&","继续")
                TrayTip , "计时器已暂停"
                Sleep 2000 ; 让它显示 3 秒钟.
                TrayTip
            }else{
                A_TrayMenu.Rename("1&","暂停")
                TrayTip , "计时器已继续"
                Sleep 2000 ; 让它显示 3 秒钟.
                TrayTip
            }
        }

    Case 2 :
        {
            logger.WorkTime :=0
            logger.BreakTime :=0
            ClockText.Value := FormatSeconds(logger.WorkTime)
            TrayTip , "计时器已重置"
            Sleep 2000 ; 让它显示 3 秒钟.
            TrayTip
        }
    Case 5:
        {
            if(IniRead("Config.ini","setting","show","1")="1"){
                A_TrayMenu.uncheck("5&")
                ClockGui.Hide()
                IniWrite "0","Config.ini","setting","show"
            }else{
                A_TrayMenu.Check("5&")
                ClockGui.Show()
                IniWrite "1","Config.ini","setting","show"
            }
        }
    Case 7 :
        {
            ShowConfig()
        }
    Case 9:
        {
            Help.Show("AutoSize Center")
        }
    Case 10:
        {
            Run "ShowWorkTime", "ShowWorkTime\"
        }
    }
}
;---------------------用到的各种托盘功能函数👇--------------------------------------
MonitorChoose(ItemName, ItemPos, MyMenu){
    MonitorGet ItemPos, &WL, &WT, &WR, &WB
    logger.x := WR/(A_ScreenDPI/96)-(bannerWidth + 137)
    ;MsgBox(logger.x)
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
        iniCache:="workexe="
        for n in WorkExe{
            iniCache .=n ","
        }
        ;写入ini文件
        iniCache := RTrim(iniCache,",")
        IniWrite iniCache,"Config.ini","exelist"
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
        iniCache:="workexe="
        for n in WorkExe{
            iniCache .=n ","
        }
        ;写入ini文件
        iniCache := RTrim(iniCache,",")
        IniWrite iniCache,"Config.ini","exelist"
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
    if(MsgBox("尚未设置工作软件，是否进行设置？","工作计时器","4 64")="Yes"){
        ShowConfig()
    }
}
;---------------------------软件设置窗口的功能函数👆----------------------------------

;计时器类（核心程序
class StateLog {
    __New(){
        MonitorGet IniRead("Config.ini","setting","monitor"), &WL, &WT, &WR, &WB
        this.x:=WR - (bannerWidth + 137)*(A_ScreenDPI/96)
        this.y:=WT
        this.WorkTime :=0 ;工作时间
        this.BreakTime :=0 ;摸鱼时间
        this.LeaveTime :=0 ;离开时间
        this.CurrentItem :=IniRead("Config.ini","data","current_item") ;当前项目
        this.StartTime :=FormatTime(,"yyyy-MM-dd HH:mm:ss") ;本次计时开始运行时间
        this.RunTime :=0 ;总运行时间
        this.WorkIn :=2 ;计时器状态，1-工作中，2-摸鱼中，3-离开中， 0-未设置工作软件   ,4-久坐提醒
        this.sitTime :=0
        this.tomatoToggle:=IniRead("Config.ini","setting","tomato_alarm")
        this.check :=ObjBindMethod(this, "StateCheck")
        ;OutputDebug CCCTTT
        ;this.tmtAlarm :=ObjBindMethod(this, "TomatoAlarm")
    }
    Start() {
        ;暂时将此行注释，因为不打算用cherrysoda了
        ;FileAppend "START," (A_Hour*3600+A_Min*60+A_Sec) "," FormatTime(, "HH:mm:ss"), this.StartTime ".csv"
        SetTimer this.check, 1000
    }
    StateCheck() {
        this.RunTime++
        if(WorkExe.Length<=0){ ;0-未设置工作软件
            WorkIn:=4
            if(this.WorkIn !=0){
                this.WorkIn:=0
                ClockGui.BackColor := Theme["black"]
                ClockText.SetFont("c" Theme["blackT"])
                ;暂时将此行注释，因为不打算用cherrysoda了
                ;FileAppend "`n" "NONE," this.RunTime "," FormatTime(, "HH:mm:ss"), this.StartTime ".csv"
            }
            ClockText.Value := "无工作软件"
            ChangeItem(0) ;悬浮窗变成灰色
        }else{
            if(ifwinAct() and A_TimeIdlePhysical<30000){ ;1-工作中
                this.WorkTime++
                this.sitTime++
                Items[this.CurrentItem]['time']++
                if (this.WorkIn != 1){ 
                    if(this.WorkIn != 4){
                        ;暂时将此行注释，因为不打算用cherrysoda了
                        ;FileAppend "`n" "work," this.RunTime "," FormatTime(, "HH:mm:ss"), this.StartTime ".csv"
                    }
                    this.WorkIn :=1 ;计时器状态，1-工作中，2-摸鱼中，3-离开中， 0-未设置工作软件   ,4-久坐提醒
                    ClockGui.BackColor := Theme["black"]
                    ClockText.SetFont("c" Theme["blackT"])
                }
                ClockText.Value := FormatSeconds(this.WorkTime)
                ItemText.Value := FormatSeconds(Items[this.CurrentItem]['time'],False)
                ChangeItem(this.CurrentItem)
                JsonFileReUpdate()
            }else if(A_TimeIdlePhysical>=30000){ ;3-离开中
                this.LeaveTime++
                this.BreakTime++ ;改动：离开后时间也计入摸鱼时间
                this.sitTime:=0
                if (this.WorkIn != 3){
                    ;暂时将此行注释，因为不打算用cherrysoda了
                    ;FileAppend "`n" "leave," this.RunTime "," FormatTime(, "HH:mm:ss"), this.StartTime ".csv"
                    this.WorkIn :=3 
                    ClockGui.BackColor := Theme["white"]
                    ClockText.SetFont("c" Theme["whiteT"])

                }
                ClockText.Value := FormatSeconds(this.BreakTime) ;改动：离开后时间也计入摸鱼时间
                ChangeItem(0) ;悬浮窗变成灰色
            }else{ ;2-摸鱼中
                this.BreakTime++
                this.sitTime++
                if (this.WorkIn != 2){
                    if(this.WorkIn != 4){
                        ;暂时将此行注释，因为不打算用cherrysoda了
                        ;FileAppend "`n" "break," this.RunTime "," FormatTime(, "HH:mm:ss"), this.StartTime ".csv"
                    }
                    this.WorkIn :=2 ;计时器状态，1-工作中，2-摸鱼中，3-离开中， 0-未设置工作软件   ,4-久坐提醒
                    ClockGui.BackColor := Theme["white"]
                    ClockText.SetFont("c" Theme["whiteT"])

                }
                ClockText.Value := FormatSeconds(this.BreakTime)
                ChangeItem(0) ;悬浮窗变成灰色
            }
        }
        if(this.tomatoToggle=1 and Mod(this.sitTime,SitLimit)>0 and Mod(this.sitTime,SitLimit)<3 and this.sitTime>SitLimit){ ;4-久坐提醒
            if (this.WorkIn != 4){
                this.WorkIn :=4 ;计时器状态，1-工作中，2-摸鱼中，3-离开中， 0-未设置工作软件   ,4-久坐提醒
                ClockGui.BackColor := "ea4135"
                ClockText.SetFont("cffffff")
                ClockText.Value := "坐太久了"
            }
        }
        ; 托盘图标提示
        Switch this.WorkIn{
        Case 1:
            A_IconTip := "工作中...`n工作时间：" FormatSeconds(this.WorkTime) "`n摸鱼时间：" FormatSeconds(this.BreakTime) "`n离开时间：" FormatSeconds(this.LeaveTime)
        Case 2:
            A_IconTip := "摸鱼中...`n工作时间：" FormatSeconds(this.WorkTime) "`n摸鱼时间：" FormatSeconds(this.BreakTime) "`n离开时间：" FormatSeconds(this.LeaveTime)
        Case 0:
            A_IconTip := "尚未设置工作软件`n右键图标选择设置" 
        }
    }
}

ifwinAct() ;核心函数！判断当前软件是否为工作软件
{
    for app in WorkExe{
        if(WinActive("ahk_exe " app)){
            ;MsgBox(WorkExe.Length)
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

JsonFileReUpdate(){
    FileDelete "Itemdata.json"
    FileAppend JSON.Dump(Items),"Itemdata.json"
}

; 帮助文本
Help.AddText("y+10 w300","说明：").SetFont("s10 bold")
Help.AddText("xp+10 y+10 w280","工作计时器是一个帮助用户记录工作时长和空闲时长的程序。")
Help.AddText("y+10 w280","程序每秒检测当前正在使用的软件是否是预先设定的工作软件，以及用户是否在30秒内有鼠标操作或键盘输入。")
Help.AddText("xm y+10 w300","图例：").SetFont("s10 bold")
Help.AddText("xp+10 y+10 w280","若当前软件是工作软件，且电脑在30秒内有键鼠操作，则会记录为工作时间，显示为黑底白字。")
Help.AddText("y+10 BackGround000000 cffffff h8 w" bannerWidth " Center","")
Help.AddText("y+0 BackGround000000 cffffff h30 w" bannerWidth " Center","06:29:01").SetFont("s12")
Help.AddText("y+10 w280","若当前软件不是工作软件，则会记录为空闲时间，显示为白底黑字。")
Help.AddText("y+10 BackGroundffffff c000000 h8 w" bannerWidth " Center","")
Help.AddText("y+0 BackGroundffffff c000000 h30 w" bannerWidth " Center","05:13:22").SetFont("s12")
Help.AddText("y+10 w280","若超过30秒没有操作，则会记录为离开时间，显示为灰底白字。")
Help.AddText("y+10 BackGroundffffff c666666 h8 w" bannerWidth " Center","")
Help.AddText("y+0 BackGroundffffff c666666 h30 w" bannerWidth " Center","05:13:22").SetFont("s12")
Help.AddText("y+10 w280","提供久坐提醒功能，当用户维持键鼠操作超过30分钟时，程序会显示红色久坐提示（这个功能可以关闭）")
Help.AddText("y+10 BackGroundea4135 cffffff h8 w" bannerWidth " Center","")
Help.AddText("y+0 BackGroundea4135 cffffff h30 w" bannerWidth " Center","坐太久了").SetFont("s12")
Help.AddText("xm y+20 w300","作者与联系方式：").SetFont("s10 bold")
Help.AddText("xp+10 y+10 w280","本程序基于AutoHotkey 2.0.2编写`n由shituniao制作`n时长统计图程序部分由C.Even编写")
Help.AddLink("y+10 w280", '<a href="https://www.autohotkey.com/">AutoHotkey官网</a>')
Help.AddLink("y+5 w280", '<a href="https://github.com/shituniao/TrueWorktime">Github地址</a>')
Help.AddLink("y+5 w280 h0",).Focus()

OnExit ExitFunc

ExitFunc(ExitReason, ExitCode)
{
    ;暂时将此行注释，因为不打算用cherrysoda了
    ;FileAppend "`n" "END," logger.RunTime "," FormatTime(, "HH:mm:ss") " 工作时间:" FormatSeconds(logger.WorkTime) "；摸鱼时间:" FormatSeconds(logger.BreakTime) "；离开时间:" FormatSeconds(logger.LeaveTime) "`n",logger.StartTime ".csv"
}

;换算周几的字符
WeekDay(){
    Switch A_WDay{
        Case "1": Return "_Sunday"
        Case "2": Return "_Monday"
        Case "3": Return "_Tuesday"
        Case "4": Return "_Wednesday"
        Case "5": Return "_Thursday"
        Case "6": Return "_Friday"
        Case "7": Return "_Saturday"
    }

}

;修改项目悬浮窗颜色
ChangeItem(Item){
    if(Item!=0){
        logger.CurrentItem := Item
        ItemGui.BackColor := Items[logger.CurrentItem]['Theme']
        ItemText.SetFont("c" Items[logger.CurrentItem]['ThemeT'])
        ;OutputDebug logger.CurrentItem
        OutputDebug Items[logger.CurrentItem]['time']
    }else{
        ItemGui.BackColor := Theme["gray"]
        ItemText.SetFont("c" Theme["grayT"])
    }

}
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