import random 
import string
from use_DB import DBConnection
import logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class CreateGroup:
    def __init__(self, username=None):
        self.username = username
        self.db = DBConnection(table='sleepMembers')

    def create_group(self):
        group_id = ''.join(random.choices(string.ascii_letters + string.digits, k=8))
        
        values_to_update = ["group_id"]
        where_values = ["username"]
        values = [group_id, self.username]

        try:
            self.db.update_items(where_values, values_to_update, values)
            logger.info(f"Group created successfully with ID: {group_id}")
        except Exception as e:
            logger.info(f"Error creating group: {e}")
    
    def invite_to_group(self, invite_user):
        values_to_update = ["group_id"]
        where_values = ["username"]
        values = [self.username, invite_user]
        try:
            self.db.update_items(where_values, values_to_update, values)
            logger.info(f"User {invite_user} invited to group {self.username}'s group.")
        except Exception as e:
            logger.info(f"Error inviting user to group: {e}")

    def get_group_info(self, group_id):
        select_value = "*"
        where_values = ["group_id"]
        values = [group_id]
        try:
            members = self.db.select_items(select_value, where_values, values, fetchAmount=None)
            logger.info(f"Group members for group {group_id}: {members}")
        except Exception as e:
            logger.info(f"Error retrieving group members: {e}")
            return None
        
        return members

    def leaderboard(self, group_stats):
        stats = []
        for row in group_stats:
            username = row[1]
            sleep_quality = row[7]
            stats.append((username, sleep_quality))
        sorted_stats = sorted(stats, key=lambda x: x[1], reverse=True)

        return sorted_stats
    
    def leave_group(self, username):
        values_to_update = ["group_id"]
        where_values = ["username"]
        values = [None, username]

        try:
            self.db.update_items(values_to_update, where_values, values)
            logger.info(f"User {username} has left the group.")
        except Exception as e:
            logger.info(f"Error leaving group: {e}")
    
# PYTHONPATH=. pytest --log-cli-level=INFO tests/test_group_functions.py