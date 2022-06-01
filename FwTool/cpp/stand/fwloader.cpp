#include "fwloader.h"
#include <QJsonObject>

#include <QDebug>
#include "assert.h"

namespace
{
const quint8 FuncCode =         0x78;
const quint8 LoadErrCode =      0x80;
const quint8 LoadCompleteCode = 0x01;

const int CheckTimeout =     1;
const int AlarmTimeout =     3000;
const int AlarmTimeoutLong = 45000;

bool CheckStarted = false;
bool LoadStarted =  false;
bool WaitAns =      false;
int Block = 0;
int Retry = 0;
const int MaxRetryNum = 3;

const QString DefCheckStatus("Not Checked");
const QString DefLoadStatus("Not Loaded");

//QByteArray reverse(QByteArray ba)
//{
//    QByteArray reverse;
//    reverse.reserve(ba.size());
//    for(int i = ba.size() - 1; i >= 0; --i) reverse.append(ba.at(i));
//    return reverse;
//}

}    // namespace

namespace stand
{

FwLoader::FwLoader(const QJsonObject &cfg, const QString &fwPath, QObject *parent)
    : m_pLink(nullptr),
      m_descr(cfg.value("descr").toString()),
      m_firm(fwPath + "/" + cfg.value("bin").toString(), 128),
      m_checkState(FwLoaderState::CHK_IDLE),
      m_loadState(FwLoaderState::LDR_IDLE),
      m_checkStatus(DefCheckStatus),
      m_loadStatus(DefLoadStatus)
{
    Q_UNUSED(parent)
    construct(cfg);
}

FwLoader::FwLoader(const QJsonObject &cfg, const QString &fileName, const QByteArray &fw, QObject *parent)
    : m_pLink(nullptr),
      m_descr(cfg.value("descr").toString()),
      m_firm(fileName, fw, 128),
      m_checkState(FwLoaderState::CHK_IDLE),
      m_loadState(FwLoaderState::LDR_IDLE),
      m_checkStatus(DefCheckStatus),
      m_loadStatus(DefLoadStatus)
{
    Q_UNUSED(parent)
    construct(cfg);
}

FwLoader::~FwLoader()
{
}

//-----------------------------------------------------------------

void FwLoader::construct(const QJsonObject &cfg)
{
    m_profile.CmdSetVer = static_cast<quint8>(cfg.value("cmdSetVer").toString().toInt(nullptr, 16));
    m_profile.CmdGetVer = static_cast<quint8>(cfg.value("cmdGetVer").toString().toInt(nullptr, 16));
    m_profile.CmdWriteBlock = static_cast<quint8>(cfg.value("cmdWrite").toString().toInt(nullptr, 16));
    m_profile.CmdCheck = static_cast<quint8>(cfg.value("cmdCheck").toString().toInt(nullptr, 16));
    m_profile.CmdLoad = static_cast<quint8>(cfg.value("cmdLoad").toString().toInt(nullptr, 16));
    m_profile.CmdLoadState = static_cast<quint8>(cfg.value("cmdLoadState").toString().toInt(nullptr, 16));
    m_profile.Addr = cfg.value("addr").toString().toInt(nullptr, 16);

    m_timer.setSingleShot(true);
    QObject::connect(&m_timer, SIGNAL(timeout()), SLOT(onTimeout()), Qt::QueuedConnection);
}

//-----------------------------------------------------------------

void FwLoader::onRcvData(const QByteArray &data)
{
    if (!CheckStarted && !LoadStarted) return;
    //m_data.append(data);
    m_data = data;
}

//-----------------------------------------------------------------

void FwLoader::onTimeout()
{
    qDebug() << "FwLoader::onTimeout: " << m_descr;

    if (m_checkState == FwLoaderState::CHK_UPDATE && Retry < MaxRetryNum)
    {
        Retry++;
        WaitAns = false;
        qDebug() << "FwLoader::onTimeout: retry: " << Retry;
        QTimer::singleShot(100, this, SLOT(chkUpdate()));
        return;
    }

//    if (m_loadState == FwLoaderState::LDR_LOADING && Retry < MaxRetryNum)
//    {
//        Retry++;
//        WaitAns = false;
//        qDebug() << "FwLoader::onTimeout: retry: " << Retry;
//        QTimer::singleShot(100, this, SLOT(ldrGetInfo()));
//        return;
//    }

    if (CheckStarted)
    {
        m_checkState = FwLoaderState::CHK_IDLE;
        m_checkStatus = "Check Error!!!";
    }

    if (LoadStarted)
    {
        m_loadState = FwLoaderState::LDR_IDLE;
        m_loadStatus = "Load Error!!!";
    }

    reset();
//    qDebug() << "FwLoader::onTimeout: emit error";
    emit error();
}

//-----------------------------------------------------------------

void FwLoader::goToCheckState(FwLoaderState::CheckState state)
{
    m_checkState = state;
    emit changed();

    if (state == FwLoaderState::CHK_GET_INFO)
    {
        CheckStarted = true;
        WaitAns = false;
        QTimer::singleShot(1, this, SLOT(chkGetInfo()));
        return;
    }

    if (state == FwLoaderState::CHK_SET_INFO)
    {
        WaitAns = false;
        QTimer::singleShot(1, this, SLOT(chkSetInfo()));
        return;
    }

    if (state == FwLoaderState::CHK_NOT_CHECKED)
    {
        WaitAns = false;
        QTimer::singleShot(1, this, SLOT(chkCheck()));
        return;
    }

    if (state == FwLoaderState::CHK_UPDATE)
    {
        WaitAns = false;
        QTimer::singleShot(1, this, SLOT(chkUpdate()));
        return;
    }

    if (state == FwLoaderState::CHK_CHECKED)
    {
        m_checkStatus = "Check ... OK";
        reset();
        emit checked();
        return;
    }
}

//-----------------------------------------------------------------

void FwLoader::chkGetInfo()
{
    if (!CheckStarted) return;
    QByteArray temp;

    if (WaitAns)
    {
        if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(chkGetInfo())); return; }
        m_timer.stop();
        qDebug() << "FwLoader::chkGetInfo: Ans: " << m_data.toHex();

