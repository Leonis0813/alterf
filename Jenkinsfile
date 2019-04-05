pipeline {
  agent any

  environment {
    PATH = '/usr/local/rvm/bin:/usr/bin:/bin'
    RUBY_VERSION = '2.3.7'
  }

  parameters {
    string(name: 'ALTERF_VERSION', defaultValue: '', description: 'デプロイするバージョン')
    string(name: 'SUBRA_BRANCH', defaultValue: 'master', description: 'Chefのブランチ')
    choice(name: 'SCOPE', choices: 'app\nfull', description: 'デプロイ範囲')
  }

  stages {
    stage('Install Gems') {
      when {
        expression { return env.ENVIRONMENT == 'development' }
      }

      steps {
        script {
          sh "rvm ${RUBY_VERSION} do bundle install --path=vendor/bundle"
        }
      }
    }

    stage('Test') {
      when {
        expression { return env.ENVIRONMENT == 'development' }
      }

      steps {
        sh "rvm ${RUBY_VERSION} do bundle exec rake spec:models"
        sh "rvm ${RUBY_VERSION} do bundle exec rake spec:controllers"
        sh "rvm ${RUBY_VERSION} do bundle exec rake spec:views"
      }
    }

    stage('Deploy') {
      steps {
        ws("${env.WORKSPACE}/../chef") {
          script {
            git url: 'https://github.com/Leonis0813/subra.git', branch: params.SUBRA_BRANCH
            def version = params.ALTERF_VERSION.replaceFirst(/^.+\//, '')
            def recipe = ('app' == params.SCOPE ? 'app' : 'default')
            sh "sudo ALTERF_VERSION=${version} chef-client -z -r alterf::${recipe} -E ${env.ENVIRONMENT}"
          }
        }
      }
    }

    stage('System Test') {
      when {
        expression { return env.ENVIRONMENT == 'development' }
      }

      steps {
        sh "rvm ${RUBY_VERSION} do env REMOTE_HOST=http://localhost/alterf bundle exec rake spec:requests"
      }
    }
  }
}
