pipeline {
    agent any

    stages{
        stage ("build") {
            steps{
                echo "Building"
                sh 'mvn clean install package'
            }
        }

        stage ("testing") {
            steps{
                echo "test completed"
                
            }
        }
    }   
}