        if (m_data.size() != 23)  { errorHandler("Check error"); return; }
        if (m_data.at(1) != FuncCode || m_data.at(2) != m_profile.CmdGetVer)  { errorHandler("Check error"); return; }
        QByteArray hash = m_data.mid(3, 16);
        temp = m_data.mid(19, 4);
        int size = 0;
        memcpy(&size, temp.data(), 4);

        if (hash == m_firm.getMd5Hash() && size == m_firm.getFileSize())
        {
            qDebug() << "FwLoader::chkGetInfo: Version matched!";
            goToCheckState(FwLoaderState::CHK_NOT_CHECKED);
            return;
        }

        goToCheckState(FwLoaderState::CHK_SET_INFO);
        return;
    }

    m_data.clear();
    QByteArray ba;
    ba.append(0x03);  // ie len
    ba.append(FuncCode);
    ba.append(static_cast<char>(m_profile.CmdGetVer));
    qDebug() << "FwLoader::chkGetInfo: Req: " << ba.toHex();
    m_pLink->sendData(ba);

    WaitAns = true;
    QTimer::singleShot(CheckTimeout, this, SLOT(chkGetInfo()));
    m_timer.start(AlarmTimeout);
}

//-----------------------------------------------------------------

void FwLoader::chkSetInfo()
{
    if (!CheckStarted) return;
    if (WaitAns)
    {
        if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(chkSetInfo())); return; }
        m_timer.stop();
        qDebug() << "FwLoader::chkSetInfo: Ans: " << m_data.toHex();

        if (m_data.size() != 3)  { errorHandler("Check error"); return; }
        if (m_data.at(1) != FuncCode || m_data.at(2) != m_profile.CmdSetVer)  { errorHandler("Check error"); return; }
        goToCheckState(FwLoaderState::CHK_UPDATE);
        return;
    }

    m_data.clear();
    QByteArray ba;
    ba.append(FuncCode);
    ba.append(static_cast<char>(m_profile.CmdSetVer));

    QByteArray hash = m_firm.getMd5Hash();
    ba.append(hash);

    int size = m_firm.getFileSize();
    ba.append((const char *)&size, 4);

    quint8 len = static_cast<quint8>(ba.size() + 1);
    ba.prepend(static_cast<char>(len));
    qDebug() << "FwLoader::chkSetInfo: Req: " << ba.toHex();
    m_pLink->sendData(ba);

    WaitAns = true;
    QTimer::singleShot(CheckTimeout, this, SLOT(chkSetInfo()));
    m_timer.start(AlarmTimeout);
}

