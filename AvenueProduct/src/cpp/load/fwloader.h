#ifndef FWLOADER_H
#define FWLOADER_H

#include <QObject>
#include <QList>
#include <QSharedPointer>
#include <QQueue>

#include "firmware.h"
#include "fwcmd.h"
#include "trans/serialclient.h"

//namespace trans
//{
//class SerialClient;
//}

namespace load
{

class FwLoader : public QObject
{
    Q_OBJECT

private:
    trans::SerialClient  *m_pClient;
    QString               m_cfgPath;
    QString               m_fwPath;
    int                   m_allBlocksNum;
    QList< QSharedPointer<Firmware> >  m_listFirm;

    QQueue< QSharedPointer<StandCmd> >  m_queue;
    QSharedPointer<StandCmd>            m_cmd;

private:
    FwLoader(const FwLoader&);
    FwLoader& operator=(const FwLoader&);

private:
    void reload();

private slots:
    void onRcvData(QByteArray data);
    void processQueue();
    void onExecuted();
    void onExecError(StandCmd::ErrorType type);
    void onCmdSendData(const QByteArray &data);

public:
    explicit FwLoader(const QString &cfgPath, const QString &fwPath, QObject *parent = nullptr);
    ~FwLoader();

signals:

public slots:
    int getFwNum() const         { return m_listFirm.size(); }
    int getAllBlocksNum() const  { return m_allBlocksNum; }

    void setSerialClient(trans::SerialClient *ptr);
    bool check();
    void loadToStand();
    void upload();
};


}    // namespace load


#endif // FWLOADER_H
