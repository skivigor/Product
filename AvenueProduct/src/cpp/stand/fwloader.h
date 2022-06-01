#ifndef FWLOADER_H
#define FWLOADER_H

#include <QObject>
#include <QTimer>
#include "firmware.h"
#include "trans/serialclient.h"

class QJsonObject;

namespace stand
{

struct FirmwareCmdProfile
{
    quint8 CmdSetVer;
    quint8 CmdGetVer;
    quint8 CmdWriteBlock;
    quint8 CmdCheck;
    quint8 CmdLoad;
    quint8 CmdLoadState;
    int    Addr;
};

class FwLoaderState : public QObject
{
    Q_OBJECT

public:
    enum CheckState
    {
        CHK_IDLE,
        CHK_GET_INFO,
        CHK_SET_INFO,
        CHK_NOT_CHECKED,
        CHK_UPDATE,
        CHK_CHECKED
    };
    enum LoadState
    {
        LDR_IDLE,
        LDR_NOT_LOADED,
        LDR_LOADING,
        LDR_LOADED
    };
    Q_ENUMS(CheckState LoadState)
};

class FwLoader : public QObject
{
    Q_OBJECT

private:
    trans::SerialClient *m_pLink;
    QString              m_descr;
    FirmwareCmdProfile   m_profile;
    Firmware             m_firm;

    FwLoaderState::CheckState  m_checkState;
    FwLoaderState::LoadState   m_loadState;
    QString      m_checkStatus;
    QString      m_loadStatus;

    QByteArray   m_data;
    QTimer       m_timer;

private:
    FwLoader(const FwLoader&);
    FwLoader& operator=(const FwLoader&);

    void construct(const QJsonObject &cfg);

private slots:
    void onRcvData(const QByteArray &data);
    void onTimeout();

    // Check
    void goToCheckState(FwLoaderState::CheckState state);
    void chkGetInfo();
    void chkSetInfo();
    void chkCheck();
    void chkUpdate();

    // Load
    void goToLoadState(FwLoaderState::LoadState state);
    void ldrLoad();
    void ldrGetInfo();

    void errorHandler(const QString &status);

public:
    explicit FwLoader(const QJsonObject &cfg, const QString &fwPath, QObject *parent = nullptr);
    explicit FwLoader(const QJsonObject &cfg, const QString &fileName, const QByteArray &fw, QObject *parent = nullptr);
    ~FwLoader();

signals:
    void changed();
    void checked();
    void loaded();
    void error();

public slots:
    void setLink(trans::SerialClient *ptr);

    void check();
    void load();
    void reset();
    void resetCheckStatus();
    void resetLoadStatus();

    QString getDescription() const      { return m_descr; }
    QString getFwName() const           { return m_firm.getFileName(); }
    int getFwSize() const               { return m_firm.getFileSize(); }
    FwLoaderState::CheckState getCheckState() const  { return m_checkState; }
    FwLoaderState::LoadState getLoadState() const    { return m_loadState; }
    QString getCheckStatus() const      { return m_checkStatus; }
    QString getLoadStatus() const       { return m_loadStatus; }
};


}    // namespace stand


#endif // FWLOADER_H
