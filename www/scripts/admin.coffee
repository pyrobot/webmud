admin = angular.module 'admin', []

admin.controller 'main', ($scope, $http) ->
  $scope.loadConfig = ->
    get = $http.get '/config'
    get.success (data) -> $scope.mudconfigJson = JSON.stringify(data, undefined, 2)

  $scope.saveConfig = ->
    post = $http.post '/config', $scope.mudconfigJson
    post.success -> console.log "posted"