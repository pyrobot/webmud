admin = angular.module 'admin', ['ngRoute']

admin.config [
  '$routeProvider',
  ($routeProvider) ->
    $routeProvider
    .when('/config', {templateUrl: "/partials/config.html", controller: 'main'})
    .otherwise redirectTo: '/config'    
]

admin.controller 'main', [
  '$scope','$http'
  ($scope, $http) ->
    $scope.loadConfig = ->
      get = $http.get '/config'
      get.success (data) -> $scope.mudconfigJson = JSON.stringify(data, undefined, 2)

    $scope.saveConfig = ->
      post = $http.post '/config', $scope.mudconfigJson
      post.success -> console.log "posted"
]