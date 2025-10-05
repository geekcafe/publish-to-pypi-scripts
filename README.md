# PyPI Publishing Scripts

This repository contains a set of scripts designed to simplify the process of building and publishing Python packages to PyPI and TestPyPI. The scripts provide an interactive and automated workflow, handling everything from dependency checks to version management and uploading.

## Features

- **Interactive Interface**: Guides you through the publishing process with clear prompts.
- **Automatic Dependency Checks**: Ensures `build`, `twine`, and `toml` are installed.
- **Self-Updating**: The script can check for and download the latest version of itself from the repository.
- **Version Management**: Automatically creates or updates a version file (e.g., `version.py`, `__init__.py`) based on the version in `pyproject.toml`.
- **Credential Management**: Helps create a local `.pypirc` file for storing PyPI API tokens securely.
- **Troubleshooting for AWS CodeArtifact**: Detects and provides solutions for common build failures related to AWS CodeArtifact credentials.
- **CI/CD Mode**: Supports a non-interactive mode for use in automated pipelines.

## Quick Start

1.  Place the `publish_to_pypi.sh` script in the root of your Python project directory.
2.  Make the script executable:
    ```bash
    chmod +x publish_to_pypi.sh
    ```
3.  Run the script and follow the on-screen instructions:
    ```bash
    ./publish_to_pypi.sh
    ```

The script will automatically download the main Python script (`publish_to_pypi.py`) if it's not present and guide you through the rest of the process.

## Detailed Usage

The primary way to use this tool is through the `publish_to_pypi.sh` shell script.

### `publish_to_pypi.sh`

This script is the entry point. It handles the fetching of the latest publishing script and then executes it.

**Options:**

- `-u`, `--update`: Automatically downloads the latest version of `publish_to_pypi.py` without prompting.
- `-n`, `--no-update`: Skips the check for a new version and uses the existing `publish_to_pypi.py`.
- `--ci`: Enables CI/CD mode. This is equivalent to `--update` and runs the Python script in a non-interactive mode.
- `-h`, `--help`: Displays the help message.

### The Publishing Process

When you run the script, it will perform the following steps:

1.  **Check for Updates**: It first checks if a newer version of the scripts is available on GitHub.
2.  **Check Dependencies**: It verifies that all required Python packages (`build`, `twine`, `toml`) are installed.
3.  **Handle Authentication**: It looks for a local `.pypirc` file. If not found, it offers to create one for you to add your PyPI/TestPyPI API tokens.
4.  **Select Repository**: It prompts you to choose whether to upload to PyPI or TestPyPI.
5.  **Update Version File**: It reads the version from your `pyproject.toml` and updates/creates a version file within your package source to ensure the version is correctly embedded.
6.  **Build Package**: It cleans the `dist/` directory and builds the source distribution and wheel.
7.  **Upload Package**: It uses `twine` to upload the contents of the `dist/` directory to your chosen repository.

## Configuration

### Storing Update Preference

You can store your preference for updating the script by creating a `publish_to_pypi.json` file in your project root with the following content:

```json
{
  "repo_update_preference": "yes" // or "no"
}
```

### PyPI Credentials

The script encourages the use of a local `.pypirc` file in your project directory to manage API tokens. It will offer to create a template for you. This file should be added to your `.gitignore` to prevent tokens from being committed to version control (the script will also offer to do this).

**Example `.pypirc`:**

```ini
[pypi]
username = __token__
password = pypi-your-token-here

[testpypi]
repository = https://test.pypi.org/legacy/
username = __token__
password = pypi-your-test-token-here
```

## Troubleshooting

### AWS CodeArtifact Build Failures

If you use AWS CodeArtifact, your global `pip` configuration might interfere with the build process, which needs to fetch build dependencies from PyPI. The script can detect this issue (indicated by a `401 Error` during the build) and offer several automated solutions:

- Temporarily renaming your global `pip.conf` file.
- Creating a local `pip.conf` file in your project that points directly to the public PyPI index.

## CI/CD Integration

For use in a CI/CD pipeline, use the `--ci` flag with the shell script:

```bash
./publish_to_pypi.sh --ci
```

This will:
- Automatically fetch the latest version of the scripts.
- Run the Python script in non-interactive mode.

In CI/CD mode, you must configure the repository and credentials using environment variables or a `.pypirc` file, as the script will not prompt for input.