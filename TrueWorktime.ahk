bannerWidth :=100
xPosition := A_ScreenWidth - bannerWidth - 137

logger := StateLog() ;定义计时器对象

WorkExe:=StrSplit(IniRead("WorkExe.ini","exelist","workexe"),",") ;工作软件列表
;WorkExe:=["HarmonyPremium.exe", "PureRef.exe", "tim.exe"] 

;计时器悬浮窗
ClockGui := Gui()
ClockGui.Opt("+AlwaysOnTop -Caption +ToolWindow" ) ; +ToolWindow 避免显示任务栏按钮和 alt-tab 菜单项.
ClockGui.BackColor := "ffffff" ; 可以是任何 RGB 颜色(下面会变成透明的).
ClockGui.SetFont("s12","Microsoft YaHei UI") 
if(WorkExe.Length>0){
    CoordText := ClockGui.Add("Text", "x0 y4 h30 w" bannerWidth " c000000 Center", "预备") 
}else{
    ClockGui.BackColor := "000000"
    CoordText := ClockGui.Add("Text", "x0 y4 h30 w" bannerWidth " cffffff Center", "无工作软件") 
}

WinSetTransColor(" 230", ClockGui) ; 半透明:
WinSetExStyle("+0x20", ClockGui) ;鼠标穿透
ClockGui.Show("x" xPosition " y0 h30 w" bannerWidth " NoActivate") ; NoActivate 让当前活动窗口继续保持活动状态.

;计时器设置窗口
Config :=Gui()
Config.Title :="设置工作软件"
Config.MarginX :=12
Config.MarginY :=15
Config.SetFont("s10","Microsoft YaHei UI")
Config.AddText("y+10","目前设置的工作软件：")
WorkList :=Config.AddEdit("y+10 w300 R9 vWorkList ReadOnly Backgrounddddddd Border",)
Config.AddText("y+15","添加新的工作软件：")
ExeWork :=Config.AddListBox("y+10 R9 vExeWork w300 Choose1 ",)
Config.Add("Button", "y+10 w80", "添加").OnEvent("Click", ClickADD)
Config.Add("Button", "x+30 w80", "刷新").OnEvent("Click", ClickREFRESH)
Config.Add("Button", "x+30 w80", "清空").OnEvent("Click", ClickCLEAR)
Config.AddText("y+10 xm w300","提示 :`n如果列表中没有要选的软件，试试打开这个软件，然后点击刷新按钮").SetFont("s9 c444444")
Caution :=Config.AddText("y+10 vCaution w300")
Caution.SetFont("s9 c444444")

logger.Start ;启动计时器

;定义托盘图标
A_TrayMenu.Rename("E&xit","退出")
A_TrayMenu.Delete("&Suspend Hotkeys")
A_TrayMenu.Delete("&Pause Script")
A_TrayMenu.Insert("1&", "久坐30分钟提醒", MenuHandler)
A_TrayMenu.Check("1&")
A_TrayMenu.Insert("2&", "暂停", MenuHandler)
A_TrayMenu.Insert("3&", "重置计时器", MenuHandler)
A_TrayMenu.Insert("4&", "设置工作软件", MenuHandler)
A_TrayMenu.Default:="2&"

Persistent
;托盘控件功能及程序设置界面
MenuHandler(ItemName, ItemPos, MyMenu) {
    Switch ItemPos{
    Case 1 :
        {
            logger.sitTime:=0
            if(logger.tomatoToggle){
                logger.tomatoToggle:=0
                A_TrayMenu.Uncheck("1&")
            }else{
                logger.tomatoToggle:=1
                A_TrayMenu.Check("1&")
            }

        }
    Case 2:
        {
            Pause -1
            if(A_IsPaused){
                A_IconTip := "计时已暂停"
                A_TrayMenu.Rename("1&","继续")
            }else{
                A_TrayMenu.Rename("1&","暂停")
            }
        }

    Case 3 :
        {
            logger.WorkTime :=0
            logger.BreakTime :=0
            CoordText.Value := FormatSeconds(logger.WorkTime)
        }
    Case 4 :
        {
            Config.Show("AutoSize Center")
            WorkL:=""
            for n in WorkExe{
                WorkL .=StrSplit(n,".exe")[1] "`n"
            }
            WorkList.Value:=WorkL
            ExeWork.Delete()
            ExeWork.Add(GetExeNameList())
            ExeWork.Choose(1)
        }
    }
}
if(WorkExe.Length<=0){
    TrayTip "右键点击任务栏图标进行设置", "尚未设置工作软件"
    Sleep 5000 ; 让它显示 3 秒钟.
    TrayTip
}

