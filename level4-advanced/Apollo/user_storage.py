import json
import os

class UserFileStorage:
    def __init__(self, users_file="users.json", files_file="file_ownership.json"):
        self.users_file = users_file
        self.files_file = files_file
        self.users = self._load_users()
        self.file_ownership = self._load_files()
    
    def _load_users(self):
        """Load users from file"""
        if os.path.exists(self.users_file):
            with open(self.users_file, 'r') as f:
                return json.load(f)
        return {}
    
    def _save_users(self):
        """Save users to file"""
        with open(self.users_file, 'w') as f:
            json.dump(self.users, f, indent=2)
    
    def _load_files(self):
        """Load file ownership data"""
        if os.path.exists(self.files_file):
            with open(self.files_file, 'r') as f:
                return json.load(f)
        return {}
    
    def _save_files(self):
        """Save file ownership data"""
        with open(self.files_file, 'w') as f:
            json.dump(self.file_ownership, f, indent=2)
    
    # USER MANAGEMENT
    def add_user(self, username, password):
        """Add a new user"""
        if username in self.users:
            print(f"User '{username}' already exists.")
            return False
        
        self.users[username] = {"password": password}
        self._save_users()
        print(f"✓ Added new user: {username}")
        return True
    
    def verify_user(self, username, password):
        """Verify user credentials"""
        if username not in self.users:
            return False
        return self.users[username]["password"] == password
    
    def user_exists(self, username):
        """Check if user exists"""
        return username in self.users
    
    # FILE OWNERSHIP MANAGEMENT
    def register_file(self, filename, owner_username):
        """Register a file to a specific user"""
        if not self.user_exists(owner_username):
            print(f"Error: User {owner_username} does not exist!")
            return False
        
        self.file_ownership[filename] = {
            "owner": owner_username,
            "encrypted": False
        }
        self._save_files()
        print(f"✓ File '{filename}' registered to user '{owner_username}'")
        return True
    
    def set_file_encrypted(self, filename, encrypted=True):
        """Mark a file as encrypted or decrypted"""
        if filename in self.file_ownership:
            self.file_ownership[filename]["encrypted"] = encrypted
            self._save_files()
            return True
        return False
    
    def get_file_owner(self, filename):
        """Get the owner of a file"""
        if filename in self.file_ownership:
            return self.file_ownership[filename]["owner"]
        return None
    
    def is_file_encrypted(self, filename):
        """Check if file is encrypted"""
        if filename in self.file_ownership:
            return self.file_ownership[filename]["encrypted"]
        return False
    
    def user_owns_file(self, username, filename):
        """Check if a user owns a specific file"""
        if filename not in self.file_ownership:
            return False
        return self.file_ownership[filename]["owner"] == username
    
    def get_user_files(self, username):
        """Get all files owned by a user"""
        user_files = []
        for filename, data in self.file_ownership.items():
            if data["owner"] == username:
                user_files.append({
                    "filename": filename,
                    "encrypted": data["encrypted"]
                })
        return user_files
    
    def unregister_file(self, filename):
        """Remove a file from the ownership system"""
        if filename in self.file_ownership:
            del self.file_ownership[filename]
            self._save_files()
            return True
        return False
    
    