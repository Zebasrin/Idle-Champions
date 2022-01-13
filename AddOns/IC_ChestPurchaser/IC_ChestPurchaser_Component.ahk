GUIFunctions.AddTab("Chests")

global g_InventoryView := new IC_InventoryView_Component()
Gui, ICScriptHub:Tab, Chests
Gui, ICScriptHub:Add, Text, x15 y+15 w350, % "Note: Game needs to be open to read chests into lists."
Gui, ICScriptHub:Add, Text, x15 y+5 w350, % "Only buy or open chests while game is closed. (Yes, this is a hassle.)"
Gui, ICScriptHub:Add, GroupBox, x15 y+15 w425 h150 vGroupBoxChestPurchaseID, Buy Chests: 
Gui, ICScriptHub:Add, ComboBox, xp+15 yp+15 w300 vChestPurchaseComboBoxID
Gui, ICScriptHub:Add, Picture, x+35 h18 w18 vButtonRefreshChestPurchaser, %g_ReloadButton%
Gui, ICScriptHub:Add, Edit, x30 y+15 w75 vChestPurchaseCountID, % "99"
Gui, ICScriptHub:Add, Button, x+15 w75 vButtonChestPurchaserBuyChests, Buy

GuiControlGet, xyVal, Pos, GroupBoxChestPurchaseID
xyValY += 150
Gui, ICScriptHub:Add, GroupBox, x15 y%xyValY% w425 h150 vGroupBoxChestOpenID, Open Chests: 
Gui, ICScriptHub:Add, ComboBox, xp+15 yp+15 w300 vChestOpenComboBoxID
Gui, ICScriptHub:Add, Edit, y+15 w75 vChestOpenCountID, % "99"
Gui, ICScriptHub:Add, Button, x+15 w75 vButtonChestPurchaserOpenChests, Open

buyChestsFunc := Func("IC_ChestPurchaser_Component.BuyChests")
GuiControl, +g, ButtonChestPurchaserBuyChests, % buyChestsFunc
openChestsFunc := Func("IC_ChestPurchaser_Component.OpenChests")
GuiControl, +g, ButtonChestPurchaserOpenChests, % openChestsFunc
chestPurchaserReadChests := Func("IC_ChestPurchaser_Component.ReadChests")
GuiControl, +g, ButtonRefreshChestPurchaser, % chestPurchaserReadChests

IC_ChestPurchaser_Component.ReadChests()


class IC_ChestPurchaser_Component
{
    ReadChests()
    {
        if(WinExist("ahk_exe IdleDragons.exe")) ; only update when the game is open
            g_SF.Memory.OpenProcessReader()
        else
            return
        size := g_SF.Memory.GenericGetValue(g_SF.Memory.CrusadersGameDataSet.CrusadersGameDataSet.ChestDefinesListSize)    
        if(!size)
            return
        loop, %size%
        {
            chestID := g_SF.Memory.GenericGetValue(g_SF.Memory.CrusadersGameDataSet.CrusadersGameDataSet.ChestDefinesList.ID.GetGameObjectFromListValues(A_Index - 1))
            chestName := g_SF.Memory.GenericGetValue(g_SF.Memory.CrusadersGameDataSet.CrusadersGameDataSet.ChestDefinesList.NameSingular.GetGameObjectFromListValues(A_Index - 1))
            comboBoxOptions .= chestID . " " . chestName . "|"
        }
        g_SF.ResetServerCall()
        GuiControl,, ChestOpenComboBoxID, %comboBoxOptions%
        GuiControl,, ChestPurchaseComboBoxID, %comboBoxOptions%
    }

    BuyChests()
    {
        global
        Gui,ICScriptHub:Submit, NoHide
        splitArray := StrSplit(ChestPurchaseComboBoxID, " ",,2)
        chestID := splitArray[1]
        chestName := splitArray[2]
        MsgBox % "Buying " . ChestPurchaseCountID . " of " . chestName . " (ID: " . chestID . ")"
        buyCount := ChestPurchaseCountID
        while(buyCount > 0)
        {
            response := g_ServerCall.CallBuyChests( chestID, buyCount )
            if(!IsObject(response))
            {
                MsgBox % "Failed with response: " . response
                return
            }
            if (!response.okay)
            {
                MsgBox % "Failed because " . response.failure_reason . response.fail_message
                return 
            }
            if(chestID != 152 AND chestID != 153 AND chestID != 219  AND chestID != 311 )
                buyCount -= 100
            else
                buyCount -= 1
        }
        MsgBox % "Done"
    }

    OpenChests()
    {
        global
        Gui,ICScriptHub:Submit, NoHide
        splitArray := StrSplit(ChestOpenComboBoxID, " ",,2)
        chestID := splitArray[1]
        chestName := splitArray[2]
        MsgBox % "Opening " . ChestOpenCountID . " of " . chestName . " (ID: " . chestID . ") Make sure the game is closed before continuing."
        openCount := ChestOpenCountID
        while(openCount > 0)
        {
            response := g_ServerCall.CallOpenChests( chestID, openCount )
            if(!IsObject(response))
            {
                MsgBox % "Failed with response: " . response
                return
            }
            if (!response.success)
            {
                MsgBox % "Failed because " . response.failure_reason . response.fail_message
                return 
            }
            openCount -= 99
        }
        MsgBox % "Done"
    }
}