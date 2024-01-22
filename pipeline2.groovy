pipeline {
    agent any
    stages {
        stage('Select source Branch') {
            steps {
                script {
                    def branches = sh(script: "git ls-remote --refs --tags --heads https://bitbucket.corp.com/mobile-it-cicd", returnStdout: true).trim().readLines().collect { it.replaceAll('.*refs/', '').trim() }

                    // Select a branch using the dropdown list
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
                    // User input for folder
                    def selectedFolder = input(
                        id: 'folderInput',
                        message: 'Enter folder:',
                        parameters: [string(name: 'FOLDER', defaultValue: 'default-folder')]
                    )
                    echo "Selected Folder: ${selectedFolder}"
                }
            }
        }
        stage('Input BlazeMeter Test ID') {
            steps {
                script {
                    // User input for BlazeMeter Test ID
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
                    // BlazeMeter API details
                    def filesUrl = "https://a.blazemeter.com/api/v4/tests/${env.TEST_ID}/files"
                    def username = 'aea9b231534f434c2e1448bf'
                    def apiKey = '5006e34571c61320e68fe3a07fbe8fae31b0bb977ced85087e2bc1297c211035ae8a76ae'

                    // Display the list of files (optional)
                    echo "Files to be uploaded:"

                    // Navigate to the specified subfolder
                    def targetSubFolder = "${params.FOLDER}"
                    if (targetSubFolder) {
                        dir(targetSubFolder) {
                            // Iterate through all .jmx and .csv files in the subfolder
                            for (file in "*.jmx *.csv".split()) {
                                if (file) {
                                    echo "Uploading $file..."
                                    def uploadResponse = sh(script: """
                                        curl -sk "$filesUrl" \
                                        -X POST \
                                        -F "file=@$file" \
                                        --user "$username:$apiKey"
                                    """, returnStatus: true)

                                    if (uploadResponse == 0) {
                                        echo "$file uploaded successfully."
                                    } else {
                                        error "Failed to upload $file."
                                    }
                                }
                            }
                        }
                    } else {
                        error "Subfolder not provided."
                    }
                }
            }
        }
    }
}
