import json
import os

class UserStorage:
    def __init__(self, filename="users.json"):
        self.filename = filename
        self.users = self._load()
    
    def _load(self):
        if os.path.exists(self.filename):
            with open(self.filename, 'r') as f:
                return json.load(f)
        return {}
    
    def _save(self):
        with open(self.filename, 'w') as f:
            json.dump(self.users, f, indent=2)
    
    def verify_user(self, username, password):
        if username not in self.users:
            return False
        return self.users[username]["password"] == password
    
    def user_exists(self, username):
        return username in self.users
    
    def add_user(self, username, password):
        if username in self.users:
            print(f"User '{username}' already exists. Updating password.")
        else:
            print(f"Added new user: {username}")
        
        self.users[username] = {"password": password}
        self._save()