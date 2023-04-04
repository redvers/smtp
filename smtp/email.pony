use "encode/base64"

class EMail
  var contents: Array[MIMEContent val] = []
  var boundary: String = "lqwkejhdlkjqewhdlhdlkjhqewdljkqwgfvedyugqewukdgqewklugqwFIXME"
  var to: Array[String val] val = []
  var cc: Array[String val] val = []
  var bcc: Array[String val] val = []
  var subject: String val = ""
  var from: String val = ""

  new iso create() => None

  fun render(): String =>
    render_headers() +
    render_bodies() +
    "--" + boundary + "--\r\n"

  fun render_headers(): String =>
    "To: " + ", ".join(to.values()) + "\r\n" +
    "Cc: " + ", ".join(cc.values()) + "\r\n" +
    "Subject: " + subject + "\r\n" +
    "Content-Type: multipart/alternative; boundary=" + boundary + "\r\n" +
    "Mime-Version: 1.0\r\n\r\n"

  fun render_bodies(): String val =>
    var bodies: String trn = recover trn "--" + boundary + "\r\n" end
    for f in contents.values() do
      bodies.append(f.render())
    end
    consume bodies

