import wx


class BootMenu(wx.Frame):
    def __init__(self):
        super().__init__(None, title="Boot Menu", size=(500, 300))
        panel = wx.Panel(self)
        panel.SetBackgroundColour("black")

        title = wx.StaticText(panel, label="GRUB-like Boot Selector")
        title.SetForegroundColour("white")
        title.SetFont(
            wx.Font(14, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_BOLD)
        )

        options = ["Windows 11", "Ubuntu 24.04", "Fedora 41", "Advanced options"]
        self.listbox = wx.ListBox(panel, choices=options, style=wx.LB_SINGLE)
        self.listbox.SetSelection(0)
        self.listbox.SetBackgroundColour("black")
        self.listbox.SetForegroundColour(wx.Colour(200, 255, 200))
        self.listbox.SetFont(
            wx.Font(12, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
        )

        info = wx.StaticText(panel, label="Use ? and ? to choose an OS, press Enter to boot")
        info.SetForegroundColour(wx.Colour(180, 180, 180))
        info.SetFont(
            wx.Font(10, wx.FONTFAMILY_MODERN, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
        )

        sizer = wx.BoxSizer(wx.VERTICAL)
        sizer.Add(title, 0, wx.ALL | wx.ALIGN_CENTER_HORIZONTAL, 15)
        sizer.Add(self.listbox, 1, wx.LEFT | wx.RIGHT | wx.EXPAND, 40)
        sizer.Add(info, 0, wx.ALL | wx.ALIGN_CENTER_HORIZONTAL, 15)
        panel.SetSizer(sizer)

        self.Bind(wx.EVT_CHAR_HOOK, self.on_key)

    def on_key(self, event):
        key = event.GetKeyCode()
        index = self.listbox.GetSelection()
        if key == wx.WXK_UP and index > 0:
            self.listbox.SetSelection(index - 1)
        elif key == wx.WXK_DOWN and index < self.listbox.GetCount() - 1:
            self.listbox.SetSelection(index + 1)
        elif key in (wx.WXK_RETURN, wx.WXK_NUMPAD_ENTER):
            choice = self.listbox.GetStringSelection()
            wx.MessageBox(f"Booting {choice} ...", "Boot", wx.OK | wx.ICON_INFORMATION)
        else:
            event.Skip()


if __name__ == "__main__":
    app = wx.App()
    frame = BootMenu()
    frame.Show()
    app.MainLoop()
