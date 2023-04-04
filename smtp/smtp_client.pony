use "net"

actor SMTPClient
  var auth: TCPConnectAuth
  let config: SMTPConfiguration val

  new create(auth': TCPConnectAuth, config': SMTPConfiguration val, email: EMail iso) =>
    auth = auth'
    config = config'

    TCPConnection(auth, recover SMTPClientNotify(config, consume email) end, config.destination, config.port)

class SMTPConfiguration
  var mydomain: String val
  var destination: String val
  var port: String val
  var callback: {(EMail val): None}

  new create(mydomain': String val = "",
             destination': String val = "",
             port': String val = "",
             callback': {(EMail val): None} = {(email: EMail val): None => None}) => None
    mydomain = mydomain'
    destination = destination'
    port = port'
    callback = callback'


type SMTPClientState is (SMTPClientStateNoConnection |
                         SMTPClientStateConnected |
                         SMTPClientStateAcceptedEHLO |
                         SMTPClientStateSendingRcptTo |
                         SMTPClientStateReadyForMessage |
                         SMTPClientStatePendingOK |
                         None)

primitive SMTPClientStateNoConnection
primitive SMTPClientStateConnected
primitive SMTPClientStateAcceptedEHLO
primitive SMTPClientStateSendingRcptTo
primitive SMTPClientStateReadyForMessage
primitive SMTPClientStatePendingOK