//-----------------------------------------------------------------

void FwLoader::chkCheck()
{
    if (!CheckStarted) return;
    QByteArray temp;

    if (WaitAns)
    {
        if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(chkCheck())); return; }
        m_timer.stop();
        qDebug() << "FwLoader::chkCheck: Ans: " << m_data.toHex();

        if (m_data.size() != 23)  { errorHandler("Check error"); return; }
        if (m_data.at(1) != FuncCode || m_data.at(2) != m_profile.CmdCheck)  { errorHandler("Check error"); return; }
        QByteArray hash = m_data.mid(3, 16);
        temp = m_data.mid(19, 4);
        int size = 0;
        memcpy(&size, temp.data(), 4);

        if (hash == m_firm.getMd5Hash() && size == m_firm.getFileSize())
        {
            qDebug() << "FwLoader::chkCheck: Version matched!";
            goToCheckState(FwLoaderState::CHK_CHECKED);
            return;
        }

        goToCheckState(FwLoaderState::CHK_SET_INFO);
        return;
    }

    m_data.clear();
    QByteArray ba;
    ba.append(0x03);
    ba.append(FuncCode);
    ba.append(static_cast<char>(m_profile.CmdCheck));
    qDebug() << "FwLoader::chkCheck: Req: " << ba.toHex();
    m_pLink->sendData(ba);
    m_checkStatus = "Checking ...";
    emit changed();

    WaitAns = true;
    QTimer::singleShot(CheckTimeout, this, SLOT(chkCheck()));
    m_timer.start(AlarmTimeoutLong);
}

//-----------------------------------------------------------------

void FwLoader::chkUpdate()
{
    if (!CheckStarted) return;
    QByteArray temp;
    if (Block == 0) { m_checkStatus = "Update stand ... 0 %"; emit changed(); }
    int blocksNum = m_firm.getBlocksNum();

    if (WaitAns)
    {
        if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(chkUpdate())); return; }
        m_timer.stop();
//        qDebug() << "FwLoader::chkUpdate: Ans: " << m_data.toHex();

        if (m_data.size() != 6 || m_data.at(1) != FuncCode || m_data.at(2) != m_profile.CmdWriteBlock)  { errorHandler("Check error"); return; }
        QByteArray baBlock = m_data.mid(3, 2);
        quint16 blkNum = 0;
        memcpy(&blkNum, baBlock.data(), 2);
        if (blkNum != Block || m_data.at(5) != 0x01) { errorHandler("Check error"); return; }

        Block++;
        if (Block >= blocksNum)
        {
            goToCheckState(FwLoaderState::CHK_NOT_CHECKED);
            return;
        }

        WaitAns = false;
        QTimer::singleShot(1, this, SLOT(chkUpdate()));
        return;
    }

    m_data.clear();
    if (Block % 20 == 0)
    {
        int percent = Block * 100 / blocksNum;
        m_checkStatus = QString("Update ... %1 %").arg(QString::number(percent));
        emit changed();
    }

    FirmwareBlock blk = m_firm.getBlock(Block);

    QByteArray ba;
    ba.append(FuncCode);
    ba.append(static_cast<char>(m_profile.CmdWriteBlock));
    ba.append((const char *)&Block, 2);
    ba.append((const char *)&blk.Crc, 2);
    ba.append(blk.Data);
    quint8 len = static_cast<quint8>(ba.size() + 1);
    ba.prepend(static_cast<char>(len));
