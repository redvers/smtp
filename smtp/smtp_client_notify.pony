use "net"
use "debug"
use "buffered"

class SMTPClientNotify is TCPConnectionNotify
  var client_state: SMTPClientState = SMTPClientStateNoConnection
  let config: SMTPConfiguration val
  let reader: Reader = Reader
  var email: EMail iso
  var rcpttos: Array[String] = []
  var currentto: String val = ""

  new create(config': SMTPConfiguration val, email': EMail iso) =>
    config = config'
    Debug.out("SMTPConfiguration:mydomain: " + config.mydomain)
    Debug.out("SMTPConfiguration:destination: " + config.destination)
    Debug.out("SMTPConfiguration:port: " + config.port)
    email = consume email'

    for to in email.to.values() do
      rcpttos.push(to)
    end
    for cc in email.cc.values() do
      rcpttos.push(cc)
    end
    for bcc in email.bcc.values() do
      rcpttos.push(bcc)
    end

  fun ref connect_failed(conn: TCPConnection ref) =>
    var temail: EMail iso = email = recover iso EMail end
    config.callback(consume temail)

  fun ref connected(conn: TCPConnection ref) =>
    Debug.out("←→ Connection Established with " + config.destination)
  fun ref sent(conn: TCPConnection ref, data: ByteSeq): ByteSeq =>
    match data
    | let d: String => Debug.out("→ " + d)
    | let d: Array[U8] val => Debug.out("→" + String.from_array(d))
    end
    data
  fun ref sentv(conn: TCPConnection ref, data: ByteSeqIter): ByteSeqIter => data
  fun ref received(conn: TCPConnection ref, data: Array[U8] iso, times: USize): Bool =>
    reader.append(consume data)
    match client_state
    | let x: SMTPClientStateNoConnection => recv_noconnection(conn)
    | let x: SMTPClientStateConnected => recv_connected(conn)
    | let x: SMTPClientStateAcceptedEHLO => recv_accepted_ehlo(conn)
    | let x: SMTPClientStateSendingRcptTo => recv_sending_rcpt_to(conn)
    | let x: SMTPClientStateReadyForMessage => recv_ready_for_message(conn)
    | let x: SMTPClientStatePendingOK => recv_pending_ok(conn)
    end
    true
  fun ref closed(conn: TCPConnection ref) =>
    var temail: EMail iso = email = recover iso EMail end
    config.callback(consume temail)

  fun ref recv_pending_ok(conn: TCPConnection ref) =>
    try
      let line: String val = reader.line()?
      Debug.out("→ " + line)
      Debug.out("→ None ←")
      client_state = None
      conn.write("QUIT\r\n")
    end

  fun ref recv_ready_for_message(conn: TCPConnection ref) =>
    try
      let response: String val = reader.line()?
      Debug.out("→ " + response)
      conn.write(email.render())
      conn.write(".\r\n")
      client_state = SMTPClientStatePendingOK
      Debug.out("→ SMTPClientStatePendingOK ←")
    end



  fun ref recv_sending_rcpt_to(conn: TCPConnection ref) =>
    try
      let response: String val = reader.line()?
      Debug.out("→ " + response + " <<<<" + currentto + ">>>>")
      if (rcpttos.size() == 0) then
        client_state = SMTPClientStateReadyForMessage
        Debug.out("→ SMTPClientStateReadyForMessage ←")

        conn.write("DATA\r\n")
        return
      end
      currentto = rcpttos.pop()?
      conn.write("RCPT TO: " + currentto + "\r\n")
    end

  fun ref recv_accepted_ehlo(conn: TCPConnection ref) =>
    try
      let response: String val = reader.line()?
      Debug.out("→ " + response + " <<<<(for Mail from)>>>>")
      Debug.out("→ SMTPClientStateSendingRcptTo ←")
      currentto = rcpttos.pop()?
      conn.write("RCPT TO: " + currentto + "\r\n")
      client_state = SMTPClientStateSendingRcptTo
    end

  fun ref recv_connected(conn: TCPConnection ref) =>
    try
      while true do
        let line: String val = reader.line()?
        Debug.out("→ " + line)
        if (line.at(" ", 3)) then
          Debug.out("→ SMTPClientStateAcceptedEHLO ←")
          conn.write("MAIL FROM: " + email.from + "\r\n")
          client_state = SMTPClientStateAcceptedEHLO
          break
        end
      end
    end



  fun ref recv_noconnection(conn: TCPConnection ref) =>
    try
      let line: String val = reader.line()?
      Debug.out("→ " + line)
    end
    conn.write("EHLO " + config.destination + "\r\n")
    Debug.out("→ SMTPClientStateConnected ←")
    client_state = SMTPClientStateConnected
