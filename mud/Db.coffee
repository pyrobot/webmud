module.exports = class Db
  defineSchemas: (mongoose) ->
    userSchema = mongoose.Schema
      name: String
      hash: String

    @User = mongoose.model 'User', userSchema

