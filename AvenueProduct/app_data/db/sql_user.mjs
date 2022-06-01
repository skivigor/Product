

//-----------------------------------------------------------------

export function addUser(name, surname, login, pass, departament, role)
{
    var req = "INSERT INTO toperator (fUserName, fUserSurname, fUserLogin, fUserPass, fRefDepartament, fRefRole) \
               VALUES (?, ?, ?, crypt(?, gen_salt('bf')), \
               (SELECT fid FROM tdepartament WHERE fDepartamentName = ?), \
               (SELECT fid FROM trole WHERE fRoleName = ?));"
    var args = [ name, surname, login, pass, departament, role ]
    var ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

export function checkUser(login, pass)
{
    var req = "SELECT (fUserPass = crypt(?, fUserPass)) AS pwd_match FROM toperator WHERE fuserlogin = ? ;"
    var args = [ pass, login ]
    var ret = db.sendQuery(req, args)
    if (ret["error"] === true) return ret

    if (ret["data"].length === 0)
    {
        ret["error"] = true
        ret["errorString"] = "User " + login + " error "
        return ret
    }

    var match = ret["data"][0]["pwd_match"]
    if (match === false)
    {
        ret["error"] = true
        ret["errorString"] = "User: " + login + " error "
        return ret
    }

    req = "SELECT fid, fUserName, fUserSurname FROM toperator WHERE fuserlogin = ? ;"
    args = [ login ]
    ret = db.sendQuery(req, args)
    return ret
}

//-----------------------------------------------------------------

