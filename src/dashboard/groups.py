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
            self.db.update_items(values_to_update, where_values, values)
            logger.info(f"{self.username} created group successfully with ID: {group_id}")
        except Exception as e:
            logger.info(f"Error creating group: {e}")
    
    def join_group(self, group_id):
        values_to_update = ["group_id"]
        where_values = ["username"]
        values = [group_id, self.username]

        try:
            self.db.update_items(values_to_update, where_values, values)
            logger.info(f"User {self.username} has joined group {group_id}.")
        except Exception as e:
            logger.info(f"Error joining group: {e}")

    # Helper -> get_group_info
    def isolate_users(self, members):
        unfiltered_group = members
        group = []
        for member in unfiltered_group:
            username = member[1]
            if username not in group:
                group.append(member)
        logger.info(f"Isolated group members: {group}")
        return group

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
        
        members = self.isolate_users(members)
        return members

    def leaderboard(self, group_stats):
        stats = []
        for row in group_stats:
            username = row[1]
            sleep_quality = row[7]
            stats.append((username, int(sleep_quality * 10)))
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