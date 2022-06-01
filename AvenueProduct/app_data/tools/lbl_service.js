//-----------------------------------------------------------------

function sendLblRequest(req)
{
    var ack = {}
    ack.error = true
    ack.errorString = "Label client: NOT connected"
    if (!label.isConnected()) return ack

    var resp
    var count = 0
    label.clearResponse()
    label.send(JSON.stringify(req))
    do
    {
        resp = label.getResponse()
        count++
        wait(100)
    } while (resp === "undefined" && count < 30)

    if (resp === "undefined")
    {
        ack.errorString = "Label client: Timeout error"
        return ack
    }

    return resp
}

//-----------------------------------------------------------------

