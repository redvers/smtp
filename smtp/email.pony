use "encode/base64"

class EMail
  var contents: Array[MIMEContent val] = []
  var boundary: String = "lqwkejhdlkjqewhdlhdlkjhqewdljkqwgfvedyugqewukdgqewklugqwFIXME"
  var to: Array[String] = []
  var cc: Array[String] = []
  var bcc: Array[String] = []
  var subject: String = ""
  var from: String = "test@example.com"



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









class MIMEContent
  var transfer_type: MIMETransferType
  var content_type: MIMEContentType
  var raw_data: (String val | Array[U8] val) = ""
  var separator: String val = ""

  new create(content_type': MIMEContentType, transfer_type': MIMETransferType) =>
    content_type = content_type'
    transfer_type = transfer_type'

  fun render(): String =>
    transfer_type.content_transfer_encoding_header() +
    content_type.content_type() +
    content_type.content_disposition() +
    "Mime-Version: 1.0\r\n\r\n" +
    transfer_type.encode(raw_data) + "\r\n"



interface MIMEContentType
  fun content_type(): String val
  fun content_disposition(): String val
  fun ref set_content_type(data: String val): None

class MIMEContentTypeText is MIMEContentType
  var texttype: String = "plain"
  var filename: (None | String val) = None

  fun content_type(): String val =>
    "Content-Type: text/" + texttype + "\r\n"

  fun content_disposition(): String val =>
    match filename
    | let name: None => return ""
    | let name: String val => return "Content-Disposition: attachment; filename=" + name + "\r\n"
    end
    ""

  fun ref set_content_type(data: String val): None =>
    texttype = data

class MIMEContentTypeApplication is MIMEContentType
  var texttype: String = "pdf"
  var filename: (None | String val) = None

  fun content_type(): String val =>
    "Content-Type: application/" + texttype + "\r\n"

  fun content_disposition(): String val =>
    match filename
    | let name: None => return ""
    | let name: String val => return "Content-Disposition: attachment; filename=" + name + "\r\n"
    end
    ""

  fun ref set_content_type(data: String val): None =>
    texttype = data




interface val MIMETransferType
  fun content_transfer_encoding_header(): String
  fun encode(data: (String val | Array[U8] val)): String val

primitive MIMETransferTypeBase64 is MIMETransferType
  fun content_transfer_encoding_header(): String => "Content-Transfer-Encoding: base64\r\n"
  fun encode(data: (String val | Array[U8] val)): String val => Base64.encode_mime(data)
