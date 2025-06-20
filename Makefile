install:
	python3 -m venv venv
	. ./venv/bin/activate && pip install -r requirements.txt && make run

run:
	. ./venv/bin/activate && python main.py --subject=ancient_history

# Makefile for Exam Question Concept Extractor


.PHONY: help venv install test run clean setup


# Default target
help:
    @echo "Available commands:"
    @echo "  setup           - Set up the project (create venv, install dependencies, create .env)"
    @echo "  venv            - Create virtual environment"
    @echo "  install         - Install Python dependencies (creates venv if not exists)"
    @echo "  test            - Run tests on all subjects"
    @echo "  test-api        - Test API connection (requires API key)"
    @echo "  run-ancient     - Run analysis on ancient history"
    @echo "  run-economics   - Run analysis on economics"
    @echo "  run-math        - Run analysis on mathematics"
    @echo "  run-physics     - Run analysis on physics"
    @echo "  run-api-ancient - Run analysis on ancient history using API"
    @echo "  list-subjects   - List all available subjects"
    @echo "  clean           - Clean up generated files"


# Setup project
setup: install
    @echo "Setting up the project..."
    @if [ ! -f .env ]; then \
        echo "Creating .env file from template..."; \
        cp env_template.txt .env; \
        echo "Please edit .env file and add your API keys"; \
    fi


# Create virtual environment
venv:
    @echo "Creating virtual environment..."
    python -m venv venv
    @echo "Virtual environment created. Activate with:"
    @echo "  source venv/bin/activate  (Linux/Mac)"
    @echo "  venv\\Scripts\\activate     (Windows)"


# Install dependencies
install:
    @echo "Installing Python dependencies..."
    @if [ ! -d "venv" ]; then \
        echo "No virtual environment found. Creating one..."; \
        python -m venv venv; \
        echo "Please activate the virtual environment:"; \
        echo "  source venv/bin/activate  (Linux/Mac)"; \
        echo "  venv\\Scripts\\activate     (Windows)"; \
        echo "Then run 'make install' again."; \
    else \
        pip install -r requirements.txt; \
    fi


# Test all subjects
test:
    @echo "Testing all subjects..."
    python main.py --list-subjects
    python main.py --subject=ancient_history --method=simulation
    python main.py --subject=economics --method=rule_based
    python main.py --subject=mathematics --method=simulation
    python main.py --subject=physics --method=rule_based


# Run specific subjects
run-ancient:
    python main.py --subject=ancient_history


run-economics:
    python main.py --subject=economics


run-math:
    python main.py --subject=mathematics


run-physics:
    python main.py --subject=physics


# List available subjects
list-subjects:
    python main.py --list-subjects


# Test API connection
test-api:
    python main.py --test-api


# Run with API method (requires API key)
run-api-ancient:
    python main.py --subject=ancient_history --method=api


# Clean up generated files
clean:
    @echo "Cleaning up generated files..."
    rm -f output_concepts_*.csv
    rm -rf __pycache__/
    rm -rf .pytest_cache/
    find . -name "*.pyc" -delete
    find . -name "*.pyo" -delete

Readme.md

# Exam Question Concept Extractor


A Python program that analyzes competitive exam questions (e.g., UPSC Ancient History) and extracts the underlying concepts being tested. This tool helps understand the conceptual distribution of past questions and aids in curriculum mapping or study analytics.


## Objective


Build a program that:
- Analyzes questions from competitive exams
- Identifies/extracts underlying concepts being tested
- Works across different domains/subjects
- Can be easily integrated with LLM APIs for enhanced concept extraction


## Project Structure


```
examtemp/
├── main.py                 # Entry point, handles CLI and orchestrates analysis
├── llm_api.py              # Handles concept extraction (simulation + API integration ready)
├── csv_reader.py           # Reads CSV from resources/ and returns structured data
├── resources/              # Folder containing subject CSV files
│   ├── ancient_history.csv
│   ├── economics.csv
│   ├── mathematics.csv
│   └── physics.csv
├── env_template.txt        # Template for environment variables
├── requirements.txt        # Python dependencies
├── Makefile               # Run commands
└── README.md              # This file
```


