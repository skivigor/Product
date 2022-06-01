#include "sqldatabase.h"
#include "util/fileloader.h"
#include <QJsonObject>

#include <QDebug>
#include "assert.h"

namespace db
{

SqlDatabase::SqlDatabase(const QJsonObject &cfg, const QString &connectionName, QObject *parent)
    : m_db(QSqlDatabase::addDatabase("QPSQL", connectionName)),
      m_cfg(cfg),
      m_inited(false)
{
    Q_UNUSED(parent)
    setConfig();
}

SqlDatabase::SqlDatabase(const QString &cfgPath, const QString &connectionName, QObject *parent)
    : m_db(QSqlDatabase::addDatabase("QPSQL", connectionName)),
      m_inited(false)
{
    Q_UNUSED(parent)

    QJsonDocument doc = util::FileLoader::instance().getFileAsJsonDoc(cfgPath);
    if (doc.isEmpty())
    {
        qWarning() << "SqlDatabase::SqlDatabase: config json empty: " << cfgPath;
        return;
    }

    QJsonObject jObj = doc.object();
    assert(jObj["db"].isObject());
    m_cfg = jObj["db"].toObject();
    setConfig();
}

SqlDatabase::~SqlDatabase()
{
}

//----------------------------------------------------------------------------

void SqlDatabase::setConfig()
{
    if (m_cfg.isEmpty())
    {
        qWarning() << "SqlDatabase::SqlDatabase: Config empty";
    } else
    {
        m_db.close();
        QString host = m_cfg.value("dbHost").toString();
        int port = m_cfg.value("dbPort").toInt();
        QString name = m_cfg.value("dbName").toString();
        QString user = m_cfg.value("dbUser").toString();
        QString pass = m_cfg.value("dbPass").toString();
        m_db.setHostName(host);
        m_db.setPort(port);
        m_db.setDatabaseName(name);
        m_db.setUserName(user);
        m_db.setPassword(pass);

        qDebug() << "SqlDatabase::setConfig: complete";
    }
    QObject::connect(&m_timer, &QTimer::timeout, this, &SqlDatabase::checkConnection, Qt::QueuedConnection);
}

//----------------------------------------------------------------------------

void SqlDatabase::checkConnection()
{
    // TODO
}

//----------------------------------------------------------------------------

bool SqlDatabase::init()
{
    if (m_cfg.isEmpty()) return false;

    m_db.close();
    m_inited = m_db.open();
    emit initChanged();
    if (m_inited) qDebug() << "SqlDatabase::init: database connection available";
    if (!m_timer.isActive()) m_timer.start(15000);
    return m_inited;
}

//----------------------------------------------------------------------------

void SqlDatabase::deInit()
{
    m_timer.stop();
    m_db.close();
    m_inited = false;
    emit initChanged();
}

//----------------------------------------------------------------------------

QVariantMap SqlDatabase::parseQuery(QSqlQuery &query) const
{
    QJsonObject resp;
    QJsonArray arr;

    QSqlError err = query.lastError();
    if (err.isValid())
    {
        resp.insert("error", true);
        resp.insert("errorString", err.databaseText());
        return resp.toVariantMap();
    }
    // TODO


    resp.insert("error", false);
    resp.insert("data", arr);
    return resp.toVariantMap();
}

//----------------------------------------------------------------------------

QVariantMap SqlDatabase::sendQuery(const QString &req)
{
    if (req.isEmpty() || !m_db.isOpen()) return QVariantMap();
    qDebug() << "SqlDatabase::sendQuery: " << req;

    QSqlQuery query(m_db);
    // TODO

    return parseQuery(query);
}

//----------------------------------------------------------------------------

QVariantMap SqlDatabase::sendQuery(const QString &req, const QVariantList &args)
{
    if (req.isEmpty() || !m_db.isOpen()) return QVariantMap();
    qDebug() << "SqlDatabase::sendQuery2: " << req << " : " << args;

    QSqlQuery query(m_db);
    // TODO

    return parseQuery(query);
}

//----------------------------------------------------------------------------

}    // namespace db

