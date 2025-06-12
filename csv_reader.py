import csv
import os
from typing import List, Dict, Optional


class CSVReader:
    """Handles reading CSV files from the resources directory"""
   
    def __init__(self, resources_dir: str = "resources"):
        self.resources_dir = resources_dir
   
    def read_csv(self, subject: str) -> List[Dict[str, str]]:
        """
        Read CSV file for a given subject
       
        Args:
            subject: Subject name (e.g., 'ancient_history', 'economics', 'mathematics', 'physics')
           
        Returns:
            List of dictionaries containing question data
        """
        file_path = os.path.join(self.resources_dir, f"{subject}.csv")
       
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"CSV file not found: {file_path}")
       
        questions = []
       
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                reader = csv.DictReader(file)
                for row in reader:
                    questions.append({
                        'question_number': row['Question Number'],
                        'question': row['Question'],
                        'option_a': row['Option A'],
                        'option_b': row['Option B'],
                        'option_c': row['Option C'],
                        'option_d': row['Option D'],
                        'answer': row['Answer']
                    })
        except Exception as e:
            raise Exception(f"Error reading CSV file {file_path}: {str(e)}")
       
        return questions
   
    def get_available_subjects(self) -> List[str]:
        """
        Get list of available subjects from the resources directory
       
        Returns:
            List of subject names
        """
        if not os.path.exists(self.resources_dir):
            return []
       
        subjects = []
        for file in os.listdir(self.resources_dir):
            if file.endswith('.csv'):
                subject_name = file[:-4]  # Remove .csv extension
                subjects.append(subject_name)
       
        return subjects
   
    def validate_csv_structure(self, subject: str) -> bool:
        """
        Validate if CSV has the required columns
       
        Args:
            subject: Subject name
           
        Returns:
            True if valid structure, False otherwise
        """
        required_columns = [
            'Question Number', 'Question', 'Option A', 'Option B',
            'Option C', 'Option D', 'Answer'
        ]
       
        file_path = os.path.join(self.resources_dir, f"{subject}.csv")
       
        if not os.path.exists(file_path):
            return False
       
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                reader = csv.DictReader(file)
                csv_columns = reader.fieldnames or []
               
                for col in required_columns:
                    if col not in csv_columns:
                        return False
               
                return True
        except Exception:
            return False
