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
    }
}
