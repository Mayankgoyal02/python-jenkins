pipeline {
    agent any
    parameters {
        string(name: 'GIT_URL', defaultValue: 'https://bitbucket.corp.com/mobile-it-cicd', description: 'Git URL')
        choice(name: 'BRANCH', choices: [], description: 'Select branch')
        choice(name: 'FOLDER', choices: [], description: 'Select folder')
        choice(name: 'SUBFOLDER', choices: [], description: 'Select subfolder')
        string(name: 'TEST_ID', defaultValue: '', description: 'BlazeMeter Test ID')
    }
    stages {
        stage('Select source Branch') {
            steps {
                script {
                    def branches = sh(script: "git ls-remote --refs --tags --heads ${params.GIT_URL}", returnStdout: true).trim().readLines().collect { it.replaceAll('.*refs/', '').trim() }

                    currentBuild.withBuildParameters {
                        property('BRANCH', choices: branches.join('\n'))
                    }

                    def selectedBranch = input(
                        id: 'branchInput',
                        message: 'Select a branch:',
                        parameters: [choice(choices: branches, description: 'Select branch', name: 'BRANCH', defaultValue: branches[0])]
                    )
                    echo "Selected Branch: ${selectedBranch}"
                }
            }
        }
        stage('Select Folder') {
            steps {
                script {
                    checkout([$class: 'GitSCM', branches: [[name: params.BRANCH]], userRemoteConfigs: [[url: params.GIT_URL]]])

                    def folders = sh(script: 'ls -d */', returnStdout: true).trim().readLines().collect { it.substring(0, it.length() - 1) }

                    currentBuild.withBuildParameters {
                        property('FOLDER', choices: folders.join('\n'))
                    }

                    def selectedFolder = input(
                        id: 'folderInput',
                        message: 'Select a folder:',
                        parameters: [choice(choices: folders, description: 'Select folder', name: 'FOLDER', defaultValue: folders[0])]
                    )
                    echo "Selected Folder: ${selectedFolder}"
                }
            }
        }
        stage('Select Subfolder') {
            steps {
                script {
                    dir(params.FOLDER) {
                        def subfolders = sh(script: 'ls -d */', returnStdout: true).trim().readLines().collect { it.substring(0, it.length() - 1) }

                        currentBuild.withBuildParameters {
                            property('SUBFOLDER', choices: subfolders.join('\n'))
                        }

                        def selectedSubfolder = input(
                            id: 'subfolderInput',
                            message: 'Select a subfolder:',
                            parameters: [choice(choices: subfolders, description: 'Select subfolder', name: 'SUBFOLDER', defaultValue: subfolders[0])]
                        )
                        echo "Selected Subfolder: ${selectedSubfolder}"
                    }
                }
            }
        }
        stage('Input BlazeMeter Test ID') {
            steps {
                script {
                    def userInputTestId = input(
                        id: 'testIdInput',
                        message: 'Please enter BlazeMeter Test ID:',
                        parameters: [string(defaultValue: '', description: 'BlazeMeter Test ID', name: 'TEST_ID')]
                    )
                    // Check if user clicked "Abort"
                    if (userInputTestId == null) {
                        error 'Pipeline aborted by the user.'
                    }
                    env.TEST_ID = userInputTestId.trim()
                }
            }
        }
        stage('Run BlazeMeter Upload Script') {
            steps {
                script {
                    def blazeMeterScript = '''
                                              #!/bin/bash
                                              
                                              # Check if TEST_ID is provided as a command-line argument
                                              if [ -z "${TEST_ID}" ]; then
                                                  echo "Usage: $0 <TEST_ID>"
                                                  exit 1
                                              fi
                                              
                                              # Jenkins build parameters
                                              SELECT_ENVIRONMENT="${SELECT_ENVIRONMENT}"
                                              SELECT_FOLDER="${SELECT_FOLDER}"
                                              
                                              # Check if build parameters are provided
                                              if [ -z "$SELECT_ENVIRONMENT" ] || [ -z "$SELECT_FOLDER" ]; then
                                                  echo "Build parameters not provided. Please provide values for 'SELECT_ENVIRONMENT' and 'SELECT_FOLDER'."
                                                  exit 1
                                              fi
                                              
                                              # Navigate to the specified environment folder
                                              TARGET_ENV_FOLDER="${SELECT_ENVIRONMENT}_Script"
                                              if [ ! -d "$TARGET_ENV_FOLDER" ]; then
                                                  echo "Folder '$TARGET_ENV_FOLDER' not found."
                                                  exit 1
                                              fi
                                              
                                              cd "$TARGET_ENV_FOLDER" || exit 1
                                              
                                              # BlazeMeter API details
                                              FILES_URL="https://a.blazemeter.com/api/v4/tests/${TEST_ID}/files"
                                              USERNAME='aea9b231534f434c2e1448bf'
                                              API_KEY='5006e34571c61320e68fe3a07fbe8fae31b0bb977ced85087e2bc1297c211035ae8a76ae'
                                              
                                              # Display the list of files (optional)
                                              echo "Files to be uploaded:"
                                              
                                              # Navigate to the specified subfolder
                                              TARGET_SUB_FOLDER="${SELECT_FOLDER}"
                                              if [ ! -d "$TARGET_SUB_FOLDER" ]; then
                                                  echo "Subfolder '$TARGET_SUB_FOLDER' not found."
                                                  exit 1
                                              fi
                                              
                                              cd "$TARGET_SUB_FOLDER" || exit 1
                                              
                                              # Iterate through all .jmx and .csv files in the subfolder
                                              for FILE in *.jmx *.csv; do
                                                  if [ -f "$FILE" ]; then
                                                      echo "Uploading $FILE..."
                                                      upload_response=$(curl -sk "$FILES_URL" \
                                                          -X POST \
                                                          -F "file=@$FILE" \
                                                          --user "$USERNAME:$API_KEY"
                                                      )
                                              
                                                      echo "$FILE uploaded successfully."
                                                  else
                                                      echo "File '$FILE' not found in subfolder."
                                                      exit 1
                                                  fi
                                              done
                                              
                                              # Uncomment the following lines if you want to run the test immediately after uploading files
                                              # curl -sk "$RUN_TEST_URL" \
                                              # -X POST \
                                              # -H 'Content-Type: application/json' \
                                              # --user "$USERNAME:$API_KEY"

                    '''
                    writeFile file: 'blazeMeterScript.sh', text: blazeMeterScript
                    sh 'chmod +x blazeMeterScript.sh'
                    sh './blazeMeterScript.sh'
                }
            }
        }
    }
}
