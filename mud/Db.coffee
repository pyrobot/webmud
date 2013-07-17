module.exports = class Db
  
  defineSchemas: (mongoose) ->

    userSchema = mongoose.Schema
      name: String
      hash: String
      entity:
        name: String
        type: { type: String } # mongo gets confused when using the fieldName "type", so must explicitly define it
        gender: String
        room: Number

    configSchema = mongoose.Schema
      races: [
        name: String
        description: String
        shortcut: String
      ]
      rooms: [
        roomId: Number
        description: String
        exits: [
          to: Number
          type: { type: String }
          name: String
          description: String
          activators: [ cmd: String ]
        ]]
      entities: [
        entityId: Number
        name: String
        type: { type: String }
        gender: String
        ]
      commands:
        sayMsgSelf: String
        sayMsgBroadcast: String

    @Config = mongoose.model 'Config', configSchema
    @User = mongoose.model 'User', userSchema