## Quick Start


### 1. Setup Environment


```bash
# Clone or navigate to the project directory
cd examtemp


# Create virtual environment
python -m venv venv


# Activate virtual environment
# On Linux/Mac:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate


# Install dependencies
pip install -r requirements.txt


# Set up environment (optional - only needed for API integration)
cp env_template.txt .env
# Edit .env and add your API keys if you plan to use LLM APIs
```


### 2. Set Up API Key (Optional - for real LLM integration)


```bash
# Copy environment template
cp env_template.txt .env


# Edit .env and add your Groq API key
# Get free API key from: https://console.groq.com/
nano .env
```


### 3. Run Analysis


```bash
# List available subjects
python main.py --list-subjects


# Test API connection (if you have API key)
python main.py --test-api


# Analyze ancient history (using simulation method)
python main.py --subject=ancient_history


# Analyze economics with rule-based method
python main.py --subject=economics --method=rule_based


# Analyze with real API (requires API key)
python main.py --subject=ancient_history --method=api


# Get help
python main.py --help
```


### 4. Using Makefile (Alternative)


```bash
# Create virtual environment
make venv


# Activate virtual environment first
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows


# Setup project (after activating venv)
make setup


# List available subjects  
make list-subjects


# Test API connection
make test-api


# Run analysis on specific subjects
make run-ancient
make run-economics
make run-math
make run-physics


# Run with API method
make run-api-ancient


# Test all subjects
make test
```


## Input Format


CSV files should follow this structure:


```csv
Question Number,Question,Option A,Option B,Option C,Option D,Answer
1,"Which of the following was a feature of the Harappan civilization?",City planning,Iron tools,Vedic rituals,Temple worship,A
```


## Output Format


### Console Output
```
Question 1: Harappan Civilization; Urban Planning
Question 2: Mauryan Empire; Kautilya's Arthashastra
...
```


### CSV Output (`output_concepts_{subject}.csv`)
```csv
Question Number,Question,Concepts
1,"Which of the following was a feature of the Harappan civilization?","Harappan Civilization; Urban Planning"
```


## Methods Available


The program supports three concept extraction methods:


### 1. Simulation Method (`--method=simulation`) - Default
- Simulates LLM responses based on predefined patterns
- Uses examples from the problem statement
- Best for testing and demonstration


### 2. Rule-based Method (`--method=rule_based`)
- Uses predefined keyword dictionaries
- Fast and deterministic
- Good for well-defined domains


### 3. API Method (`--method=api`) - Groq Integration
- **FULLY IMPLEMENTED** - Uses real Groq API calls
- Requires valid API key in `.env` file
- Falls back to simulation if API is unavailable
- Uses Llama 3 8B model by default


## LLM Integration


### Setting Up Groq API


