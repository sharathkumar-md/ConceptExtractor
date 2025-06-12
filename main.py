import argparse
import csv
import os
import sys
from typing import List, Dict


from csv_reader import CSVReader
from llm_api import ConceptExtractor


class QuestionAnalyzer:
    """Main class for analyzing exam questions and extracting concepts"""
   
    def __init__(self, resources_dir: str = "resources"):
        self.csv_reader = CSVReader(resources_dir)
        self.concept_extractor = ConceptExtractor()
        self.output_file = "output_concepts.csv"
   
    def analyze_subject(self, subject: str, method: str = "simulation") -> List[Dict]:
        """
        Analyze all questions for a given subject
       
        Args:
            subject: Subject name (e.g., 'ancient_history')
            method: Extraction method ('simulation', 'rule_based', or 'api')
           
        Returns:
            List of dictionaries with question analysis results
        """
        print(f"Analyzing {subject}...")
       
        # Validates CSV structure
        if not self.csv_reader.validate_csv_structure(subject):
            raise ValueError(f"Invalid CSV structure for subject: {subject}")
       
        # Reads questions
        questions = self.csv_reader.read_csv(subject)
       
        if not questions:
            print(f"No questions found for subject: {subject}")
            return []
       
        results = []
       
        for question_data in questions:
            question_text = question_data['question']
            question_number = question_data['question_number']
           
            # Extract concepts
            concepts = self.concept_extractor.extract_concepts(question_text, method)
           
            # Format concepts as semicolon-separated string
            concepts_str = "; ".join(concepts) if concepts else "General Knowledge"
           
            result = {
                'question_number': question_number,
                'question': question_text,
                'concepts': concepts_str,
                'concepts_list': concepts  # Keep list for internal use
            }
           
            results.append(result)
           
            # Print to console
            print(f"Question {question_number}: {concepts_str}")
       
        return results
   
    def save_results_to_csv(self, results: List[Dict], subject: str, method: str = "simulation") -> None:
        """
        Save analysis results to CSV file
       
        Args:
            results: Analysis results
            subject: Subject name
            method: Extraction method used
        """
        output_filename = f"output_concepts_{subject}_{method}.csv"
       
        with open(output_filename, 'w', newline='', encoding='utf-8') as csvfile:
            fieldnames = ['Question Number', 'Question', 'Concepts']
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
           
            writer.writeheader()
            for result in results:
                writer.writerow({
                    'Question Number': result['question_number'],
                    'Question': result['question'],
                    'Concepts': result['concepts']
                })
       
        print(f"\nResults saved to: {output_filename}")
   
    def generate_summary_report(self, results: List[Dict], subject: str, method: str = "simulation") -> None:
        """
        Generate a summary report of concept distribution
       
        Args:
            results: Analysis results
            subject: Subject name
            method: Extraction method used
        """
        print(f"\n=== Summary Report for {subject.upper()} ({method.upper()} METHOD) ===")
       
        # Count concept frequency
        concept_count = {}
        for result in results:
            for concept in result['concepts_list']:
                concept_count[concept] = concept_count.get(concept, 0) + 1
       
        # Sort by frequency
        sorted_concepts = sorted(concept_count.items(), key=lambda x: x[1], reverse=True)
       
        print(f"Total Questions Analyzed: {len(results)}")
        print(f"Unique Concepts Identified: {len(concept_count)}")
        print(f"Extraction Method: {method}")
        print("\nConcept Distribution:")
        print("-" * 50)
       
        for concept, count in sorted_concepts:
            percentage = (count / len(results)) * 100
            print(f"{concept:.<40} {count:>3} ({percentage:>5.1f}%)")
   
    def list_available_subjects(self) -> None:
        """List all available subjects"""
        subjects = self.csv_reader.get_available_subjects()
       
        if not subjects:
            print("No CSV files found in resources directory.")
            return
       
        print("Available subjects:")
        for subject in subjects:
            print(f"  - {subject}")
   
    def compare_methods(self, subject: str) -> None:
        """
        Compare results from different extraction methods for a subject
        
        Args:
            subject: Subject name
        """
        methods = ['simulation', 'rule_based']
        print(f"\n=== COMPARING EXTRACTION METHODS FOR {subject.upper()} ===")
        
        method_results = {}
        
        for method in methods:
            try:
                print(f"\n--- Running {method.upper()} method ---")
                results = self.analyze_subject(subject, method)
                if results:
                    self.save_results_to_csv(results, subject, method)
                    method_results[method] = results
                    
                    # Quick summary
                    concept_count = {}
                    for result in results:
                        for concept in result['concepts_list']:
                            concept_count[concept] = concept_count.get(concept, 0) + 1
                    
                    print(f"{method.upper()}: {len(concept_count)} unique concepts identified")
                    
            except Exception as e:
                print(f"Error with {method} method: {e}")
        
        # Generate comparison summary
        if len(method_results) > 1:
            print(f"\n=== METHOD COMPARISON SUMMARY ===")
            for method, results in method_results.items():
                concept_count = {}
                for result in results:
                    for concept in result['concepts_list']:
                        concept_count[concept] = concept_count.get(concept, 0) + 1
                print(f"{method.upper()}: {len(concept_count)} unique concepts")




