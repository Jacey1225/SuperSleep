import os
import mysql.connector
from mysql.connector import Error
import logging

logger = logging.getLogger(__name__)

CONFIG = {
    "host": os.environ.get('MYSQL_HOST', 'localhost'),
    "user": os.environ.get('MYSQL_USER', 'jaceysimpson'),
    "password": os.environ.get('MYSQL_PASSWORD', 'WeLoveDoggies16!'),
    "database": os.environ.get('MYSQL_DATABASE', 'sleepRecords'),
    "port": int(os.environ.get('MYSQL_PORT', 3306))  # Ensure port is included and cast to int
}

class DBConnection:
    def __init__(self, table, db_config=CONFIG):
        self.db_config = db_config
        logger.info(f"Database configuration: {self.db_config}")

        self.table = table
        try:
            self.connection = mysql.connector.connect(**self.db_config)

            logger.info(f"Connected to MySQL database: {self.db_config['database']} at {self.db_config['host']}:{self.db_config['port']} for table {self.table}")
            if self.connection.is_connected():
                self.cursor = self.connection.cursor()
        except Error as e:
            logger.error("Error while connecting to MySQL", e)
            raise
    
    def close(self):
        """
        Closes the database connection and cursor if the connection is active.

        This method checks if the database connection is currently active. If so, 
        it closes the cursor and the connection, and logs a message indicating 
        that the MySQL connection has been closed.
        """
        if self.connection.is_connected():
            self.cursor.close()
            self.connection.close()
    
    def open(self):
        """
        Opens a connection to the MySQL database if it is not already connected.

        This method checks the current connection status and attempts to establish
        a connection to the database using the provided configuration. If the connection
        is successful, it initializes the cursor for executing queries. Logs an error
        message if the connection fails.

        Raises:
            mysql.connector.Error: If an error occurs while connecting to the database.
        """
        try:
            self.connection = mysql.connector.connect(**self.db_config)
            self.cursor = self.connection.cursor()
        except Error as e:
            logger.error("Error while connecting to MySQL", e)

    def select_items(self, select_value, where_values, values=None, fetchAmount=1):
        self.open()

        limit_clause = f"LIMIT {fetchAmount}" if fetchAmount else ""
        if (
            not isinstance(select_value, str) or 
            not isinstance(where_values, list) or 
            not isinstance(values, list)
        ):
            raise ValueError("Invalid input types.")

        wheres = " AND ".join(f"{where} = %s" for where in where_values)
        try:
            # Pass the correct arguments to find (list, list)
            select_query = f"""
                SELECT {select_value} 
                FROM {self.table}
                WHERE {wheres}
                {limit_clause}"""
            query_values = values

            self.cursor.execute(select_query, query_values)
            rows = self.cursor.fetchall()
            self.close()
            return rows
        except Error as e:
            logger.error(f"Error selecting items: {e}")
            logger.error(f"Select query: {select_query}")
            self.close()
            return []

    def insert_items(self, where_values, values):
        """Inserts a new record into the 'behaviors' table in the database.

        Args:
            values (list): A list containing four elements:
                - userID (str): The ID of the user.
                - day (str): The day associated with the behavior.
                - currentPattern (str): The current pattern of behavior.
                - history (str): The history of behaviors.

        Raises:
            ValueError: If the input 'values' is not a list.
            Error: If there is an issue executing the database query, logs the error and rolls back the transaction.

        Notes:
            - This method assumes that the database connection and cursor are already initialized.
            - The method uses parameterized queries to prevent SQL injection."""
        self.open()

        if (not isinstance(values, list)):
            raise ValueError("Invalid input types. Expected strings for user_id, day, currentPattern, and history.")
        try:
            columns = ", ".join(where_values)
            placeholders = ", ".join(["%s"] * len(values))
            insert_query = f"""
            INSERT IGNORE INTO {self.table}
            ({columns})
            VALUES ({placeholders});
            """

            logger.info(f"Insert query: {insert_query} with values: {values}")
            self.cursor.execute(insert_query, values)
            self.connection.commit()
        except Error as e:
            logger.error(f"Error inserting items: {e}")
            self.connection.rollback()
        
        self.close()

    def update_items(self, values_to_update, where_values, values):
        """Updates a specific field in the 'behaviors' table based on given conditions.

        Args:
            value_to_update (str): The column name to update.
            where_values (list): A list containing two column names to use in the WHERE clause.
            values (list): A list containing three values - the new value for the column to update 
                           and the two values to match in the WHERE clause.

        Raises:
            ValueError: If the input types are not as expected.
            Error: If an error occurs during the database operation.

        Notes:
            - The method constructs an SQL query dynamically using the provided column names and values.
            - It ensures the database changes are committed if the operation is successful.
            - In case of an error, the transaction is rolled back and the error is logged."""
        self.open()

        if (
            not isinstance(values_to_update, list) or 
            not isinstance(where_values, list) or 
            not isinstance(values, list)
        ):
            raise ValueError("Invalid input types. Expected strings for user_id, value_to_update, where_value, and new_value.")
        sets = ", ".join(f"{value} = %s" for value in values_to_update)
        wheres = " AND ".join(f"{where} = %s" for where in where_values)
        try:
            update_query = f"""
            UPDATE {self.table}
            SET {sets}
            WHERE {wheres};
            """
            self.cursor.execute(update_query, (values))
            self.connection.commit()
        except Error as e:
            logger.error(f"Error updating items: {e}")
            self.connection.rollback()
        
        self.close()

    def delete_items(self, where_values, values):
        """
        Deletes records from the table based on the specified conditions.

        Args:
            where_values (list): List of column names to use in the WHERE clause.
            values (list): List of values corresponding to the columns in where_values.

        Raises:
            ValueError: If input types are not as expected.
            Error: If an error occurs during the database operation.
        """
        self.open()

        if not isinstance(where_values, list) or not isinstance(values, list):
            raise ValueError("Invalid input types. Expected lists for where_values and values.")

        wheres = " AND ".join(f"{col} = %s" for col in where_values)
        try:
            delete_query = f"DELETE FROM {self.table} WHERE {wheres};"
            logger.info(f"Delete query: {delete_query} with values: {values}")
            self.cursor.execute(delete_query, values)
            self.connection.commit()
        except Error as e:
            logger.error(f"Error deleting items: {e}")
            self.connection.rollback()
        self.close()

    