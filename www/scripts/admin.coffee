admin = angular.module 'admin', ['ngRoute']

admin.config [
  '$routeProvider', '$httpProvider'
  ($routeProvider,   $httpProvider) ->
    $routeProvider
    .when('/', {templateUrl: '/partials/admin.html', controller: 'admin'})
    .when('/stats', {templateUrl: '/partials/stats.html', controller: 'stats'})
    .when('/config', {templateUrl: '/partials/config.html', controller: 'config'})
    .when('/other', {templateUrl: '/partials/other.html', controller: 'other'})
    .otherwise redirectTo: '/'

    $httpProvider.defaults.headers.post['X-CSRF-Token'] = $("[name=_csrf]").val()
]

admin.value 'adminRoute', document.URL.split('//')[1].split('#/')[0].split('/')[1] # todo: less hacky way to do this

admin.controller 'main', [
  '$scope', '$http', 'adminRoute'
  ($scope, $http, adminRoute) ->
    $scope.logout = ->
      post = $http.post "/#{adminRoute}/logout"
      post.success -> window.location.href = "/#{adminRoute}"
]

admin.controller 'admin', [
  '$scope', '$http', 'adminRoute'
  ($scope, $http, adminRoute) ->
    $scope.$parent.section = 'admin'
    get = $http.get '/stats'
    get.success (data) -> $scope.stats = data

    $scope.kick = (user) ->
      post = $http.post "/#{adminRoute}/kick/#{user.connection.id}"
      post.success -> console.log "posted"
]

admin.controller 'stats', [
  '$scope', '$http'
  ($scope, $http) ->
    $scope.$parent.section = 'stats'
    get = $http.get '/stats'
    get.success (data) -> $scope.stats = data
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
