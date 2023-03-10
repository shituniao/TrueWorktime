bannerWidth :=100
xPosition := A_ScreenWidth - bannerWidth - 137

logger := StateLog() ;定义计时器对象

winArr:=["ahk_exe HarmonyPremium.exe", "ahk_exe PureRef.exe", "ahk_exe tim.exe"] ;工作软件列表

MyGui := Gui()
MyGui.Opt("+AlwaysOnTop -Caption +ToolWindow" ) ; +ToolWindow 避免显示任务栏按钮和 alt-tab 菜单项.
MyGui.BackColor := "ffffff" ; 可以是任何 RGB 颜色(下面会变成透明的).
MyGui.SetFont("s12","Microsoft YaHei UI") ; 设置大字体(32 磅).
CoordText := MyGui.Add("Text", "x0 y4 h30 w" bannerWidth " c000000 Center", "预备") 
WinSetTransColor(" 200", MyGui) ; 半透明:
WinSetExStyle("+0x20", MyGui) ;鼠标穿透
MyGui.Show("x" xPosition " y0 h30 w" bannerWidth " NoActivate") ; NoActivate 让当前活动窗口继续保持活动状态.

logger.Start ;启动计时

;定义托盘图标
A_TrayMenu.Rename("E&xit","退出")
A_TrayMenu.Delete("&Suspend Hotkeys")
A_TrayMenu.Delete("&Pause Script")
A_TrayMenu.Insert("1&", "久坐30分钟提醒", MenuHandler)
Persistent
;久坐30分钟提醒函数
MenuHandler(ItemName, ItemPos, MyMenu) {
    logger.sitTime:=0
    if(logger.tomatoToggle){
        logger.tomatoToggle:=0
        A_TrayMenu.Uncheck("1&")
    }else{
        logger.tomatoToggle:=1
        A_TrayMenu.Check("1&")
    }
}

class StateLog {
    __New(){
        this.WorkTime :=0
        this.BreakTime :=0
        this.WorkIn :=0
        this.sitTime :=0
        this.alarmWave:=6
        this.tomatoToggle:=0
        this.check :=ObjBindMethod(this, "StateCheck")
        this.tmtAlarm :=ObjBindMethod(this, "TomatoAlarm")
    }
    Start() {
        SetTimer this.check, 1000
    }
    StateCheck() {
        if(ifwinAct() and A_TimeIdlePhysical<30000){
            this.WorkTime++
            this.sitTime++
            if !(this.WorkIn = 1){
                this.WorkIn :=1
                MyGui.BackColor := "000000"
                CoordText.SetFont("cffffff")
            }
            CoordText.Value := FormatSeconds(this.WorkTime)
        }else{
            this.BreakTime++
            if !(this.WorkIn = 0){
                this.WorkIn :=0
                MyGui.BackColor := "ffffff"
                CoordText.SetFont("c000000")
            }
            CoordText.Value := FormatSeconds(this.BreakTime)
            ;关于番茄钟部分的内容↓原理是根据非离开时间累计达到1800秒（30分钟）时抖动提醒
            if(A_TimeIdlePhysical>=30000){
                this.sitTime:=0
            }else{
                this.sitTime++
            }
        }
        if(Mod(this.sitTime,5)=0 and this.sitTime>0 and this.tomatoToggle=1){
            this.WorkIn :=3
            MyGui.BackColor := "ea4135"
            CoordText.SetFont("cffffff")
            CoordText.Value := "坐太久了"
            SetTimer this.tmtAlarm, 40
        }
    }
    TomatoAlarm(){
        Switch Mod(this.alarmWave, 2){
        Case 1:
            MyGui.Move(xPosition-this.alarmWave)
        Case 0:
            MyGui.Move(xPosition+this.alarmWave)
        }
        this.alarmWave--
        if(this.alarmWave=0){
            this.alarmWave:=6
            SetTimer , 0
        }
    }
}

ifwinAct(){
    Loop winArr.Length{
        if(WinActive(winArr[A_Index])){
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