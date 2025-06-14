import random 
import string
from use_DB import DBConnection

class CreateGroup:
    def __init__(self, username):
        self.username = username
        self.db = DBConnection(table='sleepMembers')

    def create_group(self):
        group_id = ''.join(random.choices(string.ascii_letters + string.digits, k=8))
        
        values_to_update = ["group_id"]
        where_values = ["username"]
        values = [group_id, self.username]

        try:
            self.db.update_items(where_values, values_to_update, values)
            print(f"Group created successfully with ID: {group_id}")
        except Exception as e:
            print(f"Error creating group: {e}")
    
    def invite_to_group(self, invite_user):
        values_to_update = ["group_id"]
        where_values = ["username"]
        values = [self.username, invite_user]
        try:
            self.db.update_items(where_values, values_to_update, values)
            print(f"User {invite_user} invited to group {self.username}'s group.")
        except Exception as e:
            print(f"Error inviting user to group: {e}")

    def get_group_info(self, group_id):
        select_value = ["username", "sleep_quality"]
        where_values = ["group_id"]
        values = [group_id]
        try:
            members = self.db.select_items(select_value, where_values, values, fetchAmount=None)[0]
            print(f"Group members for group {group_id}: {members}")
        except Exception as e:
            print(f"Error retrieving group members: {e}")
            return None
        
        return members

    def leaderboard(self, group_stats):
        sorted_stats = sorted(group_stats, key=lambda x: x[1], reverse=True)
        leaderboard = {member[0]: member[1] for member in sorted_stats}
        print("Leaderboard:")
        for member, score in leaderboard.items():
            print(f"{member}: {score}")
        return leaderboard
    
    def leave_group(self, username):
        values_to_update = ["group_id"]
        where_values = ["username"]
        values = [None, username]

        try:
            self.db.update_items(values_to_update, where_values, values)
            print(f"User {username} has left the group.")
        except Exception as e:
            print(f"Error leaving group: {e}")
    
    