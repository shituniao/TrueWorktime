#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

WorkTime=0
WorkIn=0
bannerWidth=100
xPosition := A_ScreenWidth - bannerWidth - 137
CustomColor := "ff0000" ; 可以为任意 RGB 颜色(在下面会被设置为透明).
Gui +LastFound +AlwaysOnTop -Caption +ToolWindow ; +ToolWindow 避免显示任务栏按钮和 alt-tab 菜单项.
Gui, Color, %CustomColor%
Gui, Font, s12, Microsoft YaHei UI ; 设置字体 (16 磅).
Gui, Add, Text, x0 y4 h30 w%bannerWidth% vFormatText c000000 +Center,; XX & YY 用来自动调整窗口大小.
GuiControl, , FormatText , 没在工作...
SetTimer, Conter, 1000
; 让此颜色的所有像素透明且让文本显示为半透明 (150):
WinSet, TransColor, Off
WinSet, TransColor, CustomColor 200
Winset, ExStyle, +0x20 ;窗口鼠标穿透
Gui, Show, x%xposition% y0 h30 w%bannerWidth% NoActivate ; NoActivate 让当前活动窗口继续保持活动状态.

Loop {
    WinWaitActive, ahk_exe HarmonyPremium.exe ;检测是否切换在工作程序
    WorkIn=1

    WinWaitNotActive, ahk_exe HarmonyPremium.exe
    WorkIn=0

}

return

Conter:
    if(WorkIn=1 and A_TimeIdlePhysical<5000){
        WorkTime++
        CustomColor := "ffffff"
        Gui, Color, %CustomColor%
        GuiControl, , FormatText , % FormatSeconds(WorkTime)
    }else{
        CustomColor := "ff0000"
        Gui, Color, %CustomColor%
        GuiControl, , FormatText , 没在工作...
    }

return

FormatSeconds(NumberOfSeconds) ; Convert the specified number of seconds to hh:mm:ss format.
{
    time = 19990101 ; *Midnight* of an arbitrary date.
    if NumberOfSeconds < 0
        NumberOfSeconds := -NumberOfSeconds
    time += %NumberOfSeconds%, seconds
    FormatTime, mmss, %time%, mm:ss
    ;return NumberOfSeconds//3600 ":" mmss  ; This method is used to support more than 24 hours worth of sections.
return mmss ; This method is used to support more than 24 hours worth of sections.
}