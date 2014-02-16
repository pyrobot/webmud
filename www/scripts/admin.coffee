admin = angular.module 'admin', ['ngRoute']

admin.config [
  '$routeProvider',
  ($routeProvider) ->
    $routeProvider
    .when('/admin', {templateUrl: '/partials/admin.html', controller: 'admin'})
    .when('/stats', {templateUrl: '/partials/stats.html', controller: 'stats'})
    .when('/config', {templateUrl: '/partials/config.html', controller: 'config'})
    .when('/other', {templateUrl: '/partials/other.html', controller: 'other'})
    .otherwise redirectTo: '/admin'
]

admin.controller 'main', [
  '$scope', '$http'
  ($scope, $http) ->
    loadStats = ->
      get = $http.get '/stats'
      get.success (data) -> $scope.stats = data
    setInterval loadStats, 5000
    loadStats()
]

admin.controller 'admin', [
  '$scope', '$http'
  ($scope, $http) ->
    $scope.$parent.section = 'admin'
]

admin.controller 'stats', [
  '$scope', '$http'
  ($scope, $http) ->
    $scope.$parent.section = 'stats'
]

admin.controller 'config', [
  '$scope','$http'
  ($scope, $http) ->
    $scope.$parent.section = 'config'

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
    $scope.$parent.section = 'other'
]

# manually bootstrap the app on body element
$ -> angular.bootstrap(document.body, ['admin'])
