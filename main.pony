use "net"
use "smtp"
use "encode/base64"

actor Main
  new create(env: Env) =>
    let text: String =
    """
      These documents are based on earlier work documented in RFC 934, STD
      11, and RFC 1049, but extends and revises them.  Because RFC 822 said
      so little about message bodies, these documents are largely
      orthogonal to (rather than a revision of) RFC 822.

      This initial document specifies the various headers used to describe
      the structure of MIME messages. The second document, RFC 2046,
      defines the general structure of the MIME media typing system and
      defines an initial set of media types. The third document, RFC 2047,
      describes extensions to RFC 822 to allow non-US-ASCII text data in
    """

    let encoded: String val = Base64.encode_mime(text)


    let contentval: MIMEContent val = recover val
      let content: MIMEContent = MIMEContent(MIMEContentTypeText, MIMETransferTypeBase64)
      content.content_type.set_content_type("plain")
      content.raw_data = text
      content
    end

    var emailval: EMail val = recover val
      let email: EMail = EMail
      email.contents.push(contentval)
      email.to.push("test@example.com")
      email.subject = "Test email from pony"
      email
    end

    let smtpconfig: SMTPConfiguration val = recover SMTPConfiguration end
    let smtp: SMTPClient = SMTPClient(TCPConnectAuth(env.root), smtpconfig, emailval)
