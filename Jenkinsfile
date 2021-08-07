pipeline {
    agent any

    environement {
        version = '3'
    }

    stages{
        stage ("build Image") {
            steps{
                echo "Creatnig Image"
                sh 'docker build . -t umutderman/my-web-ste:$version'
            }
        }

        stage ("test") {
            steps{
                echo "test completed"
                
            }

        stage ("Push to Docker Hub") {
            steps{
                echo "Login to Docker hub"
                sh 'docker login -u umutderman -p 3552397Oo.,'
                sh 'docker push umutderman/my-web-ste:$version'
                
            }
        }
    }   
}
