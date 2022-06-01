#ifndef STAND_H
#define STAND_H

#include <QObject>
#include "icmdowner.h"

#include "cmdqueue.h"
#include "fwmodel.h"
#include <vector>


namespace trans
{
class SerialClient;
}    // namespace trans

namespace stand
{

class Stand : public QObject, public ICmdOwner
{
    Q_OBJECT
    Q_PROPERTY(bool    inited READ isInited  NOTIFY initChanged)
    Q_PROPERTY(QString hwType READ getHwType NOTIFY hwTypeChanged)
    Q_PROPERTY(QString swType READ getSwType NOTIFY swTypeChanged)

private:
    bool      m_inited;
    QString   m_hwType;
    QString   m_swType;
    CmdQueue  m_queue;
    FwModel   m_model;

private:
    Stand(const Stand&);
    Stand& operator=(const Stand&);

public:
    explicit Stand(QObject *parent = nullptr);
    ~Stand();

signals:
    void initChanged();
    void hwTypeChanged();
    void swTypeChanged();
    void checked();
    void loaded();
    void error();

public slots:
    // ICmdOwner impl
    void onRcvData(const QByteArray &data);

    void setSerialLink(trans::SerialClient *ptr);
    void init();
    void selectFw(const QString &cfgPath, const QString &fwPath);
    bool addFirmwareToModel(const QJsonObject &cfg, const QString &fileName, const QString &md5AsBase64, const QString &fwAsBase64);
    bool addFirmwareToModel(const QJsonObject &cfg, const QString &path);
//    void clearModel();

    void checkFw();
    void loadFw();
    void resetCheckStatus();
    void resetLoadStatus();

    bool isInited() const      { return m_inited; }
    QString getHwType() const  { return m_hwType; }
    QString getSwType() const  { return m_swType; }

    QByteArray getData() const;
    std::vector<int> getDataVec() const;

    QObject* getFwModel()  { return &m_model; }
};


}   // namespace stand


#endif // STAND_H