ClickADD(thisGui, *)
{
    hased :=0
    Choosed := thisGui.Gui.Submit(0).ExeWork
    for n in WorkExe{
        if ((Choosed ".exe") =n){
            hased :=1
            Break
        }
    }
    if(hased =0){
        WorkExe.Push(Choosed ".exe")
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
    IniWrite iniCache,"WorkExe.ini","exelist"
    ;MsgBox(iniCache)
    for n in WorkExe{
        WorkL .=StrSplit(n,".exe")[1] "`n" 
    }
    WorkList.Value:=WorkL
}

ClickREFRESH(thisGui, *){
    ExeWork.Delete()
    ExeWork.Add(GetExeNameList())
    ExeWork.Choose(1)
    Caution.Value := "软件列表刷新完成！"
}

ClickCLEAR(thisGui, *){
    WorkExe.RemoveAt(1, WorkExe.Length)
    iniCache:="workexe="
    for n in WorkExe{
        iniCache .=n ","
    }
    ;写入ini文件
    iniCache := RTrim(iniCache,",")
    IniWrite iniCache,"WorkExe.ini","exelist"
    ;IniWrite "workexe=","WorkExe.ini","exelist"
    WorkList.Value:=""
    Caution.Value := "工作软件已清空！"
}

GetExeNameList(){
    ids := WinGetList() ;获取当前程序列表
    ENL_p :=[] ;程序列表去重
    ExeNameList :=[]
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
            ExeNameList.Push(StrSplit(WinGetProcessName(this_id),".exe")[1])
        }
        ENL_p.Push(WinGetProcessName(this_id))
        hased :=0
    }
    Return ExeNameList
}

;计时器类（核心程序
class StateLog {
    __New(){
        this.WorkTime :=0
        this.BreakTime :=0
        this.WorkIn :=2 ;计时器状态，1-工作中，2-摸鱼中，3-久坐提醒， 4-未设置工作软件
        this.sitTime :=0
        this.alarmWave:=6
        this.tomatoToggle:=1
        this.check :=ObjBindMethod(this, "StateCheck")
        this.tmtAlarm :=ObjBindMethod(this, "TomatoAlarm")
    }
    Start() {
        SetTimer this.check, 1000
    }
    StateCheck() {
        if(WorkExe.Length<=0){
            WorkIn:=4
            if(this.WorkIn !=4){
                this.WorkIn:=4
                ClockGui.BackColor := "000000"
                CoordText.SetFont("cffffff")
            }
            CoordText.Value := "无工作软件"
        }else{
            if(ifwinAct() and A_TimeIdlePhysical<30000){
                this.WorkTime++
                this.sitTime++
                if (this.WorkIn != 1){
                    this.WorkIn :=1
                    ClockGui.BackColor := "000000"
                    CoordText.SetFont("cffffff")
                }
                CoordText.Value := FormatSeconds(this.WorkTime)
            }else{
                this.BreakTime++
                if (this.WorkIn != 2){
                    this.WorkIn :=2
                    ClockGui.BackColor := "ffffff"
                    CoordText.SetFont("c000000")
                }
                CoordText.Value := FormatSeconds(this.BreakTime)
                ;关于久坐提醒部分的内容↓原理是根据非离开时间累计达到1800秒（30分钟）时抖动提醒
                if(A_TimeIdlePhysical>=30000){
                    this.sitTime:=0
                }else{
                    this.sitTime++
                }
            }
            if(Mod(this.sitTime,1800)=0 and this.sitTime>0 and this.tomatoToggle=1){
                this.WorkIn :=3
                ClockGui.BackColor := "ea4135"
                CoordText.SetFont("cffffff")
                CoordText.Value := "坐太久了"
                SetTimer this.tmtAlarm, 40
            }
            ; 托盘图标提示
        }
        Switch this.WorkIn{
        Case 1:
            A_IconTip := "计时中...`n当前状态：工作" 
        Case 2:
            A_IconTip := "计时中...`n当前状态：摸鱼或离开" 
        Case 4:
            A_IconTip := "尚未设置工作软件`n右键图标选择设置" 
        }
    }
    TomatoAlarm(){
        Switch Mod(this.alarmWave, 2){
        Case 1:
            ClockGui.Move(xPosition-this.alarmWave)
        Case 0:
            ClockGui.Move(xPosition+this.alarmWave)
        }
        this.alarmWave--
        if(this.alarmWave=0){
            this.alarmWave:=6
            SetTimer , 0
        }
    }
}

ifwinAct(){
    for app in WorkExe{
        if(WinActive("ahk_exe " app)){
            ;MsgBox(WorkExe.Length)
        Return 1
    }
}
Return 0
}

FormatSeconds(NumberOfSeconds) ; 把指定的秒数转换成 hh:mm:ss 格式.
{
    time := 19990101 ; 任意日期的 *午夜*.
    time := DateAdd(time, NumberOfSeconds, "Seconds")
    return FormatTime(time, "HH:mm:ss")
    /*
    ; 和上面方法不同的是, 这里不支持超过 24 小时的秒数:
    return FormatTime(time, "h:mm:ss")
    */
}

;ahk_exe HarmonyPremium.exe