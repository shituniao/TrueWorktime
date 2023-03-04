#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

WorkTime=0
BreakTime=0
WorkIn=0
bannerWidth=100
xPosition := A_ScreenWidth - bannerWidth - 137
CustomColor := "000000" ; 初始文字颜色
Gui +LastFound +AlwaysOnTop -Caption +ToolWindow ; +ToolWindow 避免显示任务栏按钮和 alt-tab 菜单项.
Gui, Color, %CustomColor%
Gui, Font, s12 cffffff, Microsoft YaHei UI ; 设置字体.
Gui, Add, Text, x0 y4 h30 w%bannerWidth% +Center vFormatText 
GuiControl, , FormatText , 没在工作...
SetTimer, Conter, 1000
; 让此颜色的所有像素透明且让文本显示为半透明 (150):
WinSet, TransColor, Off
WinSet, TransColor, CustomColor 200
Winset, ExStyle, +0x20 ;窗口鼠标穿透
Gui, Show, x%xposition% y0 h30 w%bannerWidth% NoActivate ; NoActivate 让当前活动窗口继续保持活动状态.

Loop {
    WinWaitActive, ahk_exe HarmonyPremium.exe ;检测是否切换在工作程序
    CustomColor := "ffffff"
    Gui, Color, %CustomColor%
    Gui, Font, c000000
    GuiControl, font, FormatText
    GuiControl, , FormatText , % FormatSeconds(WorkTime)
    WorkIn=1

    WinWaitNotActive, ahk_exe HarmonyPremium.exe
    Gui, Font, cffffff
    GuiControl, font, FormatText
    CustomColor := "000000"
    Gui, Color, %CustomColor%
    GuiControl, , FormatText , % FormatSeconds(BreakTime)
    WorkIn=0
}

return

Conter:
    if(WorkIn=1 and A_TimeIdlePhysical<5000){
        WorkTime++
        GuiControl, , FormatText , % FormatSeconds(WorkTime)
    }else{
        BreakTime++
        Gui, Font, cffffff
        GuiControl, font, FormatText
        CustomColor := "000000"
        Gui, Color, %CustomColor%
        GuiControl, , FormatText , % FormatSeconds(BreakTime)
    }

return

FormatSeconds(NumberOfSeconds) ; Convert the specified number of seconds to hh:mm:ss format.
{
    time = 19990101 ; *Midnight* of an arbitrary date.
    if NumberOfSeconds < 0
        NumberOfSeconds := -NumberOfSeconds
    time += %NumberOfSeconds%, seconds
    FormatTime, hhmmss, %time%, HH:mm:ss
return hhmmss ; This method is used to support more than 24 hours worth of sections.
}