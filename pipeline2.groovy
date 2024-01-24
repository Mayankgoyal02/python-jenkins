pipeline {
    agent any

    stages {
        stage('Select source Branch') {
            steps {
                script {
                    GIT_URL="ssh://git@bitbucket.corp.chartercom.com:7999/smt/performancetestsuite.git"

                    // Check if GIT_URL is set
                    if (!GIT_URL) {
                        error 'GIT_URL is not set. Aborting pipeline.'
                    } 

                    // Configure Git credentials and remote URL
                    def branchesResult = sh(script: "git ls-remote --refs --tags --heads ${GIT_URL}", returnStatus: true)

                    // Check if branchesResult is not zero (indicating success)
                    if (branchesResult == 0) {
                        def branches = sh(script: "git ls-remote --refs --tags --heads ${GIT_URL}", returnStdout: true).trim().readLines().collect { it.replaceAll('.*refs/', '').trim() }

                        echo "Branches: ${branches}"

                        // Select a branch using radio buttons
                        def source_branches = input(
                            id: 'branchInput',
                            message: 'Select a branch:',
                            parameters: [choice(choices: branches, description: 'Select branch', name: 'BRANCH', defaultValue: branches[0])]
                        )
                        env.SOURCE_BRANCHES = source_branches 
                        echo "Selected Branch: ${env.SOURCE_BRANCHES}"
                    } else {
                        error 'Failed to retrieve branches from the Git repository.'
                    }
                }
            }
        }

        stage('List Folders in Selected Branch') {
            steps {
                script {
                    // Assume SOURCE_BRANCHES is the selected branch from the previous stage
                    def selectedBranch = env.SOURCE_BRANCHES

                    // Retrieve list of folders in the selected branch
                    def foldersResult = sh(script: "git ls-tree --name-only -d -r ${selectedBranch}", returnStatus: true)

                    // Check if foldersResult is zero (indicating success)
                    if (foldersResult == 0) {
                        def folders = sh(script: "git ls-tree --name-only -d -r ${selectedBranch}", returnStdout: true).trim().readLines()

                        echo "Folders in ${selectedBranch}: ${folders}"

                        // Select a folder using dropdown
                        def selectedFolder = input(
                            id: 'folderInput',
                            message: 'Select a folder:',
                            parameters: [choice(choices: folders, description: 'Select folder', name: 'FOLDER', defaultValue: folders[0])]
                        )

                        env.SELECTED_FOLDER = selectedFolder
                        echo "Selected Folder: ${env.SELECTED_FOLDER}"
                    } else {
                        error 'Failed to retrieve folders from the Git repository.'
                    }
                }
            }
        }

        // Add more stages or steps as needed for your pipeline
    }
}