def main():
    """Main function with CLI interface"""
    parser = argparse.ArgumentParser(
        description="Analyze competitive exam questions and extract concepts",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python main.py --subject=ancient_history
  python main.py --subject=economics --method=rule_based
  python main.py --subject=mathematics --method=api --use-api
  python main.py --subject=ancient_history --compare-methods
  python main.py --list-subjects
  python main.py --test-api
        """
    )
   
    parser.add_argument(
        '--subject',
        type=str,
        help='Subject to analyze (e.g., ancient_history, economics, mathematics, physics)'
    )
   
    parser.add_argument(
        '--method',
        type=str,
        choices=['simulation', 'rule_based', 'api'],
        default='simulation',
        help='Concept extraction method (default: simulation)'
    )
   
    parser.add_argument(
        '--compare-methods',
        action='store_true',
        help='Compare results from different extraction methods for the same subject'
    )
   
    parser.add_argument(
        '--list-subjects',
        action='store_true',
        help='List all available subjects'
    )
   
    parser.add_argument(
        '--resources-dir',
        type=str,
        default='resources',
        help='Directory containing CSV files (default: resources)'
    )
   
    parser.add_argument(
        '--test-api',
        action='store_true',
        help='Test API connection and exit'
    )
   
    parser.add_argument(
        '--use-api',
        action='store_true',
        help='Enable API usage (requires valid API key in .env file)'
    )
   
    args = parser.parse_args()
   
    # Initialize analyzer
    try:
        analyzer = QuestionAnalyzer(args.resources_dir)
       
        # Enable API usage if requested or when API method is selected
        if args.use_api or args.method == "api":
            analyzer.concept_extractor.use_api = True
           
    except Exception as e:
        print(f"Error initializing analyzer: {e}")
        sys.exit(1)
   
    # Handle API test command
    if args.test_api:
        print("Testing API connection...")
        extractor = ConceptExtractor(use_api=True)
       
        if extractor.test_api_connection():
            print("API connection successful!")
            print(f"Available models: {extractor.get_available_models()}")
           
            # Test concept extraction
            test_question = "Which of the following was a feature of the Harappan civilization?"
            print(f"\nTesting concept extraction with question: {test_question}")
            concepts = extractor.extract_concepts(test_question, method="api")
            print(f"Extracted concepts: {concepts}")
           
        else:
            print("API connection failed!")
            print("Please check your API key in the .env file")
        return
   
    # Handle list subjects command
    if args.list_subjects:
        analyzer.list_available_subjects()
        return
   
    # Validate subject argument for analysis commands
    if not args.subject and (not args.list_subjects and not args.test_api):
        print("Error: --subject argument is required (or use --list-subjects)")
        parser.print_help()
        sys.exit(1)
   
    # Check if subject exists (only if subject is provided)
    if args.subject:
        available_subjects = analyzer.csv_reader.get_available_subjects()
        if args.subject not in available_subjects:
            print(f"Error: Subject '{args.subject}' not found.")
            print("Available subjects:")
            for subject in available_subjects:
                print(f"  - {subject}")
            sys.exit(1)
   
    # Handle compare methods command
    if args.compare_methods:
        if not args.subject:
            print("Error: --subject is required when using --compare-methods")
            sys.exit(1)
        
        try:
            analyzer.compare_methods(args.subject)
            print(f"\nMethod comparison completed successfully!")
        except Exception as e:
            print(f"Error during method comparison: {e}")
            sys.exit(1)
        return
   
    # Analyze subject with single method
    if args.subject:
        try:
            print(f"Starting analysis for subject: {args.subject}")
            print(f"Using method: {args.method}")
            print("-" * 60)
           
            results = analyzer.analyze_subject(args.subject, args.method)
           
            if results:
                # Save results to CSV with method name
                analyzer.save_results_to_csv(results, args.subject, args.method)
               
                # Generate summary report with method name
                analyzer.generate_summary_report(results, args.subject, args.method)
           
            print(f"\nAnalysis completed successfully!")
           
        except Exception as e:
            print(f"Error during analysis: {e}")
            sys.exit(1)



if __name__ == "__main__":
    main()