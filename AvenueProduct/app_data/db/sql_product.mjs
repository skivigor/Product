
export function getDevice(devId)
{
    var req = "SELECT DEV.*, ORD.forder1c, ORD.forderdescription FROM tdevice DEV \
               JOIN torder ORD ON ORD.fid = DEV.freforder \
               WHERE fdeviceid = ?;"
    var args = [ devId ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function createDevice(devId, refKt, refOrder, refOperator)
{
    var req = "INSERT INTO tdevice (fdeviceid, frefkt, freforder, frefoperator) \
               VALUES (?, ?, ?, ?);"
    var args = [ devId, refKt, refOrder, refOperator ]
    var ret = db.sendQuery(req, args)
    if (ret["error"] === true) return ret

    // Get fid of device
    req = "SELECT * FROM tdevice WHERE fdeviceid = ?;"
    args = [ devId ]
    ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function updateDeviceOrder(devFid, orderFid)
{
    var req = "UPDATE tdevice SET \
               freforder = ? \
               WHERE fid = ?;"
    var args = [ orderFid, devFid ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function updateDeviceState(fid, refOption, state, errorCode, comment)
{
    var req = "UPDATE tdevice SET \
               freflastoption = ?, \
               flastoptionstate = ?, \
               flasterrorcode = ?, \
               flastcomment = ? \
               WHERE fid = ?;"
    var args = [ refOption, state, errorCode, comment, fid ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function bindDeviceOption(refDev, refOption)
{
    var req = "INSERT INTO tdevice_toption (fRefDevice, fRefOption) \
               VALUES (?, ?);"
    var args = [ refDev, refOption ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function getEuiResource(eui)
{
    var req = "SELECT * FROM teuires WHERE feui = ?;"
    var args = [ eui ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function getFreeEuiResource()
{
    // TODO
}

//-----------------------------------------------------------------

export function bindEuiResource(devFid, eui)
{
    var req = "UPDATE teuires SET frefdevice = ? WHERE feui = ?;"
    var args = [ devFid, eui ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function getLampType(typeId)
{
    var req = "SELECT * FROM tlamptype WHERE ftypeid = ?;"
    var args = [ typeId ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function addBindAttributes(devFid, name, value)
{
    var req = "SELECT * FROM tdevicebindattributes WHERE frefdevice = ? AND fkeyname = ?;"
    var args = [ devFid, name ]
    var ret = db.sendQuery(req, args)
    if (ret["error"] === true) return ret

    if (ret["data"].length === 0)
    {
        req = "INSERT INTO tdevicebindattributes (fkeyname, fdata, frefdevice ) VALUES (?, ?, ?);"
        args = [ name, value, devFid ]
        ret = db.sendQuery(req, args)
    } else
    {
        req = "UPDATE tdevicebindattributes SET fdata = ? WHERE frefdevice = ? AND fkeyname = ?;"
        args = [ value, devFid, name ]
        ret = db.sendQuery(req, args)
    }

    return ret
}

//-----------------------------------------------------------------

export function addVendorAttributes(devFid, name, value)
{
    // TODO
}

//-----------------------------------------------------------------

export function getVendorAttributesByDevice(devFid)
{
    // TODO
}

//-----------------------------------------------------------------



