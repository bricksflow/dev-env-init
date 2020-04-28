#!/bin/bash -e

if [[ -z "$PYFONY_DEV_ENV_INIT_VERSION" ]]; then PYFONY_DEV_ENV_INIT_VERSION="4433ff23130232d870c388d4e1800d20f03a5a95"; fi

PYFONY_DEV_ENV_INIT_URL="https://raw.githubusercontent.com/pyfony/dev-env-init/$PYFONY_DEV_ENV_INIT_VERSION/dev_env_init.sh"

echo "Using Pyfony dev_env_init.sh from: $PYFONY_DEV_ENV_INIT_URL"

source /dev/stdin <<< "$( curl -s "$PYFONY_DEV_ENV_INIT_URL" )"

download_winutils_on_windows() {
  if [ $IS_WINDOWS == 1 ]; then
    echo "Downloading Hadoop winutils.exe"

    mkdir -p "$CONDA_ENV_PATH/hadoop/bin"
    curl https://raw.githubusercontent.com/steveloughran/winutils/master/hadoop-3.0.0/bin/winutils.exe --silent > "$CONDA_ENV_PATH/hadoop/bin/winutils.exe"
  fi
}

download_java() {
  local JAVA_DIR="$HOME/.databricks-connect-java"

  if [ -d "$JAVA_DIR" ]; then
    echo "$JAVA_DIR already exists"
    return
  fi

  echo "Downloading Java 1.8 to $JAVA_DIR"

  mkdir -p $JAVA_DIR

  local JAVA_ZIP_DIR="$JAVA_DIR/jdk8u242-b08"

  if [ $IS_WINDOWS == 1 ]; then
    curl https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u242-b08/OpenJDK8U-jdk_x64_windows_hotspot_8u242b08.zip -L --silent > "$JAVA_DIR/java.zip"
    unzip -qq "$JAVA_DIR/java.zip" -d "$JAVA_DIR"
    mv "$JAVA_ZIP_DIR/"* $JAVA_DIR
    rm -rf "$JAVA_ZIP_DIR"
    rm -rf "$JAVA_DIR/java.zip"
    rm -rf "$JAVA_DIR/src.zip"
  elif [ $DETECTED_OS == "mac" ]; then
    curl https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u242-b08/OpenJDK8U-jdk_x64_mac_hotspot_8u242b08.tar.gz -L --silent > "$JAVA_DIR/java.tar.gz"
    tar -xzf "$JAVA_DIR/java.tar.gz" -C "$JAVA_DIR"
    mv "$JAVA_ZIP_DIR/Contents/Home/"* $JAVA_DIR
    rm -rf "$JAVA_ZIP_DIR"
    rm -rf "$JAVA_DIR/java.tar.gz"
    chmod +x "$CONDA_ENV_PATH/lib/python3.7/site-packages/pyspark/bin/"*
  elif [ $DETECTED_OS == "linux" ]; then
    curl https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u242-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u242b08.tar.gz -L --silent > "$JAVA_DIR/java.tar.gz"
    tar -xzf "$JAVA_DIR/java.tar.gz" -C "$JAVA_DIR"
    mv "$JAVA_ZIP_DIR/"* $JAVA_DIR
    rm -rf "$JAVA_ZIP_DIR"
    rm -rf "$JAVA_DIR/java.tar.gz"
    chmod +x "$CONDA_ENV_PATH/lib/python3.7/site-packages/pyspark/bin/"*
  fi
}

create_databricks_connect_config() {
  # .databricks-connect file must always exist and contain at least empty JSON for the Databricks Connect to work properly
  # specific cluster connection credentials must be set when creating the SparkSession instance
  if [ ! -f "$HOME/.databricks-connect" ]; then
    echo "Creating empty .databricks-connect file"
    echo "{}" > "$HOME/.databricks-connect"
  fi
}

databricks_environment_setup() {
  download_winutils_on_windows
  download_java
  create_databricks_connect_config
}

# main invocation functions ---------------------

prepare_environment_databricks_app() {
  base_environment_setup
  databricks_environment_setup
  create_dot_env_file
  show_installation_finished_info
}

prepare_environment_for_package_with_databricks() {
  base_environment_setup
  databricks_environment_setup
  show_installation_finished_info
}
