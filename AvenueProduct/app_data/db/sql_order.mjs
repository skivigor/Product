

//-----------------------------------------------------------------

export function getOrders(args)
{
    var ret = db.sendQuery("SELECT forder1c, forderdescription, fordereditems FROM tOrder WHERE forderedinicount < fordereditems;")
    return ret
}

//-----------------------------------------------------------------

export function getOrderByCode(code)
{
    var req = "SELECT * FROM torder WHERE forder1c = ?;"
    var args = [ code ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function updateOrderIniCount(code, count)
{
    var req = "UPDATE torder SET forderedinicount = ? WHERE forder1c = ?;"
    var args = [ count, code ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function incrementOrderIniCount(code)
{
    // TODO
}

//-----------------------------------------------------------------

export function decrementOrderIniCount(code)
{
    // TODO
}

//-----------------------------------------------------------------

export function getBoardKtByOrderCode(code)
{
    var req = "WITH RECURSIVE temp1 AS ( \
               SELECT K.fid, KK.frefchildkt \
               FROM tkt K \
               LEFT JOIN tkt_tkt KK ON KK.frefkt = K.fid \
               WHERE K.fid = (SELECT frefkt FROM torder WHERE forder1c = ?) \
               UNION ALL \
               SELECT tkt.fid, tkt_tkt.frefchildkt \
               FROM tkt \
               LEFT JOIN tkt_tkt ON tkt_tkt.frefkt = tkt.fid \
               JOIN temp1 ON tkt.fid = temp1.frefchildkt \
               ) SELECT * FROM temp1;"
    var args = [ code ]
    var ret = db.sendQuery(req, args)
    if (ret["error"] === true) return ret

    if (ret["data"].length === 0)
    {
        ret["error"] = true
        ret["errorString"] = "Can not find KT for order " + code
        return ret
    }

    var kt = ret["data"][ret["data"].length - 1]["fid"]
    ret["data"] = [kt]
    return ret
}

//-----------------------------------------------------------------

export function getHwTypeAttrByBoardKt(code)
{
    var req = "SELECT HW.fhwtypeid, B.fboardcurrentversion, B.fboardfolderpath FROM tkt \
               JOIN thwtype HW ON HW.fid = tkt.frefhwtype \
               JOIN tboard B ON B.fid = HW.frefboard \
               WHERE tkt.fid = ?;"
    var args = [ code ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function getOptionsForOrder(code)
{
    var req = "SELECT OP.fid, OP.foptionname AS name, OP.foptiondescription AS descr, OP.foptiondatafilename AS datafile, \
                      OP.foptioncontrolfilename AS controlfile, OP.foptionhwdefined AS hwdefined, \
                      OG.foptiongroupname AS group, OG.fprioritynumber AS priority \
                FROM toption OP \
                JOIN toptiongroup OG ON OG.fid = OP.frefoptiongroup \
                WHERE OP.fid = ANY ( \
                    SELECT OP.fid \
                        FROM torder_toption ORD_OPT \
                        JOIN torder ORD ON ORD.fid = ORD_OPT.freforder \
                        JOIN toption OP ON OP.fid = ORD_OPT.frefoption \
                        WHERE ORD.forder1c = ? \
                    UNION ALL \
                    SELECT tkt_toption.frefoption FROM tkt_toption WHERE frefkt = ANY( \
                        WITH RECURSIVE temp1 AS ( \
                            SELECT K.fid, K.fproductdescription, KK.frefchildkt \
                            FROM tkt K \
                            LEFT JOIN tkt_tkt KK ON KK.frefkt = K.fid \
                            WHERE K.fid = (SELECT frefkt FROM torder WHERE forder1c = ?) \
                            UNION ALL \
                            SELECT tkt.fid, tkt.fproductdescription, tkt_tkt.frefchildkt \
                            FROM tkt \
                            LEFT JOIN tkt_tkt ON tkt_tkt.frefkt = tkt.fid \
                            JOIN temp1 ON tkt.fid = temp1.frefchildkt \
                        ) SELECT fid FROM temp1 \
                    ) \
                ) ORDER BY OG.fprioritynumber;"
    var args = [ code, code ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------



