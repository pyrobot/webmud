admin = angular.module 'admin', ['ngRoute']

admin.config [
  '$routeProvider',
  ($routeProvider) ->
    $routeProvider
    .when('/stats', {templateUrl: '/partials/admin.html', controller: 'admin'})
    .when('/config', {templateUrl: '/partials/config.html', controller: 'config'})
    .when('/other', {templateUrl: '/partials/other.html', controller: 'other'})
    .otherwise redirectTo: '/stats'
]

admin.controller 'admin', [
  '$scope'
  ($scope, $http) ->
    $scope.loadStats = ->
      get = $http.get '/stats'
      get.success (data) -> $scope.statsObject = data
]

admin.controller 'config', [
  '$scope','$http'
  ($scope, $http) ->
    $scope.loadConfig = ->
      get = $http.get '/config'
      get.success (data) -> $scope.mudconfigJson = JSON.stringify(data, undefined, 2)

    $scope.saveConfig = ->
      post = $http.post '/config', $scope.mudconfigJson
      post.success -> console.log "posted"
]

admin.controller 'other', [
  '$scope','$http'
  ($scope, $http) ->
]