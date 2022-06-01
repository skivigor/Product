//-----------------------------------------------------------------

function sendStandRequest(stand, req)
{
//    _uart.getRespAsBin()   // flush
    var resp = []
    var count = 0
    _uart.sendData(req.buffer)
    do
    {
        resp = _uart.getRespAsBin()
//        if (resp.length !== 0) console.log("RESP: " + resp)
        count++
        wait(100)
    } while (resp.length === 0 && count < 40)

    return resp
}

//-----------------------------------------------------------------


