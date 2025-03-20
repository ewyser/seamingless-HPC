from setuptools import setup, find_packages

# Function to read the content of the README.md file
def read(file_name):
    with open(file_name, 'r', encoding='utf-8') as f:
        return f.read()

# Read the content of requirements.txt for install_requires
def parse_requirements(filename):
    with open(filename, 'r') as f:
        return [line.strip() for line in f.readlines() if line.strip()]

setup(
    name='seamingless-smhpc',  # Name of the package
    version='0.1.0',            # Version number
    description='This is a python project to seaminglessly operate VMs on Google Cloud Service through Compute Engine',  # Short description of the project
    long_description=read('README.md'),  # Detailed description from README.md
    long_description_content_type='text/markdown',  # Content type of README (markdown)
    author='madMax',  # Your name
    author_email='manuwyser@gmail.com',  # Your email
    url='https://github.com/ewyser/seamingless-smhpc',  # URL of your project or repo
    packages=find_packages(where='src'),  # Find all packages under src
    package_dir={'': 'src'},  # Tell setuptools to look under 'src' for packages
    install_requires=parse_requirements('requirements.txt'),  # Dependencies from requirements.txt
    tests_require=[
        'pytest>=6.0',  # Testing dependencies like pytest
    ],
    include_package_data=True,  # Include non-Python files like README.md, LICENSE
    package_data={
        '': ['LICENSE', 'README.md'],  # Specify which files should be included in the package
    },
    classifiers=[
        'Programming Language :: Python :: 3',  # Python 3 compatibility
        'License :: OSI Approved :: MIT License',  # License type
        'Operating System :: OS Independent',  # OS compatibility
    ],
    python_requires='>=3.6',  # Ensure compatibility with Python 3.6 and above
    entry_points={
        'console_scripts': [
            # Example CLI command (if your package provides one)
            # 'mycli=my_package.cli:main_function',
        ],
    },
)
