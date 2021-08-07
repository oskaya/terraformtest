pipeline {
    agent any

    stages{
        stage ("build Image") {
            steps{
                echo "Creatnig Image"
                sh 'docker build .'
            }
        }

        stage ("testing") {
            steps{
                echo "test completed"
                
            }
        }
    }   
}
