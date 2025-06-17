from use_DB import DBConnection

class Settings:
    def __init__(self, username):
        self.username = username
        self.db = DBConnection(tblae="sleepMembers")

        select_values = [""]


    