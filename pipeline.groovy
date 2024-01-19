pipeline {
    agent any
    stages {
        stage('Input Git URL') {
            steps {
                script {
                    def userInput = input(message: 'Please enter Git URL:', parameters: [string(defaultValue: '', description: 'Git URL', name: 'GIT_URL')])
                    // Check if user clicked "Abort"
                    if (userInput == null) {
                        error 'Pipeline aborted by the user.'
                    }
                    GIT_URL = userInput.trim()
                    env.GIT_URL = GIT_URL
                }
            }
        }
        stage('Select source Branch') {
            steps {
                script {
                    echo "GIT_URL: ${GIT_URL}"
                    // Check if GIT_URL is set
                    if (!GIT_URL) {
                        error 'GIT_URL is not set. Aborting pipeline.'
                    }
                    // Configure Git credentials and remote URL
                    withCredentials([usernamePassword(credentialsId: '8c043e82-07d5-4f0a-9c56-feda1e55ae2e', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        def branchesResult = sh(script: "git ls-remote --refs --tags --heads ${GIT_URL}", returnStatus: true)
                        // Check if branchesResult is not zero (indicating success)
                        if (branchesResult == 0) {
                            def branches = sh(script: "git ls-remote --refs --tags --heads ${GIT_URL}", returnStdout: true).trim().readLines().collect { it.replaceAll('.*refs/', '').trim() }
                            echo "Branches: ${branches}"
                            // Select a branch using drop down list
                            def source_branch = input(
                                id: 'branchInput',
                                message: 'Select a branch:',
                                parameters: [choice(choices: branches, description: 'Select branch', name: 'BRANCH', defaultValue: branches[0])]
                            )
                            env.SOURCE_BRANCH = source_branch
                            echo "Selected Branch: ${env.SOURCE_BRANCH}"
                        } else {
                            error 'Failed to retrieve branches from the Git repository.'
                        }
                    }
                }
            }
        }
        stage('Target Branches') {
            steps {
                script {
                    echo "GIT_URL: ${GIT_URL}"
                    // Check if GIT_URL is set
                    if (!GIT_URL) {
                        error 'GIT_URL is not set. Aborting pipeline.'
                    }
                    // Configure Git credentials and remote URL
                    withCredentials([usernamePassword(credentialsId: '8c043e82-07d5-4f0a-9c56-feda1e55ae2e', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                        def branchesResult = sh(script: "git ls-remote --heads ${GIT_URL}", returnStatus: true)
                        // Check if branchesResult is not zero (indicating success)
                        if (branchesResult == 0) {
                            def branches = sh(script: "git ls-remote --heads ${GIT_URL}", returnStdout: true).trim().readLines().collect { it.replaceAll('.*refs/heads/', '').trim() }
                            echo "Branches: ${branches}"
                            // Select multiple branches seperated by space
                            def target_branches = input(
                                id: 'branchInput',
                                message: 'Enter branches (separated by space):',
                                parameters: [string(name: 'BRANCHES', defaultValue: branches.join(' '))]
                            )
                            env.TARGET_BRANCHES = target_branches
                            echo "Selected Branches: ${env.TARGET_BRANCHES}"
                        } else {
                            error 'Failed to retrieve branches from the Git repository.'
                        }
                    }
                }
            }
        }
        // stage('Source Code Management') {
        //     steps {
        //         script {
        //             checkout([$class: 'GitSCM',
        //                       branches: [[name: 'feature/MOBIT2-31027']],
        //                       userRemoteConfigs: [[credentialsId: '8c043e82-07d5-4f0a-9c56-feda1e55ae2e', url: 'ssh://git@bitbucket.corp.chartercom.com:7999/smt/mobile-it-devops-cicd.git']]])
        //         }
        //     }
        // }
        stage('Execute Shell') {
            steps {
                script {
                    echo "GIT_URL: ${GIT_URL}"
                    // Check if GIT_URL is set
                    if (!GIT_URL) {
                        error 'GIT_URL is not set. Aborting pipeline.'
                    }
                    // Extract ARTIFACT_ID from GIT_URL
                    def repo_url = GIT_URL
                    def ARTIFACT_ID = repo_url.replaceAll('.*/([^/]+)\\.git', '$1')
                    echo "ARTIFACT_ID: ${ARTIFACT_ID}"
                    // Write ARTIFACT_ID to a properties file
                    writeFile file: 'artifactid.properties', text: "ARTIFACT_ID=${ARTIFACT_ID}"
                    sh "cat artifactid.properties"
                }
            }
        }
        stage('Inject Environment Variables') {
            steps {
                script {
                    // Define the path to the properties file
                    def propertiesFilePath = 'artifactid.properties'
                    // Read the content of the properties file
                    def propertiesFileContent = readFile(file: propertiesFilePath).trim()
                    // Check if the content is not empty
                    if (propertiesFileContent) {
                        // Split the content into lines
                        def properties = propertiesFileContent.split('\n')
                        // Loop through each property and inject it as an environment variable
                        properties.each { property ->
                            def keyValue = property.split('=')
                            def key = keyValue[0].trim()
                            def value = keyValue[1].trim()
                            // Inject the environment variable
                            env[key] = value
                        }
                    } else {
                        echo "Properties file is empty. No environment variables to inject."
                    }
                }
            }
        }
        stage('Build') {
            steps {
                script {
                    sh 'echo "file is executing"'
                    sh "python --version"
                    sh 'echo "ARTIFACT_ID: ${ARTIFACT_ID}"'
                    sh "echo 'GIT_URL: ${env.GIT_URL}'"
                    sh "echo 'Source Branch: ${env.SOURCE_BRANCH}'"
                    sh "echo 'Target Branches: ${env.TARGET_BRANCHES}'"
                    sh 'ls -ltr'
                    sh 'cd code_sync'
                    sh "chmod +rx ./code_sync/MergeMultipleBranches.sh"
                    sh "./code_sync/MergeMultipleBranches.sh ${env.GIT_URL} ${env.SOURCE_BRANCH} ${env.TARGET_BRANCHES}"
                    sh 'ls -ltr'
                    sh 'echo "************"'
                    sh 'cat conflict_log.txt'
                }
            }
        }
        stage('Build Environment') {
            steps {
                script {
                    // Use secret text(s) or file(s) for Jira credentials
                    withCredentials([usernamePassword(credentialsId: 'JIRA_Jenkins_User', passwordVariable: 'JIRA_PASSWORD', usernameVariable: 'JIRA_USERNAME')]) {
                        // Your build steps go here
                        def venvActivateScript = "/apps/jenkins/989b7f44/shiningpanda/jobs/f791f21a/virtualenvs/d41d8cd9/bin/activate"
                        // Activate the virtual environment and install packages
                        sh """
                            source $venvActivateScript
                            pip install requests
                            pip install openpyxl
                            pip install pandas
                            pip install jira
                            echo 
                            python3 code_sync/CSnotificationnew.py \${JIRA_USERNAME} \${JIRA_PASSWORD}
                        """
                        // sh "python3 code_sync/CSnotificationnew.py \${JIRA_USERNAME} \${JIRA_PASSWORD}"
                    }
                 }
            }
        }
        stage('Print Jira Details') {
            steps {
                script {
                    // Printing Jira details to console and repo_details.txt
                    echo "****** Jira details ******"
                    sh 'echo "Repository details:" > repo_details.txt'
                    sh "echo Repo name: ${ARTIFACT_ID} >> repo_details.txt"
                    sh "echo Repo URL: ${env.GIT_URL} >> repo_details.txt"
                    sh "echo Source Branch: ${env.SOURCE_BRANCH} >> repo_details.txt"
                    sh "echo Target Branches: ${env.TARGET_BRANCHES} >> repo_details.txt"
                }
            }
        }
        stage('Code Sync Notification') {
            steps {
                script {
                    def htmlContent = readFile('./mailbody.html').trim()
                    emailext (
                        subject: "'Spectrum Mobile CICD: ${ARTIFACT_ID} - Code synchronization status'",
                        body: htmlContent,
                        mimeType: 'text/html',
                        to: 'c-anurag.yadav@charter.com, C-Awesh.Kumar@charter.com',
                        attachmentsPattern: '$WORKSPACE/conflict_log.txt',
                        attachLog: false
                    )
                }
            }
        }
    }
}
