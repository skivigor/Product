

//-----------------------------------------------------------------

export function createEui(startEui, manufCode, productCode, num)
{
    var eui = startEui

    for (var i = 0; i < num; ++i)
    {
        var req = "SELECT * FROM teuires WHERE feui = ?;"
        var args = [eui]
        var ret = db.sendQuery(req, args)
        if (ret["error"] === true) return ret

        if (ret["data"].length === 0)
        {
            req = "INSERT INTO teuires (fmanufcode, fproductcode, feui) \
                   VALUES (?, ?, ?);"
            args = [ manufCode, productCode, eui ]
            ret = db.sendQuery(req, args)
            if (ret["error"] === true) return ret
        }
        eui++
    }
    return ret
}

//-----------------------------------------------------------------

export function createKt(kt, name, description)
{
    var req = "INSERT INTO tkt (fkt, fproductname, fproductdescription) \
               VALUES (?, ?, ?);"
    var args = [ kt, name, description ]
    var ret = db.sendQuery(req, args)
    if (ret["error"] === true) return ret
    req = "SELECT * FROM tkt WHERE fkt = ?;"
    args = [ kt ]
    ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function getKtInfo(kt)
{
    var req = "SELECT * FROM tkt WHERE tkt.fkt = ?;"
    var args = [ kt ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function getKtInfoRecursively(kt)
{
    var req = "WITH RECURSIVE temp1 AS ( \
               SELECT K.fid, K.fkt, K.fproductname, K.fproductdescription, KK.frefchildkt
               FROM tkt K
               JOIN tkt_tkt KK ON KK.frefkt = K.fid
               WHERE K.fkt = ?
               UNION ALL
               SELECT tkt.fid, tkt.fkt, tkt.fproductname, tkt.fproductdescription, tkt_tkt.frefchildkt
               FROM tkt
               LEFT JOIN tkt_tkt ON tkt_tkt.frefkt = tkt.fid
               JOIN temp1 ON tkt.fid = temp1.frefchildkt
               ) SELECT * FROM temp1;"
    var args = [ kt ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function getBoardInfoByDevId(devId)
{
    var v = "%" + devId
//    var req = "SELECT EUI.feui, DEV.fts, DEV.fdeviceid, DEV.flastoptionstate, DEV.flasterrorcode, DEV.flastcomment \
//               FROM teuires EUI \
//               JOIN tdevice DEV ON EUI.frefdevice = DEV.fid \
//               WHERE DEV.fdeviceid LIKE ?;"
    var req = "SELECT EUI.feui, DEV.fts, DEV.fdeviceid, DEV.flastoptionstate, DEV.flasterrorcode, DEV.flastcomment, ORD.forder1c, ORD.forderdescription \
               FROM teuires EUI \
               JOIN tdevice DEV ON EUI.frefdevice = DEV.fid \
               JOIN torder ORD ON ORD.fid = DEV.freforder \
               WHERE DEV.fdeviceid LIKE ?;"
    var args = [ v ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function getBoardInfoByEui(eui)
{
//    var req = "SELECT EUI.feui, DEV.fts, DEV.fdeviceid, DEV.flastoptionstate, DEV.flasterrorcode, DEV.flastcomment \
//               FROM teuires EUI \
//               JOIN tdevice DEV ON EUI.frefdevice = DEV.fid \
//               WHERE EUI.feui = ?;"
    var req = "SELECT EUI.feui, DEV.fts, DEV.fdeviceid, DEV.flastoptionstate, DEV.flasterrorcode, DEV.flastcomment, ORD.forder1c, ORD.forderdescription \
               FROM teuires EUI \
               JOIN tdevice DEV ON EUI.frefdevice = DEV.fid \
               JOIN torder ORD ON ORD.fid = DEV.freforder \
               WHERE EUI.feui = ?;"
    var args = [ eui ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function getSoftOptionsByScheme(scheme)
{
    var req = "SELECT OP.fid, OP.foptionname, OP.foptiondescription, OPG.fid AS grfid FROM toption OP \
               JOIN toptiongroup OPG ON OPG.fid = OP.frefoptiongroup \
               JOIN toptionschema SCH ON SCH.fid = OPG.frefoptionschema \
               WHERE SCH.foptionschemaname = ? AND OP.foptionhwdefined = FALSE AND OPG.foptiongroupname != 'LT' AND OPG.foptiongroupname != 'AS';"
    var args = [ scheme ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function createOrder(code1c, descr, num, kt, opts)
{
    // Check for existing
    var req = "SELECT * FROM torder WHERE forder1c = ?;"
    var args = [ code1c ]
    var ret = db.sendQuery(req, args)
    if (ret["error"] === true) return ret

    if (ret["data"].length !== 0)
    {
        // Order existed
        var orderFid = ret["data"][0]["fid"]

        // Check for existed devices in Order
        req = "SELECT * FROM tdevice WHERE freforder = ?;"
        args = [ orderFid ]
        ret = db.sendQuery(req, args)
        if (ret["error"] === true) return ret

        if (ret["data"].length !== 0)
        {
            // Order already contains devices. Cannot be changed
            ret["data"] = []
            ret["error"] = true
            ret["errorString"] = "Order already contains devices. Cannot be changed"
            return ret
        } else
        {
            // Order not contains devices. Can be changed
            // Delete existed Soft Options for Order
            req = "DELETE FROM torder_toption WHERE freforder = ?;"
            args = [ orderFid ]
            ret = db.sendQuery(req, args)
            if (ret["error"] === true) return ret

            // Delete Order
            req = "DELETE FROM torder WHERE fid = ?;"
            args = [ orderFid ]
            ret = db.sendQuery(req, args)
            if (ret["error"] === true) return ret
        }
    }

    // Add Order
    req = "INSERT INTO torder (forder1c, forderdescription, fordereditems, frefkt) \
               VALUES (?, ?, ?, (SELECT fid FROM tkt WHERE fkt = ?));"
    args = [ code1c, descr, num, kt ]
    ret = db.sendQuery(req, args)
    if (ret["error"] === true) return ret

    // Add Options of Order
    for (var i = 0; i < opts.length; ++i)
    {
        req = "INSERT INTO torder_toption (fRefOrder, fRefOption) \
               VALUES ((SELECT fid FROM torder WHERE fOrder1C = ?), ?);"
        args = [ code1c, opts[i] ]
        ret = db.sendQuery(req, args)
        if (ret["error"] === true) return ret
    }

    req = "SELECT * FROM torder WHERE forder1c = ?;"
    args = [ code1c ]
    ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function getOrderInfo(code1c)
{
    var req = "SELECT ORD.fts, ORD.forder1c, ORD.forderdescription, ORD.fordereditems, ORD.forderedinicount, \
               KT.fkt, KT.fproductname, KT.fproductdescription FROM torder ORD \
               JOIN tkt KT ON KT.fid = ORD.frefkt \
               WHERE ORD.forder1c = ?;"
    var args = [ code1c ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function getDeviceInfoByOrder(code1c)
{
    var req = "SELECT EUI.feui, DBA.fkeyname, DBA.fdata FROM tdevicebindattributes DBA \
               JOIN tdevice DEV ON DBA.frefdevice = DEV.fid \
               JOIN torder ORD ON DEV.freforder = ORD.fid \
               JOIN teuires EUI ON EUI.frefdevice = DEV.fid \
               WHERE ORD.forder1c = ?;"
    var args = [ code1c ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function getDeviceInfoByEui(startEui, endEui)
{
    var ret = {}
    if (startEui > endEui)
    {
        ret["error"] = true
        ret["errorString"] = "EndEUI must be greater than StartEUI";
        return ret
    }

    var req = "SELECT EUI.feui, DBA.fkeyname, DBA.fdata FROM tdevicebindattributes DBA \
               JOIN teuires EUI ON DBA.frefdevice = EUI.frefdevice \
               WHERE EUI.feui >= ? AND EUI.feui <= ?;"
    var args = [ startEui, endEui ]
    ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------



