#!/usr/bin/env python3
"""
GitLab CI YAML Validator
Validates .gitlab-ci.yml files for proper structure and script formatting.
"""

import yaml
import sys
import os

def validate_gitlab_ci(file_path):
    """Validate a GitLab CI YAML file."""
    errors = []
    warnings = []
    
    if not os.path.exists(file_path):
        print(f"Error: File {file_path} not found")
        return False
    
    try:
        with open(file_path, 'r') as f:
            data = yaml.safe_load(f)
    except yaml.YAMLError as e:
        print(f"YAML Parse Error: {e}")
        return False
    
    if not isinstance(data, dict):
        errors.append("Root level must be a dictionary")
        return False
    
    # Check for required 'stages' key
    if 'stages' not in data:
        warnings.append("No 'stages' defined")
    
    # Validate all jobs
    for key, value in data.items():
        if key in ['stages', 'variables', 'include', 'workflow']:
            continue
        
        if not isinstance(value, dict):
            continue
        
        # Check if it's a job (has 'script' or 'stage')
        if 'script' in value or 'stage' in value:
            job_name = key
            job_config = value
            
            # Validate script section
            if 'script' in job_config:
                script = job_config['script']
                
                if isinstance(script, str):
                    # Single string script is valid
                    pass
                elif isinstance(script, list):
                    # List of strings is valid
                    for i, item in enumerate(script):
                        if not isinstance(item, str):
                            errors.append(
                                f"Job '{job_name}': script[{i}] must be a string, "
                                f"got {type(item).__name__}: {repr(item)}"
                            )
                else:
                    errors.append(
                        f"Job '{job_name}': script must be a string or array of strings, "
                        f"got {type(script).__name__}"
                    )
    
    # Print results
    if errors:
        print("❌ Validation failed with errors:")
        for error in errors:
            print(f"  - {error}")
        return False
    
    if warnings:
        print("⚠️  Warnings:")
        for warning in warnings:
            print(f"  - {warning}")
    
    print("✅ GitLab CI YAML is valid!")
    return True

if __name__ == '__main__':
    file_path = sys.argv[1] if len(sys.argv) > 1 else '.gitlab-ci.yml'
    success = validate_gitlab_ci(file_path)
    sys.exit(0 if success else 1)

