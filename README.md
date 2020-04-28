# Development environment initialization

for the [Bricksflow stack](https://github.com/bricksflow/bricksflow)

### What it does:

* Extends the [Pyfony dev environment initialization](https://github.com/pyfony/dev-env-init)
* Downloads Hadoop's `winutils.exe` and puts it into the project's `.venv` directory (Windows only) 
* Downloads **Java 1.8** binaries and puts them into the `~/.databricks-connect-java` dir
* Creates the empty `~/.databricks-connect` file
