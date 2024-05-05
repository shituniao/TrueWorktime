Version :="v1.8.0"
FileEncoding "UTF-8"

;预加载
TraySetIcon(, , 1) ;冻结托盘图标

;主题颜色map
Theme := Map()
Theme["red"]:="f92f60" ;红f92f60/ffd8d9黄ffc700/7d4533蓝1c5cd7/aeddff绿008463/c6fbe7
Theme["yellow"]:="ffc700"
Theme["blue"]:="1c5cd7"
Theme["green"]:="008463"
Theme["black"]:="000000"
Theme["white"]:="ffffff"
Theme["gray"]:="999999"

;;主计时器对象
logger := Log() ;计时器对象

;加载其他ahk文件
#Include modules/Clock.ahk
#Include modules/TrayMenu.ahk
#Include modules/Config.ahk
#Include modules/Item.ahk

;;核心Log类定义
class Log {
    __New(){
        ;UI类
        this.h:=30
        this.w:=90
        MonitorGet IniRead("Config.ini","setting","monitor"), &WL, &WT, &WR, &WB ;读取显示器信息
        this.x:=WR/(A_ScreenDPI/96) - (this.w + 137)
        this.y:=WT/(A_ScreenDPI/96)
        this.color:=IniRead("Config.ini","setting","color") ;文字颜色
        this.background:=IniRead("Config.ini","setting","background") ;背景颜色
        this.show:=IniRead("Config.ini","setting","show") ;是否显示悬浮窗
        this.breakShow:=IniRead("Config.ini","setting","breakshow") ;摸鱼时是否显示浮窗
        this.itemShow:=IniRead("Config.ini","setting","itemshow") ;是否显示累计计时
        this.windowShow:=True ;是否显示当前窗口名⚠️
        ;数据类
        this.workList:=StrSplit(IniRead("Config.ini","worklist","workexe"),",") ;工作软件列表
        this.itemList:=[] ;Item列表
        this.state:=1 ;计时器状态，1-工作中，2-摸鱼中，3-离开中
        this.currentWindow:="" ;当前窗口名
        this.currentItem:=item() ;当前窗口对象
        this.workTime :=0 ;工作时间
        this.breakTime :=0 ;摸鱼时间
        this.leaveTime :=0 ;离开时间
        this.runTime:=0 ;总运行时间
        this.idleLimit:=30000 ;无操作时限（30秒）
        ;主循环
        this.mLoop:=ObjBindMethod(this, "MainLoop")
    }
    Start(){
        ;初次启动检测与6小时间隔检测是否延用
        if(InStr(FileRead("data/log.csv"),"`n")){
            if(DateDiff(A_Now,IniRead("Cache.ini","data","end"),"hours")<6){ ;21600000
                if(MsgBox("检测到近期（6小时内）有时间记录，是否延用？","工作计时器","4 64")=="Yes"){
                    logger.workTime:=IniRead("Cache.ini","data","worktime")
                    logger.breakTime:=IniRead("Cache.ini","data","breaktime")
                    logger.leaveTime:=IniRead("Cache.ini","data","leavetime")
                    logger.runTime:=IniRead("Cache.ini","data","runtime")
                }else{
                    NewLog()
                    FilterItems()
                }
            }else{
                NewLog()
                FilterItems()
            }
        }Else{
            IniWrite A_Now,"Cache.ini","data","start"
            OutputDebug("第一次运行")
        }
        ;检测是否设置工作软件
        if(this.workList.Length==0){
            if(MsgBox("尚未设置工作软件，是否进行设置？","工作计时器","4 48")="Yes"){
                ShowConfig(2)
                ShowWorkList()
                ShowExeList()
            } 
        }
        ReadItems()
        SetTimer this.mLoop, 1000 ;开启主循环
    }
    MainLoop(){
        this.StateCheck()
        this.UpDate()
        this.ReDraw()
    }
    StateCheck(){
        if(A_TimeIdlePhysical>=this.idleLimit){
            this.state:=3
        }Else{
            if(isWorking()){
                this.state:=1
                this.currentWindow:=WinGetTitle()
            }Else{
                this.state:=2
            }
        }
    }
    UpDate(){
        this.runTime++
        switch this.state{
        Case 1:
            {
                this.workTime++
                CheckItem(this.currentWindow)
                UpdateItems()
                OutputDebug("工作中,名称：" this.currentWindow " 时间：" this.workTime " 总时间：" this.runTime)
            }
        Case 2:
            {
                this.breakTime++
                OutputDebug("摸鱼中，时间：" this.breakTime " 总时间：" this.runTime)
            }
        Case 3:
            {
                this.leaveTime++
                OutputDebug("离开中，时间：" this.leaveTime " 总时间：" this.runTime)
            }
        }
        UpdateCache()
    }
    ReDraw(){
        if(this.workList.Length==0){
            DrawClock("无工作软件","--:--:--",Theme[this.color],Theme[this.background])
            A_IconTip := "尚未设置工作软件"
        }Else{
            DrawClock(FormatSeconds(this.workTime),FormatSeconds(this.currentItem.duration),Theme[this.color],Theme[this.background])
            A_IconTip := "工作时间：" FormatSeconds(this.WorkTime) "`n摸鱼时间：" FormatSeconds(this.BreakTime) "`n离开时间：" FormatSeconds(this.LeaveTime)
        }
        switch this.state{
        Case 1:
            {
                GuiShow(this.show)
            }
        Default:
            {
                GuiShow(this.show AND this.breakshow)
            }
        }
    }
}

;✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅启动计时器✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅
logger.Start 

;;其他函数和参数

;判断当前软件是否为工作软件
isWorking() 
{
    for app in logger.workList{
        if(WinActive("ahk_exe " app)){
        Return 1
    }
}
Return 0
}

;时间格式化
FormatSeconds(NumberOfSeconds,full := True) 
{
    HH:=Floor(NumberOfSeconds/3600)
    mm:=Floor(Mod(NumberOfSeconds,3600)/60)
    ss:=Mod(NumberOfSeconds,60)
    if(full){
        Return Format("{1:02u}:{2:02u}:{3:02u}" , HH,mm,ss) 
    }else{ 
        Return Format("{1:02u}:{2:02u}" , HH,mm) 
    }
}

;悬浮窗显示隐藏与置顶
GuiShow(show){
    if(show){
        ClockGui.Show("NoActivate")
        ClockGui.Move(logger.x,logger.y,logger.w,logger.h)
        if(logger.itemShow){
            ItemGui.Show("NoActivate")
            ItemGui.Move(logger.x-logger.w,logger.y,logger.w,logger.h)
        }Else{
            ItemGui.Hide()
        }
    }Else{
        ClockGui.Hide()
        ItemGui.Hide()
    }
    ClockGui.Opt("+AlwaysOnTop")
    ItemGui.Opt("+AlwaysOnTop")
}

;绘制悬浮窗内容
DrawClock(textA,textB,color,background){
    ClockGui.BackColor:=background
    ClockText.SetFont("c" color)
    ClockText.Value := textA
    ItemText.Value := textB
}

;Cache.ini数据更新
UpdateCache(){
    IniWrite logger.workTime,"Cache.ini","data","worktime"
    IniWrite logger.breakTime,"Cache.ini","data","breaktime"
    IniWrite logger.leaveTime,"Cache.ini","data","leavetime"
    IniWrite logger.runTime,"Cache.ini","data","runtime"
    IniWrite A_Now,"Cache.ini","data","end"
}
;增加每日记录
NewLog(){
    start:=IniRead("Cache.ini","data","start")
    worktime:=IniRead("Cache.ini","data","worktime")
    alltime:=DateDiff(IniRead("Cache.ini","data","end"),start,"seconds")
    ratio:=Round(100*worktime/alltime)
    FileAppend "`n" start "," worktime "," alltime "," ratio , "data/log.csv"
    IniWrite A_Now,"Cache.ini","data","start"
}