//    qDebug() << "FwLoader::chkUpdate: Req: " << ba.toHex();
    m_pLink->sendData(ba);

    WaitAns = true;
    QTimer::singleShot(CheckTimeout, this, SLOT(chkUpdate()));
    m_timer.start(AlarmTimeout);
}

//-----------------------------------------------------------------

void FwLoader::goToLoadState(FwLoaderState::LoadState state)
{
    m_loadState = state;
    emit changed();

    if (state == FwLoaderState::LDR_NOT_LOADED)
    {
        LoadStarted = true;
        WaitAns = false;
        QTimer::singleShot(1, this, SLOT(ldrLoad()));
        return;
    }

    if (state == FwLoaderState::LDR_LOADING)
    {
        qDebug() << "FwLoader::goToLoadState: LDR_LOADING";
        WaitAns = true;
        m_data.clear();
        QTimer::singleShot(1, this, SLOT(ldrGetInfo()));
        return;
    }

    if (state == FwLoaderState::LDR_LOADED)
    {
        m_loadStatus = "Load ... OK";
        reset();
        emit loaded();
        return;
    }

}

//-----------------------------------------------------------------

void FwLoader::ldrLoad()
{
    if (!LoadStarted) return;
    if (WaitAns)
    {
        if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(ldrLoad())); return; }
        m_timer.stop();
        qDebug() << "FwLoader::ldrLoad: Ans: " << m_data.toHex();

        if (m_data.size() != 4)  { errorHandler("Load error"); return; }
        if (m_data.at(1) != FuncCode || m_data.at(2) != m_profile.CmdLoad || m_data.at(3) != 1)  { errorHandler("Load error"); return; }
        goToLoadState(FwLoaderState::LDR_LOADING);
        return;
    }

    m_data.clear();
    QByteArray ba;
    ba.append(0x07);   // ie len
    ba.append(FuncCode);
    ba.append(static_cast<char>(m_profile.CmdLoad));
    ba.append((const char *)&m_profile.Addr, 4);
    qDebug() << "FwLoader::ldrLoad: Req: " << ba.toHex();
    m_pLink->sendData(ba);

    WaitAns = true;
    QTimer::singleShot(CheckTimeout, this, SLOT(ldrLoad()));
    m_timer.start(AlarmTimeoutLong);
}

//-----------------------------------------------------------------

void FwLoader::ldrGetInfo()
{
    if (!LoadStarted) return;
    if (!m_timer.isActive() && WaitAns) m_timer.start(45000);

    if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(ldrGetInfo())); return; }
    m_timer.stop();

    if (m_data.size() != 8 || m_data.at(1) != FuncCode)  { errorHandler("Load error"); return; }
    quint8 status = m_data.at(7);
    if (status == LoadErrCode) { errorHandler("Load error"); return; }

    QByteArray baSize = m_data.mid(3, 4);
    m_data.clear();
    int size = 0;
    memcpy(&size, baSize.data(), 4);
    int percent = size * 100 / m_firm.getFileSize();
    m_loadStatus = QString("Load ... %1 %").arg(QString::number(percent));
    emit changed();

    if (status == LoadCompleteCode)
    {
        if (size < m_firm.getFileSize())
        {
            qDebug() << "FwLoader::ldrGetInfo: " << size << " : " << m_firm.getFileSize();
            m_loadState = FwLoaderState::LDR_IDLE;
            m_loadStatus = "Load Error!!!";
            reset();
            emit error();
            return;
        }
        m_loadStatus = QString("Load ... 100 %");
        emit changed();
        goToLoadState(FwLoaderState::LDR_LOADED);
        return;
    }

    WaitAns = false;
    QTimer::singleShot(500, this, SLOT(ldrGetInfo()));
    m_timer.start(30000);

