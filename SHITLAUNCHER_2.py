import json
from pathlib import Path
import wx


DATA_FILE = Path(__file__).with_name("users.json")


def load_user_data():
    if not DATA_FILE.exists():
        return {"users": [], "current": None}

    try:
        raw = json.loads(DATA_FILE.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return {"users": [], "current": None}

    users = raw.get("users")
    if not isinstance(users, list):
        users = []
    users = [u for u in users if isinstance(u, str) and u.strip()]

    current = raw.get("current")
    if current not in users:
        current = users[0] if users else None

    return {"users": users, "current": current}


def save_user_data(users, current):
    payload = {"users": users, "current": current}
    DATA_FILE.write_text(json.dumps(payload, indent=2), encoding="utf-8")


class LauncherFrame(wx.Frame):
    def __init__(self):
        super().__init__(None, title="SHITLAUNCHER", size=(620, 420))
        self.SetMinSize((540, 360))
        self.users_state = load_user_data()
        self.users = self.users_state["users"]
        self.current_user = self.users_state["current"]

        panel = wx.Panel(self)
        panel.SetBackgroundColour(wx.Colour(10, 10, 10))

        main_sizer = wx.BoxSizer(wx.VERTICAL)

        title = wx.StaticText(panel, label="SHITLAUNCHER Control Center")
        title.SetForegroundColour(wx.Colour(220, 220, 220))
        title.SetFont(wx.Font(16, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_BOLD))
        main_sizer.Add(title, 0, wx.TOP | wx.LEFT | wx.RIGHT, 16)

        self.current_label = wx.StaticText(panel, label="Current user: -")
        self.current_label.SetForegroundColour(wx.Colour(180, 220, 200))
        self.current_label.SetFont(wx.Font(12, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL))
        main_sizer.Add(self.current_label, 0, wx.LEFT | wx.RIGHT | wx.TOP, 16)

        user_box = wx.StaticBox(panel, label="User Profiles")
        user_box.SetForegroundColour(wx.Colour(200, 200, 200))
        user_box.SetBackgroundColour(wx.Colour(10, 10, 10))
        user_sizer = wx.StaticBoxSizer(user_box, wx.VERTICAL)

        list_and_buttons = wx.BoxSizer(wx.HORIZONTAL)

        self.user_list = wx.ListBox(panel, style=wx.LB_SINGLE)
        self.user_list.SetBackgroundColour(wx.Colour(0, 0, 0))
        self.user_list.SetForegroundColour(wx.Colour(200, 255, 200))
        self.user_list.SetFont(wx.Font(11, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL))
        list_and_buttons.Add(self.user_list, 1, wx.ALL | wx.EXPAND, 8)

        buttons_col = wx.BoxSizer(wx.VERTICAL)
        btn_height = (36, 36)

        self.set_current_btn = wx.Button(panel, label="Set current", size=btn_height)
        self.rename_btn = wx.Button(panel, label="Rename", size=btn_height)
        self.remove_btn = wx.Button(panel, label="Remove", size=btn_height)

        for btn in (self.set_current_btn, self.rename_btn, self.remove_btn):
            btn.SetBackgroundColour(wx.Colour(30, 30, 30))
            btn.SetForegroundColour(wx.Colour(220, 220, 220))
            buttons_col.Add(btn, 0, wx.ALL | wx.EXPAND, 4)

        list_and_buttons.Add(buttons_col, 0, wx.TOP | wx.BOTTOM | wx.RIGHT, 8)

        user_sizer.Add(list_and_buttons, 1, wx.EXPAND)

        add_row = wx.BoxSizer(wx.HORIZONTAL)
        self.new_user_input = wx.TextCtrl(panel, style=wx.TE_PROCESS_ENTER)
        self.new_user_input.SetBackgroundColour(wx.Colour(20, 20, 20))
        self.new_user_input.SetForegroundColour(wx.Colour(220, 220, 220))
        self.new_user_input.SetHint("New user name")

        self.add_btn = wx.Button(panel, label="Add user")
        self.add_btn.SetBackgroundColour(wx.Colour(40, 40, 40))
        self.add_btn.SetForegroundColour(wx.Colour(220, 220, 220))

        add_row.Add(self.new_user_input, 1, wx.ALL | wx.EXPAND, 4)
        add_row.Add(self.add_btn, 0, wx.ALL, 4)
        user_sizer.Add(add_row, 0, wx.EXPAND | wx.LEFT | wx.RIGHT | wx.BOTTOM, 8)

        main_sizer.Add(user_sizer, 1, wx.LEFT | wx.RIGHT | wx.TOP | wx.EXPAND, 16)

        build_box = wx.StaticBox(panel, label="Build Targets")
        build_box.SetForegroundColour(wx.Colour(200, 200, 200))
        build_box.SetBackgroundColour(wx.Colour(10, 10, 10))
        build_sizer = wx.StaticBoxSizer(build_box, wx.VERTICAL)

        self.build_options = wx.RadioBox(
            panel,
            label="",
            choices=["Windows (.exe)", "Linux (ELF)", "Windows via Wine", "Custom script"],
            majorDimension=2,
            style=wx.RA_SPECIFY_COLS,
        )
        self.build_options.SetSelection(0)
        build_sizer.Add(self.build_options, 0, wx.ALL, 8)

        build_buttons = wx.BoxSizer(wx.HORIZONTAL)
        self.build_btn = wx.Button(panel, label="Build")
        self.build_and_run_btn = wx.Button(panel, label="Build && Run")
        for btn in (self.build_btn, self.build_and_run_btn):
            btn.SetBackgroundColour(wx.Colour(50, 50, 50))
            btn.SetForegroundColour(wx.Colour(220, 220, 220))
            build_buttons.Add(btn, 1, wx.ALL, 4)

        build_sizer.Add(build_buttons, 0, wx.EXPAND | wx.LEFT | wx.RIGHT | wx.BOTTOM, 8)
        main_sizer.Add(build_sizer, 0, wx.LEFT | wx.RIGHT | wx.BOTTOM | wx.EXPAND, 16)

        panel.SetSizer(main_sizer)

        self.bind_events()
        self.refresh_user_list()
        self.update_current_label()

    def bind_events(self):
        self.user_list.Bind(wx.EVT_LISTBOX, self.on_selection_change)
        self.user_list.Bind(wx.EVT_LISTBOX_DCLICK, self.on_list_double_click)
        self.set_current_btn.Bind(wx.EVT_BUTTON, self.on_set_current)
        self.rename_btn.Bind(wx.EVT_BUTTON, self.on_rename_user)
        self.remove_btn.Bind(wx.EVT_BUTTON, self.on_remove_user)
        self.add_btn.Bind(wx.EVT_BUTTON, self.on_add_user)
        self.new_user_input.Bind(wx.EVT_TEXT_ENTER, self.on_add_user)
        self.build_btn.Bind(wx.EVT_BUTTON, self.on_build)
        self.build_and_run_btn.Bind(wx.EVT_BUTTON, self.on_build_and_run)

    def refresh_user_list(self):
        self.user_list.Set(self.users)
        if self.current_user in self.users:
            idx = self.users.index(self.current_user)
            self.user_list.SetSelection(idx)
        else:
            self.user_list.SetSelection(wx.NOT_FOUND)

    def update_current_label(self):
        label = self.current_user or "-"
        self.current_label.SetLabel(f"Current user: {label}")

    def persist_state(self):
        save_user_data(self.users, self.current_user)

    def get_selected_user(self):
        index = self.user_list.GetSelection()
        if index == wx.NOT_FOUND:
            return None
        return self.users[index]

    def on_selection_change(self, event):
        selected = self.get_selected_user()
        if selected:
            self.current_label.SetLabel(f"Current user: {self.current_user or '-'} (selected: {selected})")
        else:
            self.update_current_label()
        event.Skip()

    def on_list_double_click(self, event):
        self.on_set_current(event)

    def on_set_current(self, event):
        selected = self.get_selected_user()
        if not selected:
            wx.MessageBox("Select a user first.", "No selection", wx.OK | wx.ICON_INFORMATION)
            return
        self.current_user = selected
        self.update_current_label()
        self.persist_state()

    def on_add_user(self, event):
        name = self.new_user_input.GetValue().strip()
        if not name:
            wx.MessageBox("Enter a user name.", "Empty name", wx.OK | wx.ICON_INFORMATION)
            return
        if name in self.users:
            wx.MessageBox("This user already exists.", "Duplicate", wx.OK | wx.ICON_WARNING)
            return
        self.users.append(name)
        self.users.sort(key=str.casefold)
        if len(self.users) == 1:
            self.current_user = name
        self.new_user_input.Clear()
        self.refresh_user_list()
        self.update_current_label()
        self.persist_state()

    def on_remove_user(self, event):
        selected = self.get_selected_user()
        if not selected:
            wx.MessageBox("Select a user to remove.", "No selection", wx.OK | wx.ICON_INFORMATION)
            return
        confirm = wx.MessageBox(
            f"Remove user '{selected}'?", "Confirm removal", wx.YES_NO | wx.NO_DEFAULT | wx.ICON_WARNING
        )
        if confirm != wx.YES:
            return
        self.users.remove(selected)
        if self.current_user == selected:
            self.current_user = self.users[0] if self.users else None
        self.refresh_user_list()
        self.update_current_label()
        self.persist_state()

    def on_rename_user(self, event):
        selected = self.get_selected_user()
        if not selected:
            wx.MessageBox("Select a user to rename.", "No selection", wx.OK | wx.ICON_INFORMATION)
            return
        dialog = wx.TextEntryDialog(self, "New name", "Rename user", value=selected)
        if dialog.ShowModal() != wx.ID_OK:
            dialog.Destroy()
            return
        new_name = dialog.GetValue().strip()
        dialog.Destroy()
        if not new_name:
            wx.MessageBox("Name cannot be empty.", "Invalid name", wx.OK | wx.ICON_WARNING)
            return
        if new_name in self.users and new_name != selected:
            wx.MessageBox("Another user already uses this name.", "Duplicate", wx.OK | wx.ICON_WARNING)
            return
        index = self.users.index(selected)
        self.users[index] = new_name
        self.users.sort(key=str.casefold)
        if self.current_user == selected:
            self.current_user = new_name
        self.refresh_user_list()
        self.update_current_label()
        self.persist_state()

    def on_build(self, event):
        self.run_build_action(run=False)

    def on_build_and_run(self, event):
        self.run_build_action(run=True)

    def run_build_action(self, run):
        if not self.current_user:
            wx.MessageBox("Set a current user before building.", "Missing user", wx.OK | wx.ICON_INFORMATION)
            return
        target = self.build_options.GetStringSelection()
        action = "Build && run" if run else "Build"
        wx.MessageBox(
            f"{action} for user '{self.current_user}' using target '{target}'.\n\n"
            "(Hook up your actual build scripts here.)",
            "Action",
            wx.OK | wx.ICON_INFORMATION,
        )


def main():
    app = wx.App()
    frame = LauncherFrame()
    frame.Centre()
    frame.Show()
    app.MainLoop()


if __name__ == "__main__":
    main()