module.exports = class Db
  
  defineSchemas: (mongoose) ->

    userSchema = mongoose.Schema
      name: String
      hash: String

    configSchema = mongoose.Schema
      rooms: [
        roomId: Number
        description: String
        exits: [
          to: Number
          type: String
          name: String
          description: String
          activators: [ cmd: String ]
        ]]
      messages: 
        connectBanner: String
        enterUsername: String
        nameLengthError: String
        invalidCharactersError: String
        enterPassword: String
        invalidPasswordError: String
        tooManyAttemptsError: String
        userCreatePrompt: String
        userCreatePromptError: String
        userCreatePasswordPrompt: String
        userCreatePasswordReentry: String
        userCreatePasswordMismatch: String
        mainUserEnterRealm: String
        mainUserEnterRealmBroadcast: String
        mainInvalidCommand: String
        goodbye: String
      commands:
        sayMsgSelf: String
        sayMsgBroadcast: String

    entitySchema = mongoose.Schema
      entityId: Number
      name: String
      race: String
      gender: String
      type: String
      roomId: Number

    @Config = mongoose.model 'Config', configSchema
    @User = mongoose.model 'User', userSchema
    @Entity = mongoose.model 'Entity', entitySchema