//    if (WaitAns)
//    {
//        if (m_data.isEmpty()) { QTimer::singleShot(CheckTimeout, this, SLOT(ldrGetInfo())); return; }
//        m_timer.stop();

//        if (m_data.size() != 8 || m_data.at(1) != FuncCode)  { errorHandler("Load error"); return; }
//        quint8 status = m_data.at(7);
//        if (status == LoadErrCode) { errorHandler("Load error"); return; }

//        QByteArray baSize = m_data.mid(3, 4);
//        int size = 0;
//        memcpy(&size, baSize.data(), 4);
//        int percent = size * 100 / m_firm.getFileSize();
//        m_loadStatus = QString("Load ... %1 %").arg(QString::number(percent));
//        emit changed();

//        if (status == LoadCompleteCode)
//        {
//            m_loadStatus = QString("Load ... 100 %");
//            emit changed();
//            goToLoadState(FwLoaderState::LDR_LOADED);
//            return;
//        }

//        WaitAns = false;
//        QTimer::singleShot(500, this, SLOT(ldrGetInfo()));
//        return;
//    }

//    m_data.clear();
//    QByteArray ba;
//    ba.append(0x03);   // ie len
//    ba.append(FuncCode);
//    ba.append(static_cast<char>(m_profile.CmdLoadState));
//    m_pLink->sendData(ba);
//    qDebug() << "FwLoader::ldrGetInfo: Req: " << ba.toHex();

//    WaitAns = true;
//    QTimer::singleShot(CheckTimeout, this, SLOT(ldrGetInfo()));
//    m_timer.start(5000);
}

//-----------------------------------------------------------------

void FwLoader::errorHandler(const QString &status)
{
    qDebug() << "FwLoader::errorHandler: " << status;

    if (CheckStarted)
    {
        m_checkState = FwLoaderState::CHK_IDLE;
        m_checkStatus = status;
    }

    if (LoadStarted)
    {
        m_loadState = FwLoaderState::LDR_IDLE;
        m_loadStatus = status;
    }

    reset();
    emit error();
}

//-----------------------------------------------------------------

void FwLoader::setLink(trans::SerialClient *ptr)
{
    if (m_pLink == ptr) return;
    if (m_pLink) m_pLink->disconnect(this);
    m_pLink = ptr;
}

//-----------------------------------------------------------------

void FwLoader::check()
{
    if (m_pLink == nullptr || !m_pLink->isConnected()) { emit error(); return; }
    if (CheckStarted || LoadStarted) return;

    QObject::connect(m_pLink, SIGNAL(rcvData(QByteArray)), SLOT(onRcvData(QByteArray)));
    goToCheckState(FwLoaderState::CHK_GET_INFO);
}

//-----------------------------------------------------------------

void FwLoader::load()
{
    if (m_pLink == nullptr || !m_pLink->isConnected()) { emit error(); return; }
    if (CheckStarted || LoadStarted) return;

    QObject::connect(m_pLink, SIGNAL(rcvData(QByteArray)), SLOT(onRcvData(QByteArray)));
    goToLoadState(FwLoaderState::LDR_NOT_LOADED);
}

//-----------------------------------------------------------------

void FwLoader::reset()
{
    m_timer.stop();
    m_data.clear();
    if (m_pLink) m_pLink->disconnect(this);
    CheckStarted = false;
    LoadStarted = false;
    WaitAns = false;
    Block = 0;
    Retry = 0;
    emit changed();
}

//-----------------------------------------------------------------

void FwLoader::resetCheckStatus()
{
    qDebug() << "FwLoader::resetCheckStatus";
    m_checkState = FwLoaderState::CHK_IDLE;
    m_checkStatus = DefCheckStatus;
    emit changed();
}

//-----------------------------------------------------------------

void FwLoader::resetLoadStatus()
{
    qDebug() << "FwLoader::resetLoadStatus";
    m_loadState = FwLoaderState::LDR_IDLE;
    m_loadStatus = DefLoadStatus;
    emit changed();
}

//-----------------------------------------------------------------

}    // namespace stand

