//-----------------------------------------------------------------

function sendDbRequest(db, req)
{
    var ack = {}
    ack.error = true
    ack.errorString = "Database client: NOT connected"
    if (!db.isConnected()) return ack

    var resp
    var count = 0
    db.clearResponse()
    db.send(JSON.stringify(req))
    do
    {
        resp = db.getResponse()
        count++
        wait(100)
    } while (resp === "undefined" && count < 50)

    if (resp === "undefined")
    {
        ack.errorString = "Database client: Timeout error"
        return ack
    }

    return resp
}

//-----------------------------------------------------------------

function updateDeviceState(db, fid, refOption, state, errorCode, comment)
{
    var req = {}
    req.req = "updateDeviceState"
    req.args = [fid, refOption, state, errorCode, comment]
    var resp = JSON.parse(sendDbRequest(db, req))
    if (resp["error"] === true)
    {
        avlog.show("red", "Update Device State ... Error!!!", false, true)
        console.warn("Error: Update Device State " + resp["errorString"])
        return false
    }
    return true
}

//-----------------------------------------------------------------

function bindDeviceOption(db, refDev, refOpt)
{
    var req = {}
    req.req = "bindDeviceOption"
    req.args = [refDev, refOpt]
    var resp = JSON.parse(sendDbRequest(db, req))
    if (resp["error"] === true)
    {
        avlog.show("red", "Bind Device Option ... Error!!!", false, true)
        console.warn("Error: Bind Device Option " + resp["errorString"])
        return false
    }
    return true
}

//-----------------------------------------------------------------

function addBindAttributes(db, refDev, key, value)
{
    var req = {}
    req.req = "addBindAttributes"
    req.args = [ refDev, key, value ]
    var resp = JSON.parse(sendDbRequest(db, req))
    if (resp["error"] === true)
    {
        avlog.show("red", "Bind Device Attribute <" + key + "> ... Error!!!", false, true)
        console.warn("Error: Bind Device Attribute <" + key + "> : " + resp["errorString"])
        return false
    }
    return true
}

//-----------------------------------------------------------------

function addVendorAttributes(db, refDev, key, value)
{
    var req = {}
    req.req = "addVendorAttributes"
    req.args = [ refDev, key, value ]
    var resp = JSON.parse(sendDbRequest(db, req))
    if (resp["error"] === true)
    {
        avlog.show("red", "Bind Vendor Attribute <" + key + "> ... Error!!!", false, true)
        console.warn("Error: Bind Vendor Attribute <" + key + "> : " + resp["errorString"])
        return false
    }
    return true
}

//-----------------------------------------------------------------

