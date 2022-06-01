

//-----------------------------------------------------------------

export function addFirmware(swType, verName, verDescr, verPath, fwType, fwName, fwApi, fwMd5, fwFile, isProduct, isLast)
{
    //-----------------------------------------------------
    // Search project & swtype
    var req = "SELECT fid, frefproject FROM tswtype WHERE fswtypeid = ?;"
    var args = [ swType ]
//    console.log("Proj Request:" + req)
    var ret = db.sendQuery(req, args)
    if (ret["error"] === true) return ret

    if (ret["data"].length === 0)
    {
        ret["error"] = true
        ret["errorString"] = "Project: " + projId + " or SwType: " + swType + " NOT found"
        return ret
    }

    var projFid = ret["data"][0]["frefproject"]
    var swFid = ret["data"][0]["fid"]
//    console.log("ProjFid & SwFid: " + projFid + " " + swFid)

    //-----------------------------------------------------
    // Add version
    req = "SELECT fid FROM tversion WHERE fversion = ?;"
    args = [ verName ]
//    console.log("Ver Request:" + req)
    ret = db.sendQuery(req, args)
    if (ret["error"] === true) return ret

    var verFid
    if (ret["data"].length === 0)
    {
        // Add version
        req = "INSERT INTO tversion (fversion, fversiondescription, fversionpath, frefproject) \
               VALUES (?, ?, ?, ?);"
        args = [ verName, verDescr, verPath, projFid ]
//        console.log("Add version: " + req)
        ret = db.sendQuery(req, args)
        if (ret["error"] === true) return ret
        // Search version
        req = "SELECT fid FROM tversion WHERE fversion = ?;"
        args = [ verName ]
//        console.log("Ver Request:" + req)
        ret = db.sendQuery(req, args)
        if (ret["error"] === true) return ret
        verFid = ret["data"][0]["fid"]
    } else
    {
        // Version exist
//        console.log("Version exists: " + verName)
        verFid = ret["data"][0]["fid"]
    }

//    console.log("Version fid: " + verFid)

    //-----------------------------------------------------
    // Add firmware (check for existing)
    req = "SELECT fid FROM tfirmware WHERE frefversion = ? AND frefswtype= ? AND ffwmd5=decode(?, 'base64');"
    args = [ verFid, swFid, fwMd5 ]
//    console.log("Fw Request:" + req)
    ret = db.sendQuery(req, args)
    if (ret["error"] === true) return ret

    if (ret["data"].length === 0)
    {
        // Load firmware
        req = "INSERT INTO tfirmware (frefswtype, frefversion, ffwtype, ffwname, ffwapi, ffwmd5, ffwfile) \
               VALUES (?, ?, ?, ?, ?, decode(?, 'base64'), decode(?, 'base64'));"
        args = [ swFid, verFid, fwType, fwName, fwApi, fwMd5, fwFile ]
//        console.log("Add firmware req: " + req)
        ret = db.sendQuery(req, args)
        if (ret["error"] === true) return ret
    }

    //-----------------------------------------------------
    // Check production flag
    if (isProduct === true)
    {
        req = "UPDATE tproject SET frefproductionversion= ? WHERE fid = ?;"
        args = [ verFid, projFid ]
        ret = db.sendQuery(req, args)
        if (ret["error"] === true) return ret
    }

    // Check last flag
    if (isLast === true)
    {
        req = "UPDATE tproject SET freflastversion = ? WHERE fid = ?;"
        args = [ verFid, projFid ]
        ret = db.sendQuery(req, args)
        if (ret["error"] === true) return ret
    }

    return ret
}

//-----------------------------------------------------------------

export function getProductFirmware(swType)
{
    var req = "SELECT FW.ffwtype, FW.ffwname, encode(FW.ffwmd5::bytea, 'base64') AS ffwmd5, encode(FW.ffwfile::bytea, 'base64') AS ffwfile, VER.fversion, VER.fversionpath \
               FROM tfirmware FW \
               JOIN tswtype ON tswtype.fswtypeid = ? \
               JOIN tproject ON tproject.fid = tswtype.frefproject \
               JOIN tversion VER ON VER.fid = tproject.frefproductionversion \
               WHERE FW.frefversion = tproject.frefproductionversion AND FW.frefswtype = tswtype.fid;"
    var args = [ swType ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function getLastFirmware(swType)
{
    var req = "SELECT FW.ffwtype, FW.ffwname, encode(FW.ffwmd5::bytea, 'base64') AS ffwmd5, encode(FW.ffwfile::bytea, 'base64') AS ffwfile, VER.fversionpath \
               FROM tfirmware FW \
               JOIN tswtype ON tswtype.fswtypeid = ? \
               JOIN tproject ON tproject.fid = tswtype.frefproject \
               JOIN tversion VER ON VER.fid = tproject.freflastversion \
               WHERE FW.frefversion = tproject.freflastversion AND FW.frefswtype = tswtype.fid;"
    var args = [ swType ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function getFirmwareByVersion(fidVersion)
{
    var req = "SELECT FW.ffwtype, FW.ffwname, encode(FW.ffwmd5::bytea, 'base64') AS ffwmd5, encode(FW.ffwfile::bytea, 'base64') AS ffwfile, VER.fversion, VER.fversionpath \
               FROM tfirmware FW \
               JOIN tversion VER ON VER.fid = FW.frefversion \
               WHERE VER.fid = ?;"
    var args = [ fidVersion ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------



