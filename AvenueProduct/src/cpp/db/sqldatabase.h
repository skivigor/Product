#ifndef SQLDATABASE_H
#define SQLDATABASE_H

#include <QObject>
#include <QtSql>
#include <QVariant>
#include <QTimer>

class QJsonObject;

namespace db
{

class SqlDatabase : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool inited READ isInited NOTIFY initChanged)

private:
    QSqlDatabase m_db;
    QJsonObject  m_cfg;
    bool         m_inited;
    QTimer       m_timer;

private:
    SqlDatabase(const SqlDatabase&);
    SqlDatabase& operator=(const SqlDatabase&);

    void setConfig();
    QVariantMap parseQuery(QSqlQuery &query) const;

private slots:
    void checkConnection();

public:
    explicit SqlDatabase(const QJsonObject &cfg, const QString &connectionName, QObject *parent = nullptr);
    explicit SqlDatabase(const QString &cfgPath, const QString &connectionName, QObject *parent = nullptr);
    ~SqlDatabase();

signals:
    void initChanged();

public slots:
    bool init();
    void deInit();
    bool isInited() const   { return m_inited; }
    QVariantMap sendQuery(const QString &req);

    QVariantMap sendQuery(const QString &req, const QVariantList &args);

};


}    // namespace db


#endif // SQLDATABASE_H
