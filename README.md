# dbcli README

## Technology
- **Python 3**
- **Neo4j**
- **LXC (Linux Containers)**

## Prerequisites
- Linux installation with root access
- `apt` with standard repositories

## Installation Instructions

To install the CLI tool and all required dependencies, follow these steps:

1. **Clone the Repository:**  
   Clone the repository using Git:
   ```sh
   git clone <repository-url>
   ```

2. **Navigate to the Directory:**  
   Open your terminal and navigate to the directory where you downloaded the `setup.sh` script:
   ```sh
   cd <repository-directory>
   ```

3. **Run the Setup Script:**  
   Execute the setup script and provide root privileges:
   ```sh
   bash setup.sh
   ```

## User Manual

To access the CLI tool, open a terminal and type:
```sh
dbcli
```

To execute a query, use:
```sh
dbcli [type of query] [name of node] [optional: new name for renaming]
```

## Design and Implementation Process

1. **Initial Discussion:**  
   Discussions on potential technologies.

2. **Containerized Solution Agreement:**  
   Decided on a containerized solution for a cleaner implementation.

3. **Technology Choices:**  
   Initial choice of Python, Docker, and Dgraph.

4. **Challenges with Dgraph:**  
   Encountered implementation and performance issues with Dgraph.

5. **Switch to Neo4j:**  
   Transitioned to using Neo4j due to issues with Dgraph.

6. **Problems with Neo4j Docker Image:**  
   Faced challenges with the Neo4j Docker image.

7. **Switch to LXC:**  
   Opted for LXC for containerization.

8. **Environment Setup Script:**  
   Completed the environment setup script.

9. **Initial Python `dbcli` Tasks:**  
   Finished the first 6 tasks for the Python `dbcli`.

10. **Testing on Clean VM:**  
    Tested the setup on a clean virtual machine.

11. **Adjustments for Virtual Environments:**  
    Modified the setup to use Python virtual environments.

12. **Finalizing Setup:**  
    Ensured the setup works on a clean installation.

13. **Completion of Python `dbcli` Queries:**  
    Developed queries 6-12 for the Python `dbcli`.

14. **Merging Versions:**  
    Merged different versions of the tool.

15. **Final Adjustments:**  
    Made final adjustments to `dbcli` and the setup script.

16. **Documentation:**  
    Completed the documentation.
