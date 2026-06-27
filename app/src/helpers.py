import yaml
from pathlib import Path
from typing import Any, Dict


def read_yaml(file_path: str) -> Dict[str, Any]:
    """
    Read a YAML file and return its contents as a dictionary.
    
    Args:
        file_path: Path to the YAML file
        
    Returns:
        Dictionary containing the parsed YAML content
        
    Raises:
        FileNotFoundError: If the file does not exist
        yaml.YAMLError: If the file is not valid YAML
    """
    path = Path(file_path)
    
    if not path.exists():
        raise FileNotFoundError(f"YAML file not found: {file_path}")
    
    with open(path, 'r') as file:
        data = yaml.safe_load(file)
    
    return data if data else {}
