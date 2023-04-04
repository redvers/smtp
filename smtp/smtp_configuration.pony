use "net"

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


