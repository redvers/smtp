use "net"

actor SMTPClient
  var auth: TCPConnectAuth
  let config: SMTPConfiguration val
  let email: EMail val

  new create(auth': TCPConnectAuth, config': SMTPConfiguration val, email': EMail val) =>
    auth = auth'
    config = config'
    email = email'

    TCPConnection(auth, recover SMTPClientNotify(SMTPConfiguration, email) end, config.destination, config.port)

class SMTPConfiguration
  var mydomain: String val
  var destination: String val
  var port: String val

  new create(mydomain': String val = "example-sending-domain.com",
             destination': String val = "example.com",
             port': String val = "25") => None
    mydomain = mydomain'
    destination = destination'
    port = port'

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