1. **Get API Key**: Sign up at [Groq Console](https://console.groq.com/) and get your free API key
2. **Configure Environment**: Copy `env_template.txt` to `.env` and add your API key:
   ```bash
   GROQ_API_KEY=your_actual_api_key_here
   ```
3. **Install Dependencies**: Make sure Groq library is installed:
   ```bash
   pip install groq
   ```
4. **Test Connection**: Verify your setup:
   ```bash
   python main.py --test-api
   ```


### Prompt Template Used


The program is designed to work with LLM APIs using this prompt template:


```
Given the question: "{question}", identify the historical/subject concept(s) this question is based on.


Please analyze the question and return the key concepts being tested, separated by semicolons.


Question: {question}


Concepts:
```


### Example LLM Prompts and Expected Outputs


#### Example 1: Ancient History
**Prompt:**
```
Given the question: "Consider the following pairs: Historical place – Well-known for
Burzahom: Rock-cut shrines
Chandraketugarh: Terracotta art  
Ganeshwar: Copper artefacts
Which of the pairs given above is/are correctly matched?", identify the historical concept(s) this question is based on.


Please analyze the question and return the key concepts being tested, separated by semicolons.


Question: Consider the following pairs: Historical place – Well-known for
Burzahom: Rock-cut shrines
Chandraketugarh: Terracotta art
Ganeshwar: Copper artefacts
Which of the pairs given above is/are correctly matched?


Concepts:
```


**Expected Output:**
```
Archaeological Site – Artifact Mapping; Material Culture of Chalcolithic & Harappan Sites
```


#### Example 2: Revenue Systems
**Prompt:**
```
Given the question: "In the context of the history of India, consider the following pairs:
Eripatti: Land revenue set aside for village tank
Taniyurs: Villages donated to Brahmins  
Ghatikas: Colleges attached to temples
Which are correct?", identify the historical concept(s) this question is based on.


Concepts:
```


**Expected Output:**
```
Revenue and Land Systems; Temple-based Education; Brahmadeya and Village Institutions
```


#### Example 3: Science History
**Prompt:**
```
Given the question: "With reference to the scientific progress of Ancient India, which of the statements are correct?
1. Surgical instruments were used by 1st century AD
2. Transplant of internal organs in 3rd century AD  
3. Sine of angle known in 5th century
4. Cyclic quadrilateral known in 7th century", identify the historical concept(s) this question is based on.


Concepts:
```


**Expected Output:**
```
History of Indian Science; Chronological Reasoning
```


## Features


- **Multi-subject Support**: Works with Ancient History, Economics, Mathematics, Physics
- **Multiple Extraction Methods**: Simulation, Rule-based, API-ready
- **Extensible Design**: Easy to add new subjects and extraction methods
- **Summary Reports**: Provides concept distribution analysis
- **CSV Export**: Saves results in structured format
- **CLI Interface**: User-friendly command-line interface


## Example Analysis Results


### Ancient History Analysis
```
=== Summary Report for ANCIENT_HISTORY ===
Total Questions Analyzed: 8
Unique Concepts Identified: 12


Concept Distribution:
Archaeological Sites......................... 2 ( 25.0%)
Mauryan Empire.............................. 1 ( 12.5%)
Harappan Civilization....................... 1 ( 12.5%)
Gupta Period................................ 1 ( 12.5%)
...
```


## Extending the System


### Adding New Subjects
1. Create a new CSV file in `resources/` directory
2. Follow the required CSV format
3. Run analysis: `python main.py --subject=your_new_subject`


### Adding New Concept Keywords
Edit the `concept_keywords` dictionary in `llm_api.py`:


```python
self.concept_keywords = {
    'New Concept': ['keyword1', 'keyword2', 'keyword3'],
    # ... existing concepts
}
```


### Integrating Real LLM APIs
The system is designed for easy API integration. Update the `_extract_concepts_api()` method in `llm_api.py` to add real API calls.


## Dependencies


- `python-dotenv`: Environment variable management
- `pandas`: Data manipulation (optional, for advanced features)
- `numpy`: Numerical operations (optional)
- `scikit-learn`: Machine learning utilities (optional)
- `nltk`: Natural language processing (optional)
- `requests`: HTTP requests for API calls
- `groq`: Groq API client (for future integration)


## Usage Examples


```bash
# Basic usage (simulation method)
python main.py --subject=ancient_history


# With specific method
python main.py --subject=economics --method=rule_based


# Using real API (requires API key setup)
python main.py --subject=ancient_history --method=api


# Test API connection
python main.py --test-api


# Custom resources directory
python main.py --subject=physics --resources-dir=/path/to/csv/files


# List all available subjects
python main.py --list-subjects


# Enable API usage explicitly
python main.py --subject=mathematics --use-api --method=api
```


## Contributing


1. Fork the repository
2. Create a feature branch
3. Add your enhancements
4. Submit a pull request


## License


This project is open source and available under the MIT License.


## Troubleshooting


### Common Issues


1. **FileNotFoundError**: Ensure CSV files are in the `resources/` directory
2. **Missing Dependencies**: Run `pip install -r requirements.txt`
3. **API Key Issues**: Check your `.env` file configuration
4. **CSV Format Issues**: Verify your CSV follows the required structure


### Getting Help


- Check the command-line help: `python main.py --help`
- Review the example CSV files in `resources/`
- Make sure all dependencies are installed